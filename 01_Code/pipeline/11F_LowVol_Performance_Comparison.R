#==============================================================================#
#==== 11F_LowVol_Performance_Comparison.R =====================================#
#==== Common Performance Metrics for Benchmark, CSI, and Low-Vol Quintiles =====#
#==============================================================================#
#
# PURPOSE:
#   Compute common performance metrics and neutral headline comparison tables for
#   the market benchmark, existing CSI strategies, and low-volatility quintile
#   portfolios. This script reads existing outputs only; it does not rebuild CSI
#   indices, low-volatility portfolios, or models.
#
# OUTPUTS:
#   03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/
#     lowvol_performance_summary.{rds,csv}
#     benchmark_performance_summary.{rds,csv}
#     csi_performance_extract.{rds,csv}
#   03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/
#     benchmark_vs_lowvol_quintiles.{rds,csv}
#     csi_vs_lowvol_headline.{rds,csv}
#     lowvol_q1_minus_q5_spread.{rds,csv}
#   03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/
#     performance_run_status.csv
#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
})

cat("\n[11F_LowVol_Performance_Comparison.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()
SCRIPT_PATH <- normalizePath("01_Code/pipeline/11F_LowVol_Performance_Comparison.R", mustWork = FALSE)

ROOT_DIR <- normalizePath(".", mustWork = TRUE)
ALPHA_ROOT <- file.path(
  ROOT_DIR,
  "03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation"
)
PERFORMANCE_DIR <- file.path(ALPHA_ROOT, "performance")
COMPARISON_DIR <- file.path(ALPHA_ROOT, "comparisons")
REPORT_DIR <- file.path(ALPHA_ROOT, "reports")
dir.create(PERFORMANCE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(COMPARISON_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_LOWVOL_RETURNS <- file.path(
  ALPHA_ROOT, "returns", "lowvol_monthly_returns_gross_net_by_tc.rds"
)
PATH_LOWVOL_TURNOVER <- file.path(
  ALPHA_ROOT, "turnover_costs", "lowvol_turnover_costs_by_month.rds"
)
PATH_BENCHMARK_RETURNS <- file.path(
  ROOT_DIR,
  "02_Data_Input", "04_Index_Replication", "Necessary",
  "crsp_like_index_returns_monthly.rds"
)
CSI_SUITE_ROOT <- file.path(
  ROOT_DIR, "03_Data_Output", "7_IndexConstructionValidation",
  "nonraw_index_suite"
)
PATH_CSI_BEST <- file.path(CSI_SUITE_ROOT, "comparison", "best_by_track_index_cost.csv")
PATH_CSI_HEADLINE_20BPS <- file.path(CSI_SUITE_ROOT, "final_tables", "headline_winners_20bps.csv")

PATH_LOWVOL_PERF_RDS <- file.path(PERFORMANCE_DIR, "lowvol_performance_summary.rds")
PATH_LOWVOL_PERF_CSV <- file.path(PERFORMANCE_DIR, "lowvol_performance_summary.csv")
PATH_BENCH_PERF_RDS <- file.path(PERFORMANCE_DIR, "benchmark_performance_summary.rds")
PATH_BENCH_PERF_CSV <- file.path(PERFORMANCE_DIR, "benchmark_performance_summary.csv")
PATH_CSI_EXTRACT_RDS <- file.path(PERFORMANCE_DIR, "csi_performance_extract.rds")
PATH_CSI_EXTRACT_CSV <- file.path(PERFORMANCE_DIR, "csi_performance_extract.csv")
PATH_BENCH_VS_LOWVOL_RDS <- file.path(COMPARISON_DIR, "benchmark_vs_lowvol_quintiles.rds")
PATH_BENCH_VS_LOWVOL_CSV <- file.path(COMPARISON_DIR, "benchmark_vs_lowvol_quintiles.csv")
PATH_CSI_VS_LOWVOL_RDS <- file.path(COMPARISON_DIR, "csi_vs_lowvol_headline.rds")
PATH_CSI_VS_LOWVOL_CSV <- file.path(COMPARISON_DIR, "csi_vs_lowvol_headline.csv")
PATH_Q1_Q5_SPREAD_RDS <- file.path(COMPARISON_DIR, "lowvol_q1_minus_q5_spread.rds")
PATH_Q1_Q5_SPREAD_CSV <- file.path(COMPARISON_DIR, "lowvol_q1_minus_q5_spread.csv")
PATH_STATUS <- file.path(REPORT_DIR, "performance_run_status.csv")

RF_ANNUAL <- 0.03
LOWVOL_TC_BPS <- c(0, 5, 10, 20)
PERIODS <- data.table(
  period = c("insample", "test", "oos", "full"),
  start_year = c(1998L, 2016L, 2020L, NA_integer_),
  end_year = c(2015L, 2019L, 2024L, NA_integer_)
)

fn_write_csv <- function(dt, path) {
  fwrite(dt, path)
}

fn_stop_missing <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0L) {
    stop("Missing required inputs:\n", paste(missing, collapse = "\n"))
  }
}

fn_ensure_inside <- function(path, root) {
  norm_path <- normalizePath(path, mustWork = FALSE)
  norm_root <- normalizePath(root, mustWork = TRUE)
  startsWith(tolower(norm_path), tolower(norm_root))
}

fn_ann_geo <- function(rv) {
  rv <- rv[is.finite(rv)]
  if (length(rv) == 0L || any(1 + rv <= 0, na.rm = TRUE)) return(NA_real_)
  prod(1 + rv)^(12 / length(rv)) - 1
}

fn_expected_shortfall <- function(rv, p = 0.025) {
  rv <- rv[is.finite(rv)]
  if (length(rv) == 0L) return(NA_real_)
  cutoff <- as.numeric(quantile(rv, p, na.rm = TRUE, names = FALSE))
  mean(rv[rv <= cutoff], na.rm = TRUE)
}

fn_perf <- function(rv, rf_annual = RF_ANNUAL) {
  rv <- rv[is.finite(rv)]
  if (length(rv) < 12L) return(NULL)
  rf_monthly <- (1 + rf_annual)^(1 / 12) - 1
  excess <- rv - rf_monthly
  ci <- cumprod(1 + rv)
  drawdown <- ci / cummax(ci) - 1
  data.table(
    n_months = length(rv),
    annualized_geometric_return = fn_ann_geo(rv),
    annualized_volatility = sd(rv) * sqrt(12),
    sharpe_ratio = if (sd(excess) > 0) mean(excess) / sd(excess) * sqrt(12) else NA_real_,
    max_drawdown = min(drawdown, na.rm = TRUE),
    expected_shortfall_2p5 = fn_expected_shortfall(rv, 0.025),
    cumulative_return = prod(1 + rv) - 1,
    rf_annual = rf_annual
  )
}

fn_period_slice <- function(dt, period_name, start_year, end_year) {
  if (identical(period_name, "full")) return(copy(dt))
  dt[year >= start_year & year <= end_year]
}

fn_perf_by_period <- function(dt, keys, return_col, extra_cols = character()) {
  rows <- list()
  groups <- unique(dt[, ..keys])
  setorder(groups)
  for (i in seq_len(nrow(groups))) {
    g <- groups[i]
    sub_all <- dt[g, on = keys]
    for (p_i in seq_len(nrow(PERIODS))) {
      p <- PERIODS[p_i]
      sub <- fn_period_slice(sub_all, p$period, p$start_year, p$end_year)
      pf <- fn_perf(sub[[return_col]])
      if (is.null(pf)) next
      extra <- if (length(extra_cols) > 0L) {
        sub[, lapply(.SD, function(x) {
          ux <- unique(x[!is.na(x)])
          if (length(ux) == 0L) NA else ux[1L]
        }), .SDcols = extra_cols]
      } else {
        data.table()
      }
      rows[[length(rows) + 1L]] <- cbind(
        g,
        data.table(
          period = p$period,
          period_start_date = min(sub$date, na.rm = TRUE),
          period_end_date = max(sub$date, na.rm = TRUE)
        ),
        pf,
        extra
      )
    }
  }
  rbindlist(rows, use.names = TRUE, fill = TRUE)
}

fn_add_turnover_metrics <- function(perf, monthly, keys) {
  turnover <- list()
  groups <- unique(monthly[, ..keys])
  for (i in seq_len(nrow(groups))) {
    g <- groups[i]
    sub_all <- monthly[g, on = keys]
    for (p_i in seq_len(nrow(PERIODS))) {
      p <- PERIODS[p_i]
      sub <- fn_period_slice(sub_all, p$period, p$start_year, p$end_year)
      if (nrow(sub) == 0L) next
      turnover[[length(turnover) + 1L]] <- cbind(
        g,
        data.table(
          period = p$period,
          mean_monthly_turnover_gross = mean(sub$turnover_gross, na.rm = TRUE),
          annualized_turnover_gross = sum(sub$turnover_gross, na.rm = TRUE) / max(uniqueN(sub$date) / 12, 1),
          total_transaction_cost_return_drag = sum(sub$transaction_cost_return_drag, na.rm = TRUE)
        )
      )
    }
  }
  merge(perf, rbindlist(turnover, use.names = TRUE, fill = TRUE), by = c(keys, "period"), all.x = TRUE)
}

fn_standard_metric_cols <- function(dt, prefix = "") {
  cols <- c(
    "annualized_geometric_return", "annualized_volatility", "sharpe_ratio",
    "max_drawdown", "expected_shortfall_2p5", "annualized_turnover_gross",
    "total_transaction_cost_return_drag"
  )
  out <- copy(dt)
  setnames(out, cols, paste0(prefix, cols), skip_absent = TRUE)
  out
}

fn_extract_analysis_model <- function(path) {
  parts <- strsplit(normalizePath(path, winslash = "/", mustWork = FALSE), "/", fixed = TRUE)[[1]]
  suite_idx <- which(parts == "nonraw_index_suite")
  if (length(suite_idx) == 1L && length(parts) >= suite_idx + 1L) {
    return(parts[[suite_idx + 1L]])
  }
  NA_character_
}

fn_track_label <- function(track) {
  fifelse(track == "dynamic_csi", "Dynamic CSI",
          fifelse(track == "permanent_csi", "Permanent CSI", track))
}

fn_index_label <- function(index_id) {
  fifelse(index_id == "large_cap", "Large cap",
          fifelse(index_id == "mid_cap", "Mid cap",
                  fifelse(index_id == "small_cap", "Small cap",
                          fifelse(index_id == "total_market", "Total market", index_id))))
}

fn_save_pair <- function(dt, rds_path, csv_path) {
  if (!fn_ensure_inside(rds_path, ALPHA_ROOT) || !fn_ensure_inside(csv_path, ALPHA_ROOT)) {
    stop("Refusing to write outside alpha-validation root: ", rds_path, " / ", csv_path)
  }
  saveRDS(dt, rds_path)
  fn_write_csv(dt, csv_path)
}

fn_stop_missing(c(PATH_LOWVOL_RETURNS, PATH_LOWVOL_TURNOVER, PATH_BENCHMARK_RETURNS))

cat("[11F] Loading low-volatility monthly returns and turnover...\n")
lowvol_returns <- as.data.table(readRDS(PATH_LOWVOL_RETURNS))
lowvol_turnover <- as.data.table(readRDS(PATH_LOWVOL_TURNOVER))
if (!inherits(lowvol_returns$date, "Date")) lowvol_returns[, date := as.Date(date)]
if (!inherits(lowvol_turnover$date, "Date")) lowvol_turnover[, date := as.Date(date)]

lowvol_returns <- lowvol_returns[
  transaction_cost_bps %in% LOWVOL_TC_BPS,
  .(
    track,
    index_id,
    index_name,
    date,
    year = as.integer(year),
    month = as.integer(month),
    strategy_id,
    portfolio_id,
    quintile,
    quintile_num = as.integer(quintile_num),
    weighting,
    gross_return,
    net_return,
    turnover_gross,
    transaction_cost_bps = as.numeric(transaction_cost_bps),
    transaction_cost_return_drag
  )
]

lowvol_keys <- c("index_id", "strategy_id", "quintile", "transaction_cost_bps")
lowvol_perf <- fn_perf_by_period(
  lowvol_returns,
  keys = lowvol_keys,
  return_col = "net_return",
  extra_cols = c("track", "index_name", "portfolio_id", "quintile_num", "weighting")
)
lowvol_perf <- fn_add_turnover_metrics(lowvol_perf, lowvol_returns, lowvol_keys)
lowvol_perf[, `:=`(
  asset_class = "lowvol_quintile",
  metric_return_basis = "net_return"
)]
setcolorder(lowvol_perf, c(
  "asset_class", "track", "period", "index_id", "index_name", "strategy_id",
  "portfolio_id", "quintile", "quintile_num", "weighting",
  "transaction_cost_bps"
))
setorder(lowvol_perf, period, index_id, quintile_num, transaction_cost_bps)

cat("[11F] Loading CRSP-like market benchmark returns...\n")
benchmark_returns <- as.data.table(readRDS(PATH_BENCHMARK_RETURNS))
if (!inherits(benchmark_returns$date, "Date")) benchmark_returns[, date := as.Date(date)]
benchmark_returns[, `:=`(
  year = as.integer(format(date, "%Y")),
  month = as.integer(format(date, "%m")),
  strategy_id = "benchmark",
  transaction_cost_bps = 0
)]
benchmark_returns <- benchmark_returns[, .(
  index_id,
  index_name,
  date,
  year,
  month,
  strategy_id,
  transaction_cost_bps,
  port_ret
)]
bench_keys <- c("index_id", "strategy_id", "transaction_cost_bps")
benchmark_perf <- fn_perf_by_period(
  benchmark_returns,
  keys = bench_keys,
  return_col = "port_ret",
  extra_cols = c("index_name")
)
benchmark_perf[, `:=`(
  asset_class = "market_benchmark",
  track = "benchmark",
  portfolio_id = "benchmark",
  weighting = "market_cap",
  metric_return_basis = "port_ret",
  mean_monthly_turnover_gross = NA_real_,
  annualized_turnover_gross = NA_real_,
  total_transaction_cost_return_drag = 0
)]
setcolorder(benchmark_perf, c(
  "asset_class", "track", "period", "index_id", "index_name", "strategy_id",
  "portfolio_id", "weighting", "transaction_cost_bps"
))
setorder(benchmark_perf, period, index_id)

cat("[11F] Extracting existing CSI performance outputs...\n")
csi_paths <- Sys.glob(file.path(
  CSI_SUITE_ROOT, "*", "3_Modelling_Results", "Necessary", "*",
  "11c_index_revised*", "index_performance_gross_and_net_by_tc.rds"
))
if (length(csi_paths) == 0L) {
  stop("No CSI performance files found under ", CSI_SUITE_ROOT)
}
csi_perf <- rbindlist(lapply(csi_paths, function(path) {
  dt <- as.data.table(readRDS(path))
  dt[, `:=`(
    source_path = normalizePath(path, winslash = "/", mustWork = TRUE),
    analysis_model = fn_extract_analysis_model(path)
  )]
  dt
}), use.names = TRUE, fill = TRUE)
csi_perf <- csi_perf[model_key != "bench"]
csi_perf[, `:=`(
  response_track = fifelse(track == "dynamic_csi", "dynamic_csi", track),
  track_label = fn_track_label(track),
  index_label = fn_index_label(index_id),
  asset_class = "csi_strategy",
  annualized_geometric_return = net_annualized_geometric_return,
  annualized_volatility = net_annualized_sd,
  sharpe_ratio = net_sharpe_ratio,
  max_drawdown = net_max_drawdown,
  expected_shortfall_2p5 = net_expected_shortfall_2p5,
  cumulative_return = net_cumulative_return,
  metric_return_basis = "source_net_return"
)]
csi_perf[, source_row_id := seq_len(.N)]

csi_perf[, is_best_by_track_index_cost := FALSE]
if (file.exists(PATH_CSI_BEST)) {
  csi_best <- fread(PATH_CSI_BEST)
  csi_best[, response_track := fifelse(response_track == "temporary_csi", "dynamic_csi", response_track)]
  best_keys <- c(
    "response_track", "index_id", "analysis_model", "model_key",
    "threshold_method", "lockout_years", "exclusion_rule", "rule_label",
    "strategy_id", "transaction_cost_bps"
  )
  csi_best <- unique(csi_best[, ..best_keys])
  csi_perf[
    csi_best,
    is_best_by_track_index_cost := TRUE,
    on = best_keys
  ]
}

csi_perf[, is_headline_20bps := FALSE]
if (file.exists(PATH_CSI_HEADLINE_20BPS)) {
  csi_headline <- fread(PATH_CSI_HEADLINE_20BPS)
  csi_headline[, transaction_cost_bps := 20]
  headline_keys <- c(
    "track_label", "index_label", "analysis_model", "threshold_method",
    "rule_label", "transaction_cost_bps"
  )
  csi_headline <- unique(csi_headline[, ..headline_keys])
  csi_perf[
    csi_headline,
    is_headline_20bps := TRUE,
    on = headline_keys
  ]
}
csi_perf[, headline_source := fifelse(
  is_headline_20bps, "final_tables/headline_winners_20bps",
  fifelse(is_best_by_track_index_cost, "comparison/best_by_track_index_cost", "full_csi_performance_extract")
)]

csi_extract <- csi_perf[, .(
  asset_class,
  period,
  track,
  response_track,
  track_label,
  index_id,
  index_name,
  index_label,
  analysis_model,
  model_key,
  model_label,
  threshold_method,
  threshold_label,
  threshold,
  lockout_years,
  strategy_id,
  exclusion_rule,
  rule_label,
  weighting,
  transaction_cost_bps,
  n_months,
  annualized_geometric_return,
  annualized_volatility,
  sharpe_ratio,
  max_drawdown,
  expected_shortfall_2p5,
  cumulative_return,
  rf_annual,
  benchmark_net_annualized_geometric_return,
  net_difference_versus_benchmark,
  mean_monthly_turnover_gross,
  annualized_turnover_gross,
  total_transaction_cost_return_drag,
  metric_return_basis,
  is_best_by_track_index_cost,
  is_headline_20bps,
  headline_source,
  source_path,
  source_row_id
)]
setorder(
  csi_extract,
  period, index_id, track, analysis_model, transaction_cost_bps,
  -is_headline_20bps, -is_best_by_track_index_cost, -sharpe_ratio
)

cat("[11F] Building neutral comparison tables...\n")
bench_cmp <- benchmark_perf[, .(
  period,
  index_id,
  benchmark_n_months = n_months,
  benchmark_annualized_geometric_return = annualized_geometric_return,
  benchmark_annualized_volatility = annualized_volatility,
  benchmark_sharpe_ratio = sharpe_ratio,
  benchmark_max_drawdown = max_drawdown,
  benchmark_expected_shortfall_2p5 = expected_shortfall_2p5
)]
lowvol_cmp <- lowvol_perf[, .(
  period,
  index_id,
  index_name,
  quintile,
  quintile_num,
  strategy_id,
  transaction_cost_bps,
  lowvol_n_months = n_months,
  lowvol_annualized_geometric_return = annualized_geometric_return,
  lowvol_annualized_volatility = annualized_volatility,
  lowvol_sharpe_ratio = sharpe_ratio,
  lowvol_max_drawdown = max_drawdown,
  lowvol_expected_shortfall_2p5 = expected_shortfall_2p5,
  lowvol_annualized_turnover_gross = annualized_turnover_gross,
  lowvol_total_transaction_cost_return_drag = total_transaction_cost_return_drag
)]
benchmark_vs_lowvol <- merge(lowvol_cmp, bench_cmp, by = c("period", "index_id"), all.x = TRUE)
benchmark_vs_lowvol[, `:=`(
  return_difference_lowvol_minus_benchmark =
    lowvol_annualized_geometric_return - benchmark_annualized_geometric_return,
  sharpe_difference_lowvol_minus_benchmark =
    lowvol_sharpe_ratio - benchmark_sharpe_ratio,
  max_drawdown_difference_lowvol_minus_benchmark =
    lowvol_max_drawdown - benchmark_max_drawdown,
  comparison_label = paste0("Benchmark vs ", quintile)
)]
setorder(benchmark_vs_lowvol, period, index_id, quintile_num, transaction_cost_bps)

q1 <- lowvol_perf[quintile == "Q1", .(
  period,
  index_id,
  transaction_cost_bps,
  q1_annualized_geometric_return = annualized_geometric_return,
  q1_annualized_volatility = annualized_volatility,
  q1_sharpe_ratio = sharpe_ratio,
  q1_max_drawdown = max_drawdown,
  q1_expected_shortfall_2p5 = expected_shortfall_2p5,
  q1_annualized_turnover_gross = annualized_turnover_gross,
  q1_total_transaction_cost_return_drag = total_transaction_cost_return_drag
)]
q5 <- lowvol_perf[quintile == "Q5", .(
  period,
  index_id,
  transaction_cost_bps,
  q5_annualized_geometric_return = annualized_geometric_return,
  q5_annualized_volatility = annualized_volatility,
  q5_sharpe_ratio = sharpe_ratio,
  q5_max_drawdown = max_drawdown,
  q5_expected_shortfall_2p5 = expected_shortfall_2p5,
  q5_annualized_turnover_gross = annualized_turnover_gross,
  q5_total_transaction_cost_return_drag = total_transaction_cost_return_drag
)]
q1_q5_spread <- merge(q1, q5, by = c("period", "index_id", "transaction_cost_bps"), all = FALSE)
q1_q5_spread[, `:=`(
  spread_label = "Q1 - Q5",
  annualized_geometric_return_spread = q1_annualized_geometric_return - q5_annualized_geometric_return,
  annualized_volatility_spread = q1_annualized_volatility - q5_annualized_volatility,
  sharpe_ratio_spread = q1_sharpe_ratio - q5_sharpe_ratio,
  max_drawdown_spread = q1_max_drawdown - q5_max_drawdown,
  expected_shortfall_2p5_spread = q1_expected_shortfall_2p5 - q5_expected_shortfall_2p5,
  annualized_turnover_gross_spread = q1_annualized_turnover_gross - q5_annualized_turnover_gross,
  total_transaction_cost_return_drag_spread =
    q1_total_transaction_cost_return_drag - q5_total_transaction_cost_return_drag
)]
setorder(q1_q5_spread, period, index_id, transaction_cost_bps)

csi_headline <- csi_extract[is_best_by_track_index_cost == TRUE | is_headline_20bps == TRUE]
if (nrow(csi_headline) == 0L) {
  warning("No CSI headline rows marked; using full CSI extract for csi_vs_lowvol_headline.")
  csi_headline <- copy(csi_extract)
}
csi_base <- csi_headline[, .(
  period,
  index_id,
  index_name,
  track,
  response_track,
  track_label,
  analysis_model,
  model_key,
  threshold_method,
  threshold_label,
  lockout_years,
  strategy_id,
  exclusion_rule,
  rule_label,
  transaction_cost_bps,
  csi_n_months = n_months,
  csi_annualized_geometric_return = annualized_geometric_return,
  csi_annualized_volatility = annualized_volatility,
  csi_sharpe_ratio = sharpe_ratio,
  csi_max_drawdown = max_drawdown,
  csi_expected_shortfall_2p5 = expected_shortfall_2p5,
  csi_annualized_turnover_gross = annualized_turnover_gross,
  csi_total_transaction_cost_return_drag = total_transaction_cost_return_drag,
  csi_net_difference_versus_benchmark = net_difference_versus_benchmark,
  is_best_by_track_index_cost,
  is_headline_20bps,
  headline_source
)]
csi_vs_lowvol <- merge(csi_base, q1, by = c("period", "index_id", "transaction_cost_bps"), all.x = TRUE)
csi_vs_lowvol <- merge(csi_vs_lowvol, q5, by = c("period", "index_id", "transaction_cost_bps"), all.x = TRUE)
csi_vs_lowvol <- merge(csi_vs_lowvol, bench_cmp, by = c("period", "index_id"), all.x = TRUE)
csi_vs_lowvol[, `:=`(
  return_difference_csi_minus_q1 = csi_annualized_geometric_return - q1_annualized_geometric_return,
  return_difference_csi_minus_q5 = csi_annualized_geometric_return - q5_annualized_geometric_return,
  return_difference_csi_minus_benchmark = csi_annualized_geometric_return - benchmark_annualized_geometric_return,
  sharpe_difference_csi_minus_q1 = csi_sharpe_ratio - q1_sharpe_ratio,
  sharpe_difference_csi_minus_q5 = csi_sharpe_ratio - q5_sharpe_ratio,
  sharpe_difference_csi_minus_benchmark = csi_sharpe_ratio - benchmark_sharpe_ratio,
  comparison_label = "CSI headline/best vs Q1, benchmark, and Q5"
)]
setorder(
  csi_vs_lowvol,
  period, index_id, transaction_cost_bps, track, analysis_model,
  -is_headline_20bps, -is_best_by_track_index_cost
)

cat("[11F] Writing output files...\n")
fn_save_pair(lowvol_perf, PATH_LOWVOL_PERF_RDS, PATH_LOWVOL_PERF_CSV)
fn_save_pair(benchmark_perf, PATH_BENCH_PERF_RDS, PATH_BENCH_PERF_CSV)
fn_save_pair(csi_extract, PATH_CSI_EXTRACT_RDS, PATH_CSI_EXTRACT_CSV)
fn_save_pair(benchmark_vs_lowvol, PATH_BENCH_VS_LOWVOL_RDS, PATH_BENCH_VS_LOWVOL_CSV)
fn_save_pair(csi_vs_lowvol, PATH_CSI_VS_LOWVOL_RDS, PATH_CSI_VS_LOWVOL_CSV)
fn_save_pair(q1_q5_spread, PATH_Q1_Q5_SPREAD_RDS, PATH_Q1_Q5_SPREAD_CSV)

RUN_ENDED <- Sys.time()
status <- data.table(
  ticket_id = "AE-ALPHA-004",
  status = "completed",
  run_started = as.character(RUN_STARTED),
  run_finished = as.character(RUN_ENDED),
  elapsed_seconds = as.numeric(difftime(RUN_ENDED, RUN_STARTED, units = "secs")),
  script = SCRIPT_PATH,
  alpha_output_root = normalizePath(ALPHA_ROOT, winslash = "/", mustWork = TRUE),
  lowvol_return_rows = nrow(lowvol_returns),
  lowvol_turnover_rows = nrow(lowvol_turnover),
  benchmark_return_rows = nrow(benchmark_returns),
  csi_source_files = length(csi_paths),
  lowvol_performance_rows = nrow(lowvol_perf),
  benchmark_performance_rows = nrow(benchmark_perf),
  csi_extract_rows = nrow(csi_extract),
  benchmark_vs_lowvol_rows = nrow(benchmark_vs_lowvol),
  csi_vs_lowvol_rows = nrow(csi_vs_lowvol),
  q1_q5_spread_rows = nrow(q1_q5_spread),
  lowvol_quintiles = paste(sort(unique(lowvol_perf$quintile)), collapse = "|"),
  lowvol_transaction_cost_bps = paste(sort(unique(lowvol_perf$transaction_cost_bps)), collapse = "|"),
  benchmark_transaction_cost_bps = paste(sort(unique(benchmark_perf$transaction_cost_bps)), collapse = "|"),
  csi_transaction_cost_bps = paste(sort(unique(csi_extract$transaction_cost_bps)), collapse = "|"),
  csi_periods = paste(sort(unique(csi_extract$period)), collapse = "|"),
  periods = paste(PERIODS$period, collapse = "|"),
  rf_annual = RF_ANNUAL,
  notes = paste(
    "CSI rows are extracted from existing nonraw_index_suite performance outputs;",
    "low-vol and benchmark metrics are computed from monthly returns;",
    "no CSI or low-vol construction is rerun."
  )
)
if (!fn_ensure_inside(PATH_STATUS, ALPHA_ROOT)) {
  stop("Refusing to write status outside alpha-validation root: ", PATH_STATUS)
}
fn_write_csv(status, PATH_STATUS)

cat("\n[11F] COMPLETE:", format(Sys.time()), "\n")
cat("  Low-vol performance rows:", nrow(lowvol_perf), "\n")
cat("  Benchmark performance rows:", nrow(benchmark_perf), "\n")
cat("  CSI extract rows:", nrow(csi_extract), "\n")
cat("  Output root:", ALPHA_ROOT, "\n")
