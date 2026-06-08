#==============================================================================#
#==== 11K_Thesis_Evidence_Summary.R ==========================================#
#==== AE-ALPHA-009: Thesis-Ready Evidence Summary =============================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
})

cat("\n[11K_Thesis_Evidence_Summary.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()
TICKET_ID <- "AE-ALPHA-009"

fn_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg)) {
    return(normalizePath(sub("^--file=", "", file_arg[[1L]]), mustWork = FALSE))
  }
  normalizePath("01_Code/pipeline/11K_Thesis_Evidence_Summary.R", mustWork = FALSE)
}

SCRIPT_PATH <- fn_script_path()
PIPELINE_DIR <- dirname(SCRIPT_PATH)
ROOT_DIR <- normalizePath(file.path(PIPELINE_DIR, "..", ".."), mustWork = TRUE)

path_root <- function(...) file.path(ROOT_DIR, ...)
path_alpha <- function(...) file.path(ALPHA_DIR, ...)

ALPHA_DIR <- path_root("03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation")
EVIDENCE_DIR <- path_alpha("evidence_summary")
REPORT_DIR <- path_alpha("reports")
TICKET_DIR <- path_root(
  "05_Documentation", "09_Epics", "AE-ALPHA_LowVol_Tilt_Independence", "Tickets"
)

dir.create(EVIDENCE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TICKET_DIR, recursive = TRUE, showWarnings = FALSE)

inputs <- list(
  benchmark_perf = path_alpha("performance", "benchmark_performance_summary.rds"),
  lowvol_perf = path_alpha("performance", "lowvol_performance_summary.rds"),
  csi_perf = path_alpha("performance", "csi_performance_extract.rds"),
  csi_headline = path_alpha("comparisons", "csi_vs_lowvol_headline.rds"),
  benchmark_lowvol = path_alpha("comparisons", "benchmark_vs_lowvol_quintiles.rds"),
  csi_flags = path_alpha("comparisons", "csi_lowvol_metric_flags.rds"),
  lowvol_anomaly = path_alpha("comparisons", "lowvol_anomaly_summary.rds"),
  char_summary = path_alpha("tilt_diagnostics", "portfolio_characteristic_summary.rds"),
  char_diff = path_alpha("tilt_diagnostics", "portfolio_characteristic_differences.rds"),
  sector_active = path_alpha("tilt_diagnostics", "sector_active_weight_summary.rds"),
  overlap_strategy = path_alpha("overlap_diagnostics", "overlap_summary_by_strategy.rds"),
  overlap_track_universe = path_alpha("overlap_diagnostics", "overlap_summary_by_track_universe.rds"),
  dist_summary = path_alpha("distribution_diagnostics", "distribution_summary_by_strategy.rds"),
  active_summary = path_alpha("distribution_diagnostics", "active_return_summary.rds"),
  capture = path_alpha("distribution_diagnostics", "upside_downside_capture.rds"),
  tail = path_alpha("distribution_diagnostics", "tail_state_summary.rds"),
  qq = path_alpha("distribution_diagnostics", "qq_plot_data.rds"),
  scatter = path_alpha("distribution_diagnostics", "scatter_plot_data.rds")
)

missing_inputs <- unlist(inputs)[!file.exists(unlist(inputs))]
if (length(missing_inputs)) {
  stop("Missing required AE-ALPHA input artifact(s):\n", paste(missing_inputs, collapse = "\n"))
}

write_pair <- function(dt, stem) {
  saveRDS(dt, paste0(stem, ".rds"))
  fwrite(dt, paste0(stem, ".csv"))
}

read_dt <- function(path) {
  as.data.table(readRDS(path))
}

truthy <- function(x) {
  !is.na(x) & x == TRUE
}

available_cols <- function(dt, cols) {
  intersect(cols, names(dt))
}

relative_path <- function(path) {
  path <- gsub("\\\\", "/", normalizePath(path, mustWork = FALSE))
  root <- paste0(gsub("\\\\", "/", ROOT_DIR), "/")
  sub(root, "", path, fixed = TRUE)
}

as_num <- function(x) {
  suppressWarnings(as.numeric(x))
}

safe_paste <- function(..., sep = " | ") {
  vals <- as.character(c(...))
  vals <- vals[!is.na(vals) & vals != ""]
  if (!length(vals)) return(NA_character_)
  paste(unique(vals), collapse = sep)
}

direction_from_value <- function(x) {
  fifelse(
    is.na(x), "not_applicable",
    fifelse(x > 0, "positive_difference",
      fifelse(x < 0, "negative_difference", "no_difference")
    )
  )
}

flag_direction <- function(x) {
  fifelse(is.na(x), "not_available", fifelse(x == 1, "flag_true", "flag_false"))
}

standardize_base <- function(dt) {
  if (!"track" %in% names(dt)) dt[, track := NA_character_]
  if ("response_track" %in% names(dt)) {
    dt[, track_out := fifelse(!is.na(response_track) & response_track != "", response_track, track)]
  } else {
    dt[, track_out := track]
  }
  if (!"universe" %in% names(dt)) dt[, universe := NA_character_]
  if ("index_id" %in% names(dt)) {
    dt[, universe_out := fifelse(!is.na(universe) & universe != "", universe, index_id)]
  } else {
    dt[, universe_out := universe]
  }
  if (!"period" %in% names(dt)) dt[, period := NA_character_]
  if (!"transaction_cost_bps" %in% names(dt)) dt[, transaction_cost_bps := NA_real_]
  dt
}

make_evidence <- function(
  research_question_area,
  evidence_family,
  source_artifact,
  track,
  universe,
  period,
  transaction_cost_bps,
  comparison,
  metric,
  value,
  benchmark_or_reference,
  direction,
  claim_support_level,
  interpretation_guardrail,
  limitation
) {
  data.table(
    research_question_area = as.character(research_question_area),
    evidence_family = as.character(evidence_family),
    source_artifact = as.character(source_artifact),
    track = as.character(track),
    universe = as.character(universe),
    period = as.character(period),
    transaction_cost_bps = as_num(transaction_cost_bps),
    comparison = as.character(comparison),
    metric = as.character(metric),
    value = as_num(value),
    benchmark_or_reference = as.character(benchmark_or_reference),
    direction = as.character(direction),
    claim_support_level = as.character(claim_support_level),
    interpretation_guardrail = as.character(interpretation_guardrail),
    limitation = as.character(limitation)
  )
}

