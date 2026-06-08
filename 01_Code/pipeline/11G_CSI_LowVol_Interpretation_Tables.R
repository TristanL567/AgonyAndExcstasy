#==============================================================================#
#==== 11G_CSI_LowVol_Interpretation_Tables.R ==================================#
#==== Neutral Interpretation Tables for CSI and Low-Vol Comparisons ============#
#==============================================================================#
#
# PURPOSE:
#   Read existing AE-ALPHA comparison outputs and create neutral interpretation
#   tables indicating whether headline/best CSI rows are above or below low-
#   volatility Q1, the market benchmark, and high-volatility Q5 on common
#   performance metrics. This script summarizes patterns only; it does not rerun
#   CSI construction, low-volatility construction, or model training.
#
# OUTPUTS:
#   03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/
#     csi_lowvol_metric_flags.{rds,csv}
#     csi_lowvol_summary_by_track_universe.{rds,csv}
#     csi_lowvol_summary_by_period_cost.{rds,csv}
#     lowvol_anomaly_summary.{rds,csv}
#   03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/
#     csi_lowvol_interpretation_report.md
#     interpretation_run_status.csv
#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
})

cat("\n[11G_CSI_LowVol_Interpretation_Tables.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()
SCRIPT_PATH <- normalizePath("01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R", mustWork = FALSE)

ROOT_DIR <- normalizePath(".", mustWork = TRUE)
ALPHA_ROOT <- file.path(
  ROOT_DIR,
  "03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation"
)
COMPARISON_DIR <- file.path(ALPHA_ROOT, "comparisons")
REPORT_DIR <- file.path(ALPHA_ROOT, "reports")
dir.create(COMPARISON_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_CSI_VS_LOWVOL <- file.path(COMPARISON_DIR, "csi_vs_lowvol_headline.rds")
PATH_BENCH_VS_LOWVOL <- file.path(COMPARISON_DIR, "benchmark_vs_lowvol_quintiles.rds")
PATH_Q1_Q5_SPREAD <- file.path(COMPARISON_DIR, "lowvol_q1_minus_q5_spread.rds")

PATH_FLAGS_RDS <- file.path(COMPARISON_DIR, "csi_lowvol_metric_flags.rds")
PATH_FLAGS_CSV <- file.path(COMPARISON_DIR, "csi_lowvol_metric_flags.csv")
PATH_SUMMARY_TRACK_RDS <- file.path(COMPARISON_DIR, "csi_lowvol_summary_by_track_universe.rds")
PATH_SUMMARY_TRACK_CSV <- file.path(COMPARISON_DIR, "csi_lowvol_summary_by_track_universe.csv")
PATH_SUMMARY_PERIOD_COST_RDS <- file.path(COMPARISON_DIR, "csi_lowvol_summary_by_period_cost.rds")
PATH_SUMMARY_PERIOD_COST_CSV <- file.path(COMPARISON_DIR, "csi_lowvol_summary_by_period_cost.csv")
PATH_LOWVOL_ANOMALY_RDS <- file.path(COMPARISON_DIR, "lowvol_anomaly_summary.rds")
PATH_LOWVOL_ANOMALY_CSV <- file.path(COMPARISON_DIR, "lowvol_anomaly_summary.csv")
PATH_REPORT <- file.path(REPORT_DIR, "csi_lowvol_interpretation_report.md")
PATH_STATUS <- file.path(REPORT_DIR, "interpretation_run_status.csv")

fn_stop_missing <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0L) {
    stop("Missing required inputs:\n", paste(missing, collapse = "\n"))
  }
}

fn_require_cols <- function(dt, cols, object_name) {
  missing <- setdiff(cols, names(dt))
  if (length(missing) > 0L) {
    stop(object_name, " is missing required columns: ", paste(missing, collapse = ", "))
  }
}

fn_share <- function(x) {
  if (length(x) == 0L) return(NA_real_)
  mean(x %in% TRUE, na.rm = TRUE)
}

