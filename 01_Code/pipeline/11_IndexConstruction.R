#==============================================================================#
#==== 11_IndexConstruction.R ==================================================#
#==== Crash-Filtered Index Construction - AutoGluon Raw CSI Overlay ===========#
#==============================================================================#
#
# PURPOSE:
#   Construct and backtest a crash-filtered equity index for the active CSI
#   response track using the AutoGluon ag_raw prediction files created by 09C.
#
# STRATEGY MATRIX:
#   Benchmark   : BENCH-MW
#   CSI model   : AutoGluon ag_raw
#   Thresholds  : CV FPR <= 1%, CV FPR <= 3%, CV Youden J
#   Rules       : dynamic_csi uses 1/2/3/5-year lockouts;
#                 permanent_csi uses absorbing permanent removal
#
# EXCLUSION RULE:
#   For dynamic_csi, a firm is excluded in holding year H if ag_raw flagged it
#   in any signal year from H - lockout_years through H - 1.
#   For permanent_csi, a firm is excluded in holding year H if ag_raw flagged
#   it in any signal year through H - 1; the exclusion is absorbing from the
#   first excluded holding year onward. Thresholds are estimated on CV
#   predictions only, never on test/OOS data.
#
# INDEX DESIGN:
#   Universe   : Top 3000 by prior December market cap, min $100M.
#   Rebalancing: Quarterly (Mar/Jun/Sep/Dec), invested from next month.
#   Signal     : Annual (Compustat-based — stable within year).
#   Weighting  : MW (market-cap weight).
#
# INPUTS:
#   config.R, PATH_PRICES_MONTHLY
#   DIR_TABLES/AutoGluon/<RESPONSE_TRACK>/ag_{key}/ag_cv_results.parquet
#   DIR_TABLES/AutoGluon/<RESPONSE_TRACK>/ag_{key}/ag_preds_test.parquet
#   DIR_TABLES/AutoGluon/<RESPONSE_TRACK>/ag_{key}/ag_preds_oos.parquet
#   DIR_TABLES/AutoGluon/<RESPONSE_TRACK>/ag_{key}/ag_preds_train_boundary.parquet
#
# OUTPUTS:
#   DIR_TABLES/<RESPONSE_TRACK>/11_index/index_weights.rds
#   DIR_TABLES/<RESPONSE_TRACK>/11_index/index_returns.rds
#   DIR_TABLES/<RESPONSE_TRACK>/11_index/index_performance.rds
#   DIR_TABLES/<RESPONSE_TRACK>/11_index/index_exclusion_summary.rds
#   DIR_TABLES/<RESPONSE_TRACK>/11_index/error_cost_decomposition.rds
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(scales)
  library(lubridate)
})

cat("\n[11_IndexConstruction.R] START:", format(Sys.time()), "\n")
FIGS <- fn_setup_figure_dirs()

