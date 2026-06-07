#==============================================================================#
#==== ae_sens_eval_raw.R =======================================================#
#==== AE-SENS raw-only compact evaluation =====================================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
  library(jsonlite)
})

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L || all(is.na(a))) b else a

fn_env <- function(name) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) stop(sprintf("%s is required", name), call. = FALSE)
  value
}

MT_ROOT <- fn_env("MT_ROOT")
AE_SENS_OUTPUT_ROOT <- fn_env("AE_SENS_OUTPUT_ROOT")
AE_SENS_RUN_ID <- fn_env("AE_SENS_RUN_ID")
MODEL <- fn_env("MODEL")
RESPONSE_TRACK <- fn_env("RESPONSE_TRACK")

if (!identical(MODEL, "raw")) stop("AE-SENS evaluation only permits MODEL=raw", call. = FALSE)
if (!identical(RESPONSE_TRACK, "dynamic_csi")) {
  stop("AE-SENS evaluation only permits RESPONSE_TRACK=dynamic_csi", call. = FALSE)
}
if (!grepl("^C(060|080|090)_M(000|020|030)_T(012|018|028)$", AE_SENS_RUN_ID)) {
  stop("Invalid AE_SENS_RUN_ID", call. = FALSE)
}
if (!grepl("/03_Data_Output/3_Modelling_Results/Necessary/sensitivity$", AE_SENS_OUTPUT_ROOT)) {
  stop("Invalid AE_SENS_OUTPUT_ROOT", call. = FALSE)
}

pred_dir <- file.path(AE_SENS_OUTPUT_ROOT, "raw_predictions", AE_SENS_RUN_ID)
eval_dir <- file.path(AE_SENS_OUTPUT_ROOT, "evaluation", AE_SENS_RUN_ID)
log_dir <- file.path(AE_SENS_OUTPUT_ROOT, "logs", AE_SENS_RUN_ID)
dir.create(eval_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

HAS_ARROW <- requireNamespace("arrow", quietly = TRUE)

fn_read_parquet <- function(path) {
  if (HAS_ARROW) return(as.data.table(arrow::read_parquet(path)))
  tmp <- tempfile(fileext = ".csv")
  py_file <- tempfile(fileext = ".py")
  on.exit(unlink(c(tmp, py_file)), add = TRUE)
  writeLines(c(
    "import pandas as pd",
    "import sys",
    "pd.read_parquet(sys.argv[1]).to_csv(sys.argv[2], index=False)"
  ), py_file)
  status <- system2("python", c(py_file, path, tmp))
  if (!identical(status, 0L)) stop(sprintf("Python parquet fallback failed for %s", path))
  fread(tmp)
}

fn_ap_auc <- function(y, p) {
  ok <- !is.na(y) & !is.na(p)
  y <- as.integer(y[ok])
  p <- as.numeric(p[ok])
  if (length(unique(y)) < 2L) {
    return(data.table(
      n_obs = length(y), n_pos = sum(y == 1L), prevalence = mean(y == 1L),
      avg_precision = NA_real_, auc_roc = NA_real_
    ))
  }
  ap <- if (requireNamespace("PRROC", quietly = TRUE)) {
    PRROC::pr.curve(scores.class0 = p[y == 1L], scores.class1 = p[y == 0L],
                    curve = FALSE)$auc.integral
  } else {
    ord <- order(p, decreasing = TRUE)
    yy <- y[ord]
    tp <- cumsum(yy == 1L)
    fp <- cumsum(yy == 0L)
    precision <- tp / pmax(tp + fp, 1L)
    recall_step <- (yy == 1L) / max(sum(yy == 1L), 1L)
    sum(precision * recall_step)
  }
  auc <- if (requireNamespace("pROC", quietly = TRUE)) {
    as.numeric(pROC::auc(pROC::roc(y, p, quiet = TRUE)))
  } else {
    NA_real_
  }
  data.table(
    n_obs = length(y),
    n_pos = sum(y == 1L),
    prevalence = mean(y == 1L),
    avg_precision = ap,
    auc_roc = auc
  )
}

pred_files <- c(
  test_eval = file.path(pred_dir, "ag_preds_test_eval.parquet"),
  test = file.path(pred_dir, "ag_preds_test.parquet"),
  oos_eval = file.path(pred_dir, "ag_preds_oos_eval.parquet"),
  oos = file.path(pred_dir, "ag_preds_oos.parquet"),
  train_boundary = file.path(pred_dir, "ag_preds_train_boundary.parquet"),
  cv = file.path(pred_dir, "ag_cv_results.parquet")
)
missing <- pred_files[!file.exists(pred_files)]
if (length(missing) > 0L) {
  stop("Missing raw prediction inputs:\n", paste(missing, collapse = "\n"), call. = FALSE)
}

metric_rows <- list()
row_counts <- list()
for (nm in names(pred_files)) {
  dt <- fn_read_parquet(pred_files[[nm]])
  row_counts[[nm]] <- data.table(
    run_id = AE_SENS_RUN_ID,
    file_role = nm,
    rows = nrow(dt),
    path = pred_files[[nm]]
  )
  if (all(c("y", "p_csi") %in% names(dt))) {
    metric_rows[[nm]] <- cbind(
      data.table(run_id = AE_SENS_RUN_ID, model = "raw", set = nm),
      fn_ap_auc(dt$y, dt$p_csi)
    )
  }
}

metrics <- rbindlist(metric_rows, use.names = TRUE, fill = TRUE)
counts <- rbindlist(row_counts, use.names = TRUE, fill = TRUE)

summary_path <- file.path(pred_dir, "ag_eval_summary.json")
if (file.exists(summary_path)) {
  ag_summary <- jsonlite::fromJSON(summary_path, simplifyVector = FALSE)
  ag_summary_compact <- data.table(
    run_id = AE_SENS_RUN_ID,
    model = ag_summary$model %||% "raw",
    cv_ap = ag_summary$cv_ap %||% NA_real_,
    cv_auc = ag_summary$cv_auc %||% NA_real_,
    cv_r3 = ag_summary$cv_r3 %||% NA_real_,
    cv_n_folds = ag_summary$cv_n_folds %||% NA_integer_
  )
  fwrite(ag_summary_compact, file.path(eval_dir, "ag_eval_summary_compact.csv"))
}

fwrite(metrics, file.path(eval_dir, "raw_model_metrics.csv"))
fwrite(counts, file.path(eval_dir, "raw_prediction_row_counts.csv"))
fwrite(data.table(
  run_id = AE_SENS_RUN_ID,
  status = "completed",
  evaluated_at = as.character(Sys.time()),
  n_metric_rows = nrow(metrics),
  n_prediction_files = nrow(counts)
), file.path(log_dir, "evaluation_status.csv"))

cat(sprintf("[AE-SENS eval] metrics=%d prediction_files=%d\n", nrow(metrics), nrow(counts)))
cat("[AE-SENS eval] DONE\n")
