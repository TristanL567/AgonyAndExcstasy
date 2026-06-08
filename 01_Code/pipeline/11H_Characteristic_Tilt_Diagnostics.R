#==============================================================================#
#==== 11H_Characteristic_Tilt_Diagnostics.R ===================================#
#==== AE-ALPHA-006: Observable Characteristic Tilt Diagnostics =================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[11H_Characteristic_Tilt_Diagnostics.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()

fn_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg)) {
    return(normalizePath(sub("^--file=", "", file_arg[[1L]]), mustWork = FALSE))
  }
  normalizePath("01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R", mustWork = FALSE)
}

SCRIPT_PATH <- fn_script_path()
PIPELINE_DIR <- dirname(SCRIPT_PATH)
ROOT_DIR <- normalizePath(file.path(PIPELINE_DIR, "..", ".."), mustWork = TRUE)

path_root <- function(...) file.path(ROOT_DIR, ...)

ALPHA_DIR <- path_root("03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation")
TILT_DIR <- file.path(ALPHA_DIR, "tilt_diagnostics")
REPORT_DIR <- file.path(ALPHA_DIR, "reports")
TICKET_DIR <- path_root(
  "05_Documentation", "09_Epics", "AE-ALPHA_LowVol_Tilt_Independence", "Tickets"
)
dir.create(TILT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TICKET_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_LOWVOL_WEIGHTS <- file.path(ALPHA_DIR, "weights", "lowvol_target_weights.rds")
PATH_LOWVOL_QUINTILES <- file.path(ALPHA_DIR, "volatility_quintiles", "lowvol_volatility_quintiles.rds")
PATH_CSI_PERF <- file.path(ALPHA_DIR, "performance", "csi_performance_extract.rds")
PATH_PRICES_MONTHLY <- path_root("02_Data_Input", "01_CRSP", "Necessary", "prices_monthly.rds")

OUT_FIELD_MANIFEST <- file.path(TILT_DIR, "characteristic_field_manifest")
OUT_CHAR_SUMMARY <- file.path(TILT_DIR, "portfolio_characteristic_summary")
OUT_CHAR_DIFF <- file.path(TILT_DIR, "portfolio_characteristic_differences")
OUT_SECTOR_SUMMARY <- file.path(TILT_DIR, "sector_weight_summary")
OUT_SECTOR_ACTIVE <- file.path(TILT_DIR, "sector_active_weight_summary")
OUT_REPORT <- file.path(REPORT_DIR, "characteristic_tilt_diagnostics_report.md")
OUT_STATUS <- file.path(REPORT_DIR, "tilt_diagnostics_run_status.csv")
OUT_COMPLETION <- file.path(TICKET_DIR, "AE-ALPHA-006_Completion_Report.md")

required_inputs <- c(
  PATH_LOWVOL_WEIGHTS,
  PATH_LOWVOL_QUINTILES,
  PATH_CSI_PERF,
  PATH_PRICES_MONTHLY
)
missing_inputs <- required_inputs[!file.exists(required_inputs)]
if (length(missing_inputs)) {
  stop("Missing required input(s):\n", paste(missing_inputs, collapse = "\n"))
}

write_pair <- function(dt, stem) {
  saveRDS(dt, paste0(stem, ".rds"))
  fwrite(dt, paste0(stem, ".csv"))
}

available_cols <- function(dt, cols) intersect(cols, names(dt))

weighted_median <- function(x, w) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  x <- x[ok]
  w <- w[ok]
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  x[which(cumsum(w) >= sum(w) / 2)[1L]]
}