INDEX_TABLE_DIR <- DIR_TABLES_INDEX_TRACK
INDEX_FIG_DIR   <- file.path(FIGS$index_general, RESPONSE_TRACK)
dir.create(INDEX_TABLE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(INDEX_FIG_DIR, recursive = TRUE, showWarnings = FALSE)

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
## Safe lookup for named vectors (returns NULL, not error, on missing key)
vlookup <- function(vec, key) {
  if (is.null(key) || !nzchar(key) || !(key %in% names(vec))) return(NULL)
  vec[[key]]
}
fn_write_csv <- function(dt, path) {
  tryCatch(
    fwrite(dt, path),
    error = function(e) {
      alt <- sub("\\.csv$", paste0("_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv"), path)
      warning(sprintf(
        "[11] Could not write %s; writing fallback CSV %s. Original error: %s",
        path, alt, conditionMessage(e)
      ))
      fwrite(dt, alt)
    }
  )
}

HAS_ARROW <- requireNamespace("arrow", quietly=TRUE)

fn_read_parquet <- function(path) {
  if (HAS_ARROW) {
    return(as.data.table(arrow::read_parquet(path)))
  }

  tmp <- tempfile(fileext=".csv")
  py_file <- tempfile(fileext=".py")
  on.exit(unlink(c(tmp, py_file)), add=TRUE)
  writeLines(c(
    "import pandas as pd",
    "import sys",
    "pd.read_parquet(sys.argv[1]).to_csv(sys.argv[2], index=False)"
  ), py_file)
  status <- system2("python", c(py_file, path, tmp))
  if (!identical(status, 0L)) {
    stop(sprintf("Python parquet fallback failed for %s", path))
  }
  as.data.table(utils::read.csv(tmp, stringsAsFactors = FALSE, check.names = FALSE))
}

## ── Parameters ───────────────────────────────────────────────────────────────
UNIVERSE_SIZE  <- 3000L
MIN_MKTCAP_MM  <- 100
RF_ANNUAL      <- 0.03
REBAL_MONTHS   <- c(3L, 6L, 9L, 12L)
UNIVERSE_MONTH <- 12L
TC_BPS         <- 0L

MODEL_KEY <- "raw"
THRESHOLD_METHODS <- c(
  fpr1 = "CV FPR <= 1%",
  fpr3 = "CV FPR <= 3%",
  youden = "CV Youden J"
)
LOCKOUT_YEARS <- c("1yr" = 1L, "2yr" = 2L, "3yr" = 3L, "5yr" = 5L)
IS_PERMANENT_TRACK <- identical(RESPONSE_TRACK, "permanent_csi")
EXCLUSION_RULES <- if (IS_PERMANENT_TRACK) {
  data.table(
    rule_id = "permanent",
    lockout_years = 0L,
    exclusion_rule = "permanent_removal",
    rule_label = "Permanent removal"
  )
} else {
  data.table(
    rule_id = names(LOCKOUT_YEARS),
    lockout_years = as.integer(LOCKOUT_YEARS),
    exclusion_rule = paste0("lockout_", names(LOCKOUT_YEARS)),
    rule_label = paste0(names(LOCKOUT_YEARS), " lockout")
  )
}

INSAMPLE_START <- 1998L
OOS_END        <- 2024L

## ── Short names for display (not in config.R) ────────────────────────────────
MODEL_SHORTS <- c(raw = "raw")

INDEX_MODEL_LABELS <- c(raw = "AutoGluon raw")
MODEL_LABELS[names(INDEX_MODEL_LABELS)] <- INDEX_MODEL_LABELS
MODEL_TRACK[names(INDEX_MODEL_LABELS)] <- RESPONSE_TRACK

## ── AutoGluon model key used for this index experiment ───────────────────────
ALL_MODEL_KEYS <- names(INDEX_MODEL_LABELS)

## Active CSI score strategy.
SIMPLE_KEYS <- MODEL_KEY

## Keys needed for predictions.
COMBO_STRATS <- list()
PRED_KEYS <- SIMPLE_KEYS

#==============================================================================#
# 1. Monthly prices
#==============================================================================#

cat("[11] Loading monthly prices...\n")
monthly <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
setnames(monthly, "ret_adj", "ret", skip_absent = TRUE)
setnames(monthly, "mktcap",  "mkvalt", skip_absent = TRUE)
monthly[, year  := year(date)]
monthly[, month := month(date)]
if (!inherits(monthly$date, "Date")) monthly[, date := as.Date(date)]
monthly[!is.na(ret), ret := pmin(pmax(ret, -0.99), 10)]
cat(sprintf("  %d rows | %d permnos | %d-%d\n",
            nrow(monthly), uniqueN(monthly$permno),
            min(monthly$year), max(monthly$year)))

#==============================================================================#
# 2. Annual universe
#==============================================================================#

cat("[11] Building annual universe...\n")
dec_mv <- monthly[month == UNIVERSE_MONTH & !is.na(mkvalt),
                  .(mkvalt_dec = mkvalt[.N]), by = .(permno, year)]
universe_ann <- dec_mv[mkvalt_dec >= MIN_MKTCAP_MM]
universe_ann[, rank_mv := frank(-mkvalt_dec, ties.method="first"), by = year]
universe_ann <- universe_ann[rank_mv <= UNIVERSE_SIZE]
cat(sprintf("  %d firm-years | avg %.0f/yr | %d-%d\n",
            nrow(universe_ann),
            nrow(universe_ann) / uniqueN(universe_ann$year),
            min(universe_ann$year), max(universe_ann$year)))

#==============================================================================#
# 3. Load predictions for all required model keys
#==============================================================================#

cat("[11] Loading predictions...\n")
SRC_PRI <- c(oos=1L, test=2L, boundary=3L, cv=4L)
PREDS   <- list()

for (key in PRED_KEYS) {
  tdir <- file.path(DIR_TABLES_AUTOGLUON_TRACK, paste0("ag_", key))
  fmap <- c(
    oos      = file.path(tdir, "ag_preds_oos.parquet"),
    test     = file.path(tdir, "ag_preds_test.parquet"),
    boundary = file.path(tdir, "ag_preds_train_boundary.parquet"),
    cv       = file.path(tdir, "ag_cv_results.parquet")
  )

  parts <- Filter(Negate(is.null), lapply(names(fmap), function(nm) {
    if (!file.exists(fmap[[nm]])) return(NULL)
    dt <- fn_read_parquet(fmap[[nm]])
    dt[, src := nm][, .(permno, year, p_csi, src)]
  }))
  if (length(parts) == 0) { cat(sprintf("  [%-35s] SKIP\n", key)); next }

  comb <- rbindlist(parts)
  comb[, src_rank := SRC_PRI[src]]
  ord <- order(comb[["permno"]], comb[["year"]], comb[["src_rank"]], na.last = TRUE)
  comb <- comb[ord]
  comb <- comb[!duplicated(data.frame(permno = comb[["permno"]], year = comb[["year"]]))]
  PREDS[[key]] <- comb[, .(permno, year, p_csi)]
  cat(sprintf("  [%-35s] %d rows | %d-%d\n",
              INDEX_MODEL_LABELS[[key]] %||% key,
              nrow(PREDS[[key]]),
              min(PREDS[[key]]$year), max(PREDS[[key]]$year)))
}
cat(sprintf("  Loaded: %d/%d required models\n", length(PREDS), length(PRED_KEYS)))
if (length(PREDS) == 0L) {
  stop("No AutoGluon prediction files found for RESPONSE_TRACK=", RESPONSE_TRACK)
}
FIRST_SIGNAL_YEAR <- min(vapply(PREDS, function(x) min(x$year, na.rm = TRUE), numeric(1)))
INDEX_START <- max(INSAMPLE_START, FIRST_SIGNAL_YEAR + 1L)
cat(sprintf("  First investable holding year: %d\n", INDEX_START))
cat("  Exclusion rules:\n")
print(EXCLUSION_RULES)

#==============================================================================#
# 4. CV thresholds (no test/OOS contamination)
#==============================================================================#

cat("[11] Computing CV thresholds...\n")

fn_cv_thresholds <- function(key) {
  cv_path <- file.path(
    DIR_TABLES_AUTOGLUON_TRACK, paste0("ag_", key),
    "ag_cv_results.parquet"
  )
  if (!file.exists(cv_path)) {
    stop(sprintf("[11] CV not found for %s: %s", key, cv_path))
  }

  cv <- fn_read_parquet(cv_path)
  cv <- cv[!is.na(y) & !is.na(p_csi), .(y = as.integer(y), p_csi)]
  if (nrow(cv) < 100L || uniqueN(cv$y) < 2L) {
    stop(sprintf("[11] CV data is insufficient for thresholding: %s", key))
  }

  total_pos <- sum(cv$y == 1L)
  total_neg <- sum(cv$y == 0L)
  roc_grid <- cv[, .(
    pos = sum(y == 1L),
    neg = sum(y == 0L)
  ), by = .(threshold = p_csi)]
  setorder(roc_grid, -threshold)
  roc_grid[, `:=`(
    tp = cumsum(pos),
    fp = cumsum(neg)
  )]
  roc_grid[, `:=`(
    fn = total_pos - tp,
    tn = total_neg - fp
  )]
  roc_grid[, `:=`(
    recall = tp / total_pos,
    fpr = fp / total_neg,
    precision = fifelse(tp + fp > 0L, tp / (tp + fp), NA_real_)
  )]
  roc_grid[, youden := recall - fpr]

  fpr1 <- roc_grid[fpr <= 0.01]
  if (nrow(fpr1) == 0L) {
    stop("[11] No CV threshold satisfies FPR <= 1%.")
  }
  setorder(fpr1, -recall, fpr, -threshold)
  fpr1 <- fpr1[1L]

  fpr3 <- roc_grid[fpr <= 0.03]
  if (nrow(fpr3) == 0L) {
    stop("[11] No CV threshold satisfies FPR <= 3%.")
  }
  setorder(fpr3, -recall, fpr, -threshold)
  fpr3 <- fpr3[1L]

  youden <- copy(roc_grid)
  setorder(youden, -youden, -recall, fpr, -threshold)
  youden <- youden[1L]

  out <- rbindlist(list(
    fpr1[, .(
      model_key = key,
      threshold_method = "fpr1",
      threshold_label = THRESHOLD_METHODS[["fpr1"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )],
    fpr3[, .(
      model_key = key,
      threshold_method = "fpr3",
      threshold_label = THRESHOLD_METHODS[["fpr3"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )],
    youden[, .(
      model_key = key,
      threshold_method = "youden",
      threshold_label = THRESHOLD_METHODS[["youden"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )]
  ), use.names = TRUE)

  out[]
}

THRESHOLDS <- rbindlist(lapply(PRED_KEYS, fn_cv_thresholds), use.names = TRUE)
setorder(THRESHOLDS, model_key, threshold_method)
print(THRESHOLDS)
saveRDS(THRESHOLDS, PATH_INDEX_OPT_THRESHOLDS)
fn_write_csv(THRESHOLDS, file.path(INDEX_TABLE_DIR, "index_thresholds.csv"))

#==============================================================================#
# 5. Build quarterly weights
#==============================================================================#

cat("\n[11] Building quarterly weights...\n")

q_dates <- monthly[month %in% REBAL_MONTHS,
                   .(qdate = max(date)), by = .(year, month)]
setorder(q_dates, qdate)
q_dates[, holding_year := year(qdate %m+% months(1L))]
q_dates[, signal_year := holding_year - 1L]
q_dates <- q_dates[holding_year >= INDEX_START & holding_year <= OOS_END]
N_Q     <- nrow(q_dates)

## Helper: given universe dt (permno, mkvalt_dec) and an exclusion flag vector,
## return market-cap-weighted rows.
fn_weights <- function(uni, excl_flag, qdate, q_yr, q_mo, holding_year,
                       signal_year, model_key, threshold_method,
                       lockout_years, strategy_id,
                       exclusion_rule, rule_label) {
  incl <- uni[!excl_flag]
  if (nrow(incl) == 0L) return(NULL)
  sm <- sum(incl$mkvalt_dec, na.rm=TRUE)
  data.table(
    permno=incl$permno, mkvalt_dec=incl$mkvalt_dec,
    qdate=qdate, q_year=q_yr, q_month=q_mo,
    holding_year=holding_year, signal_year=signal_year,
    model_key=model_key,
    threshold_method=threshold_method,
    lockout_years=lockout_years,
    strategy_id=strategy_id,
    exclusion_rule=exclusion_rule,
    rule_label=rule_label,
    excl_rate=strategy_id,
    weighting="mw",
    w=incl$mkvalt_dec / sm
  )
}

## Helper: compute exclusion flag for a single model and exclusion rule.
## Returns logical vector aligned to uni (permno order).
fn_excl_flag <- function(uni, p_key, pred_yr, method,
                         lockout_years, exclusion_rule) {
  p <- PREDS[[p_key]]
  if (is.null(p)) return(rep(FALSE, nrow(uni)))
  thresh <- THRESHOLDS[
    model_key == p_key & threshold_method == method,
    threshold
  ]
  if (length(thresh) != 1L || is.na(thresh)) return(rep(FALSE, nrow(uni)))

  if (identical(exclusion_rule, "permanent_removal")) {
    signal_years <- seq.int(FIRST_SIGNAL_YEAR, pred_yr)
  } else {
    signal_years <- seq.int(pred_yr - lockout_years + 1L, pred_yr)
  }
  p_window <- p[
    year %in% signal_years & !is.na(p_csi) & p_csi >= thresh,
    .(permno)
  ]
  p_window <- unique(p_window)
  u <- merge(uni[, .(permno)], p_window[, flagged := TRUE], by="permno", all.x=TRUE)
  setorder(u, permno); setorder(uni, permno)  # ensure alignment
  !is.na(u$flagged)
}

w_list <- list()
entry  <- 0L

for (i in seq_len(N_Q)) {
  q_yr  <- q_dates$year[i]
  q_mo  <- q_dates$month[i]
  qdate <- q_dates$qdate[i]
  holding_year <- q_dates$holding_year[i]
  pred_yr <- q_dates$signal_year[i]

  uni_q <- universe_ann[year == pred_yr, .(permno, mkvalt_dec)]
  if (nrow(uni_q) == 0L) next
  setorder(uni_q, permno)

  ## ── Benchmarks ─────────────────────────────────────────────────────────────
  entry <- entry + 1L
  w_list[[entry]] <- fn_weights(uni_q, rep(FALSE, nrow(uni_q)),
                                qdate, q_yr, q_mo, holding_year, pred_yr,
                                "bench", "benchmark", 0L, "bench_mw",
                                "benchmark", "Benchmark")

  ## ── ag_raw threshold x exclusion-rule strategies ──────────────────────────
  for (key in SIMPLE_KEYS) {
    if (is.null(PREDS[[key]])) next
    for (method in names(THRESHOLD_METHODS)) {
      for (rule_i in seq_len(nrow(EXCLUSION_RULES))) {
        rule <- EXCLUSION_RULES[rule_i]
        lock_n <- rule$lockout_years
        strategy_id <- paste(method, rule$rule_id, sep = "_")
        flag <- fn_excl_flag(
          uni_q, key, pred_yr, method, lock_n, rule$exclusion_rule
        )
        entry <- entry + 1L
        w_list[[entry]] <- fn_weights(
          uni_q, flag, qdate, q_yr, q_mo, holding_year, pred_yr,
          key, method, lock_n, strategy_id,
          rule$exclusion_rule, rule$rule_label
        )
      }
    }
  }

  if (i %% 20 == 0 || i == N_Q) cat(sprintf("  %d/%d quarters\n", i, N_Q))
}

weights_all <- rbindlist(w_list, use.names=TRUE, fill=TRUE)
setorder(weights_all, model_key, strategy_id, weighting, qdate, permno)
saveRDS(weights_all, PATH_INDEX_WEIGHTS)
fn_write_csv(weights_all, file.path(INDEX_TABLE_DIR, "index_weights.csv"))
cat(sprintf("  Weights: %d rows saved\n", nrow(weights_all)))

#==============================================================================#
# 6. Monthly portfolio returns
#==============================================================================#

cat("\n[11] Computing monthly returns...\n")
strats  <- unique(weights_all[, .(
  model_key, threshold_method, lockout_years, strategy_id,
  exclusion_rule, rule_label, excl_rate, weighting
)])
N_S     <- nrow(strats)
ret_list <- vector("list", N_S)

for (i in seq_len(N_S)) {
  sk  <- strats[i]
  w_s <- weights_all[model_key == sk$model_key &
                       threshold_method == sk$threshold_method &
                       lockout_years == sk$lockout_years &
                       strategy_id == sk$strategy_id &
                       exclusion_rule == sk$exclusion_rule &
                       excl_rate == sk$excl_rate &
                       weighting == sk$weighting,
                     .(permno, qdate, w)]
  rdates <- sort(unique(w_s$qdate))
  rel_p  <- unique(w_s$permno)
  m_sub  <- monthly[permno %in% rel_p, .(permno, date, year, month, ret)]
  m_sub[, aqd := {
    idx <- findInterval(date, rdates, left.open=FALSE)
    idx[idx == 0L] <- NA_integer_
    rdates[idx]
  }]
  m_sub  <- m_sub[!is.na(aqd) & date > aqd & year >= INDEX_START]
  setnames(w_s, "qdate", "aqd")
  m_s    <- merge(m_sub, w_s, by=c("permno","aqd"), all.x=FALSE)
  m_s    <- m_s[!is.na(ret) & !is.na(w)]
  if (TC_BPS > 0) m_s[month %in% REBAL_MONTHS, ret := ret - TC_BPS/10000]

  ret_list[[i]] <- m_s[, .(
    port_ret   = sum(w * ret, na.rm=TRUE),
    n_holdings = uniqueN(permno),
    model_key  = sk$model_key,
    threshold_method = sk$threshold_method,
    lockout_years = sk$lockout_years,
    strategy_id = sk$strategy_id,
    exclusion_rule = sk$exclusion_rule,
    rule_label = sk$rule_label,
    excl_rate  = sk$excl_rate,
    weighting  = sk$weighting
  ), by = .(date, year, month)]

  if (i %% 50 == 0 || i == N_S) cat(sprintf("  %d/%d strategies\n", i, N_S))
}

port_returns <- rbindlist(ret_list)
setorder(port_returns, model_key, strategy_id, weighting, date)
saveRDS(port_returns, PATH_INDEX_RETURNS)
fn_write_csv(port_returns, file.path(INDEX_TABLE_DIR, "index_returns.csv"))
cat(sprintf("  Returns: %d rows\n", nrow(port_returns)))

#==============================================================================#
# 7. Performance metrics
#==============================================================================#

cat("\n[11] Computing performance metrics...\n")

fn_perf <- function(rv, rf = RF_ANNUAL) {
  rv <- rv[is.finite(rv)]
  if (length(rv) < 12) return(NULL)
  ny   <- length(rv) / 12
  rfm  <- (1 + rf)^(1/12) - 1
  cum  <- prod(1 + rv) - 1
  cagr <- (1 + cum)^(1/ny) - 1
  vol  <- sd(rv) * sqrt(12)
  exc  <- rv - rfm
  sh   <- mean(exc) / sd(exc) * sqrt(12)
  ddr  <- exc[rv < rfm]
  srt  <- if (length(ddr) > 1) mean(exc) / (sd(ddr) * sqrt(12)) else NA_real_
  ci   <- cumprod(1 + rv); pk <- cummax(ci)
  mdd  <- min((ci - pk) / pk)
  cal  <- if (mdd < 0) cagr / abs(mdd) else NA_real_
  ## Expected Shortfall
  es975 <- mean(rv[rv <= quantile(rv, 0.025)])
  es99  <- mean(rv[rv <= quantile(rv, 0.010)])
  turn  <- NA_real_  # computed separately if needed
  data.frame(
    n_months=length(rv), cum_ret=round(cum,4), cagr=round(cagr,4),
    vol=round(vol,4), sharpe=round(sh,4), sortino=round(srt,4),
    max_dd=round(mdd,4), calmar=round(cal,4),
    es_975=round(es975,4), es_99=round(es99,4),
    win_rate=round(mean(rv > 0), 4)
  )
}

PERIODS_P <- list(
  insample = c(INDEX_START,     TRAIN_END_YR),
  test     = c(TEST_START_YR,   TEST_END_YR),
  oos      = c(OOS_START_YR,    OOS_END),
  full     = c(INDEX_START,     OOS_END)
)

perf_rows <- list()
for (i in seq_len(N_S)) {
  sk  <- strats[i]
  rdt <- port_returns[model_key == sk$model_key &
                        threshold_method == sk$threshold_method &
                        lockout_years == sk$lockout_years &
                        strategy_id == sk$strategy_id &
                        exclusion_rule == sk$exclusion_rule &
                        excl_rate == sk$excl_rate &
                        weighting == sk$weighting]
  for (pnm in names(PERIODS_P)) {
    yr  <- PERIODS_P[[pnm]]
    sub <- rdt[year >= yr[1] & year <= yr[2]]
    pf  <- fn_perf(sub$port_ret); if (is.null(pf)) next
    pf$model_key  <- sk$model_key
    pf$threshold_method <- sk$threshold_method
    pf$lockout_years <- sk$lockout_years
    pf$strategy_id <- sk$strategy_id
    pf$exclusion_rule <- sk$exclusion_rule
    pf$rule_label <- sk$rule_label
    pf$excl_rate  <- sk$excl_rate
    pf$weighting  <- sk$weighting
    pf$period     <- pnm
    pf$track      <- RESPONSE_TRACK
    pf$short      <- vlookup(MODEL_SHORTS, sk$model_key) %||% sk$model_key
    pf$label      <- vlookup(INDEX_MODEL_LABELS, sk$model_key) %||% sk$model_key
    perf_rows[[length(perf_rows) + 1]] <- pf
  }
}

perf_all <- rbindlist(perf_rows, fill=TRUE)
setDT(perf_all)
saveRDS(perf_all, PATH_INDEX_PERF)
fn_write_csv(perf_all, file.path(INDEX_TABLE_DIR, "index_performance.csv"))
cat("  index_performance.rds saved.\n")

## Console summary - OOS, market-weighted benchmark comparison
cat("\n  -- OOS performance (MW benchmark comparison) --\n")
oos_mw <- perf_all[period == "oos" & weighting == "mw"]
setorder(oos_mw, model_key, threshold_method, lockout_years)
bench_r <- oos_mw[model_key == "bench"]
if (nrow(bench_r) > 0) {
  cat(sprintf("  BENCH-MW : CAGR=%+.2f%% | Sharpe=%.3f | MaxDD=%.2f%%\n",
              bench_r$cagr*100, bench_r$sharpe, bench_r$max_dd*100))
}
for (j in seq_len(nrow(oos_mw[model_key != "bench"]))) {
  r <- oos_mw[model_key != "bench"][j]
  rule_txt <- if (identical(r$exclusion_rule, "permanent_removal")) {
    "perm"
  } else {
    paste0(r$lockout_years, "yr")
  }
  cat(sprintf("  %-10s %-9s: CAGR=%+.2f%% | Sharpe=%.3f | MaxDD=%.2f%%\n",
              r$threshold_method, rule_txt,
              r$cagr*100, r$sharpe, r$max_dd*100))
}

#==============================================================================#
# 8. Exclusion diagnostics
#==============================================================================#

excl_d <- weights_all[q_month == UNIVERSE_MONTH,
                      .(n_included = .N),
                      by = .(
                        model_key, threshold_method, lockout_years,
                        strategy_id, exclusion_rule, rule_label,
                        excl_rate, weighting, q_year, holding_year, signal_year
                      )]
uni_sz <- universe_ann[, .(n_universe = .N), by = year]
excl_d <- merge(excl_d, uni_sz, by.x="signal_year", by.y="year", all.x=TRUE)
excl_d[, n_excluded := n_universe - n_included]
excl_d[, excl_pct   := round(n_excluded / n_universe * 100, 2)]
saveRDS(excl_d, PATH_INDEX_EXCLUSION_SUMMARY)
fn_write_csv(excl_d, file.path(INDEX_TABLE_DIR, "index_exclusion_summary.csv"))
cat("  index_exclusion_summary.rds saved.\n")

#==============================================================================#
# 9. Error-cost decomposition
#==============================================================================#

cat("\n[11] Computing CSI error-cost decomposition...\n")

PATH_ERROR_COST_DECOMP <- file.path(INDEX_TABLE_DIR, "error_cost_decomposition.rds")

fn_ann_geo <- function(rv) {
  rv <- rv[is.finite(rv)]
  if (length(rv) == 0L || any(1 + rv <= 0, na.rm = TRUE)) return(NA_real_)
  prod(1 + rv)^(12 / length(rv)) - 1
}

fn_load_track_labels <- function() {
  candidates <- if (IS_PERMANENT_TRACK) {
    c(PATH_LABELS_MODEL_READY, PATH_LABELS_PERMANENT)
  } else {
    c(PATH_LABELS_MODEL_READY, PATH_LABELS_BASE)
  }
  label_path <- candidates[file.exists(candidates)][1L]
  if (is.na(label_path)) {
    stop("[11] No annual CSI label file found for RESPONSE_TRACK=", RESPONSE_TRACK)
  }
  lbl <- as.data.table(readRDS(label_path))
  y_col <- if (IS_PERMANENT_TRACK && "y_permanent_csi" %in% names(lbl)) {
    "y_permanent_csi"
  } else {
    "y"
  }
  lbl <- lbl[!is.na(get(y_col)), .(
    permno = as.integer(permno),
    signal_year = as.integer(year),
    actual_event = as.integer(get(y_col)) == 1L
  )]
  unique(lbl, by = c("permno", "signal_year"))
}

CATEGORY_LEVELS <- c(
  "false_positive",
  "false_negative",
  "true_positive",
  "true_negative"
)
CATEGORY_NOTES <- c(
  false_positive = paste(
    "Model excluded the firm, but the active-track CSI label was not realized",
    "for the aligned holding year; negative contribution is opportunity cost."
  ),
  false_negative = paste(
    "Model retained the firm, and the active-track CSI label was realized",
    "for the aligned holding year; negative contribution is missed protection."
  ),
  true_positive = paste(
    "Model excluded the firm, and the active-track CSI label was realized",
    "for the aligned holding year; positive contribution is avoided loss."
  ),
  true_negative = paste(
    "Model retained the firm, and the active-track CSI label was not realized",
    "for the aligned holding year; contribution reflects preserved exposure."
  )
)

labels_track <- fn_load_track_labels()
bench_weights <- weights_all[
  model_key == "bench" & weighting == "mw",
  .(permno, qdate, holding_year, signal_year, bench_w = w)
]
bench_weights <- merge(
  bench_weights, labels_track,
  by = c("permno", "signal_year"), all.x = TRUE
)
bench_weights[is.na(actual_event), actual_event := FALSE]

all_qdates <- sort(unique(bench_weights$qdate))
monthly_base <- monthly[
  permno %in% unique(bench_weights$permno),
  .(permno, date, year, month, ret)
]
monthly_base[, qdate := {
  idx <- findInterval(date, all_qdates, left.open = FALSE)
  idx[idx == 0L] <- NA_integer_
  all_qdates[idx]
}]
monthly_base <- monthly_base[
  !is.na(qdate) & date > qdate & year >= INDEX_START & year <= OOS_END
]
base_month <- merge(
  monthly_base, bench_weights,
  by = c("permno", "qdate"), all.x = FALSE
)
base_month <- base_month[!is.na(ret)]

bench_returns_mw <- port_returns[
  model_key == "bench" & weighting == "mw",
  .(date, year, month, benchmark_return = port_ret)
]
all_months <- unique(bench_returns_mw[, .(date, year, month)])
all_months[, tmp_key := 1L]
category_grid <- data.table(confusion_category = CATEGORY_LEVELS, tmp_key = 1L)
month_grid <- merge(
  all_months, category_grid,
  by = "tmp_key",
  allow.cartesian = TRUE
)
month_grid[, tmp_key := NULL]
all_months[, tmp_key := NULL]

decomp_rows <- list()
model_strats <- strats[model_key != "bench" & weighting == "mw"]

for (i in seq_len(nrow(model_strats))) {
  sk <- model_strats[i]
  model_q <- weights_all[
    model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule &
      weighting == sk$weighting,
    .(permno, qdate, model_w = w)
  ]

  d <- merge(base_month, model_q, by = c("permno", "qdate"), all.x = TRUE)
  d[is.na(model_w), model_w := 0]
  d[, predicted_excluded := model_w <= 0]
  d[, confusion_category := fifelse(
    predicted_excluded & !actual_event, "false_positive",
    fifelse(
      !predicted_excluded & actual_event, "false_negative",
      fifelse(predicted_excluded & actual_event, "true_positive", "true_negative")
    )
  )]

  cat_month <- d[, .(
    benchmark_category_return = sum(bench_w * ret, na.rm = TRUE),
    filtered_category_return = sum(model_w * ret, na.rm = TRUE),
    category_return_difference = sum((model_w - bench_w) * ret, na.rm = TRUE),
    n_firm_months = .N,
    portfolio_weight_affected = sum(bench_w, na.rm = TRUE),
    filtered_portfolio_weight = sum(model_w, na.rm = TRUE)
  ), by = .(date, year, month, confusion_category)]

  cat_month <- merge(
    month_grid, cat_month,
    by = c("date", "year", "month", "confusion_category"),
    all.x = TRUE
  )
  zero_cols <- c(
    "benchmark_category_return",
    "filtered_category_return",
    "category_return_difference",
    "n_firm_months",
    "portfolio_weight_affected",
    "filtered_portfolio_weight"
  )
  for (zc in zero_cols) set(cat_month, which(is.na(cat_month[[zc]])), zc, 0)

  strat_returns <- port_returns[
    model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule &
      weighting == sk$weighting,
    .(date, year, month, filtered_return = port_ret)
  ]

  for (pnm in names(PERIODS_P)) {
    yr <- PERIODS_P[[pnm]]
    cm <- cat_month[year >= yr[1] & year <= yr[2]]
    br <- bench_returns_mw[year >= yr[1] & year <= yr[2]]
    sr <- strat_returns[year >= yr[1] & year <= yr[2]]
    if (nrow(cm) == 0L || nrow(br) == 0L || nrow(sr) == 0L) next

    bench_ann <- fn_ann_geo(br$benchmark_return)
    filtered_ann <- fn_ann_geo(sr$filtered_return)
    out <- cm[, .(
      n_months = .N,
      n_firm_months = sum(n_firm_months, na.rm = TRUE),
      portfolio_weight_affected = mean(portfolio_weight_affected, na.rm = TRUE),
      filtered_portfolio_weight = mean(filtered_portfolio_weight, na.rm = TRUE),
      annualized_geometric_return_contribution =
        fn_ann_geo(category_return_difference),
      category_benchmark_annualized_contribution =
        fn_ann_geo(benchmark_category_return),
      category_filtered_annualized_contribution =
        fn_ann_geo(filtered_category_return)
    ), by = confusion_category]

    out[, `:=`(
      track = RESPONSE_TRACK,
      model_key = sk$model_key,
      threshold_method = sk$threshold_method,
      threshold_label = THRESHOLD_METHODS[[sk$threshold_method]],
      lockout_years = sk$lockout_years,
      exclusion_rule = sk$exclusion_rule,
      rule_label = sk$rule_label,
      strategy_id = sk$strategy_id,
      weighting = sk$weighting,
      period = pnm,
      benchmark_annualized_geometric_return = bench_ann,
      filtered_annualized_geometric_return = filtered_ann,
      difference_versus_benchmark = filtered_ann - bench_ann,
      interpretation_notes = CATEGORY_NOTES[confusion_category]
    )]
    decomp_rows[[length(decomp_rows) + 1L]] <- out
  }

  if (i %% 4 == 0 || i == nrow(model_strats)) {
    cat(sprintf("  %d/%d decomposition strategies\n", i, nrow(model_strats)))
  }
}

error_cost_decomp <- rbindlist(decomp_rows, use.names = TRUE, fill = TRUE)
setcolorder(error_cost_decomp, c(
  "track", "period", "model_key", "threshold_method", "threshold_label",
  "exclusion_rule", "rule_label", "lockout_years", "strategy_id", "weighting",
  "confusion_category", "n_months", "n_firm_months",
  "portfolio_weight_affected", "filtered_portfolio_weight",
  "annualized_geometric_return_contribution",
  "category_benchmark_annualized_contribution",
  "category_filtered_annualized_contribution",
  "benchmark_annualized_geometric_return",
  "filtered_annualized_geometric_return",
  "difference_versus_benchmark", "interpretation_notes"
))
setorder(
  error_cost_decomp,
  period, threshold_method, exclusion_rule, lockout_years, confusion_category
)
saveRDS(error_cost_decomp, PATH_ERROR_COST_DECOMP)
fn_write_csv(error_cost_decomp, file.path(INDEX_TABLE_DIR, "error_cost_decomposition.csv"))
cat("  error_cost_decomposition.rds saved.\n")

#==============================================================================#
# 10. Core plots
#==============================================================================#

cat("\n[11] Generating core plots...\n")

STRATEGY_COLS <- c(
  bench_mw = "#757575",
  fpr1_1yr = "#08306B",
  fpr1_2yr = "#2171B5",
  fpr1_3yr = "#6BAED6",
  fpr1_5yr = "#C6DBEF",
  fpr3_1yr = "#004D40",
  fpr3_2yr = "#00897B",
  fpr3_3yr = "#4DB6AC",
  fpr3_5yr = "#B2DFDB",
  youden_1yr = "#1B5E20",
  youden_2yr = "#43A047",
  youden_3yr = "#A5D6A7",
  youden_5yr = "#E8F5E9",
  fpr1_permanent = "#08306B",
  fpr3_permanent = "#00897B",
  youden_permanent = "#43A047"
)

plot_returns <- copy(port_returns[weighting == "mw"])
plot_returns[, plot_id := fifelse(model_key == "bench", "bench_mw", strategy_id)]
plot_returns[, plot_label := fifelse(
  model_key == "bench",
  "Benchmark MW",
  paste0(threshold_method, " / ", rule_label)
)]
plot_returns[, cum_idx := cumprod(1 + port_ret), by = plot_id]
legend_labels <- unique(plot_returns[, .(plot_id, plot_label)])
legend_labels <- setNames(legend_labels$plot_label, legend_labels$plot_id)

p_cum <- ggplot(plot_returns, aes(x=date, y=cum_idx, colour=plot_id, group=plot_id)) +
  geom_line(linewidth=0.85) +
  geom_vline(xintercept=as.Date("2016-01-01"),
             linetype="dashed", colour="grey40") +
  geom_vline(xintercept=as.Date("2020-01-01"),
             linetype="dotted", colour="grey40") +
  scale_colour_manual(values=STRATEGY_COLS, labels=legend_labels) +
  scale_y_continuous(labels=dollar_format(prefix="$")) +
  scale_x_date(date_breaks="2 years", date_labels="%Y") +
  labs(title="AutoGluon Raw CSI Overlay - MW Index",
       subtitle=if (IS_PERMANENT_TRACK) {
         "CV thresholds with absorbing permanent removal"
       } else {
         "CV thresholds crossed with 1/2/3/5-year exclusion lockouts"
       },
       x=NULL, y="Portfolio Value ($1)", colour="Strategy") +
  theme_minimal(base_size=12) +
  theme(legend.position="bottom", axis.text.x=element_text(angle=30, hjust=1))
ggsave(file.path(INDEX_FIG_DIR, "ag_raw_lockout_mw_cumulative.png"),
       p_cum, width=PLOT_WIDTH*1.2, height=PLOT_HEIGHT, dpi=PLOT_DPI)

oos_plot <- copy(perf_all[period == "oos" & weighting == "mw"])
bench_sharpe <- oos_plot[model_key == "bench", sharpe][1L]
oos_plot <- oos_plot[model_key != "bench"]
oos_plot[, threshold_method := factor(
  threshold_method,
  levels = names(THRESHOLD_METHODS),
  labels = THRESHOLD_METHODS
)]
oos_plot[, rule_plot_label := ifelse(
  exclusion_rule == "permanent_removal",
  "Permanent",
  paste0(lockout_years, "yr")
)]

p_oos <- ggplot(oos_plot, aes(x=rule_plot_label, y=sharpe, fill=threshold_method)) +
  geom_col(position=position_dodge(width=0.8), width=0.72) +
  geom_hline(yintercept=bench_sharpe, linetype="dashed", colour="#757575") +
  scale_fill_manual(values=c("#2171B5", "#00897B", "#43A047")) +
  labs(title="OOS Sharpe vs MW Benchmark",
       subtitle="Dashed line is BENCH-MW",
       x=if (IS_PERMANENT_TRACK) "Removal rule" else "Exclusion lockout",
       y="Sharpe", fill="Threshold") +
  theme_minimal(base_size=12) +
  theme(legend.position="bottom")
ggsave(file.path(INDEX_FIG_DIR, "ag_raw_lockout_oos_sharpe.png"),
       p_oos, width=PLOT_WIDTH, height=PLOT_HEIGHT, dpi=PLOT_DPI)

cat(sprintf("\n[11_IndexConstruction.R] DONE: %s\n", format(Sys.time())))
