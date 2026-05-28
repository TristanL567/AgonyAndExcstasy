#==============================================================================#
#==== 11C_IndexConstruction_Revised.R =========================================#
#==== CSI Overlay on CRSP-like Total/Large/Mid/Small Market Indices ===========#
#==============================================================================#
#
# PURPOSE:
#   Repeat the CSI model-filtered index methodology on the four locally
#   reconstructed CRSP-like market-cap indices:
#     total_market, large_cap, mid_cap, small_cap.
#
# DESIGN:
#   - Inputs are the CRSP-like quarterly constituents from 01_Code/IndexConstruction
#     and AutoGluon ag_raw CSI predictions from 09C.
#   - Thresholds are estimated on CV predictions only:
#       FPR <= 1%, FPR <= 3%, and Youden J.
#   - dynamic_csi uses 1/2/3/5-year temporary lockouts.
#   - permanent_csi uses absorbing permanent removal.
#   - Benchmark for each index is the unfiltered market-cap-weighted version of
#     that index universe.
#   - Returns are monthly drifted portfolios from quarterly rebalance weights.
#
# OUTPUTS:
#   DIR_TABLES/<RESPONSE_TRACK>/11c_index_revised/
#     index_thresholds_by_crsp_universe.{rds,csv}
#     index_weights_by_crsp_universe.{rds,csv}
#     index_returns_by_crsp_universe.{rds,csv}
#     index_performance_by_crsp_universe.{rds,csv}
#     index_exclusion_summary_by_crsp_universe.{rds,csv}
#     error_cost_decomposition_by_crsp_universe.{rds,csv}
#     run_status.csv
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[11C_IndexConstruction_Revised.R] START:", format(Sys.time()), "\n")

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L || all(is.na(a))) b else a

RUN_STARTED <- Sys.time()
SCRIPT_PATH <- normalizePath("11C_IndexConstruction_Revised.R", mustWork = FALSE)

AE_SENS_RUN_ID <- Sys.getenv("AE_SENS_RUN_ID", unset = "")
AE_SENS_OUTPUT_ROOT <- Sys.getenv("AE_SENS_OUTPUT_ROOT", unset = "")
AE_SENS_MODE <- nzchar(AE_SENS_RUN_ID) || nzchar(AE_SENS_OUTPUT_ROOT)
if (AE_SENS_MODE) {
  if (!nzchar(AE_SENS_RUN_ID) || !nzchar(AE_SENS_OUTPUT_ROOT)) {
    stop("AE_SENS_RUN_ID and AE_SENS_OUTPUT_ROOT are both required in AE-SENS mode.")
  }
  if (!identical(Sys.getenv("MODEL", unset = ""), "raw")) {
    stop("AE-SENS 11C mode only permits MODEL=raw.")
  }
  if (!identical(RESPONSE_TRACK, "dynamic_csi")) {
    stop("AE-SENS 11C mode only permits RESPONSE_TRACK=dynamic_csi.")
  }
  if (!grepl("^C(060|080|090)_M(000|020|030)_T(012|018|028)$", AE_SENS_RUN_ID)) {
    stop("Invalid AE_SENS_RUN_ID: ", AE_SENS_RUN_ID)
  }
  if (!grepl("/03_Data_Output/3_Modelling_Results/Necessary/sensitivity$", AE_SENS_OUTPUT_ROOT)) {
    stop("AE_SENS_OUTPUT_ROOT is outside the approved sensitivity root: ",
         AE_SENS_OUTPUT_ROOT)
  }
  data.table::setDTthreads(1L)
  Sys.setenv(
    OMP_NUM_THREADS = "1",
    OPENBLAS_NUM_THREADS = "1",
    MKL_NUM_THREADS = "1"
  )
}

OUT_DIR <- if (AE_SENS_MODE) {
  file.path(AE_SENS_OUTPUT_ROOT, "index_construction", AE_SENS_RUN_ID)
} else {
  file.path(DIR_TABLES_TRACK, "11c_index_revised")
}
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

## CRSP-MI replication data lives under
## 02_Data_Input/04_Index_Replication/Necessary/. DIR_IDXREP_NEC is defined
## in config.R.
PATH_CRSP_INDEX_DIR <- DIR_IDXREP_NEC
PATH_CRSP_CONSTITUENTS <- file.path(
  PATH_CRSP_INDEX_DIR,
  "crsp_like_index_constituents_quarterly.rds"
)
PATH_CRSP_INDEX_RETURNS <- file.path(
  PATH_CRSP_INDEX_DIR,
  "crsp_like_index_returns_monthly.rds"
)
PATH_CRSP_INDEX_SUMMARY <- file.path(
  PATH_CRSP_INDEX_DIR,
  "crsp_like_index_summary_quarterly.csv"
)

PATH_11C_THRESHOLDS <- file.path(OUT_DIR, "index_thresholds_by_crsp_universe.rds")
PATH_11C_WEIGHTS <- file.path(OUT_DIR, "index_weights_by_crsp_universe.rds")
PATH_11C_RETURNS <- file.path(OUT_DIR, "index_returns_by_crsp_universe.rds")
PATH_11C_PERF <- file.path(OUT_DIR, "index_performance_by_crsp_universe.rds")
PATH_11C_EXCLUSION <- file.path(OUT_DIR, "index_exclusion_summary_by_crsp_universe.rds")
PATH_11C_DECOMP <- file.path(OUT_DIR, "error_cost_decomposition_by_crsp_universe.rds")
PATH_11C_STATUS <- file.path(OUT_DIR, "run_status.csv")
PATH_AE_SENS_11C_DIAG <- file.path(OUT_DIR, "ae_sens_11c_merge_diagnostics.csv")

