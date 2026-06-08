#==============================================================================#
#==== 11E_LowVolatility_Quintiles.R ==========================================#
#==== AE-ALPHA-003 Low-Volatility Quintile Portfolio Builder ==================#
#==============================================================================#

args_file <- commandArgs(trailingOnly = FALSE)
file_arg <- args_file[grepl("^--file=", args_file)]
SCRIPT_PATH <- if (length(file_arg) > 0L) {
  normalizePath(sub("^--file=", "", file_arg[[1L]]), mustWork = FALSE)
} else {
  normalizePath("11E_LowVolatility_Quintiles.R", mustWork = FALSE)
}
SCRIPT_DIR <- dirname(SCRIPT_PATH)
source(file.path(SCRIPT_DIR, "config.R"))

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[11E_LowVolatility_Quintiles.R] START:", format(Sys.time()), "\n")

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L || all(is.na(a))) b else a

RUN_STARTED <- Sys.time()
TRANSACTION_COST_BPS <- c(0, 5, 10, 20)
MIN_VALID_RETURNS <- 24L
MAX_LOOKBACK_MONTHS <- 60L

PATH_CRSP_CONSTITUENTS <- file.path(
  DIR_IDXREP_NEC,
  "crsp_like_index_constituents_quarterly.rds"
)
PATH_CRSP_INDEX_RETURNS <- file.path(
  DIR_IDXREP_NEC,
  "crsp_like_index_returns_monthly.rds"
)

OUT_ROOT <- file.path(
  DIR_MODELLING_NEC,
  "alpha_validation"
)
OUT_DIRS <- list(
  inputs_manifest = file.path(OUT_ROOT, "inputs_manifest"),
  volatility_quintiles = file.path(OUT_ROOT, "volatility_quintiles"),
  weights = file.path(OUT_ROOT, "weights"),
  returns = file.path(OUT_ROOT, "returns"),
  turnover_costs = file.path(OUT_ROOT, "turnover_costs"),
  reports = file.path(OUT_ROOT, "reports")
)
invisible(lapply(OUT_DIRS, dir.create, recursive = TRUE, showWarnings = FALSE))

PATH_MANIFEST_RDS <- file.path(OUT_DIRS$inputs_manifest, "lowvol_inputs_manifest.rds")
PATH_MANIFEST_CSV <- file.path(OUT_DIRS$inputs_manifest, "lowvol_inputs_manifest.csv")
PATH_QUINTILES_RDS <- file.path(OUT_DIRS$volatility_quintiles, "lowvol_volatility_quintiles.rds")
PATH_QUINTILES_CSV <- file.path(OUT_DIRS$volatility_quintiles, "lowvol_volatility_quintiles.csv")
PATH_WEIGHTS_RDS <- file.path(OUT_DIRS$weights, "lowvol_target_weights.rds")
PATH_WEIGHTS_CSV <- file.path(OUT_DIRS$weights, "lowvol_target_weights.csv")
PATH_RETURNS_RDS <- file.path(OUT_DIRS$returns, "lowvol_monthly_returns_gross_net_by_tc.rds")
PATH_RETURNS_CSV <- file.path(OUT_DIRS$returns, "lowvol_monthly_returns_gross_net_by_tc.csv")
PATH_TURNOVER_RDS <- file.path(OUT_DIRS$turnover_costs, "lowvol_turnover_costs_by_month.rds")
PATH_TURNOVER_CSV <- file.path(OUT_DIRS$turnover_costs, "lowvol_turnover_costs_by_month.csv")
PATH_STATUS <- file.path(OUT_DIRS$reports, "lowvol_run_status.csv")

fn_write_csv <- function(dt, path) {
  fwrite(dt, path)
}

fn_stop_missing <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0L) {
    stop("Missing required inputs:\n", paste(missing, collapse = "\n"))
  }
}

fn_file_manifest <- function(paths) {
  rbindlist(lapply(names(paths), function(nm) {
    info <- file.info(paths[[nm]])
    data.table(
      input_name = nm,
      path = normalizePath(paths[[nm]], winslash = "/", mustWork = FALSE),
      exists = file.exists(paths[[nm]]),
      size_bytes = as.numeric(info$size),
      modified_time = as.character(info$mtime)
    )
  }), use.names = TRUE)
}

