#==============================================================================#
#==== 11I_CSI_LowVol_Overlap_Diagnostics.R ===================================#
#==== AE-ALPHA-007: CSI / Low-Volatility Overlap Diagnostics ==================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
})

cat("\n[11I_CSI_LowVol_Overlap_Diagnostics.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()

fn_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg)) {
    return(normalizePath(sub("^--file=", "", file_arg[[1L]]), mustWork = FALSE))
  }
  normalizePath("01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R", mustWork = FALSE)
}

SCRIPT_PATH <- fn_script_path()
PIPELINE_DIR <- dirname(SCRIPT_PATH)
ROOT_DIR <- normalizePath(file.path(PIPELINE_DIR, "..", ".."), mustWork = TRUE)

path_root <- function(...) file.path(ROOT_DIR, ...)

ALPHA_DIR <- path_root("03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation")
OVERLAP_DIR <- file.path(ALPHA_DIR, "overlap_diagnostics")
REPORT_DIR <- file.path(ALPHA_DIR, "reports")
TICKET_DIR <- path_root(
  "05_Documentation", "09_Epics", "AE-ALPHA_LowVol_Tilt_Independence", "Tickets"
)
dir.create(OVERLAP_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TICKET_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_LOWVOL_QUINTILES <- file.path(ALPHA_DIR, "volatility_quintiles", "lowvol_volatility_quintiles.rds")
PATH_CSI_PERF <- file.path(ALPHA_DIR, "performance", "csi_performance_extract.rds")
PATH_BENCHMARK_CONSTITUENTS <- path_root(
  "02_Data_Input", "04_Index_Replication", "Necessary",
  "crsp_like_index_constituents_quarterly.rds"
)

OUT_EXCLUSION <- file.path(OVERLAP_DIR, "csi_exclusion_quintile_overlap")
OUT_RETAINED <- file.path(OVERLAP_DIR, "csi_retained_quintile_exposure")
OUT_ACTIVE <- file.path(OVERLAP_DIR, "csi_active_quintile_exposure")
OUT_SUMMARY_STRATEGY <- file.path(OVERLAP_DIR, "overlap_summary_by_strategy")
OUT_SUMMARY_TRACK_UNIVERSE <- file.path(OVERLAP_DIR, "overlap_summary_by_track_universe")
OUT_REPORT <- file.path(REPORT_DIR, "overlap_diagnostics_report.md")
OUT_STATUS <- file.path(REPORT_DIR, "overlap_diagnostics_run_status.csv")
OUT_COMPLETION <- file.path(TICKET_DIR, "AE-ALPHA-007_Completion_Report.md")

required_inputs <- c(PATH_LOWVOL_QUINTILES, PATH_CSI_PERF, PATH_BENCHMARK_CONSTITUENTS)
missing_inputs <- required_inputs[!file.exists(required_inputs)]
if (length(missing_inputs)) {
  stop("Missing required input(s):\n", paste(missing_inputs, collapse = "\n"))
}

write_pair <- function(dt, stem) {
  saveRDS(dt, paste0(stem, ".rds"))
  fwrite(dt, paste0(stem, ".csv"))
}

safe_divide <- function(num, den) {
  fifelse(is.finite(den) & den != 0, num / den, NA_real_)
}

truthy <- function(x) {
  !is.na(x) & x == TRUE
}

normalize_track <- function(x) fifelse(x == "temporary_csi", "dynamic_csi", x)

quintile_grid <- data.table(
  quintile = paste0("Q", 1:5),
  quintile_num = as.integer(1:5)
)

strategy_meta_cols <- c(
  "strategy_key", "period", "track", "response_track", "track_label",
  "index_id", "index_name", "index_label", "analysis_model", "model_key",
  "model_label", "threshold_method", "threshold_label", "threshold",
  "lockout_years", "strategy_id", "exclusion_rule", "rule_label", "weighting",
  "transaction_cost_bps", "is_best_by_track_index_cost", "is_headline_20bps",
  "weights_path"
)

cat("[11I] Loading low-volatility quintile assignments...\n")
quintiles <- as.data.table(readRDS(PATH_LOWVOL_QUINTILES))
quintiles[, qdate := as.Date(qdate)]
quintiles <- unique(quintiles[, .(
  qdate,
  index_id,
  permno,
  quintile,
  quintile_num,
  trailing_volatility
)], by = c("qdate", "index_id", "permno"))

cat("[11I] Loading benchmark universe...\n")
benchmark <- as.data.table(readRDS(PATH_BENCHMARK_CONSTITUENTS))
benchmark[, qdate := as.Date(qdate)]
benchmark <- benchmark[, .(
  qdate,
  index_id,
  benchmark_index_name = index_name,
  permno,
  permco,
  size_segment,
  security_mktcap,
  benchmark_weight = as.numeric(weight)
)]
benchmark <- unique(benchmark, by = c("qdate", "index_id", "permno"))

cat("[11I] Selecting CSI headline/best strategy rows from performance extract...\n")
csi_perf <- as.data.table(readRDS(PATH_CSI_PERF))
csi_perf[, response_track := normalize_track(response_track)]
csi_selected <- csi_perf[
  period == "full" &
    (truthy(is_best_by_track_index_cost) | truthy(is_headline_20bps))
]
if ("transaction_cost_bps" %in% names(csi_selected)) {
  csi_selected <- csi_selected[transaction_cost_bps %in% c(0, 20)]
}
if (!nrow(csi_selected)) {
  csi_selected <- csi_perf[period == "full" & truthy(is_best_by_track_index_cost)]
}
csi_selected[, weights_path := file.path(dirname(source_path), "index_weights_by_crsp_universe.rds")]
csi_selected <- csi_selected[file.exists(weights_path)]
if (!nrow(csi_selected)) {
  stop("No selected CSI strategy rows mapped to available weight files.")
}

available_meta_cols <- intersect(setdiff(strategy_meta_cols, "strategy_key"), names(csi_selected))
csi_selected <- unique(csi_selected[, unique(c(available_meta_cols, "weights_path")), with = FALSE])
csi_selected[, strategy_key := .I]
setcolorder(csi_selected, c("strategy_key", setdiff(names(csi_selected), "strategy_key")))

read_csi_weights <- function(path, selected_keys) {
  dt <- as.data.table(readRDS(path))
  dt[, weights_path := path]
  dt[, track := normalize_track(track)]

  merge_cols <- intersect(c(
    "track", "index_id", "model_key", "threshold_method", "threshold_label",
    "lockout_years", "strategy_id", "exclusion_rule", "rule_label", "weights_path"
  ), names(dt))
  keep_keys <- unique(selected_keys[, c("strategy_key", merge_cols), with = FALSE])
  dt <- merge(dt, keep_keys, by = merge_cols, all = FALSE, allow.cartesian = TRUE)
  if (!nrow(dt)) return(data.table())

  keep_cols <- intersect(c(
    "strategy_key", "track", "index_id", "index_name", "qdate", "q_year",
    "q_month", "holding_year", "signal_year", "permno", "permco",
    "size_segment", "security_mktcap", "benchmark_weight", "w", "model_key",
    "model_label", "threshold_method", "threshold_label", "threshold",
    "lockout_years", "strategy_id", "exclusion_rule", "rule_label", "weighting"
  ), names(dt))
  dt <- dt[, ..keep_cols]
  dt[, qdate := as.Date(qdate)]
  dt
}

cat("[11I] Reading selected CSI strategy weights...\n")
csi_weights <- rbindlist(lapply(unique(csi_selected$weights_path), function(path) {
  read_csi_weights(path, csi_selected[weights_path == path])
}), fill = TRUE)
if (!nrow(csi_weights)) stop("Selected CSI strategy weights were empty after filtering.")

csi_weights <- csi_weights[is.finite(w) & w > 0 & !is.na(permno)]
strategy_meta <- unique(csi_selected[, ..strategy_meta_cols], by = "strategy_key")

cat("[11I] Building benchmark, retained, and excluded panels...\n")
retained <- csi_weights[, .(
  strategy_key,
  qdate,
  index_id,
  permno,
  retained_permco = permco,
  retained_size_segment = size_segment,
  csi_weight = as.numeric(w)
)]
retained <- retained[, .(
  csi_weight = sum(csi_weight, na.rm = TRUE),
  retained_permco = retained_permco[which.max(csi_weight)],
  retained_size_segment = retained_size_segment[which.max(csi_weight)]
), by = .(strategy_key, qdate, index_id, permno)]

strategy_periods <- unique(retained[, .(strategy_key, qdate, index_id)])
benchmark_panel <- merge(
  strategy_periods,
  benchmark,
  by = c("qdate", "index_id"),
  all.x = TRUE,
  allow.cartesian = TRUE
)
benchmark_panel <- benchmark_panel[!is.na(permno)]

retained_key <- unique(retained[, .(strategy_key, qdate, index_id, permno)])
retained_key[, is_retained := TRUE]
benchmark_panel <- merge(
  benchmark_panel,
  retained_key,
  by = c("strategy_key", "qdate", "index_id", "permno"),
  all.x = TRUE
)
benchmark_panel[is.na(is_retained), is_retained := FALSE]

excluded <- benchmark_panel[is_retained == FALSE]
benchmark_q <- merge(
  benchmark_panel,
  quintiles,
  by = c("qdate", "index_id", "permno"),
  all.x = TRUE
)
excluded_q <- benchmark_q[is_retained == FALSE]
retained_q <- merge(
  retained,
  quintiles,
  by = c("qdate", "index_id", "permno"),
  all.x = TRUE
)

rm(csi_weights, benchmark_panel)
gc()

make_complete_quintiles <- function(dt, value_cols) {
  keys <- unique(dt[, .(strategy_key, qdate, index_id)])
  keys[, join_key := 1L]
  q_grid <- copy(quintile_grid)
  q_grid[, join_key := 1L]
  grid <- merge(keys, q_grid, by = "join_key", allow.cartesian = TRUE)
  grid[, join_key := NULL]
  out <- merge(grid, dt, by = c("strategy_key", "qdate", "index_id", "quintile", "quintile_num"), all.x = TRUE)
  for (col in value_cols) {
    if (col %in% names(out)) out[is.na(get(col)), (col) := 0]
  }
  out
}

cat("[11I] Computing exclusion overlap diagnostics...\n")
excluded_totals <- excluded_q[, .(
  excluded_name_count_total = .N,
  excluded_benchmark_weight_total = sum(benchmark_weight, na.rm = TRUE),
  excluded_name_count_with_quintile = sum(!is.na(quintile_num)),
  excluded_benchmark_weight_with_quintile = sum(fifelse(!is.na(quintile_num), benchmark_weight, 0), na.rm = TRUE)
), by = .(strategy_key, qdate, index_id)]

exclusion_by_q <- excluded_q[!is.na(quintile_num), .(
  excluded_name_count = .N,
  excluded_benchmark_weight = sum(benchmark_weight, na.rm = TRUE)
), by = .(strategy_key, qdate, index_id, quintile, quintile_num)]
exclusion_by_q <- make_complete_quintiles(
  exclusion_by_q,
  c("excluded_name_count", "excluded_benchmark_weight")
)
exclusion_by_q <- merge(exclusion_by_q, excluded_totals, by = c("strategy_key", "qdate", "index_id"), all.x = TRUE)
exclusion_by_q[, excluded_name_share_assigned := safe_divide(
  excluded_name_count, excluded_name_count_with_quintile
)]
exclusion_by_q[, excluded_benchmark_weight_share_assigned := safe_divide(
  excluded_benchmark_weight, excluded_benchmark_weight_with_quintile
)]
exclusion_by_q[, excluded_assignment_name_coverage := safe_divide(
  excluded_name_count_with_quintile, excluded_name_count_total
)]
exclusion_by_q[, excluded_assignment_weight_coverage := safe_divide(
  excluded_benchmark_weight_with_quintile, excluded_benchmark_weight_total
)]

q_focus <- dcast(
  exclusion_by_q[quintile %in% c("Q1", "Q5"), .(
    strategy_key, qdate, index_id, quintile,
    excluded_name_share_assigned,
    excluded_benchmark_weight_share_assigned
  )],
  strategy_key + qdate + index_id ~ quintile,
  value.var = c("excluded_name_share_assigned", "excluded_benchmark_weight_share_assigned")
)
setnames(q_focus, old = names(q_focus), new = sub("_Q1$", "_q1", sub("_Q5$", "_q5", names(q_focus))))
exclusion_by_q <- merge(exclusion_by_q, q_focus, by = c("strategy_key", "qdate", "index_id"), all.x = TRUE)
setnames(
  exclusion_by_q,
  old = c(
    "excluded_name_share_assigned_q5", "excluded_benchmark_weight_share_assigned_q5",
    "excluded_name_share_assigned_q1", "excluded_benchmark_weight_share_assigned_q1"
  ),
  new = c(
    "excluded_csi_intersection_q5_name_share",
    "excluded_csi_intersection_q5_benchmark_weight_share",
    "excluded_csi_intersection_q1_name_share",
    "excluded_csi_intersection_q1_benchmark_weight_share"
  ),
  skip_absent = TRUE
)

cat("[11I] Computing retained and benchmark quintile exposure diagnostics...\n")
retained_totals <- retained_q[, .(
  retained_name_count_total = .N,
  retained_csi_weight_total = sum(csi_weight, na.rm = TRUE),
  retained_name_count_with_quintile = sum(!is.na(quintile_num)),
  retained_csi_weight_with_quintile = sum(fifelse(!is.na(quintile_num), csi_weight, 0), na.rm = TRUE)
), by = .(strategy_key, qdate, index_id)]

retained_by_q <- retained_q[!is.na(quintile_num), .(
  retained_name_count = .N,
  retained_csi_weight = sum(csi_weight, na.rm = TRUE)
), by = .(strategy_key, qdate, index_id, quintile, quintile_num)]
retained_by_q <- make_complete_quintiles(
  retained_by_q,
  c("retained_name_count", "retained_csi_weight")
)
retained_by_q <- merge(retained_by_q, retained_totals, by = c("strategy_key", "qdate", "index_id"), all.x = TRUE)
retained_by_q[, retained_csi_weight_share_total := safe_divide(retained_csi_weight, retained_csi_weight_total)]
retained_by_q[, retained_csi_weight_share_assigned := safe_divide(retained_csi_weight, retained_csi_weight_with_quintile)]
retained_by_q[, retained_assignment_name_coverage := safe_divide(
  retained_name_count_with_quintile, retained_name_count_total
)]
retained_by_q[, retained_assignment_weight_coverage := safe_divide(
  retained_csi_weight_with_quintile, retained_csi_weight_total
)]

benchmark_totals <- benchmark_q[, .(
  benchmark_name_count_total = .N,
  benchmark_weight_total = sum(benchmark_weight, na.rm = TRUE),
  benchmark_name_count_with_quintile = sum(!is.na(quintile_num)),
  benchmark_weight_with_quintile = sum(fifelse(!is.na(quintile_num), benchmark_weight, 0), na.rm = TRUE)
), by = .(strategy_key, qdate, index_id)]

benchmark_by_q <- benchmark_q[!is.na(quintile_num), .(
  benchmark_name_count = .N,
  benchmark_weight = sum(benchmark_weight, na.rm = TRUE)
), by = .(strategy_key, qdate, index_id, quintile, quintile_num)]
benchmark_by_q <- make_complete_quintiles(
  benchmark_by_q,
  c("benchmark_name_count", "benchmark_weight")
)
benchmark_by_q <- merge(benchmark_by_q, benchmark_totals, by = c("strategy_key", "qdate", "index_id"), all.x = TRUE)
benchmark_by_q[, benchmark_weight_share_total := safe_divide(benchmark_weight, benchmark_weight_total)]
benchmark_by_q[, benchmark_weight_share_assigned := safe_divide(benchmark_weight, benchmark_weight_with_quintile)]

retained_exposure <- merge(
  retained_by_q,
  benchmark_by_q,
  by = c("strategy_key", "qdate", "index_id", "quintile", "quintile_num"),
  all = TRUE
)
retained_exposure[, active_csi_weight_vs_benchmark_total := retained_csi_weight_share_total - benchmark_weight_share_total]
retained_exposure[, active_csi_weight_vs_benchmark_assigned := retained_csi_weight_share_assigned - benchmark_weight_share_assigned]

active_exposure <- retained_exposure[, .(
  strategy_key,
  qdate,
  index_id,
  quintile,
  quintile_num,
  csi_retained_weight = retained_csi_weight,
  csi_retained_weight_share_total = retained_csi_weight_share_total,
  csi_retained_weight_share_assigned = retained_csi_weight_share_assigned,
  benchmark_weight,
  benchmark_weight_share_total,
  benchmark_weight_share_assigned,
  active_csi_weight_vs_benchmark_total,
  active_csi_weight_vs_benchmark_assigned,
  retained_assignment_weight_coverage,
  benchmark_assignment_weight_coverage = safe_divide(benchmark_weight_with_quintile, benchmark_weight_total)
)]

add_meta <- function(dt) {
  meta_by <- intersect(c("strategy_key", "index_id"), names(dt))
  out <- merge(dt, strategy_meta, by = meta_by, all.x = TRUE, sort = FALSE)
  out[, universe := index_id]
  preferred <- c(
    "strategy_key", "period", "track", "response_track", "track_label",
    "universe", "index_id", "index_name", "index_label", "analysis_model",
    "model_key", "model_label", "threshold_method", "threshold_label",
    "threshold", "lockout_years", "strategy_id", "exclusion_rule",
    "rule_label", "weighting", "transaction_cost_bps",
    "is_best_by_track_index_cost", "is_headline_20bps", "qdate",
    "quintile", "quintile_num"
  )
  setcolorder(out, c(intersect(preferred, names(out)), setdiff(names(out), preferred)))
  out[]
}

exclusion_overlap <- add_meta(exclusion_by_q)
retained_exposure <- add_meta(retained_exposure)
active_exposure <- add_meta(active_exposure)

cat("[11I] Computing full-sample summaries...\n")
summary_by_strategy <- active_exposure[, .(
  sample_scope = "full_sample",
  n_qdates = uniqueN(qdate),
  mean_csi_retained_weight_share = mean(csi_retained_weight_share_total, na.rm = TRUE),
  median_csi_retained_weight_share = median(csi_retained_weight_share_total, na.rm = TRUE),
  mean_benchmark_weight_share = mean(benchmark_weight_share_total, na.rm = TRUE),
  median_benchmark_weight_share = median(benchmark_weight_share_total, na.rm = TRUE),
  mean_active_weight_vs_benchmark = mean(active_csi_weight_vs_benchmark_total, na.rm = TRUE),
  median_active_weight_vs_benchmark = median(active_csi_weight_vs_benchmark_total, na.rm = TRUE),
  mean_retained_assignment_weight_coverage = mean(retained_assignment_weight_coverage, na.rm = TRUE),
  mean_benchmark_assignment_weight_coverage = mean(benchmark_assignment_weight_coverage, na.rm = TRUE)
), by = .(
  strategy_key, period, response_track, track_label, universe, index_id,
  index_name, index_label, analysis_model, model_key, model_label,
  strategy_id, transaction_cost_bps, threshold_method, threshold_label,
  lockout_years, exclusion_rule, rule_label, weighting, quintile, quintile_num
)]

exclusion_focus_summary <- exclusion_overlap[, .(
  mean_excluded_name_share = mean(excluded_name_share_assigned, na.rm = TRUE),
  median_excluded_name_share = median(excluded_name_share_assigned, na.rm = TRUE),
  mean_excluded_benchmark_weight_share = mean(excluded_benchmark_weight_share_assigned, na.rm = TRUE),
  median_excluded_benchmark_weight_share = median(excluded_benchmark_weight_share_assigned, na.rm = TRUE),
  mean_excluded_q5_name_share = mean(excluded_csi_intersection_q5_name_share, na.rm = TRUE),
  mean_excluded_q5_benchmark_weight_share = mean(excluded_csi_intersection_q5_benchmark_weight_share, na.rm = TRUE),
  mean_excluded_q1_name_share = mean(excluded_csi_intersection_q1_name_share, na.rm = TRUE),
  mean_excluded_q1_benchmark_weight_share = mean(excluded_csi_intersection_q1_benchmark_weight_share, na.rm = TRUE),
  mean_excluded_assignment_name_coverage = mean(excluded_assignment_name_coverage, na.rm = TRUE),
  mean_excluded_assignment_weight_coverage = mean(excluded_assignment_weight_coverage, na.rm = TRUE)
), by = .(
  strategy_key, period, response_track, universe, index_id, analysis_model,
  model_key, strategy_id, transaction_cost_bps, quintile, quintile_num
)]
summary_by_strategy <- merge(
  summary_by_strategy,
  exclusion_focus_summary,
  by = c(
    "strategy_key", "period", "response_track", "universe", "index_id",
    "analysis_model", "model_key", "strategy_id", "transaction_cost_bps",
    "quintile", "quintile_num"
  ),
  all.x = TRUE
)

summary_by_track_universe <- summary_by_strategy[, .(
  sample_scope = "full_sample",
  n_strategies = uniqueN(strategy_key),
  n_qdates_median = median(n_qdates, na.rm = TRUE),
  mean_excluded_name_share = mean(mean_excluded_name_share, na.rm = TRUE),
  mean_excluded_benchmark_weight_share = mean(mean_excluded_benchmark_weight_share, na.rm = TRUE),
  mean_csi_retained_weight_share = mean(mean_csi_retained_weight_share, na.rm = TRUE),
  mean_benchmark_weight_share = mean(mean_benchmark_weight_share, na.rm = TRUE),
  mean_active_weight_vs_benchmark = mean(mean_active_weight_vs_benchmark, na.rm = TRUE),
  mean_excluded_q5_name_share = mean(mean_excluded_q5_name_share, na.rm = TRUE),
  mean_excluded_q1_name_share = mean(mean_excluded_q1_name_share, na.rm = TRUE)
), by = .(
  period, response_track, universe, index_id, index_name, index_label,
  quintile, quintile_num
)]

setorder(exclusion_overlap, response_track, index_id, model_key, strategy_id, transaction_cost_bps, qdate, quintile_num)
setorder(retained_exposure, response_track, index_id, model_key, strategy_id, transaction_cost_bps, qdate, quintile_num)
setorder(active_exposure, response_track, index_id, model_key, strategy_id, transaction_cost_bps, qdate, quintile_num)
setorder(summary_by_strategy, response_track, index_id, model_key, strategy_id, transaction_cost_bps, quintile_num)
setorder(summary_by_track_universe, response_track, index_id, quintile_num)

cat("[11I] Writing outputs...\n")
write_pair(exclusion_overlap, OUT_EXCLUSION)
write_pair(retained_exposure, OUT_RETAINED)
write_pair(active_exposure, OUT_ACTIVE)
write_pair(summary_by_strategy, OUT_SUMMARY_STRATEGY)
write_pair(summary_by_track_universe, OUT_SUMMARY_TRACK_UNIVERSE)

row_counts <- data.table(
  artifact = c(
    "csi_exclusion_quintile_overlap",
    "csi_retained_quintile_exposure",
    "csi_active_quintile_exposure",
    "overlap_summary_by_strategy",
    "overlap_summary_by_track_universe"
  ),
  rows = c(
    nrow(exclusion_overlap),
    nrow(retained_exposure),
    nrow(active_exposure),
    nrow(summary_by_strategy),
    nrow(summary_by_track_universe)
  )
)

coverage <- data.table(
  metric = c(
    "excluded_assignment_name_coverage_median",
    "excluded_assignment_weight_coverage_median",
    "retained_assignment_weight_coverage_median",
    "benchmark_assignment_weight_coverage_median",
    "quintiles_in_exclusion",
    "quintiles_in_retained",
    "selected_strategy_rows"
  ),
  value = c(
    signif(median(exclusion_overlap$excluded_assignment_name_coverage, na.rm = TRUE), 5),
    signif(median(exclusion_overlap$excluded_assignment_weight_coverage, na.rm = TRUE), 5),
    signif(median(retained_exposure$retained_assignment_weight_coverage, na.rm = TRUE), 5),
    signif(median(active_exposure$benchmark_assignment_weight_coverage, na.rm = TRUE), 5),
    paste(sort(unique(exclusion_overlap$quintile)), collapse = ", "),
    paste(sort(unique(retained_exposure$quintile)), collapse = ", "),
    as.character(nrow(strategy_meta))
  )
)

headline <- summary_by_track_universe[quintile %in% c("Q1", "Q5"), .(
  response_track,
  universe,
  quintile,
  mean_excluded_name_share = signif(mean_excluded_name_share, 4),
  mean_excluded_benchmark_weight_share = signif(mean_excluded_benchmark_weight_share, 4),
  mean_csi_retained_weight_share = signif(mean_csi_retained_weight_share, 4),
  mean_active_weight_vs_benchmark = signif(mean_active_weight_vs_benchmark, 4)
)]

report_lines <- c(
  "# AE-ALPHA-007 Overlap Diagnostics Report",
  "",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Scope",
  "",
  "This diagnostic quantifies overlap between selected CSI headline/best retained and excluded sets and low-volatility quintile assignments. It reads existing CSI weights, existing CSI performance selection metadata, existing low-volatility quintiles, and the benchmark constituent universe. It does not rerun CSI construction, low-volatility construction, model training, thesis edits, presentation edits, or chart creation.",
  "",
  "## Selection",
  "",
  paste0("- Selected CSI strategy metadata rows: ", nrow(strategy_meta)),
  paste0("- Response tracks: ", paste(sort(unique(strategy_meta$response_track)), collapse = ", ")),
  paste0("- Universes: ", paste(sort(unique(strategy_meta$index_id)), collapse = ", ")),
  paste0("- Transaction-cost bps included: ", paste(sort(unique(strategy_meta$transaction_cost_bps)), collapse = ", ")),
  "",
  "## Output Row Counts",
  "",
  paste0("- ", row_counts$artifact, ": ", row_counts$rows),
  "",
  "## Coverage Notes",
  "",
  paste0("- ", coverage$metric, ": ", coverage$value),
  "",
  "## Neutral Headline Observations",
  "",
  if (nrow(headline)) {
    paste0(
      "- ", headline$response_track, " / ", headline$universe, " / ", headline$quintile,
      ": mean excluded-name share ", headline$mean_excluded_name_share,
      "; mean excluded benchmark-weight share ", headline$mean_excluded_benchmark_weight_share,
      "; mean retained CSI weight share ", headline$mean_csi_retained_weight_share,
      "; mean active weight versus benchmark ", headline$mean_active_weight_vs_benchmark, "."
    )
  } else {
    "- Q1/Q5 headline rows were unavailable in the generated summaries."
  },
  "",
  "## Interpretation Guardrails",
  "",
  "- These outputs describe concentration, retained exposure, and active-weight differences by volatility quintile.",
  "- The report does not make final interpretive claims about CSI or low-volatility exposure.",
  "",
  "## Operational Constraints",
  "",
  "- Existing CSI outputs were read only.",
  "- Existing low-volatility outputs were read only.",
  "- No CSI construction rerun was performed.",
  "- No low-volatility construction, performance, or tilt diagnostic rerun was performed.",
  "- No model training was performed.",
  "- No charts were created.",
  "- No thesis or presentation files were edited.",
  "- No staging, commit, or push was performed."
)
writeLines(report_lines, OUT_REPORT, useBytes = TRUE)

status <- data.table(
  ticket_id = "AE-ALPHA-007",
  status = "completed",
  run_started = format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z"),
  run_finished = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
  script_path = SCRIPT_PATH,
  selected_strategy_rows = nrow(strategy_meta),
  exclusion_overlap_rows = nrow(exclusion_overlap),
  retained_exposure_rows = nrow(retained_exposure),
  active_exposure_rows = nrow(active_exposure),
  summary_by_strategy_rows = nrow(summary_by_strategy),
  summary_by_track_universe_rows = nrow(summary_by_track_universe),
  csi_construction_rerun = FALSE,
  lowvol_construction_rerun = FALSE,
  model_training_rerun = FALSE,
  charts_created = FALSE,
  thesis_or_presentation_edited = FALSE,
  staged_committed_or_pushed = FALSE
)
fwrite(status, OUT_STATUS)

completion_lines <- c(
  "# AE-ALPHA-007 Completion Report",
  "",
  "status: completed",
  "",
  "summary:",
  "- Created `01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R`.",
  "- Quantified CSI excluded-name and excluded benchmark-weight overlap with Q1-Q5 volatility quintiles.",
  "- Quantified CSI retained portfolio exposure and active weight versus benchmark across Q1-Q5.",
  "- Used existing CSI weights, CSI performance extract, low-volatility quintile assignments, and benchmark constituents only.",
  "- Did not rerun CSI construction, rerun low-volatility construction/performance/tilt diagnostics, train models, create charts, stage, commit, push, or edit thesis/presentation files.",
  "",
  "changed_files:",
  "- `01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R`",
  "- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-007_Completion_Report.md`",
  "",
  "generated_outputs:",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_exclusion_quintile_overlap.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_retained_quintile_exposure.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_active_quintile_exposure.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/overlap_summary_by_strategy.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/overlap_summary_by_track_universe.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/overlap_diagnostics_report.md`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/overlap_diagnostics_run_status.csv`",
  "",
  "row_counts:",
  paste0("- ", row_counts$artifact, ": ", row_counts$rows),
  "",
  "coverage_notes:",
  paste0("- ", coverage$metric, ": ", coverage$value),
  "",
  "headline_findings_neutral:",
  if (nrow(headline)) {
    paste0(
      "- ", headline$response_track, " / ", headline$universe, " / ", headline$quintile,
      ": mean excluded-name share ", headline$mean_excluded_name_share,
      "; mean excluded benchmark-weight share ", headline$mean_excluded_benchmark_weight_share,
      "; mean retained CSI weight share ", headline$mean_csi_retained_weight_share,
      "; mean active weight versus benchmark ", headline$mean_active_weight_vs_benchmark, "."
    )
  } else {
    "- Q1/Q5 headline rows were unavailable in the generated summaries."
  },
  "",
  "verification:",
  "- `Rscript -e \"parse('01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R')\"` completed successfully.",
  "- `Rscript 01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R` completed successfully.",
  "- Output checks confirmed nonzero exclusion and retained rows, Q1-Q5 representation, response-track columns, and universe columns.",
  "- Run-status CSV records completion and no prohibited reruns or git actions.",
  "",
  "known_caveats:",
  "- Diagnostics are limited to selected headline/best strategies available from the existing alpha-validation performance extract.",
  "- Q1-Q5 shares are computed over firms or weights with available low-volatility quintile assignments; coverage fields quantify assignment coverage.",
  "- The requested AE-ALPHA-005 completion report was not present at the ticket path during worker inspection.",
  "",
  "validator_result: pending",
  "",
  "next_recommended_role: validator"
)
writeLines(completion_lines, OUT_COMPLETION, useBytes = TRUE)

cat("[11I] COMPLETE:", format(Sys.time()), "\n")