fn_write_csv <- function(dt, path) {
  tryCatch(
    fwrite(dt, path),
    error = function(e) {
      alt <- sub("\\.csv$", paste0("_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv"), path)
      warning(sprintf("Could not write %s; writing fallback %s: %s", path, alt, conditionMessage(e)))
      fwrite(dt, alt)
    }
  )
}

fn_stop_missing <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0L) {
    stop("Missing required inputs:\n", paste(missing, collapse = "\n"))
  }
}

fn_ae_sens_key_classes <- function(dt, cols) {
  paste(
    vapply(cols, function(col) {
      if (!col %in% names(dt)) return(paste0(col, "=<missing>"))
      paste0(col, "=", paste(class(dt[[col]]), collapse = "/"))
    }, character(1)),
    collapse = ";"
  )
}

fn_ae_sens_key_na_counts <- function(dt, cols) {
  paste(
    vapply(cols, function(col) {
      if (!col %in% names(dt)) return(paste0(col, "=NA"))
      paste0(col, "=", sum(is.na(dt[[col]])))
    }, character(1)),
    collapse = ";"
  )
}

fn_ae_sens_prepare_join_keys <- function(dt, key_cols, context, side) {
  out <- copy(dt)
  if ("index_id" %in% names(out)) out[, index_id := as.character(index_id)]
  if ("qdate" %in% names(out)) out[, qdate := as.IDate(qdate)]
  if ("permno" %in% names(out)) out[, permno := as.integer(permno)]

  n_before <- nrow(out)
  if (length(key_cols) > 0L) {
    out <- out[complete.cases(out[, ..key_cols])]
    setorderv(out, key_cols)
  }
  n_after <- nrow(out)
  n_dup <- if (n_after > 0L && length(key_cols) > 0L) {
    n_after - uniqueN(out, by = key_cols)
  } else {
    0L
  }
  diag <- data.table(
    run_id = AE_SENS_RUN_ID,
    context = context,
    side = side,
    n_before = n_before,
    n_after = n_after,
    n_dropped_na_key = n_before - n_after,
    n_duplicate_keys = n_dup,
    key_classes = fn_ae_sens_key_classes(out, key_cols),
    key_na_counts = fn_ae_sens_key_na_counts(out, key_cols)
  )
  fwrite(diag, PATH_AE_SENS_11C_DIAG, append = file.exists(PATH_AE_SENS_11C_DIAG))
  out
}

fn_ae_sens_left_merge <- function(left, right, by, context) {
  if (!AE_SENS_MODE) {
    return(merge(left, right, by = by, all.x = TRUE))
  }
  left_prepped <- fn_ae_sens_prepare_join_keys(left, by, context, "left")
  right_prepped <- fn_ae_sens_prepare_join_keys(right, by, context, "right")
  merge(left_prepped, right_prepped, by = by, all.x = TRUE)
}

HAS_ARROW <- requireNamespace("arrow", quietly = TRUE) && !AE_SENS_MODE

fn_read_parquet <- function(path) {
  if (HAS_ARROW) {
    return(as.data.table(arrow::read_parquet(path)))
  }

  tmp <- tempfile(fileext = ".csv")
  py_file <- tempfile(fileext = ".py")
  on.exit(unlink(c(tmp, py_file)), add = TRUE)
  writeLines(c(
    "import pandas as pd",
    "import sys",
    "pd.read_parquet(sys.argv[1]).to_csv(sys.argv[2], index=False)"
  ), py_file)
  py_bin <- Sys.which("python3")
  if (!nzchar(py_bin)) py_bin <- Sys.which("python")
  if (!nzchar(py_bin)) stop("Python is required for parquet fallback")
  status <- system2(py_bin, c(py_file, path, tmp))
  if (!identical(status, 0L)) {
    stop(sprintf("Python parquet fallback failed for %s", path))
  }
  as.data.table(utils::read.csv(tmp, stringsAsFactors = FALSE, check.names = FALSE))
}

MODEL_KEY <- "raw"
MODEL_LABEL <- "AutoGluon raw"
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
OOS_END <- 2024L
RF_ANNUAL <- 0.03

TRAIN_END_YR_SAFE <- get0("TRAIN_END_YR", ifnotfound = 2015L)
TEST_START_YR_SAFE <- get0("TEST_START_YR", ifnotfound = 2016L)
TEST_END_YR_SAFE <- get0("TEST_END_YR", ifnotfound = 2019L)
OOS_START_YR_SAFE <- get0("OOS_START_YR", ifnotfound = 2020L)

fn_stop_missing(c(
  PATH_PRICES_MONTHLY,
  PATH_CRSP_CONSTITUENTS,
  PATH_CRSP_INDEX_RETURNS,
  PATH_CRSP_INDEX_SUMMARY
))

#==============================================================================#
# 1. Load inputs
#==============================================================================#

cat("[11C] Loading CRSP-like constituents and monthly returns...\n")

monthly <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
if (!inherits(monthly$date, "Date")) monthly[, date := as.Date(date)]
monthly[, ret := pmax(as.numeric(ret_adj), -1)]
monthly[, `:=`(
  year = as.integer(format(date, "%Y")),
  month = as.integer(format(date, "%m")),
  dlret_applied = as.logical(dlret_applied %||% FALSE)
)]
monthly <- monthly[!is.na(permno) & !is.na(date) & !is.na(ret), .(
  permno = as.integer(permno),
  date,
  year,
  month,
  ret,
  dlret_applied
)]
setkey(monthly, date, permno)