fn_turnover_event <- function(target_holdings, pre_trade_holdings) {
  target <- copy(target_holdings[, .(permno, target_w = w)])
  if (is.null(pre_trade_holdings) || nrow(pre_trade_holdings) == 0L) {
    target[, pre_trade_w := 0]
    is_initial <- TRUE
  } else {
    pre <- copy(pre_trade_holdings[, .(permno, pre_trade_w = w)])
    target <- merge(target, pre, by = "permno", all = TRUE)
    is_initial <- FALSE
  }
  target[is.na(target_w), target_w := 0]
  target[is.na(pre_trade_w), pre_trade_w := 0]
  target[, delta_w := target_w - pre_trade_w]
  turnover_buy <- sum(pmax(target$delta_w, 0), na.rm = TRUE)
  turnover_sell <- sum(abs(pmin(target$delta_w, 0)), na.rm = TRUE)
  data.table(
    turnover_buy = turnover_buy,
    turnover_sell = turnover_sell,
    turnover_gross = turnover_buy + turnover_sell,
    turnover_one_way = 0.5 * (turnover_buy + turnover_sell),
    is_initial_formation = is_initial,
    turnover_basis = if (is_initial) "initial_target_weights" else "drifted_pre_trade_to_target"
  )
}

fn_compute_quintile_returns <- function(w_s, sk, monthly, monthly_dates, max_monthly_date) {
  qdates <- sort(unique(w_s$qdate))
  out <- vector("list", length(qdates) * 3L)
  out_i <- 0L
  pre_trade_holdings <- NULL

  for (qi in seq_along(qdates)) {
    qd <- qdates[qi]
    next_qd <- if (qi < length(qdates)) qdates[qi + 1L] else max_monthly_date
    hdates <- monthly_dates[monthly_dates > qd & monthly_dates <= next_qd]
    if (length(hdates) == 0L) next

    target_holdings <- copy(w_s[qdate == qd, .(permno, w)])
    turnover_event <- fn_turnover_event(target_holdings, pre_trade_holdings)
    holdings <- copy(target_holdings)
    setorder(holdings, permno)
    n_holdings_start <- nrow(holdings)
    if (n_holdings_start == 0L) next

    for (hi in seq_along(hdates)) {
      hd <- as.Date(hdates[hi], origin = "1970-01-01")
      active <- merge(
        holdings,
        monthly[date == hd, .(permno, ret, dlret_applied)],
        by = "permno",
        all.x = FALSE
      )
      active <- active[is.finite(ret) & !is.na(w)]
      pre_weight_sum <- sum(active$w, na.rm = TRUE)
      if (!is.finite(pre_weight_sum) || pre_weight_sum <= 0) break

      active[, w_pre := w / pre_weight_sum]
      gross_return <- sum(active$w_pre * active$ret, na.rm = TRUE)
      month_turnover <- if (hi == 1L) turnover_event else data.table(
        turnover_buy = 0,
        turnover_sell = 0,
        turnover_gross = 0,
        turnover_one_way = 0,
        is_initial_formation = FALSE,
        turnover_basis = "no_rebalance"
      )

      out_i <- out_i + 1L
      out[[out_i]] <- cbind(data.table(
        track = "lowvol_quintile",
        universe = sk$index_id,
        strategy = sk$portfolio_id,
        index_id = sk$index_id,
        index_name = sk$index_name,
        date = hd,
        rebalance_date = qd,
        qdate = qd,
        year = as.integer(format(hd, "%Y")),
        month = as.integer(format(hd, "%m")),
        portfolio_id = sk$portfolio_id,
        strategy_id = sk$portfolio_id,
        quintile = sk$quintile,
        quintile_num = sk$quintile_num,
        weighting = "cap_weighted_within_quintile",
        gross_return = gross_return,
        port_ret = gross_return,
        n_holdings_start = n_holdings_start,
        n_holdings_with_return = nrow(active),
        active_weight_before_rescale = pre_weight_sum
      ), month_turnover)

      active[, post_value := w_pre * (1 + ret)]
      active <- active[
        is.finite(post_value) & post_value > 0 & !isTRUE(dlret_applied),
        .(permno, w = post_value)
      ]
      if (nrow(active) == 0L) break
      active[, w := w / sum(w, na.rm = TRUE)]
      holdings <- active
    }
    pre_trade_holdings <- holdings
  }

  rbindlist(out[seq_len(out_i)], use.names = TRUE, fill = TRUE)
}