fn_classify_csi <- function(beat_q1_return, beat_q1_sharpe,
                            beat_benchmark_return, beat_benchmark_sharpe) {
  fifelse(
    beat_q1_return & beat_q1_sharpe,
    "beats_q1_on_return_and_sharpe",
    fifelse(
      beat_benchmark_return & beat_benchmark_sharpe & !(beat_q1_return & beat_q1_sharpe),
      "beats_benchmark_but_not_q1",
      fifelse(
        !beat_q1_return & !beat_q1_sharpe,
        "underperforms_q1",
        "mixed"
      )
    )
  )
}

fn_classify_lowvol <- function(left_label, return_flag, sharpe_flag, drawdown_flag, es_flag) {
  fifelse(
    return_flag & sharpe_flag,
    paste0(left_label, "_higher_return_and_sharpe"),
    fifelse(
      sharpe_flag & (drawdown_flag | es_flag) & !return_flag,
      paste0(left_label, "_risk_adjusted_or_tail_only"),
      fifelse(
        !return_flag & !sharpe_flag,
        paste0(left_label, "_lower_return_and_sharpe"),
        "mixed"
      )
    )
  )
}

fn_add_csi_comparison <- function(dt, comparator) {
  prefix <- paste0(comparator, "_")
  suffix <- switch(
    comparator,
    q1 = "q1",
    q5 = "q5",
    benchmark = "benchmark",
    stop("Unsupported comparator: ", comparator)
  )

  dt[, paste0("return_difference_csi_minus_", suffix) :=
    csi_annualized_geometric_return - get(paste0(prefix, "annualized_geometric_return"))]
  dt[, paste0("volatility_difference_csi_minus_", suffix) :=
    csi_annualized_volatility - get(paste0(prefix, "annualized_volatility"))]
  dt[, paste0("sharpe_difference_csi_minus_", suffix) :=
    csi_sharpe_ratio - get(paste0(prefix, "sharpe_ratio"))]
  dt[, paste0("max_drawdown_difference_csi_minus_", suffix) :=
    csi_max_drawdown - get(paste0(prefix, "max_drawdown"))]
  dt[, paste0("expected_shortfall_2p5_difference_csi_minus_", suffix) :=
    csi_expected_shortfall_2p5 - get(paste0(prefix, "expected_shortfall_2p5"))]

  dt[, paste0("csi_beats_", suffix, "_on_return") :=
    get(paste0("return_difference_csi_minus_", suffix)) > 0]
  dt[, paste0("csi_has_lower_volatility_than_", suffix) :=
    get(paste0("volatility_difference_csi_minus_", suffix)) < 0]
  dt[, paste0("csi_beats_", suffix, "_on_sharpe") :=
    get(paste0("sharpe_difference_csi_minus_", suffix)) > 0]
  dt[, paste0("csi_has_less_severe_drawdown_than_", suffix) :=
    get(paste0("max_drawdown_difference_csi_minus_", suffix)) > 0]
  dt[, paste0("csi_has_less_severe_es_2p5_than_", suffix) :=
    get(paste0("expected_shortfall_2p5_difference_csi_minus_", suffix)) > 0]
  dt[, paste0("csi_beats_", suffix, "_on_return_and_sharpe") :=
    get(paste0("csi_beats_", suffix, "_on_return")) &
      get(paste0("csi_beats_", suffix, "_on_sharpe"))]

  invisible(dt)
}