constituents <- as.data.table(readRDS(PATH_CRSP_CONSTITUENTS))
if (!inherits(constituents$qdate, "Date")) constituents[, qdate := as.Date(qdate)]
constituents <- constituents[, .(
  qdate,
  index_id,
  index_name,
  permno = as.integer(permno),
  permco = as.integer(permco),
  size_segment,
  security_mktcap = as.numeric(security_mktcap),
  index_mktcap = as.numeric(index_mktcap),
  benchmark_weight = as.numeric(weight)
)]
constituents[, `:=`(
  q_year = as.integer(format(qdate, "%Y")),
  q_month = as.integer(format(qdate, "%m")),
  holding_year = year(qdate %m+% months(1L)),
  signal_year = year(qdate %m+% months(1L)) - 1L
)]
setorder(constituents, index_id, qdate, permno)

crsp_benchmark_returns <- as.data.table(readRDS(PATH_CRSP_INDEX_RETURNS))
if (!inherits(crsp_benchmark_returns$date, "Date")) {
  crsp_benchmark_returns[, date := as.Date(date)]
}
crsp_benchmark_returns[, `:=`(
  year = as.integer(format(date, "%Y")),
  month = as.integer(format(date, "%m"))
)]

cat(sprintf("  Monthly rows: %d | constituents: %d | indices: %s\n",
            nrow(monthly), nrow(constituents),
            paste(sort(unique(constituents$index_id)), collapse = ", ")))

#==============================================================================#
# 2. Load AutoGluon predictions and CV thresholds
#==============================================================================#

cat("[11C] Loading ag_raw predictions and estimating CV thresholds...\n")

fn_load_predictions <- function() {
  tdir <- if (AE_SENS_MODE) {
    file.path(AE_SENS_OUTPUT_ROOT, "raw_predictions", AE_SENS_RUN_ID)
  } else {
    file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_raw")
  }
  fmap <- c(
    oos = file.path(tdir, "ag_preds_oos.parquet"),
    test = file.path(tdir, "ag_preds_test.parquet"),
    boundary = file.path(tdir, "ag_preds_train_boundary.parquet"),
    cv = file.path(tdir, "ag_cv_results.parquet")
  )
  fn_stop_missing(unname(fmap))

  src_rank <- c(oos = 1L, test = 2L, boundary = 3L, cv = 4L)
  parts <- lapply(names(fmap), function(nm) {
    dt <- fn_read_parquet(fmap[[nm]])
    dt[, src := nm]
    dt[, .(
      permno = as.integer(permno),
      year = as.integer(year),
      y = as.integer(y),
      p_csi = as.numeric(p_csi),
      src
    )]
  })
  pred <- rbindlist(parts, use.names = TRUE, fill = TRUE)
  pred[, src_rank := src_rank[src]]
  setorder(pred, permno, year, src_rank)
  if (AE_SENS_MODE) {
    keep_first <- !duplicated(data.frame(permno = pred$permno, year = pred$year))
    pred <- pred[keep_first]
  } else {
    pred <- pred[!duplicated(pred, by = c("permno", "year"))]
  }
  pred[, src_rank := NULL]
  pred[]
}