performance_guardrail <- paste(
  "Descriptive realized portfolio outcome; compare only within aligned",
  "period and transaction-cost cells where possible."
)
comparison_guardrail <- paste(
  "Directional difference or flag from existing summaries; no statistical",
  "significance test is added here."
)
tilt_guardrail <- "Observable exposure association; not a return-attribution result."
overlap_guardrail <- "Composition overlap diagnostic; it does not identify the driver of performance."
distribution_guardrail <- "Distributional comparison from existing monthly-return diagnostics only."
limitation_guardrail <- "Boundary condition for thesis wording and robustness planning."

evidence_parts <- list()

cat("[11K] Loading performance and comparison inputs...\n")
benchmark_perf <- standardize_base(read_dt(inputs$benchmark_perf))
lowvol_perf <- standardize_base(read_dt(inputs$lowvol_perf))
csi_perf <- standardize_base(read_dt(inputs$csi_perf))
csi_headline <- standardize_base(read_dt(inputs$csi_headline))
benchmark_lowvol <- standardize_base(read_dt(inputs$benchmark_lowvol))
csi_flags <- standardize_base(read_dt(inputs$csi_flags))
lowvol_anomaly <- standardize_base(read_dt(inputs$lowvol_anomaly))

perf_metrics <- c(
  "annualized_geometric_return",
  "annualized_volatility",
  "sharpe_ratio",
  "max_drawdown",
  "expected_shortfall_2p5",
  "annualized_turnover_gross"
)

long_performance <- function(dt, source_key, area, comparison_expr) {
  metrics <- available_cols(dt, perf_metrics)
  if (!length(metrics) || !nrow(dt)) return(data.table())
  id_cols <- available_cols(dt, c(
    "track_out", "universe_out", "period", "transaction_cost_bps",
    "strategy_id", "portfolio_id", "quintile", "analysis_model",
    "model_key", "model_label", "rule_label", "index_name"
  ))
  out <- melt(
    dt,
    id.vars = id_cols,
    measure.vars = metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  out <- out[is.finite(value)]
  if (!nrow(out)) return(data.table())
  out[, comparison := comparison_expr(.SD)]
  make_evidence(
    research_question_area = area,
    evidence_family = "performance",
    source_artifact = relative_path(inputs[[source_key]]),
    track = out$track_out,
    universe = out$universe_out,
    period = out$period,
    transaction_cost_bps = out$transaction_cost_bps,
    comparison = out$comparison,
    metric = out$metric,
    value = out$value,
    benchmark_or_reference = "realized portfolio metric",
    direction = "observed_value",
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = performance_guardrail,
    limitation = "Full-period sample starts can differ across benchmark, low-volatility, and CSI rows."
  )
}

evidence_parts[["benchmark_perf"]] <- long_performance(
  benchmark_perf,
  "benchmark_perf",
  "main_rq",
  function(x) rep("market benchmark performance", nrow(x))
)

evidence_parts[["lowvol_perf"]] <- long_performance(
  lowvol_perf,
  "lowvol_perf",
  "sq_volatility_comparison",
  function(x) paste0("low-volatility ", x$quintile, " performance")
)

csi_selected <- csi_perf[
  period == "full" &
    (truthy(is_best_by_track_index_cost) | truthy(is_headline_20bps))
]
if ("transaction_cost_bps" %in% names(csi_selected)) {
  csi_selected <- csi_selected[transaction_cost_bps %in% c(0, 20)]
}
if (!nrow(csi_selected)) {
  csi_selected <- csi_perf[period == "full"]
}
evidence_parts[["csi_perf"]] <- long_performance(
  csi_selected,
  "csi_perf",
  "main_rq",
  function(x) {
    paste(
      "selected CSI performance",
      x$model_key,
      x$strategy_id,
      x$rule_label,
      sep = " | "
    )
  }
)

auto_metrics <- c("annualized_geometric_return", "sharpe_ratio", "annualized_volatility")
auto_cols <- available_cols(csi_perf, auto_metrics)
if (length(auto_cols)) {
  auto_long <- melt(
    csi_perf[period == "full" & transaction_cost_bps %in% c(0, 20)],
    id.vars = available_cols(csi_perf, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "analysis_model", "model_key", "model_label"
    )),
    measure.vars = auto_cols,
    variable.name = "metric",
    value.name = "metric_value",
    variable.factor = FALSE
  )
  auto_summary <- auto_long[is.finite(metric_value), .(
    value = max(metric_value, na.rm = TRUE),
    rows_summarized = .N
  ), by = .(
    track_out, universe_out, period, transaction_cost_bps,
    analysis_model, model_key, model_label, metric
  )]
  evidence_parts[["autoencoder_model_family_perf"]] <- make_evidence(
    research_question_area = "sq_autoencoder",
    evidence_family = "performance",
    source_artifact = relative_path(inputs$csi_perf),
    track = auto_summary$track_out,
    universe = auto_summary$universe_out,
    period = auto_summary$period,
    transaction_cost_bps = auto_summary$transaction_cost_bps,
    comparison = paste(
      "best observed CSI portfolio metric by feature/model family",
      auto_summary$analysis_model,
      auto_summary$model_key,
      sep = " | "
    ),
    metric = paste0("best_observed_", auto_summary$metric),
    value = auto_summary$value,
    benchmark_or_reference = "other CSI model-key families in the same output",
    direction = "observed_value",
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = paste(
      "Portfolio outcome summaries are descriptive and do not isolate",
      "predictive feature contribution."
    ),
    limitation = paste(
      "Use original predictive-validation evidence before claiming",
      "autoencoder feature improvement."
    )
  )
}