fn_csi_summary <- function(dt, by_cols) {
  dt[, .(
    n_rows = .N,
    n_distinct_strategies = uniqueN(strategy_id),
    n_beats_q1_return_and_sharpe = sum(csi_beats_q1_on_return_and_sharpe, na.rm = TRUE),
    n_beats_benchmark_return_and_sharpe = sum(csi_beats_benchmark_on_return_and_sharpe, na.rm = TRUE),
    n_beats_q5_return_and_sharpe = sum(csi_beats_q5_on_return_and_sharpe, na.rm = TRUE),
    share_beats_q1_return_and_sharpe = fn_share(csi_beats_q1_on_return_and_sharpe),
    share_beats_benchmark_return_and_sharpe = fn_share(csi_beats_benchmark_on_return_and_sharpe),
    share_beats_q5_return_and_sharpe = fn_share(csi_beats_q5_on_return_and_sharpe),
    share_less_severe_drawdown_than_q1 = fn_share(csi_has_less_severe_drawdown_than_q1),
    share_less_severe_es_2p5_than_q1 = fn_share(csi_has_less_severe_es_2p5_than_q1),
    median_return_difference_csi_minus_q1 = median(return_difference_csi_minus_q1, na.rm = TRUE),
    median_sharpe_difference_csi_minus_q1 = median(sharpe_difference_csi_minus_q1, na.rm = TRUE),
    median_return_difference_csi_minus_benchmark = median(return_difference_csi_minus_benchmark, na.rm = TRUE),
    median_sharpe_difference_csi_minus_benchmark = median(sharpe_difference_csi_minus_benchmark, na.rm = TRUE),
    n_beats_q1_on_return_and_sharpe = sum(interpretation_class == "beats_q1_on_return_and_sharpe", na.rm = TRUE),
    n_beats_benchmark_but_not_q1 = sum(interpretation_class == "beats_benchmark_but_not_q1", na.rm = TRUE),
    n_underperforms_q1 = sum(interpretation_class == "underperforms_q1", na.rm = TRUE),
    n_mixed = sum(interpretation_class == "mixed", na.rm = TRUE)
  ), by = by_cols]
}

fn_add_lowvol_anomaly_flags <- function(dt, left_label, right_label) {
  left <- paste0(left_label, "_")
  right <- paste0(right_label, "_")
  out <- copy(dt)
  out[, comparison := paste0(toupper(left_label), " vs ", toupper(right_label))]
  out[, left_portfolio := toupper(left_label)]
  out[, right_portfolio := toupper(right_label)]
  out[, annualized_geometric_return_difference := get(paste0(left, "annualized_geometric_return")) -
    get(paste0(right, "annualized_geometric_return"))]
  out[, annualized_volatility_difference := get(paste0(left, "annualized_volatility")) -
    get(paste0(right, "annualized_volatility"))]
  out[, sharpe_ratio_difference := get(paste0(left, "sharpe_ratio")) -
    get(paste0(right, "sharpe_ratio"))]
  out[, max_drawdown_difference := get(paste0(left, "max_drawdown")) -
    get(paste0(right, "max_drawdown"))]
  out[, expected_shortfall_2p5_difference := get(paste0(left, "expected_shortfall_2p5")) -
    get(paste0(right, "expected_shortfall_2p5"))]
  out[, left_higher_return := annualized_geometric_return_difference > 0]
  out[, left_lower_volatility := annualized_volatility_difference < 0]
  out[, left_higher_sharpe := sharpe_ratio_difference > 0]
  out[, left_less_severe_drawdown := max_drawdown_difference > 0]
  out[, left_less_severe_es_2p5 := expected_shortfall_2p5_difference > 0]
  out[, pattern_class := fn_classify_lowvol(
    left_label,
    left_higher_return,
    left_higher_sharpe,
    left_less_severe_drawdown,
    left_less_severe_es_2p5
  )]
  out
}

fn_write_pair <- function(dt, rds_path, csv_path) {
  saveRDS(dt, rds_path)
  fwrite(dt, csv_path)
}

fn_stop_missing(c(PATH_CSI_VS_LOWVOL, PATH_BENCH_VS_LOWVOL, PATH_Q1_Q5_SPREAD))

csi_vs_lowvol <- as.data.table(readRDS(PATH_CSI_VS_LOWVOL))
benchmark_vs_lowvol <- as.data.table(readRDS(PATH_BENCH_VS_LOWVOL))
q1_q5_spread <- as.data.table(readRDS(PATH_Q1_Q5_SPREAD))