required_inputs <- c(
  prices_monthly = PATH_PRICES_MONTHLY,
  crsp_like_index_constituents_quarterly = PATH_CRSP_CONSTITUENTS,
  crsp_like_index_returns_monthly = PATH_CRSP_INDEX_RETURNS
)
fn_stop_missing(unname(required_inputs))

manifest <- fn_file_manifest(required_inputs)
manifest[, `:=`(
  run_started = as.character(RUN_STARTED),
  script = normalizePath(SCRIPT_PATH, winslash = "/", mustWork = FALSE),
  output_root = normalizePath(OUT_ROOT, winslash = "/", mustWork = FALSE),
  return_field = "ret_adj",
  rebalance_cadence = "quarterly",
  lookback_months = MAX_LOOKBACK_MONTHS,
  min_valid_returns = MIN_VALID_RETURNS,
  transaction_cost_bps = paste(TRANSACTION_COST_BPS, collapse = "|")
)]
saveRDS(manifest, PATH_MANIFEST_RDS)
fn_write_csv(manifest, PATH_MANIFEST_CSV)

cat("[11E] Loading required inputs...\n")
monthly <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
if (!inherits(monthly$date, "Date")) monthly[, date := as.Date(date)]
monthly[, ret := pmax(as.numeric(ret_adj), -1)]
monthly[, dlret_applied := as.logical(dlret_applied %||% FALSE)]
monthly <- monthly[
  !is.na(permno) & !is.na(date),
  .(
    permno = as.integer(permno),
    date,
    ret,
    dlret_applied
  )
]
monthly[!is.finite(ret), ret := NA_real_]
setkey(monthly, permno, date)

constituents <- as.data.table(readRDS(PATH_CRSP_CONSTITUENTS))
if (!inherits(constituents$qdate, "Date")) constituents[, qdate := as.Date(qdate)]
constituents <- constituents[!is.na(permno), .(
  qdate,
  index_id,
  index_name,
  permno = as.integer(permno),
  permco = as.integer(permco),
  size_segment,
  security_mktcap = as.numeric(security_mktcap),
  benchmark_weight = as.numeric(weight)
)]
constituents[, `:=`(
  q_year = as.integer(format(qdate, "%Y")),
  q_month = as.integer(format(qdate, "%m")),
  holding_year = year(qdate %m+% months(1L)),
  signal_start_date = qdate %m-% months(MAX_LOOKBACK_MONTHS)
)]
constituents[, cap_source_value := fifelse(
  is.finite(security_mktcap) & security_mktcap > 0,
  security_mktcap,
  fifelse(is.finite(benchmark_weight) & benchmark_weight > 0, benchmark_weight, NA_real_)
)]
constituents[, cap_source := fifelse(
  is.finite(security_mktcap) & security_mktcap > 0,
  "security_mktcap",
  fifelse(is.finite(benchmark_weight) & benchmark_weight > 0, "benchmark_weight", NA_character_)
)]
setorder(constituents, index_id, qdate, permno)

cat(sprintf(
  "  Monthly rows: %d | constituent rows: %d | index-quarter groups: %d\n",
  nrow(monthly), nrow(constituents), uniqueN(constituents[, .(index_id, qdate)])
))

cat("[11E] Computing trailing volatility signals with no look-ahead...\n")
signal_windows <- unique(constituents[, .(
  permno,
  qdate,
  signal_start_date
)])
setkey(signal_windows, permno, signal_start_date, qdate)
vol_source <- monthly[is.finite(ret), .(permno, ret_date = date, ret)]
setkey(vol_source, permno, ret_date)
vol_join <- vol_source[
  signal_windows,
  on = .(permno, ret_date >= signal_start_date, ret_date < qdate),
  nomatch = 0L,
  allow.cartesian = TRUE
]
volatility <- vol_join[, .(
  n_valid_returns = .N,
  trailing_volatility = sd(ret)
), by = .(permno, qdate = ret_date.1)]
volatility <- volatility[
  n_valid_returns >= MIN_VALID_RETURNS &
    is.finite(trailing_volatility)
]

