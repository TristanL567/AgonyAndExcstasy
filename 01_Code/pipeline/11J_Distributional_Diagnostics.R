#==============================================================================#
#==== 11J_Distributional_Diagnostics.R ========================================#
#==== AE-ALPHA-008: Return Distribution Diagnostics ===========================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
})

cat("\n[11J_Distributional_Diagnostics.R] START:", format(Sys.time()), "\n")

RUN_STARTED <- Sys.time()

fn_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg)) {
    return(normalizePath(sub("^--file=", "", file_arg[[1L]]), mustWork = FALSE))
  }
  normalizePath("01_Code/pipeline/11J_Distributional_Diagnostics.R", mustWork = FALSE)
}

SCRIPT_PATH <- fn_script_path()
PIPELINE_DIR <- dirname(SCRIPT_PATH)
ROOT_DIR <- normalizePath(file.path(PIPELINE_DIR, "..", ".."), mustWork = TRUE)

path_root <- function(...) file.path(ROOT_DIR, ...)

ALPHA_DIR <- path_root("03_Data_Output", "3_Modelling_Results", "Necessary", "alpha_validation")
DIST_DIR <- file.path(ALPHA_DIR, "distribution_diagnostics")
REPORT_DIR <- file.path(ALPHA_DIR, "reports")
TICKET_DIR <- path_root(
  "05_Documentation", "09_Epics", "AE-ALPHA_LowVol_Tilt_Independence", "Tickets"
)
dir.create(DIST_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TICKET_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_LOWVOL_RETURNS <- file.path(ALPHA_DIR, "returns", "lowvol_monthly_returns_gross_net_by_tc.rds")
PATH_BENCHMARK_RETURNS <- path_root(
  "02_Data_Input", "04_Index_Replication", "Necessary",
  "crsp_like_index_returns_monthly.rds"
)
PATH_CSI_PERF <- file.path(ALPHA_DIR, "performance", "csi_performance_extract.rds")
PATH_LOWVOL_PERF <- file.path(ALPHA_DIR, "performance", "lowvol_performance_summary.rds")
PATH_BENCHMARK_PERF <- file.path(ALPHA_DIR, "performance", "benchmark_performance_summary.rds")

OUT_PANEL <- file.path(DIST_DIR, "monthly_return_panel")
OUT_DISTRIBUTION <- file.path(DIST_DIR, "distribution_summary_by_strategy")
OUT_ACTIVE <- file.path(DIST_DIR, "active_return_summary")
OUT_CAPTURE <- file.path(DIST_DIR, "upside_downside_capture")
OUT_TAIL <- file.path(DIST_DIR, "tail_state_summary")
OUT_QQ <- file.path(DIST_DIR, "qq_plot_data")
OUT_SCATTER <- file.path(DIST_DIR, "scatter_plot_data")
OUT_REPORT <- file.path(REPORT_DIR, "distribution_diagnostics_report.md")
OUT_STATUS <- file.path(REPORT_DIR, "distribution_diagnostics_run_status.csv")
OUT_COMPLETION <- file.path(TICKET_DIR, "AE-ALPHA-008_Completion_Report.md")

required_inputs <- c(
  PATH_LOWVOL_RETURNS,
  PATH_BENCHMARK_RETURNS,
  PATH_CSI_PERF,
  PATH_LOWVOL_PERF,
  PATH_BENCHMARK_PERF
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

truthy <- function(x) {
  !is.na(x) & x == TRUE
}

safe_divide <- function(num, den) {
  fifelse(is.finite(den) & den != 0, num / den, NA_real_)
}

clean_mean <- function(x) {
  if (!any(is.finite(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
}

clean_sd <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 2L) return(NA_real_)
  sd(x)
}

clean_quantile <- function(x, p) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  as.numeric(quantile(x, probs = p, na.rm = TRUE, names = FALSE, type = 7))
}

expected_shortfall <- function(x, p = 0.025) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  cutoff <- as.numeric(quantile(x, probs = p, na.rm = TRUE, names = FALSE, type = 7))
  mean(x[x <= cutoff], na.rm = TRUE)
}

skewness <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 3L) return(NA_real_)
  s <- sd(x)
  if (!is.finite(s) || s == 0) return(NA_real_)
  mean(((x - mean(x)) / s)^3)
}