fn_require_cols(
  csi_vs_lowvol,
  c(
    "period", "index_id", "transaction_cost_bps", "response_track",
    "analysis_model", "headline_source", "strategy_id",
    "csi_annualized_geometric_return", "csi_annualized_volatility",
    "csi_sharpe_ratio", "csi_max_drawdown", "csi_expected_shortfall_2p5",
    "q1_annualized_geometric_return", "q1_annualized_volatility",
    "q1_sharpe_ratio", "q1_max_drawdown", "q1_expected_shortfall_2p5",
    "q5_annualized_geometric_return", "q5_annualized_volatility",
    "q5_sharpe_ratio", "q5_max_drawdown", "q5_expected_shortfall_2p5",
    "benchmark_annualized_geometric_return", "benchmark_annualized_volatility",
    "benchmark_sharpe_ratio", "benchmark_max_drawdown",
    "benchmark_expected_shortfall_2p5"
  ),
  "csi_vs_lowvol_headline"
)

fn_require_cols(
  benchmark_vs_lowvol,
  c(
    "period", "index_id", "quintile", "transaction_cost_bps",
    "lowvol_annualized_geometric_return", "lowvol_annualized_volatility",
    "lowvol_sharpe_ratio", "lowvol_max_drawdown",
    "lowvol_expected_shortfall_2p5",
    "benchmark_annualized_geometric_return",
    "benchmark_annualized_volatility", "benchmark_sharpe_ratio",
    "benchmark_max_drawdown", "benchmark_expected_shortfall_2p5"
  ),
  "benchmark_vs_lowvol_quintiles"
)

fn_require_cols(
  q1_q5_spread,
  c(
    "period", "index_id", "transaction_cost_bps",
    "q1_annualized_geometric_return", "q1_annualized_volatility",
    "q1_sharpe_ratio", "q1_max_drawdown", "q1_expected_shortfall_2p5",
    "q5_annualized_geometric_return", "q5_annualized_volatility",
    "q5_sharpe_ratio", "q5_max_drawdown", "q5_expected_shortfall_2p5"
  ),
  "lowvol_q1_minus_q5_spread"
)

metric_flags <- copy(csi_vs_lowvol)
fn_add_csi_comparison(metric_flags, "q1")
fn_add_csi_comparison(metric_flags, "benchmark")
fn_add_csi_comparison(metric_flags, "q5")

metric_flags[, interpretation_class := fn_classify_csi(
  csi_beats_q1_on_return,
  csi_beats_q1_on_sharpe,
  csi_beats_benchmark_on_return,
  csi_beats_benchmark_on_sharpe
)]

setorder(
  metric_flags,
  period, response_track, index_id, transaction_cost_bps,
  analysis_model, headline_source, strategy_id
)

summary_by_track_universe <- fn_csi_summary(
  metric_flags,
  c(
    "period", "response_track", "index_id", "transaction_cost_bps",
    "analysis_model", "headline_source"
  )
)
setorder(
  summary_by_track_universe,
  period, response_track, index_id, transaction_cost_bps, analysis_model, headline_source
)

summary_by_period_cost <- fn_csi_summary(
  metric_flags,
  c("period", "transaction_cost_bps", "headline_source")
)
setorder(summary_by_period_cost, period, transaction_cost_bps, headline_source)

q1_vs_benchmark <- benchmark_vs_lowvol[
  quintile == "Q1",
  .(
    period, index_id, transaction_cost_bps,
    q1_annualized_geometric_return = lowvol_annualized_geometric_return,
    q1_annualized_volatility = lowvol_annualized_volatility,
    q1_sharpe_ratio = lowvol_sharpe_ratio,
    q1_max_drawdown = lowvol_max_drawdown,
    q1_expected_shortfall_2p5 = lowvol_expected_shortfall_2p5,
    benchmark_annualized_geometric_return,
    benchmark_annualized_volatility,
    benchmark_sharpe_ratio,
    benchmark_max_drawdown,
    benchmark_expected_shortfall_2p5
  )
]
q1_vs_benchmark <- fn_add_lowvol_anomaly_flags(q1_vs_benchmark, "q1", "benchmark")