quintiles <- merge(
  constituents,
  volatility,
  by = c("permno", "qdate"),
  all.x = FALSE
)
quintiles <- quintiles[is.finite(cap_source_value) & cap_source_value > 0]
setorder(quintiles, index_id, qdate, trailing_volatility, -cap_source_value, permno)
quintiles[, eligible_count := .N, by = .(qdate, index_id)]
quintiles <- quintiles[eligible_count >= 5L]
quintiles[, rank_in_index := seq_len(.N), by = .(qdate, index_id)]
quintiles[, quintile_num := pmin(5L, floor((rank_in_index - 1L) * 5L / eligible_count) + 1L)]
quintiles[, quintile := paste0("Q", quintile_num)]
quintiles[, portfolio_id := paste0("lowvol_", quintile)]
quintiles[, volatility_signal_date := qdate]
quintiles_out <- quintiles[, .(
  track = "lowvol_quintile",
  index_id,
  index_name,
  qdate,
  q_year,
  q_month,
  holding_year,
  volatility_signal_date,
  permno,
  permco,
  size_segment,
  security_mktcap,
  benchmark_weight,
  cap_source,
  cap_source_value,
  n_valid_returns,
  trailing_volatility,
  eligible_count,
  rank_in_index,
  quintile,
  quintile_num,
  portfolio_id
)]
setorder(quintiles_out, index_id, qdate, quintile_num, rank_in_index)

cat("[11E] Building capitalization-weighted quintile targets...\n")
weights <- copy(quintiles_out)
weights[, w := cap_source_value / sum(cap_source_value, na.rm = TRUE),
        by = .(qdate, index_id, quintile)]
weights <- weights[is.finite(w) & w > 0]
weights_out <- weights[, .(
  track,
  index_id,
  index_name,
  qdate,
  q_year,
  q_month,
  holding_year,
  permno,
  permco,
  size_segment,
  security_mktcap,
  benchmark_weight,
  cap_source,
  cap_source_value,
  n_valid_returns,
  trailing_volatility,
  eligible_count,
  rank_in_index,
  quintile,
  quintile_num,
  portfolio_id,
  strategy_id = portfolio_id,
  weighting = "cap_weighted_within_quintile",
  w
)]
setorder(weights_out, index_id, qdate, quintile_num, -w, permno)

saveRDS(quintiles_out, PATH_QUINTILES_RDS)
fn_write_csv(quintiles_out, PATH_QUINTILES_CSV)
saveRDS(weights_out, PATH_WEIGHTS_RDS)
fn_write_csv(weights_out, PATH_WEIGHTS_CSV)
cat(sprintf(
  "  Saved volatility rows: %d | target weight rows: %d\n",
  nrow(quintiles_out), nrow(weights_out)
))

cat("[11E] Computing monthly drifted quintile returns and turnover...\n")
monthly_dates <- sort(unique(monthly[is.finite(ret), date]))
max_monthly_date <- max(monthly_dates)
strategies <- unique(weights_out[, .(
  index_id,
  index_name,
  quintile,
  quintile_num,
  portfolio_id
)])
setorder(strategies, index_id, quintile_num)

ret_list <- vector("list", nrow(strategies))
for (i in seq_len(nrow(strategies))) {
  sk <- strategies[i]
  w_s <- weights_out[
    index_id == sk$index_id & quintile == sk$quintile,
    .(qdate, permno, w)
  ]
  ret_list[[i]] <- fn_compute_quintile_returns(
    w_s = w_s,
    sk = sk,
    monthly = monthly,
    monthly_dates = monthly_dates,
    max_monthly_date = max_monthly_date
  )
  if (i %% 5L == 0L || i == nrow(strategies)) {
    cat(sprintf("  %d/%d low-volatility portfolios\n", i, nrow(strategies)))
  }
}

returns_gross <- rbindlist(ret_list, use.names = TRUE, fill = TRUE)
setorder(returns_gross, index_id, quintile_num, date)
returns_gross[, cumulative_gross_index := cumprod(1 + gross_return),
              by = .(index_id, portfolio_id)]