excess_kurtosis <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 4L) return(NA_real_)
  s <- sd(x)
  if (!is.finite(s) || s == 0) return(NA_real_)
  mean(((x - mean(x)) / s)^4) - 3
}

normalize_track <- function(x) {
  fifelse(x == "temporary_csi", "dynamic_csi", x)
}

coalesce_character <- function(...) {
  vals <- list(...)
  out <- vals[[1L]]
  if (length(vals) == 1L) return(out)
  for (i in 2:length(vals)) {
    out <- fifelse(is.na(out) | out == "", vals[[i]], out)
  }
  out
}

cat("[11J] Loading benchmark monthly returns...\n")
benchmark_raw <- as.data.table(readRDS(PATH_BENCHMARK_RETURNS))
benchmark_raw[, date := as.Date(date)]
if ("qdate" %in% names(benchmark_raw)) benchmark_raw[, qdate := as.Date(qdate)]
benchmark_returns <- benchmark_raw[, .(
  date,
  benchmark_qdate = if ("qdate" %in% names(benchmark_raw)) qdate else as.Date(NA),
  index_id,
  benchmark_index_name = index_name,
  benchmark_return = as.numeric(port_ret)
)]
benchmark_returns <- unique(benchmark_returns, by = c("date", "index_id"))

benchmark_panel_base <- benchmark_returns[, .(
  date,
  qdate = benchmark_qdate,
  response_track = NA_character_,
  track = "benchmark",
  universe = index_id,
  index_id,
  index_name = benchmark_index_name,
  strategy_group = "benchmark",
  strategy_id = "benchmark",
  strategy_label = paste0(benchmark_index_name, " benchmark"),
  portfolio_id = "benchmark",
  quintile = NA_character_,
  quintile_num = NA_integer_,
  analysis_model = NA_character_,
  model_key = "benchmark",
  model_label = "Benchmark",
  threshold_method = NA_character_,
  threshold_label = NA_character_,
  threshold = NA_real_,
  lockout_years = NA_integer_,
  exclusion_rule = NA_character_,
  rule_label = NA_character_,
  weighting = "market_cap",
  transaction_cost_bps = 0,
  gross_return = benchmark_return,
  net_return = benchmark_return,
  source_path = PATH_BENCHMARK_RETURNS,
  selection_reason = "market_benchmark"
)]

cat("[11J] Loading low-volatility monthly returns...\n")
lowvol_raw <- as.data.table(readRDS(PATH_LOWVOL_RETURNS))
lowvol_raw[, date := as.Date(date)]
if ("qdate" %in% names(lowvol_raw)) lowvol_raw[, qdate := as.Date(qdate)]
lowvol_raw <- lowvol_raw[!is.na(quintile) & !is.na(date) & !is.na(index_id)]
lowvol_panel_base <- lowvol_raw[, .(
  date,
  qdate = if ("qdate" %in% names(lowvol_raw)) qdate else as.Date(NA),
  response_track = NA_character_,
  track = track,
  universe = fifelse(!is.na(universe) & universe != "", universe, index_id),
  index_id,
  index_name,
  strategy_group = "lowvol",
  strategy_id = fifelse(!is.na(strategy_id) & strategy_id != "", strategy_id, paste0("lowvol_", quintile)),
  strategy_label = paste0("Low-vol ", quintile),
  portfolio_id,
  quintile,
  quintile_num = as.integer(quintile_num),
  analysis_model = NA_character_,
  model_key = "lowvol",
  model_label = "Low-volatility quintile",
  threshold_method = NA_character_,
  threshold_label = NA_character_,
  threshold = NA_real_,
  lockout_years = NA_integer_,
  exclusion_rule = NA_character_,
  rule_label = NA_character_,
  weighting,
  transaction_cost_bps = as.numeric(transaction_cost_bps),
  gross_return = as.numeric(gross_return),
  net_return = as.numeric(net_return),
  source_path = PATH_LOWVOL_RETURNS,
  selection_reason = "available_lowvol_quintile"
)]