q1_vs_q5 <- fn_add_lowvol_anomaly_flags(q1_q5_spread, "q1", "q5")

q5_vs_benchmark <- benchmark_vs_lowvol[
  quintile == "Q5",
  .(
    period, index_id, transaction_cost_bps,
    q5_annualized_geometric_return = lowvol_annualized_geometric_return,
    q5_annualized_volatility = lowvol_annualized_volatility,
    q5_sharpe_ratio = lowvol_sharpe_ratio,
    q5_max_drawdown = lowvol_max_drawdown,
    q5_expected_shortfall_2p5 = lowvol_expected_shortfall_2p5,
    benchmark_annualized_geometric_return,
    benchmark_annualized_volatility,
    benchmark_sharpe_ratio,
    benchmark_max_drawdown,
    benchmark_expected_shortfall_2p5
  )
]
q5_vs_benchmark <- fn_add_lowvol_anomaly_flags(q5_vs_benchmark, "q5", "benchmark")

lowvol_anomaly_summary <- rbindlist(
  list(
    q1_vs_benchmark[, .(
      comparison, period, index_id, transaction_cost_bps,
      annualized_geometric_return_difference,
      annualized_volatility_difference,
      sharpe_ratio_difference,
      max_drawdown_difference,
      expected_shortfall_2p5_difference,
      left_higher_return,
      left_lower_volatility,
      left_higher_sharpe,
      left_less_severe_drawdown,
      left_less_severe_es_2p5,
      pattern_class
    )],
    q1_vs_q5[, .(
      comparison, period, index_id, transaction_cost_bps,
      annualized_geometric_return_difference,
      annualized_volatility_difference,
      sharpe_ratio_difference,
      max_drawdown_difference,
      expected_shortfall_2p5_difference,
      left_higher_return,
      left_lower_volatility,
      left_higher_sharpe,
      left_less_severe_drawdown,
      left_less_severe_es_2p5,
      pattern_class
    )],
    q5_vs_benchmark[, .(
      comparison, period, index_id, transaction_cost_bps,
      annualized_geometric_return_difference,
      annualized_volatility_difference,
      sharpe_ratio_difference,
      max_drawdown_difference,
      expected_shortfall_2p5_difference,
      left_higher_return,
      left_lower_volatility,
      left_higher_sharpe,
      left_less_severe_drawdown,
      left_less_severe_es_2p5,
      pattern_class
    )]
  ),
  use.names = TRUE
)
setorder(lowvol_anomaly_summary, comparison, period, index_id, transaction_cost_bps)

fn_write_pair(metric_flags, PATH_FLAGS_RDS, PATH_FLAGS_CSV)
fn_write_pair(summary_by_track_universe, PATH_SUMMARY_TRACK_RDS, PATH_SUMMARY_TRACK_CSV)
fn_write_pair(summary_by_period_cost, PATH_SUMMARY_PERIOD_COST_RDS, PATH_SUMMARY_PERIOD_COST_CSV)
fn_write_pair(lowvol_anomaly_summary, PATH_LOWVOL_ANOMALY_RDS, PATH_LOWVOL_ANOMALY_CSV)

csi_class_counts <- metric_flags[, .N, by = interpretation_class][order(interpretation_class)]
lowvol_class_counts <- lowvol_anomaly_summary[, .N, by = .(comparison, pattern_class)][order(comparison, pattern_class)]