fn_cv_thresholds <- function() {
  cv_path <- if (AE_SENS_MODE) {
    file.path(AE_SENS_OUTPUT_ROOT, "raw_predictions", AE_SENS_RUN_ID,
              "ag_cv_results.parquet")
  } else {
    file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_raw", "ag_cv_results.parquet")
  }
  cv <- fn_read_parquet(cv_path)
  y <- as.integer(cv$y)
  p_csi <- as.numeric(cv$p_csi)
  ok <- !is.na(y) & !is.na(p_csi)
  y <- y[ok]
  p_csi <- p_csi[ok]
  if (length(y) < 100L || length(unique(y)) < 2L) {
    stop("CV predictions are insufficient for thresholding.")
  }

  if (AE_SENS_MODE) {
    ord <- order(p_csi, decreasing = TRUE)
    y <- y[ord]
    p_csi <- p_csi[ord]
    runs <- rle(p_csi)
    ends <- cumsum(runs$lengths)
    pos_cum <- cumsum(y == 1L)
    neg_cum <- cumsum(y == 0L)
    pos_before <- c(0L, pos_cum[ends[-length(ends)]])
    neg_before <- c(0L, neg_cum[ends[-length(ends)]])

    roc_grid <- data.frame(
      threshold = runs$values,
      tp = pos_cum[ends],
      fp = neg_cum[ends],
      pos = pos_cum[ends] - pos_before,
      neg = neg_cum[ends] - neg_before
    )
    total_pos <- sum(y == 1L)
    total_neg <- sum(y == 0L)
    roc_grid$fn <- total_pos - roc_grid$tp
    roc_grid$tn <- total_neg - roc_grid$fp
    roc_grid$recall <- roc_grid$tp / total_pos
    roc_grid$fpr <- roc_grid$fp / total_neg
    roc_grid$precision <- ifelse(
      roc_grid$tp + roc_grid$fp > 0L,
      roc_grid$tp / (roc_grid$tp + roc_grid$fp),
      NA_real_
    )
    roc_grid$youden_j <- roc_grid$recall - roc_grid$fpr

    fpr1_idx <- which(roc_grid$fpr <= 0.01)
    fpr3_idx <- which(roc_grid$fpr <= 0.03)
    if (length(fpr1_idx) == 0L) stop("No CV threshold satisfies FPR <= 1%.")
    if (length(fpr3_idx) == 0L) stop("No CV threshold satisfies FPR <= 3%.")

    pick_fpr <- function(idx) {
      idx[order(-roc_grid$recall[idx], roc_grid$fpr[idx],
                -roc_grid$threshold[idx])][1L]
    }
    picks <- c(
      fpr1 = pick_fpr(fpr1_idx),
      fpr3 = pick_fpr(fpr3_idx),
      youden = order(-roc_grid$youden_j, -roc_grid$recall,
                     roc_grid$fpr, -roc_grid$threshold)[1L]
    )

    out <- rbindlist(lapply(names(picks), function(method) {
      row <- roc_grid[picks[[method]], ]
      data.table(
        track = RESPONSE_TRACK,
        model_key = MODEL_KEY,
        model_label = MODEL_LABEL,
        threshold_method = method,
        threshold_label = THRESHOLD_METHODS[[method]],
        threshold = row$threshold,
        cv_fpr = row$fpr,
        cv_recall = row$recall,
        cv_precision = row$precision,
        cv_youden = row$youden_j,
        cv_flag_rate = (row$tp + row$fp) / (total_pos + total_neg),
        cv_n_flagged = row$tp + row$fp
      )
    }), use.names = TRUE)
    return(out[order(threshold_method)])
  }

  cv <- data.table(y = y, p_csi = p_csi)
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
  roc_grid[, youden_j := recall - fpr]

  fpr1 <- roc_grid[fpr <= 0.01]
  fpr3 <- roc_grid[fpr <= 0.03]
  if (nrow(fpr1) == 0L) stop("No CV threshold satisfies FPR <= 1%.")
  if (nrow(fpr3) == 0L) stop("No CV threshold satisfies FPR <= 3%.")

  setorder(fpr1, -recall, fpr, -threshold)
  setorder(fpr3, -recall, fpr, -threshold)
  youden <- copy(roc_grid)
  setorder(youden, -youden_j, -recall, fpr, -threshold)

  out <- rbindlist(list(
    fpr1[1L, .(
      track = RESPONSE_TRACK,
      model_key = MODEL_KEY,
      model_label = MODEL_LABEL,
      threshold_method = "fpr1",
      threshold_label = THRESHOLD_METHODS[["fpr1"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden_j,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )],
    fpr3[1L, .(
      track = RESPONSE_TRACK,
      model_key = MODEL_KEY,
      model_label = MODEL_LABEL,
      threshold_method = "fpr3",
      threshold_label = THRESHOLD_METHODS[["fpr3"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden_j,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )],
    youden[1L, .(
      track = RESPONSE_TRACK,
      model_key = MODEL_KEY,
      model_label = MODEL_LABEL,
      threshold_method = "youden",
      threshold_label = THRESHOLD_METHODS[["youden"]],
      threshold,
      cv_fpr = fpr,
      cv_recall = recall,
      cv_precision = precision,
      cv_youden = youden_j,
      cv_flag_rate = (tp + fp) / (total_pos + total_neg),
      cv_n_flagged = tp + fp
    )]
  ), use.names = TRUE)
  setorder(out, threshold_method)
  out[]
}

predictions <- fn_load_predictions()
thresholds <- fn_cv_thresholds()
FIRST_SIGNAL_YEAR <- min(predictions$year, na.rm = TRUE)
INDEX_START <- max(INSAMPLE_START, FIRST_SIGNAL_YEAR + 1L)

saveRDS(thresholds, PATH_11C_THRESHOLDS)
fn_write_csv(thresholds, file.path(OUT_DIR, "index_thresholds_by_crsp_universe.csv"))
print(thresholds)
cat(sprintf("  Predictions: %d rows | signal years %d-%d | first holding year %d\n",
            nrow(predictions), min(predictions$year), max(predictions$year), INDEX_START))

constituents <- constituents[
  holding_year >= INDEX_START & holding_year <= OOS_END
]
if (nrow(constituents) == 0L) {
  stop("No CRSP-like constituent rows remain after holding-year filter.")
}

#==============================================================================#
# 3. Build filtered quarterly weights
#==============================================================================#

cat("[11C] Building benchmark and model-filtered quarterly weights...\n")

fn_excl_flag <- function(permnos, pred_yr, threshold, lockout_years, exclusion_rule) {
  if (identical(exclusion_rule, "permanent_removal")) {
    signal_years <- seq.int(FIRST_SIGNAL_YEAR, pred_yr)
  } else {
    first_year <- max(FIRST_SIGNAL_YEAR, pred_yr - lockout_years + 1L)
    signal_years <- seq.int(first_year, pred_yr)
  }
  flagged <- unique(predictions[
    year %in% signal_years & !is.na(p_csi) & p_csi >= threshold,
    .(permno)
  ])
  x <- data.table(permno = permnos, row_id = seq_along(permnos))
  x <- merge(x, flagged[, flagged := TRUE], by = "permno", all.x = TRUE)
  setorder(x, row_id)
  !is.na(x$flagged)
}

fn_make_weight_rows <- function(base, included_flag, model_key, threshold_method,
                                threshold_label, threshold, lockout_years,
                                strategy_id, exclusion_rule, rule_label) {
  incl <- base[included_flag]
  if (nrow(incl) == 0L) return(NULL)
  incl[, filtered_weight := benchmark_weight / sum(benchmark_weight, na.rm = TRUE)]
  incl[, .(
    track = RESPONSE_TRACK,
    index_id,
    index_name,
    qdate,
    q_year,
    q_month,
    holding_year,
    signal_year,
    permno,
    permco,
    size_segment,
    security_mktcap,
    benchmark_weight,
    w = filtered_weight,
    model_key,
    model_label = fifelse(model_key == "bench", "Benchmark", MODEL_LABEL),
    threshold_method,
    threshold_label,
    threshold = as.numeric(threshold),
    lockout_years = as.integer(lockout_years),
    strategy_id,
    exclusion_rule,
    rule_label,
    weighting = "mw"
  )]
}

q_groups <- unique(constituents[, .(
  index_id, index_name, qdate, q_year, q_month, holding_year, signal_year
)])
setorder(q_groups, index_id, qdate)

w_list <- vector("list", nrow(q_groups) * (1L + length(THRESHOLD_METHODS) * nrow(EXCLUSION_RULES)))
entry <- 0L

for (i in seq_len(nrow(q_groups))) {
  g <- q_groups[i]
  base <- constituents[index_id == g$index_id & qdate == g$qdate]
  setorder(base, permno)

  entry <- entry + 1L
  w_list[[entry]] <- fn_make_weight_rows(
    base = base,
    included_flag = rep(TRUE, nrow(base)),
    model_key = "bench",
    threshold_method = "benchmark",
    threshold_label = "Benchmark",
    threshold = NA_real_,
    lockout_years = 0L,
    strategy_id = "bench_mw",
    exclusion_rule = "benchmark",
    rule_label = "Benchmark"
  )

  for (method in names(THRESHOLD_METHODS)) {
    threshold <- thresholds[threshold_method == method, threshold]
    threshold_label <- thresholds[threshold_method == method, threshold_label]
    for (rule_i in seq_len(nrow(EXCLUSION_RULES))) {
      rule <- EXCLUSION_RULES[rule_i]
      flag <- fn_excl_flag(
        permnos = base$permno,
        pred_yr = g$signal_year,
        threshold = threshold,
        lockout_years = rule$lockout_years,
        exclusion_rule = rule$exclusion_rule
      )
      strategy_id <- paste(method, rule$rule_id, sep = "_")
      entry <- entry + 1L
      w_list[[entry]] <- fn_make_weight_rows(
        base = base,
        included_flag = !flag,
        model_key = MODEL_KEY,
        threshold_method = method,
        threshold_label = threshold_label,
        threshold = threshold,
        lockout_years = rule$lockout_years,
        strategy_id = strategy_id,
        exclusion_rule = rule$exclusion_rule,
        rule_label = rule$rule_label
      )
    }
  }

  if (i %% 100L == 0L || i == nrow(q_groups)) {
    cat(sprintf("  %d/%d index-quarter groups\n", i, nrow(q_groups)))
  }
}

weights_all <- rbindlist(w_list, use.names = TRUE, fill = TRUE)
weights_all <- weights_all[!is.na(permno)]
setorder(weights_all, track, index_id, model_key, strategy_id, qdate, -w, permno)

saveRDS(weights_all, PATH_11C_WEIGHTS)
fn_write_csv(weights_all, file.path(OUT_DIR, "index_weights_by_crsp_universe.csv"))
cat(sprintf("  Saved weights: %d rows\n", nrow(weights_all)))

#==============================================================================#
# 4. Monthly drifted portfolio returns
#==============================================================================#

cat("[11C] Computing monthly drifted portfolio returns...\n")

monthly_dates <- sort(unique(monthly$date))
max_monthly_date <- max(monthly_dates)

strategies <- unique(weights_all[, .(
  track, index_id, index_name, model_key, model_label,
  threshold_method, threshold_label, threshold, lockout_years,
  strategy_id, exclusion_rule, rule_label, weighting
)])
setorder(strategies, index_id, model_key, threshold_method, lockout_years)

fn_compute_strategy_returns <- function(w_s, sk) {
  qdates <- sort(unique(w_s$qdate))
  out <- vector("list", length(qdates) * 3L)
  out_i <- 0L

  for (qi in seq_along(qdates)) {
    qd <- qdates[qi]
    next_qd <- if (qi < length(qdates)) qdates[qi + 1L] else max_monthly_date
    hdates <- monthly_dates[monthly_dates > qd & monthly_dates <= next_qd]
    if (length(hdates) == 0L) next

    holdings <- copy(w_s[qdate == qd, .(permno, w)])
    setorder(holdings, permno)
    n_holdings_start <- nrow(holdings)
    if (n_holdings_start == 0L) next

    for (hd in hdates) {
      hd <- as.Date(hd, origin = '1970-01-01')
      active <- merge(
        holdings,
        monthly[date == hd, .(permno, ret, dlret_applied)],
        by = "permno",
        all.x = FALSE
      )
      active <- active[!is.na(ret) & !is.na(w)]
      pre_weight_sum <- sum(active$w, na.rm = TRUE)
      if (!is.finite(pre_weight_sum) || pre_weight_sum <= 0) break

      active[, w_pre := w / pre_weight_sum]
      port_ret <- sum(active$w_pre * active$ret, na.rm = TRUE)

      out_i <- out_i + 1L
      out[[out_i]] <- data.table(
        track = RESPONSE_TRACK,
        index_id = sk$index_id,
        index_name = sk$index_name,
        date = hd,
        qdate = qd,
        year = as.integer(format(hd, "%Y")),
        month = as.integer(format(hd, "%m")),
        model_key = sk$model_key,
        model_label = sk$model_label,
        threshold_method = sk$threshold_method,
        threshold_label = sk$threshold_label,
        threshold = sk$threshold,
        lockout_years = sk$lockout_years,
        strategy_id = sk$strategy_id,
        exclusion_rule = sk$exclusion_rule,
        rule_label = sk$rule_label,
        weighting = sk$weighting,
        port_ret = port_ret,
        n_holdings_start = n_holdings_start,
        n_holdings_with_return = nrow(active),
        active_weight_before_rescale = pre_weight_sum
      )

      active[, post_value := w_pre * (1 + ret)]
      active <- active[
        is.finite(post_value) & post_value > 0 & !isTRUE(dlret_applied),
        .(permno, w = post_value)
      ]
      if (nrow(active) == 0L) break
      active[, w := w / sum(w, na.rm = TRUE)]
      holdings <- active
    }
  }

  rbindlist(out[seq_len(out_i)], use.names = TRUE, fill = TRUE)
}

ret_list <- vector("list", nrow(strategies))
for (i in seq_len(nrow(strategies))) {
  sk <- strategies[i]
  w_s <- weights_all[
    index_id == sk$index_id &
      model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule,
    .(qdate, permno, w)
  ]
  ret_list[[i]] <- fn_compute_strategy_returns(w_s, sk)
  if (i %% 10L == 0L || i == nrow(strategies)) {
    cat(sprintf("  %d/%d strategies\n", i, nrow(strategies)))
  }
}

returns_all <- rbindlist(ret_list, use.names = TRUE, fill = TRUE)
setorder(returns_all, index_id, model_key, threshold_method, lockout_years, strategy_id, date)
returns_all[, cumulative_index := cumprod(1 + port_ret), by = .(
  index_id, model_key, threshold_method, lockout_years, strategy_id, exclusion_rule
)]

saveRDS(returns_all, PATH_11C_RETURNS)
fn_write_csv(returns_all, file.path(OUT_DIR, "index_returns_by_crsp_universe.csv"))
cat(sprintf("  Saved returns: %d rows\n", nrow(returns_all)))

#==============================================================================#
# 5. Performance metrics
#==============================================================================#

cat("[11C] Computing performance metrics...\n")

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
  ann_geo <- fn_ann_geo(rv)
  ann_sd <- sd(rv) * sqrt(12)
  rf_monthly <- (1 + rf_annual)^(1 / 12) - 1
  excess <- rv - rf_monthly
  sharpe <- if (sd(excess) > 0) mean(excess) / sd(excess) * sqrt(12) else NA_real_
  ci <- cumprod(1 + rv)
  drawdown <- ci / cummax(ci) - 1
  data.table(
    n_months = length(rv),
    annualized_geometric_return = ann_geo,
    annualized_sd = ann_sd,
    sharpe_ratio = sharpe,
    max_drawdown = min(drawdown, na.rm = TRUE),
    expected_shortfall_2p5 = fn_expected_shortfall(rv, 0.025),
    cumulative_return = prod(1 + rv) - 1,
    rf_annual = rf_annual
  )
}

PERIODS <- list(
  insample = c(INDEX_START, TRAIN_END_YR_SAFE),
  test = c(TEST_START_YR_SAFE, TEST_END_YR_SAFE),
  oos = c(OOS_START_YR_SAFE, OOS_END),
  full = c(INDEX_START, OOS_END)
)

perf_rows <- list()
perf_i <- 0L

for (i in seq_len(nrow(strategies))) {
  sk <- strategies[i]
  rdt <- returns_all[
    index_id == sk$index_id &
      model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule
  ]
  for (pnm in names(PERIODS)) {
    yr <- PERIODS[[pnm]]
    sub <- rdt[year >= yr[1L] & year <= yr[2L]]
    pf <- fn_perf(sub$port_ret)
    if (is.null(pf)) next
    bench <- returns_all[
      index_id == sk$index_id &
        model_key == "bench" &
        year >= yr[1L] & year <= yr[2L]
    ]
    bench_geo <- fn_ann_geo(bench$port_ret)
    bench_sd <- sd(bench$port_ret, na.rm = TRUE) * sqrt(12)
    perf_i <- perf_i + 1L
    perf_rows[[perf_i]] <- cbind(
      data.table(
        track = RESPONSE_TRACK,
        period = pnm,
        index_id = sk$index_id,
        index_name = sk$index_name,
        benchmark_index_id = sk$index_id,
        model_key = sk$model_key,
        model_label = sk$model_label,
        threshold_method = sk$threshold_method,
        threshold_label = sk$threshold_label,
        threshold = sk$threshold,
        lockout_years = sk$lockout_years,
        strategy_id = sk$strategy_id,
        exclusion_rule = sk$exclusion_rule,
        rule_label = sk$rule_label,
        weighting = sk$weighting
      ),
      pf,
      data.table(
        benchmark_annualized_geometric_return = bench_geo,
        benchmark_annualized_sd = bench_sd,
        difference_versus_benchmark = pf$annualized_geometric_return - bench_geo
      )
    )
  }
}

performance <- rbindlist(perf_rows, use.names = TRUE, fill = TRUE)
setorder(performance, period, index_id, model_key, threshold_method, lockout_years)

saveRDS(performance, PATH_11C_PERF)
fn_write_csv(performance, file.path(OUT_DIR, "index_performance_by_crsp_universe.csv"))
cat(sprintf("  Saved performance rows: %d\n", nrow(performance)))

#==============================================================================#
# 6. Exclusion summary
#==============================================================================#

cat("[11C] Computing exclusion summary...\n")

bench_q <- weights_all[
  model_key == "bench",
  .(
    index_id,
    index_name,
    qdate,
    holding_year,
    signal_year,
    permno,
    benchmark_weight
  )
]

excl_rows <- list()
model_strategies <- strategies[model_key != "bench"]
for (i in seq_len(nrow(model_strategies))) {
  sk <- model_strategies[i]
  model_q <- weights_all[
    index_id == sk$index_id &
      model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule,
    .(index_id, qdate, permno, model_w = w)
  ]
  d <- fn_ae_sens_left_merge(
    bench_q[index_id == sk$index_id],
    model_q,
    by = c("index_id", "qdate", "permno"),
    context = paste("exclusion_summary", sk$strategy_id, sep = "::")
  )
  d[, excluded := is.na(model_w)]
  out <- d[, .(
    n_benchmark = .N,
    n_included = sum(!excluded),
    n_excluded = sum(excluded),
    exclusion_rate_names = mean(excluded),
    benchmark_weight_excluded = sum(benchmark_weight[excluded], na.rm = TRUE),
    benchmark_weight_retained = sum(benchmark_weight[!excluded], na.rm = TRUE)
  ), by = .(index_id, index_name, qdate, holding_year, signal_year)]
  out[, `:=`(
    track = RESPONSE_TRACK,
    model_key = sk$model_key,
    model_label = sk$model_label,
    threshold_method = sk$threshold_method,
    threshold_label = sk$threshold_label,
    threshold = sk$threshold,
    lockout_years = sk$lockout_years,
    strategy_id = sk$strategy_id,
    exclusion_rule = sk$exclusion_rule,
    rule_label = sk$rule_label,
    weighting = sk$weighting
  )]
  excl_rows[[i]] <- out
}

exclusion_summary <- rbindlist(excl_rows, use.names = TRUE, fill = TRUE)
setorder(exclusion_summary, index_id, qdate, threshold_method, lockout_years)

saveRDS(exclusion_summary, PATH_11C_EXCLUSION)
fn_write_csv(exclusion_summary, file.path(OUT_DIR, "index_exclusion_summary_by_crsp_universe.csv"))

#==============================================================================#
# 7. Error-cost decomposition
#==============================================================================#

cat("[11C] Computing FP/FN/TP/TN error-cost decomposition...\n")

fn_load_track_labels <- function() {
  if (AE_SENS_MODE) {
    candidates <- file.path(AE_SENS_OUTPUT_ROOT, "labels", AE_SENS_RUN_ID,
                            "labels_model_ready.rds")
  } else if (IS_PERMANENT_TRACK) {
    c(PATH_LABELS_MODEL_READY, PATH_LABELS_PERMANENT)
  } else {
    c(PATH_LABELS_MODEL_READY, PATH_LABELS_BASE)
  }
  label_path <- candidates[file.exists(candidates)][1L]
  if (is.na(label_path)) {
    stop("No annual CSI label file found for RESPONSE_TRACK=", RESPONSE_TRACK)
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
    "for the aligned signal year; negative contribution is opportunity cost."
  ),
  false_negative = paste(
    "Model retained the firm, and the active-track CSI label was realized",
    "for the aligned signal year; negative contribution is missed protection."
  ),
  true_positive = paste(
    "Model excluded the firm, and the active-track CSI label was realized",
    "for the aligned signal year; positive contribution is avoided loss."
  ),
  true_negative = paste(
    "Model retained the firm, and the active-track CSI label was not realized",
    "for the aligned signal year; contribution reflects preserved exposure."
  )
)

labels_track <- fn_load_track_labels()

bench_weights <- weights_all[
  model_key == "bench",
  .(
    index_id,
    index_name,
    qdate,
    holding_year,
    signal_year,
    permno,
    bench_w = w
  )
]
bench_weights <- merge(
  bench_weights,
  labels_track,
  by = c("permno", "signal_year"),
  all.x = TRUE
)
bench_weights[is.na(actual_event), actual_event := FALSE]

qdates_all <- sort(unique(bench_weights$qdate))
monthly_base <- monthly[
  permno %in% unique(bench_weights$permno),
  .(permno, date, year, month, ret)
]
monthly_base[, qdate := {
  idx <- findInterval(date, qdates_all, left.open = FALSE)
  idx[idx == 0L] <- NA_integer_
  qdates_all[idx]
}]
monthly_base <- monthly_base[
  !is.na(qdate) & date > qdate & year >= INDEX_START & year <= OOS_END
]
base_month <- merge(
  monthly_base,
  bench_weights,
  by = c("permno", "qdate"),
  allow.cartesian = TRUE
)
base_month <- base_month[!is.na(ret)]

all_months <- unique(returns_all[, .(index_id, date, year, month)])
all_months[, tmp_key := 1L]
category_grid <- data.table(confusion_category = CATEGORY_LEVELS, tmp_key = 1L)
month_grid <- merge(all_months, category_grid, by = "tmp_key", allow.cartesian = TRUE)
month_grid[, tmp_key := NULL]
all_months[, tmp_key := NULL]

decomp_rows <- list()

for (i in seq_len(nrow(model_strategies))) {
  sk <- model_strategies[i]
  model_q <- weights_all[
    index_id == sk$index_id &
      model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule,
    .(index_id, qdate, permno, model_w = w)
  ]
  d <- fn_ae_sens_left_merge(
    base_month[index_id == sk$index_id],
    model_q,
    by = c("index_id", "qdate", "permno"),
    context = paste("error_cost_decomposition", sk$strategy_id, sep = "::")
  )
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
  ), by = .(index_id, date, year, month, confusion_category)]

  cat_month <- merge(
    month_grid[index_id == sk$index_id],
    cat_month,
    by = c("index_id", "date", "year", "month", "confusion_category"),
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

  strat_returns <- returns_all[
    index_id == sk$index_id &
      model_key == sk$model_key &
      threshold_method == sk$threshold_method &
      lockout_years == sk$lockout_years &
      strategy_id == sk$strategy_id &
      exclusion_rule == sk$exclusion_rule,
    .(date, year, month, filtered_return = port_ret)
  ]
  bench_returns <- returns_all[
    index_id == sk$index_id & model_key == "bench",
    .(date, year, month, benchmark_return = port_ret)
  ]

  for (pnm in names(PERIODS)) {
    yr <- PERIODS[[pnm]]
    cm <- cat_month[year >= yr[1L] & year <= yr[2L]]
    br <- bench_returns[year >= yr[1L] & year <= yr[2L]]
    sr <- strat_returns[year >= yr[1L] & year <= yr[2L]]
    if (nrow(cm) == 0L || nrow(br) == 0L || nrow(sr) == 0L) next

    bench_ann <- fn_ann_geo(br$benchmark_return)
    filtered_ann <- fn_ann_geo(sr$filtered_return)

    out <- cm[, .(
      n_months = .N,
      n_firm_months = sum(n_firm_months, na.rm = TRUE),
      portfolio_weight_affected = mean(portfolio_weight_affected, na.rm = TRUE),
      filtered_portfolio_weight = mean(filtered_portfolio_weight, na.rm = TRUE),
      annualized_geometric_return_contribution = fn_ann_geo(category_return_difference),
      category_benchmark_annualized_contribution = fn_ann_geo(benchmark_category_return),
      category_filtered_annualized_contribution = fn_ann_geo(filtered_category_return)
    ), by = confusion_category]

    out[, `:=`(
      track = RESPONSE_TRACK,
      period = pnm,
      index_id = sk$index_id,
      index_name = sk$index_name,
      benchmark_index_id = sk$index_id,
      model_key = sk$model_key,
      model_label = sk$model_label,
      threshold_method = sk$threshold_method,
      threshold_label = sk$threshold_label,
      threshold = sk$threshold,
      lockout_years = sk$lockout_years,
      exclusion_rule = sk$exclusion_rule,
      rule_label = sk$rule_label,
      strategy_id = sk$strategy_id,
      weighting = sk$weighting,
      benchmark_annualized_geometric_return = bench_ann,
      filtered_annualized_geometric_return = filtered_ann,
      difference_versus_benchmark = filtered_ann - bench_ann,
      interpretation_notes = CATEGORY_NOTES[confusion_category]
    )]

    decomp_rows[[length(decomp_rows) + 1L]] <- out
  }

  if (i %% 10L == 0L || i == nrow(model_strategies)) {
    cat(sprintf("  %d/%d decomposition strategies\n", i, nrow(model_strategies)))
  }
}

error_cost_decomp <- rbindlist(decomp_rows, use.names = TRUE, fill = TRUE)
setcolorder(error_cost_decomp, c(
  "track", "period", "index_id", "index_name", "benchmark_index_id",
  "model_key", "model_label", "threshold_method", "threshold_label",
  "threshold", "exclusion_rule", "rule_label", "lockout_years",
  "strategy_id", "weighting", "confusion_category", "n_months",
  "n_firm_months", "portfolio_weight_affected",
  "filtered_portfolio_weight",
  "annualized_geometric_return_contribution",
  "category_benchmark_annualized_contribution",
  "category_filtered_annualized_contribution",
  "benchmark_annualized_geometric_return",
  "filtered_annualized_geometric_return",
  "difference_versus_benchmark", "interpretation_notes"
))
setorder(
  error_cost_decomp,
  period, index_id, threshold_method, exclusion_rule, lockout_years,
  confusion_category
)

saveRDS(error_cost_decomp, PATH_11C_DECOMP)
fn_write_csv(error_cost_decomp, file.path(OUT_DIR, "error_cost_decomposition_by_crsp_universe.csv"))

#==============================================================================#
# 8. Status and console summary
#==============================================================================#

RUN_ENDED <- Sys.time()
status <- data.table(
  track = RESPONSE_TRACK,
  started_at = as.character(RUN_STARTED),
  ended_at = as.character(RUN_ENDED),
  elapsed_minutes = as.numeric(difftime(RUN_ENDED, RUN_STARTED, units = "mins")),
  script_path = SCRIPT_PATH,
  output_dir = OUT_DIR,
  n_threshold_rows = nrow(thresholds),
  n_weight_rows = nrow(weights_all),
  n_return_rows = nrow(returns_all),
  n_performance_rows = nrow(performance),
  n_exclusion_rows = nrow(exclusion_summary),
  n_decomposition_rows = nrow(error_cost_decomp),
  response_track = RESPONSE_TRACK,
  permanent_removal = IS_PERMANENT_TRACK
)
fn_write_csv(status, PATH_11C_STATUS)

cat("\n[11C] OOS performance by index and best Sharpe model-filtered strategy:\n")
oos_model <- performance[period == "oos" & model_key != "bench"]
if (nrow(oos_model) > 0L) {
  setorder(oos_model, index_id, -sharpe_ratio, -annualized_geometric_return)
  print(oos_model[, .SD[1L], by = index_id][
    , .(
      index_id,
      threshold_method,
      rule_label,
      annualized_geometric_return,
      annualized_sd,
      sharpe_ratio,
      max_drawdown,
      expected_shortfall_2p5,
      difference_versus_benchmark
    )
  ])
}

cat("\n[11C] COMPLETE:", format(Sys.time()), "\n")
cat("  Output dir:", OUT_DIR, "\n")