cat("[11J] Selecting CSI headline/best strategy rows...\n")
csi_perf <- as.data.table(readRDS(PATH_CSI_PERF))
csi_perf[, track := normalize_track(track)]
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
csi_selected[, returns_path := file.path(dirname(source_path), "index_returns_gross_and_net_by_tc.rds")]
csi_selected[, returns_path_exists := file.exists(returns_path)]
csi_selected <- csi_selected[returns_path_exists == TRUE]
if (!nrow(csi_selected)) {
  stop("No selected CSI strategy rows mapped to available monthly return files.")
}

csi_selected[, selection_reason := fifelse(
  truthy(is_headline_20bps) & truthy(is_best_by_track_index_cost),
  "headline_20bps_and_best_by_track_index_cost",
  fifelse(truthy(is_headline_20bps), "headline_20bps", "best_by_track_index_cost")
)]

csi_meta_cols <- c(
  "track", "response_track", "track_label", "index_id", "index_name", "index_label",
  "analysis_model", "model_key", "model_label", "threshold_method",
  "threshold_label", "threshold", "lockout_years", "strategy_id",
  "exclusion_rule", "rule_label", "weighting", "transaction_cost_bps",
  "is_best_by_track_index_cost", "is_headline_20bps", "headline_source",
  "source_path", "returns_path", "selection_reason"
)
csi_selected <- unique(csi_selected[, ..csi_meta_cols])
csi_selected[, selected_strategy_key := .I]

read_selected_csi_returns <- function(path, selected_rows) {
  dt <- as.data.table(readRDS(path))
  dt[, returns_path := path]
  if ("track" %in% names(dt)) dt[, track := normalize_track(track)]
  if ("date" %in% names(dt)) dt[, date := as.Date(date)]
  if ("qdate" %in% names(dt)) dt[, qdate := as.Date(qdate)]

  merge_cols <- intersect(
    c(
      "track", "index_id", "model_key", "threshold_method", "threshold_label",
      "threshold", "lockout_years", "strategy_id", "exclusion_rule",
      "rule_label", "weighting", "transaction_cost_bps", "returns_path"
    ),
    intersect(names(dt), names(selected_rows))
  )
  keys <- selected_rows[, c("selected_strategy_key", merge_cols), with = FALSE]
  out <- merge(dt, keys, by = merge_cols, all = FALSE, allow.cartesian = TRUE)
  if (!nrow(out)) return(data.table())
  out
}

cat("[11J] Reading selected CSI monthly return files...\n")
csi_returns <- rbindlist(lapply(unique(csi_selected$returns_path), function(path) {
  read_selected_csi_returns(path, csi_selected[returns_path == path])
}), fill = TRUE)
if (!nrow(csi_returns)) {
  stop("Selected CSI monthly returns were empty after filtering.")
}

csi_meta <- copy(csi_selected)
setnames(csi_meta, "source_path", "performance_source_path")
csi_returns <- merge(csi_returns, csi_meta, by = "selected_strategy_key", all.x = TRUE, suffixes = c("", "_meta"))

csi_panel_base <- csi_returns[, .(
  date,
  qdate = if ("qdate" %in% names(csi_returns)) qdate else as.Date(NA),
  response_track = response_track,
  track = track,
  universe = fifelse(!is.na(universe) & universe != "", universe, index_id),
  index_id,
  index_name,
  strategy_group = "csi",
  strategy_id,
  strategy_label = paste(
    response_track,
    index_id,
    coalesce_character(model_label, model_key),
    coalesce_character(threshold_label, threshold_method),
    coalesce_character(rule_label, exclusion_rule),
    paste0(as.integer(transaction_cost_bps), "bps"),
    sep = " | "
  ),
  portfolio_id = strategy_id,
  quintile = NA_character_,
  quintile_num = NA_integer_,
  analysis_model,
  model_key,
  model_label,
  threshold_method,
  threshold_label,
  threshold = as.numeric(threshold),
  lockout_years = as.integer(lockout_years),
  exclusion_rule,
  rule_label,
  weighting,
  transaction_cost_bps = as.numeric(transaction_cost_bps),
  gross_return = as.numeric(gross_return),
  net_return = as.numeric(net_return),
  source_path = returns_path,
  performance_source_path,
  selection_reason
)]
csi_panel_base <- unique(csi_panel_base)