sector_from_sic <- function(sic) {
  sic_num <- suppressWarnings(as.integer(sic))
  sic2 <- floor(sic_num / 100)
  fifelse(is.na(sic2), "Unknown",
    fifelse(sic2 >= 1 & sic2 <= 9, "Agriculture, Forestry, Fishing",
      fifelse(sic2 >= 10 & sic2 <= 14, "Mining",
        fifelse(sic2 >= 15 & sic2 <= 17, "Construction",
          fifelse(sic2 >= 20 & sic2 <= 39, "Manufacturing",
            fifelse(sic2 >= 40 & sic2 <= 49, "Transportation/Utilities",
              fifelse(sic2 >= 50 & sic2 <= 51, "Wholesale Trade",
                fifelse(sic2 >= 52 & sic2 <= 59, "Retail Trade",
                  fifelse(sic2 >= 60 & sic2 <= 67, "Finance/Insurance/Real Estate",
                    fifelse(sic2 >= 70 & sic2 <= 89, "Services",
                      fifelse(sic2 >= 91 & sic2 <= 99, "Public Administration", "Other")
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
}

normalize_track <- function(x) fifelse(x == "temporary_csi", "dynamic_csi", x)
track_folder <- function(x) fifelse(x == "dynamic_csi", "temporary_csi", x)

expand_to_csi_tracks <- function(dt) {
  rbindlist(lapply(c("dynamic_csi", "permanent_csi"), function(rt) {
    copy_dt <- copy(dt)
    copy_dt[, response_track := rt]
    copy_dt
  }), fill = TRUE)
}

feature_candidates <- list(
  volatility = c("vol_12m", "vol_60m", "trailing_volatility"),
  size = c("log_mkvalt", "log_at", "security_mktcap"),
  sector = c("siccd", "sich"),
  profitability_quality = c("roa", "roe", "roic", "gross_margin", "ebitda_margin", "ocf_margin"),
  leverage_solvency = c("leverage", "net_debt_ebitda", "interest_cov", "current_ratio", "quick_ratio"),
  altman_z = c("altman_z", "altman_z1", "altman_z2", "altman_z3", "altman_z4", "altman_z5"),
  market_value_deterioration = c("peak_drop_log_mkvalt", "consec_decline_log_mkvalt", "yoy_log_mkvalt"),
  liquidity = c("liquidity_dollar_volume", "liquidity_share_turnover")
)

base_feature_fields <- unique(unlist(feature_candidates))
base_feature_fields <- setdiff(base_feature_fields, c("security_mktcap", "liquidity_dollar_volume", "liquidity_share_turnover"))

read_feature_track <- function(response_track) {
  response_track_value <- response_track
  folder <- track_folder(response_track)
  path <- path_root("02_Data_Input", "05_PipelineResults", "Necessary", folder, "Features", "features_raw.rds")
  if (!file.exists(path)) return(NULL)
  dt <- as.data.table(readRDS(path))
  cols <- unique(c("permno", "year", "fyear", "response_track", available_cols(dt, base_feature_fields)))
  dt <- dt[, ..cols]
  if (!"year" %in% names(dt) && "fyear" %in% names(dt)) setnames(dt, "fyear", "year")
  dt[, response_track := response_track_value]
  dt[, feature_year := as.integer(year)]
  dt[, sector_group := if ("siccd" %in% names(dt)) sector_from_sic(siccd) else "Unknown"]
  unique(dt, by = c("response_track", "permno", "feature_year"))
}

cat("[11H] Loading features and liquidity proxies...\n")
features <- rbindlist(lapply(c("dynamic_csi", "permanent_csi"), read_feature_track), fill = TRUE)
if (!nrow(features)) stop("No annual feature rows were available.")

prices <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
price_cols <- available_cols(prices, c("permno", "date", "price", "vol", "shrout"))
prices <- prices[, ..price_cols]
if (all(c("permno", "date") %in% names(prices))) {
  prices[, price_year := year(as.Date(date))]
  if (all(c("price", "vol") %in% names(prices))) {
    prices[, liquidity_dollar_volume := abs(as.numeric(price)) * as.numeric(vol)]
  }
  if (all(c("vol", "shrout") %in% names(prices))) {
    prices[, liquidity_share_turnover := fifelse(as.numeric(shrout) > 0, as.numeric(vol) / as.numeric(shrout), NA_real_)]
  }
  liq_cols <- available_cols(prices, c("liquidity_dollar_volume", "liquidity_share_turnover"))
  if (length(liq_cols)) {
    liquidity <- prices[, lapply(.SD, function(x) mean(x, na.rm = TRUE)),
      by = .(permno, feature_year = price_year), .SDcols = liq_cols
    ]
    for (col in liq_cols) liquidity[is.nan(get(col)), (col) := NA_real_]
    features <- merge(features, liquidity, by = c("permno", "feature_year"), all.x = TRUE)
  }
}
rm(prices)
gc()

available_feature_fields <- available_cols(features, unique(unlist(feature_candidates)))
available_feature_fields <- unique(c(available_feature_fields, "security_mktcap"))
manifest <- rbindlist(lapply(names(feature_candidates), function(family) {
  fields <- feature_candidates[[family]]
  data.table(
    diagnostic_family = family,
    field = fields,
    status = fifelse(fields %in% available_feature_fields, "included", "missing"),
    source = fifelse(fields %in% c("liquidity_dollar_volume", "liquidity_share_turnover"),
      "prices_monthly trailing prior-year proxy",
      fifelse(fields == "security_mktcap", "portfolio weights", "annual features aligned to holding_year - 1")
    )
  )
}))

cat("[11H] Loading low-volatility benchmark, Q1, and Q5 weights...\n")
lowvol <- as.data.table(readRDS(PATH_LOWVOL_WEIGHTS))
lowvol[, response_track := normalize_track(track)]
lowvol[, period := "full"]
lowvol[, transaction_cost_bps := NA_real_]
lowvol[, model_key := "lowvol"]
lowvol[, strategy_id := fifelse(quintile_num == 1L, "Q1", fifelse(quintile_num == 5L, "Q5", NA_character_))]
lowvol[, portfolio_group := strategy_id]
q_weights <- lowvol[quintile_num %in% c(1L, 5L), .(
  period, index_id, index_name, response_track, transaction_cost_bps,
  model_key, strategy_id, portfolio_group, qdate, q_year, q_month, holding_year,
  permno, permco, size_segment, security_mktcap, w
)]
q_weights <- expand_to_csi_tracks(q_weights)

quintiles <- as.data.table(readRDS(PATH_LOWVOL_QUINTILES))
quintiles[, response_track := normalize_track(track)]
quintiles[, period := "full"]
quintiles[, transaction_cost_bps := NA_real_]
quintiles[, model_key := "benchmark"]
quintiles[, strategy_id := "benchmark"]
quintiles[, portfolio_group := "benchmark"]
bench_weights <- unique(quintiles[, .(
  period, index_id, index_name, response_track, transaction_cost_bps,
  model_key, strategy_id, portfolio_group, qdate, q_year, q_month, holding_year,
  permno, permco, size_segment, security_mktcap, w = benchmark_weight
)])
bench_weights <- expand_to_csi_tracks(bench_weights)
rm(lowvol, quintiles)
gc()

cat("[11H] Selecting CSI headline/best strategy weights from existing outputs...\n")
csi_perf <- as.data.table(readRDS(PATH_CSI_PERF))
csi_selected <- csi_perf[
  period == "full" &
    (isTRUE(is_best_by_track_index_cost) | isTRUE(is_headline_20bps) |
       is_best_by_track_index_cost == TRUE | is_headline_20bps == TRUE)
]
if ("transaction_cost_bps" %in% names(csi_selected)) {
  csi_selected <- csi_selected[transaction_cost_bps %in% c(20, 0)]
}
if (!nrow(csi_selected)) {
  csi_selected <- csi_perf[period == "full" & is_best_by_track_index_cost == TRUE]
}
csi_selected[, weights_path := file.path(dirname(source_path), "index_weights_by_crsp_universe.rds")]
csi_selected <- csi_selected[file.exists(weights_path)]
if (!nrow(csi_selected)) {
  warning("No selected CSI strategy rows mapped to available weight files.")
}

csi_key_cols <- c(
  "period", "track", "response_track", "index_id", "transaction_cost_bps",
  "analysis_model", "model_key", "threshold_method", "threshold_label",
  "lockout_years", "strategy_id", "exclusion_rule", "rule_label", "weights_path"
)
csi_selected <- unique(csi_selected[, ..csi_key_cols])

read_csi_weights <- function(path, selected_keys) {
  dt <- as.data.table(readRDS(path))
  dt[, weights_path := path]
  merge_cols <- intersect(c(
    "track", "index_id", "model_key", "threshold_method", "threshold_label",
    "lockout_years", "strategy_id", "exclusion_rule", "rule_label", "weights_path"
  ), names(dt))
  keep_keys <- unique(selected_keys[, ..merge_cols])
  dt <- merge(dt, keep_keys, by = merge_cols, all = FALSE)
  dt[, response_track := normalize_track(track)]
  meta <- unique(selected_keys[, .(
    response_track, index_id, transaction_cost_bps, model_key, strategy_id,
    period, analysis_model, threshold_method, threshold_label, lockout_years,
    exclusion_rule, rule_label, weights_path
  )])
  dt <- merge(dt, meta,
    by = c("response_track", "index_id", "model_key", "strategy_id",
      "threshold_method", "threshold_label", "lockout_years", "exclusion_rule",
      "rule_label", "weights_path"),
    allow.cartesian = TRUE
  )
  dt[, portfolio_group := "CSI headline/best"]
  dt[, .(
    period, index_id, index_name, response_track, transaction_cost_bps,
    model_key, strategy_id, portfolio_group, qdate, q_year, q_month, holding_year,
    permno, permco, size_segment, security_mktcap, w
  )]
}

csi_weights <- if (nrow(csi_selected)) {
  rbindlist(lapply(unique(csi_selected$weights_path), function(path) {
    read_csi_weights(path, csi_selected[weights_path == path])
  }), fill = TRUE)
} else {
  data.table()
}
rm(csi_perf, csi_selected)
gc()

weights <- rbindlist(list(bench_weights, q_weights, csi_weights), fill = TRUE)
weights <- weights[is.finite(w) & w > 0 & !is.na(permno)]
weights[, feature_year := as.integer(holding_year) - 1L]
weights[, qdate := as.Date(qdate)]
weights[, holding_period := format(qdate, "%Y-%m-%d")]
weights[, weight_total := sum(w), by = .(
  period, index_id, response_track, transaction_cost_bps, model_key, strategy_id,
  portfolio_group, qdate
)]
weights[weight_total > 0, w_norm := w / weight_total]

cat("[11H] Joining prior-year features and computing diagnostics...\n")
joined <- merge(
  weights,
  features,
  by = c("response_track", "permno", "feature_year"),
  all.x = TRUE,
  allow.cartesian = TRUE
)
joined[, security_mktcap := as.numeric(security_mktcap)]

id_cols <- c(
  "period", "index_id", "index_name", "response_track", "transaction_cost_bps",
  "model_key", "strategy_id", "portfolio_group", "qdate", "holding_period",
  "holding_year", "feature_year"
)

numeric_fields <- setdiff(available_cols(joined, unique(unlist(feature_candidates))), c("siccd", "sich"))
numeric_fields <- numeric_fields[vapply(joined[, ..numeric_fields], is.numeric, logical(1L))]

long <- melt(
  joined,
  id.vars = c(id_cols, "permno", "w_norm"),
  measure.vars = numeric_fields,
  variable.name = "characteristic",
  value.name = "value",
  variable.factor = FALSE
)
long <- merge(
  long,
  manifest[status == "included", .(diagnostic_family, characteristic = field)],
  by = "characteristic",
  all.x = TRUE
)
long[is.na(diagnostic_family), diagnostic_family := "other"]

char_summary <- long[, .(
  weighted_mean = if (sum(w_norm[is.finite(value)], na.rm = TRUE) > 0) {
    sum(w_norm * value, na.rm = TRUE) / sum(w_norm[is.finite(value)], na.rm = TRUE)
  } else NA_real_,
  weighted_median = weighted_median(value, w_norm),
  n_holdings = uniqueN(permno),
  n_nonmissing = uniqueN(permno[is.finite(value)]),
  weight_coverage = sum(w_norm[is.finite(value)], na.rm = TRUE),
  total_weight = sum(w_norm, na.rm = TRUE)
), by = c(id_cols, "diagnostic_family", "characteristic")]

diff_bases <- char_summary[portfolio_group %in% c("benchmark", "Q1", "Q5"), .(
  period, index_id, response_track, qdate, holding_period, diagnostic_family,
  characteristic, base_group = portfolio_group, base_weighted_mean = weighted_mean
)]
char_diffs <- merge(
  char_summary,
  diff_bases,
  by = c("period", "index_id", "response_track", "qdate", "holding_period", "diagnostic_family", "characteristic"),
  allow.cartesian = TRUE
)
char_diffs <- char_diffs[portfolio_group != base_group]
char_diffs[, difference_weighted_mean := weighted_mean - base_weighted_mean]
char_diffs <- char_diffs[, .(
  period, index_id, index_name, response_track, transaction_cost_bps,
  model_key, strategy_id, portfolio_group, qdate, holding_period, holding_year,
  feature_year, diagnostic_family, characteristic, comparison_base = base_group,
  weighted_mean, base_weighted_mean, difference_weighted_mean,
  weighted_median, n_holdings, n_nonmissing, weight_coverage
)]

sector_available <- "sector_group" %in% names(joined)
if (sector_available) {
  sector_summary <- joined[, .(
    sector_weight = sum(w_norm, na.rm = TRUE),
    n_holdings = uniqueN(permno)
  ), by = c(id_cols, "sector_group")]
  bench_sector <- sector_summary[portfolio_group == "benchmark", .(
    period, index_id, response_track, qdate, holding_period, sector_group,
    benchmark_sector_weight = sector_weight
  )]
  sector_active <- merge(
    sector_summary,
    bench_sector,
    by = c("period", "index_id", "response_track", "qdate", "holding_period", "sector_group"),
    all.x = TRUE
  )
  sector_active[, active_sector_weight := sector_weight - benchmark_sector_weight]
} else {
  sector_summary <- data.table()
  sector_active <- data.table()
}

write_pair(manifest, OUT_FIELD_MANIFEST)
write_pair(char_summary, OUT_CHAR_SUMMARY)
write_pair(char_diffs, OUT_CHAR_DIFF)
write_pair(sector_summary, OUT_SECTOR_SUMMARY)
write_pair(sector_active, OUT_SECTOR_ACTIVE)

included_fields <- manifest[status == "included", paste(field, collapse = ", "), by = diagnostic_family]
missing_fields <- manifest[status == "missing", paste(field, collapse = ", "), by = diagnostic_family]
coverage <- char_summary[, .(
  median_weight_coverage = median(weight_coverage, na.rm = TRUE),
  min_weight_coverage = min(weight_coverage, na.rm = TRUE)
), by = .(portfolio_group, diagnostic_family)]
headline <- char_diffs[
  portfolio_group == "CSI headline/best" & comparison_base %in% c("benchmark", "Q1", "Q5"),
  .(
    median_difference_weighted_mean = median(difference_weighted_mean, na.rm = TRUE),
    n_period_characteristics = .N
  ),
  by = .(comparison_base, diagnostic_family)
]

report_lines <- c(
  "# Characteristic Tilt Diagnostics Report",
  "",
  paste0("Run timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Scope",
  "",
  "This diagnostic compares observable weighted-average firm characteristics for the market benchmark, low-volatility Q1, high-volatility Q5, and selected CSI headline/best strategies. It uses existing portfolio weights and existing feature inputs only. It does not rerun CSI construction, rerun low-volatility construction, train models, or create charts.",
  "",
  "Feature alignment is no-look-ahead: holdings in year Y are matched to annual features from Y-1. Liquidity proxies are computed from monthly CRSP price data by prior calendar year.",
  "",
  "## Rows Written",
  "",
  paste0("- characteristic_field_manifest: ", nrow(manifest)),
  paste0("- portfolio_characteristic_summary: ", nrow(char_summary)),
  paste0("- portfolio_characteristic_differences: ", nrow(char_diffs)),
  paste0("- sector_weight_summary: ", nrow(sector_summary)),
  paste0("- sector_active_weight_summary: ", nrow(sector_active)),
  "",
  "## Included Fields",
  "",
  if (nrow(included_fields)) paste0("- ", included_fields$diagnostic_family, ": ", included_fields$V1) else "- None",
  "",
  "## Missing Fields",
  "",
  if (nrow(missing_fields)) paste0("- ", missing_fields$diagnostic_family, ": ", missing_fields$V1) else "- None recorded",
  "",
  "## Coverage Notes",
  "",
  paste0("- ", coverage$portfolio_group, " / ", coverage$diagnostic_family,
    ": median weight coverage ", round(coverage$median_weight_coverage, 4),
    ", minimum ", round(coverage$min_weight_coverage, 4)),
  "",
  "## Neutral Headline Observations",
  "",
  if (nrow(headline)) {
    paste0("- CSI headline/best versus ", headline$comparison_base, " / ",
      headline$diagnostic_family, ": median weighted-mean difference ",
      signif(headline$median_difference_weighted_mean, 4),
      " across ", headline$n_period_characteristics, " period-characteristic rows.")
  } else {
    "- CSI headline/best comparison rows were not available in the generated differences."
  },
  "",
  "These rows describe higher or lower weighted average exposures in the available data. They are diagnostic summaries and do not establish final or causal conclusions.",
  "",
  "## Sector Diagnostics",
  "",
  if (nrow(sector_summary)) {
    "Sector diagnostics were produced from SIC-derived sector groups."
  } else {
    "Sector diagnostics were unavailable because no SIC-derived sector field could be aligned."
  }
)
writeLines(report_lines, OUT_REPORT)

status <- data.table(
  ticket_id = "AE-ALPHA-006",
  status = "completed",
  run_started = format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z"),
  run_finished = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
  script = SCRIPT_PATH,
  characteristic_summary_rows = nrow(char_summary),
  characteristic_difference_rows = nrow(char_diffs),
  sector_summary_rows = nrow(sector_summary),
  sector_active_rows = nrow(sector_active),
  included_field_count = manifest[status == "included", .N],
  missing_field_count = manifest[status == "missing", .N],
  no_lookahead_alignment = "holding_year minus 1",
  csi_construction_rerun = FALSE,
  lowvol_construction_rerun = FALSE,
  models_trained = FALSE,
  charts_created = FALSE
)
fwrite(status, OUT_STATUS)

completion_lines <- c(
  "# AE-ALPHA-006 Completion Report",
  "",
  "status: completed",
  "",
  "summary:",
  "- Created `01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R`.",
  "- Produced observable characteristic and sector diagnostics for benchmark, Q1, Q5, and selected CSI headline/best strategies.",
  "- Used no-look-ahead alignment by matching holding year Y to feature year Y-1.",
  "- Did not rerun CSI construction, rerun low-volatility construction, train models, create charts, stage, commit, push, or edit thesis/presentation files.",
  "",
  "changed_files:",
  "- `01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R`",
  "- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-006_Completion_Report.md`",
  "",
  "generated_outputs:",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/characteristic_field_manifest.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/portfolio_characteristic_summary.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/portfolio_characteristic_differences.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/sector_weight_summary.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/sector_active_weight_summary.{rds,csv}`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/characteristic_tilt_diagnostics_report.md`",
  "- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/tilt_diagnostics_run_status.csv`",
  "",
  "row_counts:",
  paste0("- characteristic_field_manifest: ", nrow(manifest)),
  paste0("- portfolio_characteristic_summary: ", nrow(char_summary)),
  paste0("- portfolio_characteristic_differences: ", nrow(char_diffs)),
  paste0("- sector_weight_summary: ", nrow(sector_summary)),
  paste0("- sector_active_weight_summary: ", nrow(sector_active)),
  "",
  "fields_included:",
  if (nrow(included_fields)) paste0("- ", included_fields$diagnostic_family, ": ", included_fields$V1) else "- None",
  "",
  "fields_missing:",
  if (nrow(missing_fields)) paste0("- ", missing_fields$diagnostic_family, ": ", missing_fields$V1) else "- None recorded",
  "",
  "coverage_notes:",
  paste0("- ", coverage$portfolio_group, " / ", coverage$diagnostic_family,
    ": median weight coverage ", round(coverage$median_weight_coverage, 4),
    ", minimum ", round(coverage$min_weight_coverage, 4)),
  "",
  "headline_findings_neutral:",
  if (nrow(headline)) {
    paste0("- CSI headline/best versus ", headline$comparison_base, " / ",
      headline$diagnostic_family, ": median weighted-mean difference ",
      signif(headline$median_difference_weighted_mean, 4),
      ".")
  } else {
    "- CSI headline/best difference rows were unavailable."
  },
  "",
  "verification:",
  "- Worker ran parse and execution checks after implementation; see final worker envelope for exact command results.",
  "",
  "known_caveats:",
  "- The requested AE-ALPHA-005 completion report was not present at the expected path during worker inspection.",
  "- CSI diagnostics are limited to selected headline/best strategies available from the existing alpha-validation performance extract.",
  "- Liquidity is a prior-year monthly proxy based on available CRSP `vol`, `shrout`, and price fields.",
  "",
  "validator_result: pending",
  "",
  "next_recommended_role: validator"
)
writeLines(completion_lines, OUT_COMPLETION)

cat("[11H] COMPLETE:", format(Sys.time()), "\n")