report_lines <- c(
  "# CSI Low-Vol Interpretation Report",
  "",
  "## Scope",
  "",
  "This report summarizes existing comparison tables for AE-ALPHA-005. It reports directional patterns only and avoids thesis-level conclusions.",
  "",
  "Inputs read:",
  paste0("- `", normalizePath(PATH_CSI_VS_LOWVOL, winslash = "/", mustWork = FALSE), "`"),
  paste0("- `", normalizePath(PATH_BENCH_VS_LOWVOL, winslash = "/", mustWork = FALSE), "`"),
  paste0("- `", normalizePath(PATH_Q1_Q5_SPREAD, winslash = "/", mustWork = FALSE), "`"),
  "",
  "Outputs written:",
  paste0("- `", normalizePath(PATH_FLAGS_RDS, winslash = "/", mustWork = FALSE), "` and `.csv`"),
  paste0("- `", normalizePath(PATH_SUMMARY_TRACK_RDS, winslash = "/", mustWork = FALSE), "` and `.csv`"),
  paste0("- `", normalizePath(PATH_SUMMARY_PERIOD_COST_RDS, winslash = "/", mustWork = FALSE), "` and `.csv`"),
  paste0("- `", normalizePath(PATH_LOWVOL_ANOMALY_RDS, winslash = "/", mustWork = FALSE), "` and `.csv`"),
  "",
  "## CSI Classification Counts",
  "",
  "| interpretation_class | rows |",
  "|---|---:|",
  paste0("| ", csi_class_counts$interpretation_class, " | ", csi_class_counts$N, " |"),
  "",
  "## Low-Vol Pattern Counts",
  "",
  "| comparison | pattern_class | rows |",
  "|---|---|---:|",
  paste0("| ", lowvol_class_counts$comparison, " | ", lowvol_class_counts$pattern_class, " | ", lowvol_class_counts$N, " |"),
  "",
  "## Metric Direction Notes",
  "",
  "- Return and Sharpe flags are `TRUE` when the left-hand strategy has a higher value.",
  "- Volatility flags are `TRUE` when the left-hand strategy has a lower value.",
  "- Max drawdown and ES 2.5 percent are stored as negative values, so less severe drawdown or ES is represented by a higher numeric value.",
  "- Composite CSI labels use return and Sharpe only; drawdown and ES flags are available as separate diagnostic fields.",
  "",
  "## Neutral Reading Guide",
  "",
  "- `beats_q1_on_return_and_sharpe` identifies CSI rows above Q1 on both annualized geometric return and Sharpe.",
  "- `beats_benchmark_but_not_q1` identifies CSI rows above the benchmark on both annualized geometric return and Sharpe, without meeting the same two-metric condition against Q1.",
  "- `underperforms_q1` identifies CSI rows below Q1 on both annualized geometric return and Sharpe.",
  "- `mixed` captures rows where the return and Sharpe comparisons point in different directions or do not match the other labels.",
  "",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"))
)
writeLines(report_lines, PATH_REPORT)

status <- data.table(
  script = basename(SCRIPT_PATH),
  status = "completed",
  run_started = format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z"),
  run_finished = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
  csi_metric_flag_rows = nrow(metric_flags),
  summary_by_track_universe_rows = nrow(summary_by_track_universe),
  summary_by_period_cost_rows = nrow(summary_by_period_cost),
  lowvol_anomaly_summary_rows = nrow(lowvol_anomaly_summary),
  input_csi_vs_lowvol_rows = nrow(csi_vs_lowvol),
  input_benchmark_vs_lowvol_rows = nrow(benchmark_vs_lowvol),
  input_q1_q5_spread_rows = nrow(q1_q5_spread)
)
fwrite(status, PATH_STATUS)

cat("Metric flags rows:", nrow(metric_flags), "\n")
cat("Summary by track/universe rows:", nrow(summary_by_track_universe), "\n")
cat("Summary by period/cost rows:", nrow(summary_by_period_cost), "\n")
cat("Low-vol anomaly summary rows:", nrow(lowvol_anomaly_summary), "\n")
cat("[11G_CSI_LowVol_Interpretation_Tables.R] END:", format(Sys.time()), "\n\n")