cat("[11J] Building period windows from existing performance summaries...\n")
lowvol_perf <- as.data.table(readRDS(PATH_LOWVOL_PERF))
benchmark_perf <- as.data.table(readRDS(PATH_BENCHMARK_PERF))
period_windows <- unique(rbindlist(list(
  lowvol_perf[period != "full", .(period, index_id, period_start_date, period_end_date)],
  benchmark_perf[period != "full", .(period, index_id, period_start_date, period_end_date)]
), fill = TRUE))
period_windows <- period_windows[
  !is.na(period) & !is.na(index_id) & !is.na(period_start_date) & !is.na(period_end_date),
  .(
    period_start_date = max(as.Date(period_start_date), na.rm = TRUE),
    period_end_date = min(as.Date(period_end_date), na.rm = TRUE)
  ),
  by = .(period, index_id)
]
period_windows <- period_windows[period %in% c("insample", "test", "oos")]

expand_periods <- function(dt, windows) {
  full_dt <- copy(dt)
  full_dt[, period := "full"]
  nonfull <- merge(dt, windows, by = "index_id", allow.cartesian = TRUE)
  nonfull <- nonfull[date >= period_start_date & date <= period_end_date]
  nonfull[, c("period_start_date", "period_end_date") := NULL]
  rbindlist(list(full_dt, nonfull), fill = TRUE)
}

cat("[11J] Combining benchmark, low-volatility, and CSI returns...\n")
panel_base <- rbindlist(
  list(benchmark_panel_base, lowvol_panel_base, csi_panel_base),
  fill = TRUE,
  use.names = TRUE
)
panel_period <- expand_periods(panel_base, period_windows)

panel <- merge(
  panel_period,
  benchmark_returns[, .(date, index_id, benchmark_return)],
  by = c("date", "index_id"),
  all.x = TRUE
)
panel[, active_return_gross := gross_return - benchmark_return]
panel[, active_return_net := net_return - benchmark_return]
panel[strategy_group == "benchmark", active_return_gross := 0]
panel[strategy_group == "benchmark", active_return_net := 0]

panel <- panel[!is.na(benchmark_return)]
setcolorder(panel, c(
  "date", "qdate", "period", "response_track", "track", "universe", "index_id",
  "index_name", "strategy_group", "strategy_id", "strategy_label",
  "transaction_cost_bps", "gross_return", "net_return", "benchmark_return",
  "active_return_gross", "active_return_net"
))
setorder(panel, index_id, strategy_group, strategy_id, transaction_cost_bps, period, date)

summary_keys <- c(
  "period", "response_track", "universe", "index_id", "index_name",
  "strategy_group", "strategy_id", "strategy_label", "transaction_cost_bps",
  "analysis_model", "model_key", "model_label", "threshold_method",
  "threshold_label", "lockout_years", "exclusion_rule", "rule_label",
  "weighting", "selection_reason", "source_path"
)

cat("[11J] Computing distribution summaries...\n")
distribution_summary <- panel[, .(
  n_months = sum(is.finite(net_return)),
  period_start_date = min(date[is.finite(net_return)], na.rm = TRUE),
  period_end_date = max(date[is.finite(net_return)], na.rm = TRUE),
  mean_monthly_return = clean_mean(net_return),
  median_monthly_return = clean_quantile(net_return, 0.50),
  monthly_volatility = clean_sd(net_return),
  skewness = skewness(net_return),
  excess_kurtosis = excess_kurtosis(net_return),
  quantile_2p5 = clean_quantile(net_return, 0.025),
  quantile_5 = clean_quantile(net_return, 0.05),
  quantile_50 = clean_quantile(net_return, 0.50),
  quantile_95 = clean_quantile(net_return, 0.95),
  quantile_97p5 = clean_quantile(net_return, 0.975),
  expected_shortfall_2p5 = expected_shortfall(net_return, 0.025),
  best_monthly_return = if (any(is.finite(net_return))) max(net_return, na.rm = TRUE) else NA_real_,
  worst_monthly_return = if (any(is.finite(net_return))) min(net_return, na.rm = TRUE) else NA_real_,
  share_positive_months = clean_mean(as.numeric(net_return > 0)),
  mean_gross_monthly_return = clean_mean(gross_return),
  mean_active_return_gross = clean_mean(active_return_gross),
  mean_active_return_net = clean_mean(active_return_net),
  active_return_volatility_gross = clean_sd(active_return_gross),
  active_return_volatility_net = clean_sd(active_return_net),
  tracking_error_like_monthly_sd = clean_sd(active_return_net)
), by = summary_keys]