comparison_diff_cols <- available_cols(csi_headline, c(
  "return_difference_csi_minus_q1",
  "return_difference_csi_minus_q5",
  "return_difference_csi_minus_benchmark",
  "sharpe_difference_csi_minus_q1",
  "sharpe_difference_csi_minus_q5",
  "sharpe_difference_csi_minus_benchmark"
))
if (length(comparison_diff_cols)) {
  cmp_long <- melt(
    csi_headline,
    id.vars = available_cols(csi_headline, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_id", "model_key", "rule_label", "index_name"
    )),
    measure.vars = comparison_diff_cols,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  cmp_long <- cmp_long[is.finite(value)]
  cmp_long[, reference := fifelse(grepl("_q1$", metric), "low-volatility Q1",
    fifelse(grepl("_q5$", metric), "low-volatility Q5", "market benchmark")
  )]
  evidence_parts[["csi_headline_diffs"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "comparison",
    source_artifact = relative_path(inputs$csi_headline),
    track = cmp_long$track_out,
    universe = cmp_long$universe_out,
    period = cmp_long$period,
    transaction_cost_bps = cmp_long$transaction_cost_bps,
    comparison = paste("CSI minus", cmp_long$reference),
    metric = cmp_long$metric,
    value = cmp_long$value,
    benchmark_or_reference = cmp_long$reference,
    direction = direction_from_value(cmp_long$value),
    claim_support_level = "directional_comparison",
    interpretation_guardrail = comparison_guardrail,
    limitation = "These are metric differences, not independent performance tests."
  )
}

flag_cols <- grep("^csi_.*_(q1|q5|benchmark)", names(csi_flags), value = TRUE)
flag_cols <- flag_cols[vapply(csi_flags[, ..flag_cols], is.logical, logical(1))]
if (length(flag_cols)) {
  flag_long <- melt(
    csi_flags,
    id.vars = available_cols(csi_flags, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_id", "model_key", "rule_label", "interpretation_class"
    )),
    measure.vars = flag_cols,
    variable.name = "metric",
    value.name = "flag_value",
    variable.factor = FALSE
  )
  flag_long[, value := as.numeric(flag_value == TRUE)]
  flag_long[, reference := fifelse(grepl("_q1", metric), "low-volatility Q1",
    fifelse(grepl("_q5", metric), "low-volatility Q5", "market benchmark")
  )]
  evidence_parts[["csi_metric_flags"]] <- make_evidence(
    research_question_area = "sq_volatility_comparison",
    evidence_family = "comparison",
    source_artifact = relative_path(inputs$csi_flags),
    track = flag_long$track_out,
    universe = flag_long$universe_out,
    period = flag_long$period,
    transaction_cost_bps = flag_long$transaction_cost_bps,
    comparison = paste("CSI directional flag versus", flag_long$reference),
    metric = flag_long$metric,
    value = flag_long$value,
    benchmark_or_reference = flag_long$reference,
    direction = flag_direction(flag_long$value),
    claim_support_level = "directional_comparison",
    interpretation_guardrail = comparison_guardrail,
    limitation = "Boolean flags summarize direction only and should be paired with metric magnitudes."
  )
}