turnover_by_month <- returns_gross[, .(
  track,
  universe,
  strategy,
  index_id,
  index_name,
  date,
  rebalance_date,
  qdate,
  year,
  month,
  portfolio_id,
  strategy_id,
  quintile,
  quintile_num,
  weighting,
  turnover_buy,
  turnover_sell,
  turnover_gross,
  turnover_one_way,
  is_initial_formation,
  turnover_basis
)]

returns_tc <- rbindlist(lapply(TRANSACTION_COST_BPS, function(bps) {
  out <- copy(returns_gross)
  out[, transaction_cost_bps := as.numeric(bps)]
  out[, transaction_cost_return_drag := turnover_gross * transaction_cost_bps / 10000]
  out[, net_return := gross_return - transaction_cost_return_drag]
  out[]
}), use.names = TRUE, fill = TRUE)
setorder(returns_tc, index_id, quintile_num, transaction_cost_bps, date)
returns_tc[, cumulative_net_index := cumprod(1 + net_return),
           by = .(index_id, portfolio_id, transaction_cost_bps)]

turnover_costs <- rbindlist(lapply(TRANSACTION_COST_BPS, function(bps) {
  out <- copy(turnover_by_month)
  out[, transaction_cost_bps := as.numeric(bps)]
  out[, transaction_cost_return_drag := turnover_gross * transaction_cost_bps / 10000]
  out[]
}), use.names = TRUE, fill = TRUE)
setorder(turnover_costs, index_id, quintile, transaction_cost_bps, date)

saveRDS(returns_tc, PATH_RETURNS_RDS)
fn_write_csv(returns_tc, PATH_RETURNS_CSV)
saveRDS(turnover_costs, PATH_TURNOVER_RDS)
fn_write_csv(turnover_costs, PATH_TURNOVER_CSV)
cat(sprintf(
  "  Saved return rows: %d | turnover/cost rows: %d\n",
  nrow(returns_tc), nrow(turnover_costs)
))

weight_check <- weights_out[, .(weight_sum = sum(w), n = .N),
                            by = .(qdate, index_id, quintile)]
count_check <- quintiles_out[, .(n = .N), by = .(qdate, index_id, quintile)]
count_spread <- count_check[, .(
  min_quintile_count = min(n),
  max_quintile_count = max(n),
  count_spread = max(n) - min(n)
), by = .(qdate, index_id)]

RUN_FINISHED <- Sys.time()
status <- data.table(
  ticket_id = "AE-ALPHA-003",
  status = "completed",
  run_started = as.character(RUN_STARTED),
  run_finished = as.character(RUN_FINISHED),
  elapsed_seconds = as.numeric(difftime(RUN_FINISHED, RUN_STARTED, units = "secs")),
  script = normalizePath(SCRIPT_PATH, winslash = "/", mustWork = FALSE),
  output_root = normalizePath(OUT_ROOT, winslash = "/", mustWork = FALSE),
  n_monthly_rows = nrow(monthly),
  n_constituent_rows = nrow(constituents),
  n_volatility_rows = nrow(quintiles_out),
  n_weight_rows = nrow(weights_out),
  n_return_rows = nrow(returns_tc),
  n_turnover_cost_rows = nrow(turnover_costs),
  n_index_quarters = uniqueN(weights_out[, .(index_id, qdate)]),
  n_portfolios = uniqueN(weights_out[, .(index_id, portfolio_id)]),
  min_weight_sum = min(weight_check$weight_sum, na.rm = TRUE),
  max_weight_sum = max(weight_check$weight_sum, na.rm = TRUE),
  max_abs_weight_sum_error = max(abs(weight_check$weight_sum - 1), na.rm = TRUE),
  max_quintile_count_spread = max(count_spread$count_spread, na.rm = TRUE),
  min_turnover_gross = min(turnover_costs$turnover_gross, na.rm = TRUE),
  max_turnover_gross = max(turnover_costs$turnover_gross, na.rm = TRUE),
  transaction_cost_bps = paste(sort(unique(returns_tc$transaction_cost_bps)), collapse = "|")
)
fn_write_csv(status, PATH_STATUS)

cat("[11E] COMPLETE:", format(RUN_FINISHED), "\n")
print(status)