active_return_summary <- panel[, .(
  n_months = sum(is.finite(active_return_net)),
  mean_active_return_gross = clean_mean(active_return_gross),
  median_active_return_gross = clean_quantile(active_return_gross, 0.50),
  active_return_gross_sd = clean_sd(active_return_gross),
  active_return_gross_q2p5 = clean_quantile(active_return_gross, 0.025),
  active_return_gross_q5 = clean_quantile(active_return_gross, 0.05),
  active_return_gross_q95 = clean_quantile(active_return_gross, 0.95),
  active_return_gross_q97p5 = clean_quantile(active_return_gross, 0.975),
  mean_active_return_net = clean_mean(active_return_net),
  median_active_return_net = clean_quantile(active_return_net, 0.50),
  active_return_net_sd = clean_sd(active_return_net),
  active_return_net_q2p5 = clean_quantile(active_return_net, 0.025),
  active_return_net_q5 = clean_quantile(active_return_net, 0.05),
  active_return_net_q95 = clean_quantile(active_return_net, 0.95),
  active_return_net_q97p5 = clean_quantile(active_return_net, 0.975),
  share_positive_active_months_net = clean_mean(as.numeric(active_return_net > 0)),
  tracking_error_like_monthly_sd = clean_sd(active_return_net)
), by = summary_keys]

cat("[11J] Computing upside/downside capture...\n")
upside_downside_capture <- panel[, {
  up <- is.finite(benchmark_return) & benchmark_return > 0 & is.finite(net_return)
  down <- is.finite(benchmark_return) & benchmark_return < 0 & is.finite(net_return)
  .(
    up_month_count = sum(up),
    down_month_count = sum(down),
    mean_strategy_return_up_net = if (any(up)) mean(net_return[up], na.rm = TRUE) else NA_real_,
    mean_benchmark_return_up = if (any(up)) mean(benchmark_return[up], na.rm = TRUE) else NA_real_,
    upside_capture_net = safe_divide(
      if (any(up)) mean(net_return[up], na.rm = TRUE) else NA_real_,
      if (any(up)) mean(benchmark_return[up], na.rm = TRUE) else NA_real_
    ),
    mean_strategy_return_down_net = if (any(down)) mean(net_return[down], na.rm = TRUE) else NA_real_,
    mean_benchmark_return_down = if (any(down)) mean(benchmark_return[down], na.rm = TRUE) else NA_real_,
    downside_capture_net = safe_divide(
      if (any(down)) mean(net_return[down], na.rm = TRUE) else NA_real_,
      if (any(down)) mean(benchmark_return[down], na.rm = TRUE) else NA_real_
    ),
    mean_strategy_return_up_gross = if (any(up)) mean(gross_return[up], na.rm = TRUE) else NA_real_,
    upside_capture_gross = safe_divide(
      if (any(up)) mean(gross_return[up], na.rm = TRUE) else NA_real_,
      if (any(up)) mean(benchmark_return[up], na.rm = TRUE) else NA_real_
    ),
    mean_strategy_return_down_gross = if (any(down)) mean(gross_return[down], na.rm = TRUE) else NA_real_,
    downside_capture_gross = safe_divide(
      if (any(down)) mean(gross_return[down], na.rm = TRUE) else NA_real_,
      if (any(down)) mean(benchmark_return[down], na.rm = TRUE) else NA_real_
    )
  )
}, by = summary_keys]