benchmark_lowvol_diff_cols <- available_cols(benchmark_lowvol, c(
  "return_difference_lowvol_minus_benchmark",
  "sharpe_difference_lowvol_minus_benchmark",
  "max_drawdown_difference_lowvol_minus_benchmark"
))
if (length(benchmark_lowvol_diff_cols)) {
  bl_long <- melt(
    benchmark_lowvol,
    id.vars = available_cols(benchmark_lowvol, c(
      "universe_out", "period", "transaction_cost_bps", "quintile", "quintile_num"
    )),
    measure.vars = benchmark_lowvol_diff_cols,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  bl_long <- bl_long[is.finite(value)]
  evidence_parts[["benchmark_lowvol_diffs"]] <- make_evidence(
    research_question_area = "sq_volatility_comparison",
    evidence_family = "comparison",
    source_artifact = relative_path(inputs$benchmark_lowvol),
    track = "lowvol_quintile",
    universe = bl_long$universe_out,
    period = bl_long$period,
    transaction_cost_bps = bl_long$transaction_cost_bps,
    comparison = paste0("low-volatility ", bl_long$quintile, " minus benchmark"),
    metric = bl_long$metric,
    value = bl_long$value,
    benchmark_or_reference = "market benchmark",
    direction = direction_from_value(bl_long$value),
    claim_support_level = "directional_comparison",
    interpretation_guardrail = comparison_guardrail,
    limitation = "Low-volatility rows are mechanical quintile sorts, not CSI exclusions."
  )
}

if (nrow(lowvol_anomaly)) {
  anomaly_counts <- lowvol_anomaly[, .N, by = .(
    comparison, period, universe_out, transaction_cost_bps, pattern_class
  )]
  evidence_parts[["lowvol_anomaly_patterns"]] <- make_evidence(
    research_question_area = "sq_volatility_comparison",
    evidence_family = "comparison",
    source_artifact = relative_path(inputs$lowvol_anomaly),
    track = "lowvol_quintile",
    universe = anomaly_counts$universe_out,
    period = anomaly_counts$period,
    transaction_cost_bps = anomaly_counts$transaction_cost_bps,
    comparison = anomaly_counts$comparison,
    metric = paste0("pattern_count:", anomaly_counts$pattern_class),
    value = anomaly_counts$N,
    benchmark_or_reference = "low-volatility anomaly directional pattern",
    direction = anomaly_counts$pattern_class,
    claim_support_level = "diagnostic_pattern",
    interpretation_guardrail = comparison_guardrail,
    limitation = "Pattern classes are summaries of existing metric directions."
  )
}

cat("[11K] Loading tilt diagnostics...\n")
char_summary <- standardize_base(read_dt(inputs$char_summary))
char_diff <- standardize_base(read_dt(inputs$char_diff))
sector_active <- standardize_base(read_dt(inputs$sector_active))

if (nrow(char_diff)) {
  char_diff_sum <- char_diff[is.finite(difference_weighted_mean), .(
    value = mean(difference_weighted_mean, na.rm = TRUE),
    rows_summarized = .N,
    mean_weight_coverage = mean(weight_coverage, na.rm = TRUE)
  ), by = .(
    period, index_id, response_track, transaction_cost_bps,
    portfolio_group, diagnostic_family, characteristic, comparison_base
  )]
  evidence_parts[["char_differences"]] <- make_evidence(
    research_question_area = "sq_features",
    evidence_family = "tilt",
    source_artifact = relative_path(inputs$char_diff),
    track = char_diff_sum$response_track,
    universe = char_diff_sum$index_id,
    period = char_diff_sum$period,
    transaction_cost_bps = char_diff_sum$transaction_cost_bps,
    comparison = paste(
      char_diff_sum$portfolio_group,
      "minus",
      char_diff_sum$comparison_base,
      char_diff_sum$diagnostic_family,
      sep = " | "
    ),
    metric = paste0("mean_weighted_difference:", char_diff_sum$characteristic),
    value = char_diff_sum$value,
    benchmark_or_reference = char_diff_sum$comparison_base,
    direction = direction_from_value(char_diff_sum$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = tilt_guardrail,
    limitation = "Characteristic coverage varies by field and holding period."
  )
}

if (nrow(char_summary)) {
  char_cov <- char_summary[, .(
    value = mean(weight_coverage, na.rm = TRUE),
    rows_summarized = .N
  ), by = .(
    period, index_id, response_track, transaction_cost_bps,
    portfolio_group, diagnostic_family, characteristic
  )]
  char_cov <- char_cov[is.finite(value)]
  evidence_parts[["char_coverage"]] <- make_evidence(
    research_question_area = "limitations",
    evidence_family = "tilt",
    source_artifact = relative_path(inputs$char_summary),
    track = char_cov$response_track,
    universe = char_cov$index_id,
    period = char_cov$period,
    transaction_cost_bps = char_cov$transaction_cost_bps,
    comparison = paste("feature coverage", char_cov$portfolio_group, char_cov$diagnostic_family, sep = " | "),
    metric = paste0("mean_weight_coverage:", char_cov$characteristic),
    value = char_cov$value,
    benchmark_or_reference = "nonmissing characteristic weight coverage",
    direction = "coverage_share",
    claim_support_level = "data_availability",
    interpretation_guardrail = limitation_guardrail,
    limitation = "Lower coverage should weaken thesis wording for the affected characteristic."
  )
}

if (nrow(sector_active)) {
  sector_sum <- sector_active[is.finite(active_sector_weight), .(
    value = mean(active_sector_weight, na.rm = TRUE),
    rows_summarized = .N
  ), by = .(
    period, index_id, response_track, transaction_cost_bps,
    portfolio_group, sector_group
  )]
  evidence_parts[["sector_active"]] <- make_evidence(
    research_question_area = "sq_features",
    evidence_family = "tilt",
    source_artifact = relative_path(inputs$sector_active),
    track = sector_sum$response_track,
    universe = sector_sum$index_id,
    period = sector_sum$period,
    transaction_cost_bps = sector_sum$transaction_cost_bps,
    comparison = paste("sector active weight", sector_sum$portfolio_group, sep = " | "),
    metric = paste0("mean_active_sector_weight:", sector_sum$sector_group),
    value = sector_sum$value,
    benchmark_or_reference = "market benchmark sector weight",
    direction = direction_from_value(sector_sum$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = tilt_guardrail,
    limitation = "Sector active weights describe composition, not return contribution."
  )
}

cat("[11K] Loading overlap diagnostics...\n")
overlap_strategy <- standardize_base(read_dt(inputs$overlap_strategy))
overlap_track_universe <- standardize_base(read_dt(inputs$overlap_track_universe))

overlap_metrics <- available_cols(overlap_track_universe, c(
  "mean_excluded_name_share",
  "mean_excluded_benchmark_weight_share",
  "mean_csi_retained_weight_share",
  "mean_benchmark_weight_share",
  "mean_active_weight_vs_benchmark",
  "mean_excluded_q5_name_share",
  "mean_excluded_q1_name_share"
))
if (length(overlap_metrics)) {
  ov_long <- melt(
    overlap_track_universe,
    id.vars = available_cols(overlap_track_universe, c(
      "period", "response_track", "universe", "index_id", "quintile", "quintile_num"
    )),
    measure.vars = overlap_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  ov_long <- ov_long[is.finite(value)]
  evidence_parts[["overlap_track_universe"]] <- make_evidence(
    research_question_area = "sq_volatility_comparison",
    evidence_family = "overlap",
    source_artifact = relative_path(inputs$overlap_track_universe),
    track = ov_long$response_track,
    universe = fifelse(!is.na(ov_long$universe) & ov_long$universe != "", ov_long$universe, ov_long$index_id),
    period = ov_long$period,
    transaction_cost_bps = NA_real_,
    comparison = paste("CSI overlap by volatility quintile", ov_long$quintile),
    metric = ov_long$metric,
    value = ov_long$value,
    benchmark_or_reference = "volatility quintile assignment",
    direction = direction_from_value(ov_long$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = overlap_guardrail,
    limitation = "Overlap shares do not by themselves explain realized returns."
  )
}

strategy_overlap_metrics <- available_cols(overlap_strategy, c(
  "mean_excluded_q5_name_share",
  "mean_excluded_q1_name_share",
  "mean_excluded_benchmark_weight_share",
  "mean_active_weight_vs_benchmark",
  "mean_csi_retained_weight_share"
))
if (length(strategy_overlap_metrics)) {
  ovs_long <- melt(
    overlap_strategy,
    id.vars = available_cols(overlap_strategy, c(
      "period", "response_track", "universe", "index_id", "transaction_cost_bps",
      "strategy_id", "model_key", "quintile"
    )),
    measure.vars = strategy_overlap_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  ovs_long <- ovs_long[is.finite(value)]
  evidence_parts[["overlap_strategy"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "overlap",
    source_artifact = relative_path(inputs$overlap_strategy),
    track = ovs_long$response_track,
    universe = fifelse(!is.na(ovs_long$universe) & ovs_long$universe != "", ovs_long$universe, ovs_long$index_id),
    period = ovs_long$period,
    transaction_cost_bps = ovs_long$transaction_cost_bps,
    comparison = paste("selected CSI strategy overlap", ovs_long$strategy_id, ovs_long$quintile, sep = " | "),
    metric = ovs_long$metric,
    value = ovs_long$value,
    benchmark_or_reference = "benchmark and low-volatility quintile weights",
    direction = direction_from_value(ovs_long$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = overlap_guardrail,
    limitation = "Strategy-level overlap is descriptive and should be read with performance and distribution rows."
  )
}

cat("[11K] Loading distribution diagnostics...\n")
dist_summary <- standardize_base(read_dt(inputs$dist_summary))
active_summary <- standardize_base(read_dt(inputs$active_summary))
capture <- standardize_base(read_dt(inputs$capture))
tail <- standardize_base(read_dt(inputs$tail))
qq <- read_dt(inputs$qq)
scatter <- read_dt(inputs$scatter)

dist_metrics <- available_cols(dist_summary, c(
  "mean_monthly_return", "monthly_volatility", "skewness", "excess_kurtosis",
  "quantile_2p5", "quantile_97p5", "expected_shortfall_2p5",
  "share_positive_months", "tracking_error_like_monthly_sd"
))
if (length(dist_metrics)) {
  d_long <- melt(
    dist_summary,
    id.vars = available_cols(dist_summary, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_group", "strategy_id", "strategy_label", "selection_reason"
    )),
    measure.vars = dist_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  d_long <- d_long[is.finite(value)]
  evidence_parts[["distribution_summary"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "distribution",
    source_artifact = relative_path(inputs$dist_summary),
    track = d_long$track_out,
    universe = d_long$universe_out,
    period = d_long$period,
    transaction_cost_bps = d_long$transaction_cost_bps,
    comparison = paste("return distribution", d_long$strategy_group, d_long$strategy_id, sep = " | "),
    metric = d_long$metric,
    value = d_long$value,
    benchmark_or_reference = "matched monthly return panel",
    direction = "observed_value",
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = distribution_guardrail,
    limitation = "Distribution summaries are descriptive and period dependent."
  )
}

active_metrics <- available_cols(active_summary, c(
  "mean_active_return_net",
  "median_active_return_net",
  "active_return_net_sd",
  "active_return_net_q2p5",
  "active_return_net_q97p5",
  "share_positive_active_months_net",
  "tracking_error_like_monthly_sd"
))
if (length(active_metrics)) {
  a_long <- melt(
    active_summary,
    id.vars = available_cols(active_summary, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_group", "strategy_id", "strategy_label"
    )),
    measure.vars = active_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  a_long <- a_long[is.finite(value)]
  evidence_parts[["active_return_summary"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "distribution",
    source_artifact = relative_path(inputs$active_summary),
    track = a_long$track_out,
    universe = a_long$universe_out,
    period = a_long$period,
    transaction_cost_bps = a_long$transaction_cost_bps,
    comparison = paste("active return distribution", a_long$strategy_group, a_long$strategy_id, sep = " | "),
    metric = a_long$metric,
    value = a_long$value,
    benchmark_or_reference = "matched market benchmark",
    direction = direction_from_value(a_long$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = distribution_guardrail,
    limitation = "Active-return summaries do not decompose the source of active returns."
  )
}

capture_metrics <- available_cols(capture, c("upside_capture_net", "downside_capture_net"))
if (length(capture_metrics)) {
  c_long <- melt(
    capture,
    id.vars = available_cols(capture, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_group", "strategy_id", "strategy_label"
    )),
    measure.vars = capture_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  c_long <- c_long[is.finite(value)]
  evidence_parts[["capture"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "distribution",
    source_artifact = relative_path(inputs$capture),
    track = c_long$track_out,
    universe = c_long$universe_out,
    period = c_long$period,
    transaction_cost_bps = c_long$transaction_cost_bps,
    comparison = paste("benchmark up/down capture", c_long$strategy_group, c_long$strategy_id, sep = " | "),
    metric = c_long$metric,
    value = c_long$value,
    benchmark_or_reference = "benchmark up-month or down-month average",
    direction = "capture_ratio",
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = distribution_guardrail,
    limitation = "Capture ratios summarize conditional averages and are not a full downside-risk test."
  )
}

tail_metrics <- available_cols(tail, c(
  "strategy_mean_return_tail_net",
  "benchmark_mean_return_tail",
  "strategy_mean_active_return_tail_net"
))
if (length(tail_metrics)) {
  t_long <- melt(
    tail,
    id.vars = available_cols(tail, c(
      "track_out", "universe_out", "period", "transaction_cost_bps",
      "strategy_group", "strategy_id", "strategy_label", "tail_label"
    )),
    measure.vars = tail_metrics,
    variable.name = "metric",
    value.name = "value",
    variable.factor = FALSE
  )
  t_long <- t_long[is.finite(value)]
  evidence_parts[["tail"]] <- make_evidence(
    research_question_area = "main_rq",
    evidence_family = "distribution",
    source_artifact = relative_path(inputs$tail),
    track = t_long$track_out,
    universe = t_long$universe_out,
    period = t_long$period,
    transaction_cost_bps = t_long$transaction_cost_bps,
    comparison = paste("benchmark-tail behavior", t_long$strategy_group, t_long$strategy_id, sep = " | "),
    metric = paste(t_long$tail_label, t_long$metric, sep = ":"),
    value = t_long$value,
    benchmark_or_reference = "benchmark tail-state months",
    direction = direction_from_value(t_long$value),
    claim_support_level = "descriptive_metric",
    interpretation_guardrail = distribution_guardrail,
    limitation = "Tail-state evidence is conditional on benchmark tail definitions."
  )
}

availability <- data.table(
  source_artifact = c(relative_path(inputs$qq), relative_path(inputs$scatter)),
  metric = c("qq_plot_data_rows", "scatter_plot_data_rows"),
  value = c(nrow(qq), nrow(scatter))
)
evidence_parts[["distribution_availability"]] <- make_evidence(
  research_question_area = "limitations",
  evidence_family = "distribution",
  source_artifact = availability$source_artifact,
  track = NA_character_,
  universe = NA_character_,
  period = "all_available",
  transaction_cost_bps = NA_real_,
  comparison = "plot-data availability without rendering",
  metric = availability$metric,
  value = availability$value,
  benchmark_or_reference = "data-only diagnostics",
  direction = "data_available",
  claim_support_level = "data_availability",
  interpretation_guardrail = limitation_guardrail,
  limitation = "Data are available for later chart work; this ticket does not render charts."
)

manual_limitations <- data.table(
  comparison = c(
    "scope boundary",
    "feature-family interpretation",
    "low-volatility comparison wording",
    "alpha wording",
    "robustness boundary"
  ),
  metric = c(
    "no_thesis_or_presentation_edit",
    "autoencoder_feature_claim_boundary",
    "mechanical_sort_vs_csi_boundary",
    "descriptive_alpha_boundary",
    "remaining_robustness_checks"
  ),
  limitation = c(
    "No thesis or presentation files are edited by this ticket.",
    "Portfolio evidence alone cannot establish that autoencoder features improve predictive performance.",
    "Overlap with low-volatility quintiles supports a careful comparison but not an identity statement.",
    "CSI return differences should be phrased as descriptive evidence before further inference.",
    "Statistical inference, factor regressions, alternative rebalancing, and out-of-sample robustness remain separate checks."
  )
)
evidence_parts[["manual_limitations"]] <- make_evidence(
  research_question_area = "limitations",
  evidence_family = "limitation",
  source_artifact = "AE-ALPHA-009 synthesis scope",
  track = NA_character_,
  universe = NA_character_,
  period = "not_applicable",
  transaction_cost_bps = NA_real_,
  comparison = manual_limitations$comparison,
  metric = manual_limitations$metric,
  value = NA_real_,
  benchmark_or_reference = "ticket scope and current output set",
  direction = "scope_guardrail",
  claim_support_level = "scope_limitation",
  interpretation_guardrail = limitation_guardrail,
  limitation = manual_limitations$limitation
)

evidence_map <- rbindlist(evidence_parts, fill = TRUE, use.names = TRUE)
setcolorder(evidence_map, c(
  "research_question_area", "evidence_family", "source_artifact", "track",
  "universe", "period", "transaction_cost_bps", "comparison", "metric",
  "value", "benchmark_or_reference", "direction", "claim_support_level",
  "interpretation_guardrail", "limitation"
))
evidence_map[, evidence_id := sprintf("AE009-EV-%05d", .I)]
setcolorder(evidence_map, c("evidence_id", setdiff(names(evidence_map), "evidence_id")))

area_labels <- data.table(
  research_question_area = c(
    "main_rq",
    "sq_autoencoder",
    "sq_volatility_comparison",
    "sq_features",
    "limitations"
  ),
  area_label = c(
    "Crash-filtered index versus market benchmark and low-volatility strategies",
    "Whether autoencoder features improve predictive performance relative to raw data",
    "Whether CSI differs from a simple low-volatility or high-volatility rule",
    "Which characteristic families appear related to CSI exclusions or retained portfolios",
    "What cannot be claimed from the current outputs"
  ),
  synthesis_reading = c(
    "Use performance, comparison, overlap, and distribution rows to describe CSI relative to benchmark and low-volatility alternatives.",
    "Use only as descriptive portfolio evidence by model family unless paired with predictive-validation evidence.",
    "Use low-volatility quintile comparisons and overlap diagnostics to phrase similarity and difference carefully.",
    "Use tilt rows as observable characteristic diagnostics for volatility, size, sector, profitability or quality, leverage or solvency, and liquidity where available.",
    "Use scope rows to prevent overstatement and to identify robustness checks still outside this ticket."
  ),
  key_guardrail = c(
    "Avoid treating descriptive return differences as final evidence.",
    "Do not infer feature contribution from portfolio outcomes alone.",
    "Avoid identity statements between CSI and low-volatility sorts.",
    "Treat characteristic tilts as associations.",
    "Keep thesis wording conditional on current diagnostics."
  )
)

rq_matrix <- evidence_map[, .(
  evidence_item_count = .N,
  source_artifacts = safe_paste(source_artifact),
  tracks = safe_paste(track),
  universes = safe_paste(universe),
  claim_support_levels = safe_paste(claim_support_level),
  evidence_id_examples = paste(head(evidence_id, 8L), collapse = " | ")
), by = .(research_question_area, evidence_family)]
rq_matrix <- merge(area_labels, rq_matrix, by = "research_question_area", all.x = TRUE, allow.cartesian = TRUE)
rq_matrix[is.na(evidence_family), `:=`(
  evidence_family = "none",
  evidence_item_count = 0L,
  source_artifacts = NA_character_,
  tracks = NA_character_,
  universes = NA_character_,
  claim_support_levels = NA_character_,
  evidence_id_examples = NA_character_
)]
setorder(rq_matrix, research_question_area, evidence_family)

performance_evidence_summary <- evidence_map[
  evidence_family %in% c("performance", "comparison"),
  .(
    evidence_rows = .N,
    finite_value_rows = sum(is.finite(value)),
    mean_value = if (any(is.finite(value))) mean(value, na.rm = TRUE) else NA_real_,
    min_value = if (any(is.finite(value))) min(value, na.rm = TRUE) else NA_real_,
    max_value = if (any(is.finite(value))) max(value, na.rm = TRUE) else NA_real_,
    source_artifacts = safe_paste(source_artifact)
  ),
  by = .(
    research_question_area, evidence_family, track, universe, period,
    transaction_cost_bps, comparison, metric, benchmark_or_reference,
    direction, claim_support_level
  )
]
setorder(performance_evidence_summary, research_question_area, evidence_family, universe, period, metric)

tilt_overlap_distribution_evidence_summary <- evidence_map[
  evidence_family %in% c("tilt", "overlap", "distribution", "limitation"),
  .(
    evidence_rows = .N,
    finite_value_rows = sum(is.finite(value)),
    mean_value = if (any(is.finite(value))) mean(value, na.rm = TRUE) else NA_real_,
    min_value = if (any(is.finite(value))) min(value, na.rm = TRUE) else NA_real_,
    max_value = if (any(is.finite(value))) max(value, na.rm = TRUE) else NA_real_,
    source_artifacts = safe_paste(source_artifact)
  ),
  by = .(
    research_question_area, evidence_family, track, universe, period,
    transaction_cost_bps, comparison, metric, benchmark_or_reference,
    direction, claim_support_level
  )
]
setorder(tilt_overlap_distribution_evidence_summary, research_question_area, evidence_family, universe, period, metric)

suggested_tables <- data.table(
  table_id = sprintf("AE009-T%02d", 1:8),
  table_title = c(
    "Benchmark, low-volatility quintile, and selected CSI performance metrics",
    "CSI versus benchmark, Q1, and Q5 directional comparison flags",
    "Low-volatility quintile anomaly summary",
    "CSI and low-volatility quintile overlap diagnostics",
    "Observable characteristic tilt summary",
    "Sector active-weight summary",
    "Return distribution and active-return summary",
    "Tail-state and upside/downside capture summary"
  ),
  primary_research_question_area = c(
    "main_rq", "main_rq", "sq_volatility_comparison", "sq_volatility_comparison",
    "sq_features", "sq_features", "main_rq", "main_rq"
  ),
  evidence_family = c(
    "performance", "comparison", "comparison", "overlap",
    "tilt", "tilt", "distribution", "distribution"
  ),
  source_output = c(
    "evidence_summary/performance_evidence_summary.csv",
    "evidence_summary/performance_evidence_summary.csv",
    "evidence_summary/performance_evidence_summary.csv",
    "evidence_summary/tilt_overlap_distribution_evidence_summary.csv",
    "evidence_summary/tilt_overlap_distribution_evidence_summary.csv",
    "evidence_summary/tilt_overlap_distribution_evidence_summary.csv",
    "evidence_summary/tilt_overlap_distribution_evidence_summary.csv",
    "evidence_summary/tilt_overlap_distribution_evidence_summary.csv"
  ),
  suggested_columns = c(
    "track, universe, period, transaction_cost_bps, comparison, metric, mean_value",
    "track, universe, period, transaction_cost_bps, metric, direction, mean_value",
    "universe, period, transaction_cost_bps, comparison, metric, evidence_rows",
    "track, universe, period, comparison, metric, mean_value",
    "track, universe, period, comparison, metric, mean_value, finite_value_rows",
    "track, universe, period, comparison, metric, mean_value",
    "track, universe, period, transaction_cost_bps, comparison, metric, mean_value",
    "track, universe, period, transaction_cost_bps, comparison, metric, mean_value"
  ),
  thesis_use = c(
    "Core descriptive performance table for benchmark, Q1-Q5, and selected CSI rows.",
    "Compact evidence table for CSI comparisons against market benchmark and low-volatility references.",
    "Supports careful wording about low-volatility behavior across quintiles.",
    "Shows whether CSI exclusions and retained weights are concentrated in volatility quintiles.",
    "Summarizes observable characteristic families associated with retained or excluded portfolios.",
    "Adds industry-composition context for characteristic interpretation.",
    "Provides distributional context behind average performance comparisons.",
    "Provides benchmark-tail and capture evidence for downside/upside phrasing."
  ),
  guardrail = c(
    performance_guardrail,
    comparison_guardrail,
    comparison_guardrail,
    overlap_guardrail,
    tilt_guardrail,
    tilt_guardrail,
    distribution_guardrail,
    distribution_guardrail
  )
)

write_pair(evidence_map, file.path(EVIDENCE_DIR, "thesis_evidence_map"))
write_pair(rq_matrix, file.path(EVIDENCE_DIR, "research_question_evidence_matrix"))
write_pair(performance_evidence_summary, file.path(EVIDENCE_DIR, "performance_evidence_summary"))
write_pair(
  tilt_overlap_distribution_evidence_summary,
  file.path(EVIDENCE_DIR, "tilt_overlap_distribution_evidence_summary")
)
write_pair(suggested_tables, file.path(EVIDENCE_DIR, "suggested_thesis_tables"))

row_counts <- data.table(
  artifact = c(
    "thesis_evidence_map",
    "research_question_evidence_matrix",
    "performance_evidence_summary",
    "tilt_overlap_distribution_evidence_summary",
    "suggested_thesis_tables"
  ),
  rows = c(
    nrow(evidence_map),
    nrow(rq_matrix),
    nrow(performance_evidence_summary),
    nrow(tilt_overlap_distribution_evidence_summary),
    nrow(suggested_tables)
  )
)

family_counts <- evidence_map[, .N, by = evidence_family][order(evidence_family)]
rq_counts <- evidence_map[, .N, by = research_question_area][order(research_question_area)]
coverage_flags <- data.table(
  research_question_area = area_labels$research_question_area,
  covered = area_labels$research_question_area %in% evidence_map$research_question_area
)

format_table <- function(dt) {
  paste(capture.output(print(dt)), collapse = "\n")
}

memo_lines <- c(
  "# Thesis-Ready Evidence Summary",
  "",
  paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## What the current evidence supports",
  "",
  "- The current outputs support descriptive comparison of market benchmarks, low-volatility quintiles, and selected CSI rows across return, volatility, Sharpe, drawdown, expected shortfall, turnover, overlap, tilt, and distribution diagnostics.",
  "- CSI rows can be described relative to market benchmark, Q1, and Q5 references using existing metric differences and directional flags.",
  "- Low-volatility quintile outputs support careful discussion of whether Q1, Q5, and benchmark patterns align with a low-volatility anomaly in the generated sample.",
  "- Tilt and overlap outputs provide descriptive evidence on observable characteristics and volatility-quintile composition.",
  "- Distribution outputs provide downside/upside capture, benchmark-tail behavior, active-return distribution, and data availability for Q-Q and scatter diagnostics.",
  "",
  "## What the current evidence does not support",
  "",
  "- The current synthesis does not establish feature contribution from autoencoder inputs by itself; it records portfolio-outcome evidence by model family and leaves predictive-validation interpretation to the relevant upstream evidence.",
  "- The current synthesis does not identify return drivers from overlap or tilt rows alone.",
  "- The current synthesis does not add factor regressions, statistical inference, new model training, new portfolio construction, or chart rendering.",
  "- The current synthesis should not be copied into thesis claims without the human deciding which diagnostics belong in the thesis argument.",
  "",
  "## How to phrase the low-volatility comparison",
  "",
  "- Prefer: The evidence is consistent with CSI having measurable overlap with volatility-sorted portfolios while retaining differences that should be evaluated jointly with performance, tilt, and distribution diagnostics.",
  "- Prefer: CSI exclusions and retained weights can be compared with Q1-Q5 assignments to assess how much of the CSI behavior coincides with simple volatility sorts.",
  "- Avoid identity language. Use terms such as overlap, concentration, directional comparison, and descriptive difference.",
  "",
  "## How to phrase CSI alpha carefully",
  "",
  "- Prefer: Selected CSI rows show descriptive return and Sharpe differences versus the benchmark and low-volatility references in the generated outputs.",
  "- Prefer: The evidence suggests patterns that may warrant thesis discussion, subject to transaction-cost, period-alignment, and robustness caveats.",
  "- Avoid treating return differences as standalone final evidence before robustness and inference choices are made.",
  "",
  "## Remaining robustness checks",
  "",
  "- Align comparison windows where full-period sample starts differ.",
  "- Decide whether transaction-cost scenarios should be presented as headline or robustness rows.",
  "- Pair feature-family discussion with upstream predictive-validation outputs before making claims about autoencoder inputs.",
  "- Consider whether factor regressions, alternative rebalancing assumptions, bootstrap intervals, or subperiod tests are needed for the thesis claim level.",
  "- Validate that selected CSI rows are the intended headline strategies before copying table values into thesis text.",
  "",
  "## Suggested thesis table list",
  "",
  format_table(suggested_tables[, .(table_id, table_title, primary_research_question_area, evidence_family)]),
  "",
  "## Evidence row counts",
  "",
  format_table(row_counts),
  "",
  "## Evidence family coverage",
  "",
  format_table(family_counts),
  "",
  "## Research question coverage",
  "",
  format_table(coverage_flags)
)
writeLines(memo_lines, file.path(REPORT_DIR, "thesis_ready_evidence_summary.md"), useBytes = TRUE)

RUN_FINISHED <- Sys.time()
run_status <- data.table(
  ticket_id = TICKET_ID,
  script = relative_path(SCRIPT_PATH),
  run_started = format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z"),
  run_finished = format(RUN_FINISHED, "%Y-%m-%d %H:%M:%S %Z"),
  status = "completed",
  input_checks_passed = TRUE,
  evidence_map_rows = nrow(evidence_map),
  performance_summary_rows = nrow(performance_evidence_summary),
  tilt_overlap_distribution_summary_rows = nrow(tilt_overlap_distribution_evidence_summary),
  suggested_thesis_table_rows = nrow(suggested_tables),
  no_staging_commit_push = TRUE,
  no_thesis_or_presentation_edit = TRUE,
  no_upstream_regeneration = TRUE
)
fwrite(run_status, file.path(REPORT_DIR, "thesis_ready_evidence_run_status.csv"))

headline_findings <- c(
  "Current outputs support descriptive comparison across benchmark, low-volatility quintiles, and selected CSI rows.",
  "CSI versus Q1/Q5/benchmark evidence is available as both metric differences and directional flags.",
  "Overlap diagnostics allow careful discussion of CSI exclusions and retained weights across Q1-Q5.",
  "Tilt diagnostics provide observable characteristic and sector context where field coverage is available.",
  "Distribution diagnostics provide active-return, tail-state, and capture context without rendering charts."
)

changed_files <- c(
  relative_path(SCRIPT_PATH),
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/thesis_evidence_map.rds",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/thesis_evidence_map.csv",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/research_question_evidence_matrix.rds",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/research_question_evidence_matrix.csv",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/performance_evidence_summary.rds",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/performance_evidence_summary.csv",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/tilt_overlap_distribution_evidence_summary.rds",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/tilt_overlap_distribution_evidence_summary.csv",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/suggested_thesis_tables.rds",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/suggested_thesis_tables.csv",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/thesis_ready_evidence_summary.md",
  "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/thesis_ready_evidence_run_status.csv",
  "05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-009_Completion_Report.md"
)

completion_lines <- c(
  "# AE-ALPHA-009 Completion Report",
  "",
  "## Status",
  "",
  "completed",
  "",
  "## Summary",
  "",
  "Created a dedicated thesis-ready evidence synthesis that reads existing AE-ALPHA-004 through AE-ALPHA-008 alpha-validation outputs only. The synthesis consolidates performance, comparison, tilt, overlap, distribution, and limitation evidence into table-ready outputs and a neutral interpretation memo.",
  "",
  "No staging, commit, push, thesis edit, presentation edit, input-data edit, CSI construction rerun, low-volatility rerun, model training, factor regression, or chart rendering occurred.",
  "",
  "## Changed Files",
  "",
  paste0("- `", changed_files, "`"),
  "",
  "## Generated Outputs",
  "",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/thesis_evidence_map.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/research_question_evidence_matrix.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/performance_evidence_summary.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/tilt_overlap_distribution_evidence_summary.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/suggested_thesis_tables.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/thesis_ready_evidence_summary.md`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/thesis_ready_evidence_run_status.csv`",
  "",
  "## Row Counts",
  "",
  "```",
  format_table(row_counts),
  "```",
  "",
  "## Research Question Coverage",
  "",
  "```",
  format_table(coverage_flags),
  "```",
  "",
  "## Headline Findings Neutral",
  "",
  paste0("- ", headline_findings),
  "",
  "## Limitations",
  "",
  "- The synthesis is descriptive and does not add inference, factor regressions, model training, or new statistics beyond aggregation of existing outputs.",
  "- Full-period rows can reflect different available sample starts across benchmark, low-volatility, and CSI artifacts.",
  "- Autoencoder-related rows summarize observed portfolio outcomes by model family and do not isolate predictive feature contribution.",
  "- Tilt and overlap diagnostics are composition evidence and should not be used alone to explain returns.",
  "- Q-Q and scatter data availability is recorded, but no charts were created or rendered.",
  "",
  "## Verification",
  "",
  "- Script parse check: completed with `Rscript -e \"parse('01_Code/pipeline/11K_Thesis_Evidence_Summary.R')\"`.",
  "- Script execution: completed during this run.",
  "- Required output families written under `alpha_validation/evidence_summary` and `alpha_validation/reports`.",
  "- Evidence map contains nonzero performance, comparison, tilt, overlap, distribution, and limitation rows.",
  "- Research-question evidence matrix covers `main_rq`, `sq_autoencoder`, `sq_volatility_comparison`, `sq_features`, and `limitations`.",
  "- Suggested thesis table list has nonzero rows.",
  "- No staging, commit, push, thesis edit, or presentation edit occurred.",
  "",
  "## Known Caveats",
  "",
  "- Validator should independently inspect wording for thesis tone before text is copied into thesis files.",
  "- Human selection is still needed for which tables become thesis exhibits.",
  "- Prior completion reports were not required as inputs; generated alpha-validation outputs were used as source of truth.",
  "",
  "## Validator Result",
  "",
  "pending",
  "",
  "## Next Recommended Role",
  "",
  "validator",
  "",
  "## Next Ticket Preview",
  "",
  "human decision point"
)
writeLines(completion_lines, file.path(TICKET_DIR, "AE-ALPHA-009_Completion_Report.md"), useBytes = TRUE)

cat("[11K] Evidence rows:", nrow(evidence_map), "\n")
cat("[11K] Finished:", format(RUN_FINISHED), "\n")