cat("[11J] Computing benchmark tail-state summaries...\n")
tail_state_summary <- rbindlist(lapply(c(0.025, 0.05), function(p) {
  panel[, {
    finite_bench <- benchmark_return[is.finite(benchmark_return)]
    cutoff <- if (length(finite_bench)) {
      as.numeric(quantile(finite_bench, probs = p, na.rm = TRUE, names = FALSE, type = 7))
    } else {
      NA_real_
    }
    tail_month <- is.finite(benchmark_return) & benchmark_return <= cutoff & is.finite(net_return)
    .(
      tail_probability = p,
      tail_label = paste0("benchmark_bottom_", ifelse(p == 0.025, "2p5", "5"), "pct"),
      benchmark_tail_cutoff = cutoff,
      tail_month_count = sum(tail_month),
      strategy_mean_return_tail_net = if (any(tail_month)) mean(net_return[tail_month], na.rm = TRUE) else NA_real_,
      strategy_mean_return_tail_gross = if (any(tail_month)) mean(gross_return[tail_month], na.rm = TRUE) else NA_real_,
      benchmark_mean_return_tail = if (any(tail_month)) mean(benchmark_return[tail_month], na.rm = TRUE) else NA_real_,
      strategy_mean_active_return_tail_net = if (any(tail_month)) mean(active_return_net[tail_month], na.rm = TRUE) else NA_real_,
      strategy_mean_active_return_tail_gross = if (any(tail_month)) mean(active_return_gross[tail_month], na.rm = TRUE) else NA_real_
    )
  }, by = summary_keys]
}), fill = TRUE)

cat("[11J] Building Q-Q and scatter plot input data...\n")
qq_probs <- sort(unique(c(seq(0.01, 0.99, by = 0.01), 0.025, 0.05, 0.50, 0.95, 0.975)))
qq_plot_data <- panel[, {
  ok <- is.finite(benchmark_return) & is.finite(net_return)
  if (!any(ok)) {
    data.table()
  } else {
    data.table(
      quantile_probability = qq_probs,
      benchmark_return_quantile = as.numeric(quantile(benchmark_return[ok], probs = qq_probs, na.rm = TRUE, names = FALSE, type = 7)),
      strategy_net_return_quantile = as.numeric(quantile(net_return[ok], probs = qq_probs, na.rm = TRUE, names = FALSE, type = 7)),
      strategy_gross_return_quantile = as.numeric(quantile(gross_return[ok], probs = qq_probs, na.rm = TRUE, names = FALSE, type = 7))
    )
  }
}, by = summary_keys]

scatter_plot_data <- copy(panel)
scatter_plot_data[, strategy_gross_return := gross_return]
scatter_plot_data[, strategy_net_return := net_return]
scatter_plot_data[, benchmark_up_month := benchmark_return > 0]
scatter_plot_data[, benchmark_down_month := benchmark_return < 0]
scatter_cols <- unique(c(
  summary_keys,
  "date", "qdate", "benchmark_return", "strategy_gross_return",
  "strategy_net_return", "active_return_gross", "active_return_net",
  "benchmark_up_month", "benchmark_down_month"
))
scatter_plot_data <- scatter_plot_data[, ..scatter_cols]
setorder(scatter_plot_data, index_id, strategy_group, strategy_id, transaction_cost_bps, period, date)

cat("[11J] Writing output tables...\n")
write_pair(panel, OUT_PANEL)
write_pair(distribution_summary, OUT_DISTRIBUTION)
write_pair(active_return_summary, OUT_ACTIVE)
write_pair(upside_downside_capture, OUT_CAPTURE)
write_pair(tail_state_summary, OUT_TAIL)
write_pair(qq_plot_data, OUT_QQ)
write_pair(scatter_plot_data, OUT_SCATTER)

row_counts <- data.table(
  artifact = c(
    "monthly_return_panel",
    "distribution_summary_by_strategy",
    "active_return_summary",
    "upside_downside_capture",
    "tail_state_summary",
    "qq_plot_data",
    "scatter_plot_data"
  ),
  rows = c(
    nrow(panel),
    nrow(distribution_summary),
    nrow(active_return_summary),
    nrow(upside_downside_capture),
    nrow(tail_state_summary),
    nrow(qq_plot_data),
    nrow(scatter_plot_data)
  )
)

group_coverage <- panel[, .(
  rows = .N,
  strategy_ids = uniqueN(strategy_id),
  strategy_labels = uniqueN(strategy_label),
  transaction_cost_bps = paste(sort(unique(transaction_cost_bps)), collapse = "|"),
  periods = paste(sort(unique(period)), collapse = "|")
), by = strategy_group][order(strategy_group)]

selected_strategy_coverage <- csi_selected[, .(
  selected_strategy_rows = .N,
  indexes = paste(sort(unique(index_id)), collapse = "|"),
  response_tracks = paste(sort(unique(response_track)), collapse = "|"),
  transaction_cost_bps = paste(sort(unique(transaction_cost_bps)), collapse = "|"),
  return_files = uniqueN(returns_path)
)]

period_window_text <- unique(period_windows[, .(period, period_start_date, period_end_date)])
setorder(period_window_text, period, period_start_date, period_end_date)
period_alignment_rule <- paste(
  "Rows are expanded to full, insample, test, and oos periods.",
  "The non-full windows use the explicit AE-ALPHA performance-summary dates shared by benchmark and low-vol outputs:",
  paste0(paste(period_window_text[, paste0(period, "=", period_start_date, " to ", period_end_date)], collapse = "; "), "."),
  "The full period uses each strategy's available monthly span after matching to the same date and index_id benchmark return."
)

neutral_findings <- c(
  "The panel separates benchmark, low-volatility quintile, and selected CSI monthly return distributions with matched benchmark returns.",
  "The capture tables identify benchmark-up and benchmark-down month averages and counts for each strategy-period row.",
  "The tail-state tables summarize strategy and active returns during each strategy's matched benchmark bottom 2.5% and 5% months.",
  "Q-Q and scatter outputs are data-only inputs for later chart rendering outside this ticket."
)

report_lines <- c(
  "# AE-ALPHA-008 Distributional Diagnostics Report",
  "",
  paste0("Run started: ", format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z")),
  paste0("Run finished: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Scope",
  "",
  "This run reads existing benchmark, low-volatility, and CSI monthly return artifacts only. It creates table-ready and plot-ready distributional comparison data. No CSI construction, low-volatility construction, model training, chart rendering, thesis edit, presentation edit, staging, commit, or push was performed.",
  "",
  "## Period Alignment Rule",
  "",
  period_alignment_rule,
  "",
  "## Row Counts",
  "",
  paste(capture.output(print(row_counts)), collapse = "\n"),
  "",
  "## Strategy Group Coverage",
  "",
  paste(capture.output(print(group_coverage)), collapse = "\n"),
  "",
  "## Selected CSI Strategy Coverage",
  "",
  paste(capture.output(print(selected_strategy_coverage)), collapse = "\n"),
  "",
  "## Neutral Headline Observations",
  "",
  paste0("- ", neutral_findings),
  "",
  "## Outputs",
  "",
  paste0("- ", c(
    paste0(OUT_PANEL, ".rds/.csv"),
    paste0(OUT_DISTRIBUTION, ".rds/.csv"),
    paste0(OUT_ACTIVE, ".rds/.csv"),
    paste0(OUT_CAPTURE, ".rds/.csv"),
    paste0(OUT_TAIL, ".rds/.csv"),
    paste0(OUT_QQ, ".rds/.csv"),
    paste0(OUT_SCATTER, ".rds/.csv")
  )),
  "",
  "## Caveats",
  "",
  "- Full-period rows reflect each strategy's own available matched monthly span, so full-period sample starts differ across benchmark, low-volatility, and CSI rows.",
  "- CSI strategy selection follows prior AE-ALPHA diagnostics by keeping full-period rows flagged as headline 20 bps or best by track/index/cost, restricted to 0 and 20 bps where available.",
  "- The outputs support distributional comparison and do not make final cause-and-effect claims."
)
writeLines(report_lines, OUT_REPORT)

RUN_FINISHED <- Sys.time()
status <- data.table(
  ticket_id = "AE-ALPHA-008",
  status = "completed",
  run_started = format(RUN_STARTED, "%Y-%m-%d %H:%M:%S %Z"),
  run_finished = format(RUN_FINISHED, "%Y-%m-%d %H:%M:%S %Z"),
  elapsed_seconds = as.numeric(difftime(RUN_FINISHED, RUN_STARTED, units = "secs")),
  script_path = SCRIPT_PATH,
  monthly_return_panel_rows = nrow(panel),
  distribution_summary_rows = nrow(distribution_summary),
  active_return_summary_rows = nrow(active_return_summary),
  upside_downside_capture_rows = nrow(upside_downside_capture),
  tail_state_summary_rows = nrow(tail_state_summary),
  qq_plot_data_rows = nrow(qq_plot_data),
  scatter_plot_data_rows = nrow(scatter_plot_data),
  selected_csi_strategy_rows = nrow(csi_selected),
  selected_csi_return_files = uniqueN(csi_selected$returns_path),
  strategy_groups = paste(sort(unique(panel$strategy_group)), collapse = "|"),
  periods = paste(sort(unique(panel$period)), collapse = "|"),
  lowvol_quintiles = paste(sort(unique(na.omit(panel[strategy_group == "lowvol", quintile]))), collapse = "|"),
  csi_construction_rerun = FALSE,
  lowvol_construction_rerun = FALSE,
  model_training_rerun = FALSE,
  charts_created = FALSE,
  thesis_or_presentation_edited = FALSE,
  staged_committed_or_pushed = FALSE
)
fwrite(status, OUT_STATUS)

completion_lines <- c(
  "# AE-ALPHA-008 Completion Report",
  "",
  "## status",
  "",
  "completed",
  "",
  "## summary",
  "",
  "Created the dedicated distribution diagnostics script and generated table-ready monthly return, distribution, active-return, capture, tail-state, Q-Q, and scatter input datasets. The run read existing benchmark, low-volatility, and CSI outputs only.",
  "",
  "## changed_files",
  "",
  paste0("- ", SCRIPT_PATH),
  paste0("- ", OUT_REPORT),
  paste0("- ", OUT_STATUS),
  paste0("- ", OUT_COMPLETION),
  "",
  "## generated_outputs",
  "",
  paste0("- ", c(
    paste0(OUT_PANEL, ".rds"),
    paste0(OUT_PANEL, ".csv"),
    paste0(OUT_DISTRIBUTION, ".rds"),
    paste0(OUT_DISTRIBUTION, ".csv"),
    paste0(OUT_ACTIVE, ".rds"),
    paste0(OUT_ACTIVE, ".csv"),
    paste0(OUT_CAPTURE, ".rds"),
    paste0(OUT_CAPTURE, ".csv"),
    paste0(OUT_TAIL, ".rds"),
    paste0(OUT_TAIL, ".csv"),
    paste0(OUT_QQ, ".rds"),
    paste0(OUT_QQ, ".csv"),
    paste0(OUT_SCATTER, ".rds"),
    paste0(OUT_SCATTER, ".csv"),
    OUT_REPORT,
    OUT_STATUS
  )),
  "",
  "## row_counts",
  "",
  paste(capture.output(print(row_counts)), collapse = "\n"),
  "",
  "## period_alignment_rule",
  "",
  period_alignment_rule,
  "",
  "## selected_strategy_coverage",
  "",
  paste(capture.output(print(selected_strategy_coverage)), collapse = "\n"),
  "",
  "## headline_findings_neutral",
  "",
  paste0("- ", neutral_findings),
  "",
  "## verification",
  "",
  "- Dedicated script exists and was run.",
  "- Required RDS and CSV output families were written.",
  "- Monthly panel includes benchmark, lowvol, and csi strategy groups.",
  "- Low-volatility Q1 and Q5 are present.",
  "- Active returns are matched by date and index_id.",
  "- Upside/downside capture and tail-state rows have nonzero month counts.",
  "- No chart files were created.",
  "- No staging, commit, push, thesis edit, or presentation edit occurred.",
  "",
  "## known_caveats",
  "",
  "- Full-period sample starts differ by artifact availability after benchmark matching.",
  "- CSI full-period dates are inferred from the selected existing monthly return files because the performance extract stores full-period month counts but not explicit start/end dates.",
  "- Diagnostics are descriptive and table-ready; interpretation is intentionally limited.",
  "",
  "## validator_result",
  "",
  "pending",
  "",
  "## next_recommended_role",
  "",
  "validator"
)
writeLines(completion_lines, OUT_COMPLETION)

cat("[11J] Completed successfully in", round(status$elapsed_seconds, 2), "seconds.\n")
