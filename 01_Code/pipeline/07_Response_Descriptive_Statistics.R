#==============================================================================#
#==== 07_Response_Descriptive_Statistics.R ====================================#
#==== Response Descriptive Statistics Generator ================================#
#==============================================================================#
#
# PURPOSE:
#   Build response-label overview tables for the active descriptive-statistics
#   output track without running upstream pipeline steps.
#
# INPUTS:
#   02_Data_Input/05_PipelineResults/Necessary/{temporary_csi,permanent_csi}/
#     Labels/labels_model_ready.rds
#     Features/features_raw.rds
#     Features/splits.rds
#
# OUTPUTS:
#   03_Data_Output/1_Descriptive_Statistics/Necessary/{TRACK_FOLDER}/
#     csi_revised_label_scaffold_stats/overview_counts_cv_and_full.csv
#     csi_response_stats/overview_by_track_response.csv
#     csi_prediction_response_stats/overview_by_track_split_response.csv
#     csi_prediction_response_stats_with_cv/overview_by_track_split_response.csv
#
# DRY RUN:
#   Set DRY_RUN=1 to print planned inputs, outputs, and summaries without
#   writing CSV files.
#==============================================================================#

suppressPackageStartupMessages(library(data.table))

.script_path <- tryCatch(normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
                         error = function(e) NA_character_)
if (is.na(.script_path)) {
  .cmd_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  .script_path <- normalizePath(.cmd_file, winslash = "/", mustWork = FALSE)
}
.script_dir <- dirname(.script_path)
if (!file.exists(file.path(.script_dir, "config.R"))) {
  .script_dir <- getwd()
}

source(file.path(.script_dir, "config.R"))

cat("\n[07_Response_Descriptive_Statistics.R] START:", format(Sys.time()), "\n")
cat(sprintf("  RESPONSE_TRACK: %s\n", RESPONSE_TRACK))
cat(sprintf("  TRACK_FOLDER  : %s\n", TRACK_FOLDER))

DRY_RUN <- tolower(trimws(Sys.getenv("DRY_RUN", unset = "0"))) %in%
  c("1", "true", "t", "yes", "y", "on")
cat(sprintf("  DRY_RUN       : %s\n", if (DRY_RUN) "TRUE" else "FALSE"))

TRACK_META <- data.table(
  response_track = c("dynamic_csi", "permanent_csi"),
  track_folder   = c("temporary_csi", "permanent_csi"),
  csi_type       = c("Temporary-CSI", "Permanent-CSI"),
  csi_type_short = c("Temporary", "Permanent")
)

fn_track_dir <- function(track_folder, subdir) {
  file.path(PR_NEC, track_folder, subdir)
}

fn_required_paths <- function(track_folder) {
  list(
    labels   = file.path(fn_track_dir(track_folder, "Labels"), "labels_model_ready.rds"),
    features = file.path(fn_track_dir(track_folder, "Features"), "features_raw.rds"),
    splits   = file.path(fn_track_dir(track_folder, "Features"), "splits.rds")
  )
}

fn_stop_missing <- function(paths, track_folder) {
  missing <- unlist(paths)[!file.exists(unlist(paths))]
  if (length(missing) > 0L) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] Missing required input artifact(s) for track '%s':\n%s",
      track_folder,
      paste(sprintf("  - %s", missing), collapse = "\n")
    ), call. = FALSE)
  }
  invisible(TRUE)
}

fn_assert_columns <- function(dt, required, label, path) {
  missing <- setdiff(required, names(dt))
  if (length(missing) > 0L) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] %s is missing required column(s): %s\n  path: %s",
      label,
      paste(missing, collapse = ", "),
      path
    ), call. = FALSE)
  }
  invisible(TRUE)
}

fn_cv_validation_rows <- function(splits, n_rows, track_folder) {
  cv_folds <- splits$oot$cv_folds
  if (is.null(cv_folds) || length(cv_folds) == 0L) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] splits.rds for '%s' has no oot$cv_folds.",
      track_folder
    ), call. = FALSE)
  }

  rows <- sort(unique(unlist(lapply(cv_folds, `[[`, "validation"), use.names = FALSE)))
  if (length(rows) == 0L) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] splits.rds for '%s' has empty CV validation rows.",
      track_folder
    ), call. = FALSE)
  }
  if (any(is.na(rows)) || min(rows) < 1L || max(rows) > n_rows) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] CV validation row indices for '%s' do not align to features_raw.rds.",
      track_folder
    ), call. = FALSE)
  }
  rows
}

fn_load_track <- function(meta_row) {
  paths <- fn_required_paths(meta_row$track_folder)
  fn_stop_missing(paths, meta_row$track_folder)

  labels <- as.data.table(readRDS(paths$labels))
  features <- as.data.table(readRDS(paths$features))
  splits <- readRDS(paths$splits)

  fn_assert_columns(labels, c("permno", "year", "y"), "labels_model_ready.rds", paths$labels)
  fn_assert_columns(features, c("permno", "year", "y"), "features_raw.rds", paths$features)

  if (nrow(features) != length(splits$oot$split_col) ||
      nrow(features) != length(splits$oot$eval_split_col)) {
    stop(sprintf(
      "[07_Response_Descriptive_Statistics.R] splits.rds row count does not match features_raw.rds for '%s'.",
      meta_row$track_folder
    ), call. = FALSE)
  }

  labels <- labels[!is.na(y)]
  labels[, `:=`(
    response_track = meta_row$response_track,
    track = meta_row$track_folder,
    csi_type = meta_row$csi_type,
    csi_type_short = meta_row$csi_type_short
  )]

  split_dt <- copy(features)
  split_dt[, `:=`(
    split = splits$oot$split_col,
    eval_split = splits$oot$eval_split_col,
    response_track = meta_row$response_track,
    track = meta_row$track_folder,
    csi_type = meta_row$csi_type,
    csi_type_short = meta_row$csi_type_short
  )]
  split_dt <- split_dt[!is.na(y)]

  cv_rows <- fn_cv_validation_rows(splits, nrow(features), meta_row$track_folder)
  cv_dt <- copy(features[cv_rows])
  cv_dt[, `:=`(
    split = "cv",
    split_label = "CV",
    response_track = meta_row$response_track,
    track = meta_row$track_folder,
    csi_type = meta_row$csi_type,
    csi_type_short = meta_row$csi_type_short
  )]
  cv_dt <- cv_dt[!is.na(y)]

  list(
    labels = labels,
    split_dt = split_dt,
    cv_dt = cv_dt,
    paths = paths
  )
}

fn_response_summary <- function(dt) {
  out <- dt[, .(
    n_obs = .N,
    n_firms = uniqueN(permno),
    first_year = min(year, na.rm = TRUE),
    last_year = max(year, na.rm = TRUE)
  ), by = .(track, response = y)]
  totals <- dt[, .(track_n_obs = .N), by = track]
  out <- totals[out, on = "track"]
  out[, response_share := n_obs / track_n_obs]
  setcolorder(out, c("track", "response", "n_obs", "response_share",
                     "n_firms", "first_year", "last_year", "track_n_obs"))
  setorder(out, track, response)
  out[]
}

fn_split_summary <- function(dt, include_cv = FALSE) {
  base <- dt[split %in% c("test", "oos")]
  base[, split_label := fifelse(split == "test", "Test", "Test-OOS")]
  if (include_cv) {
    cv_base <- rbindlist(lapply(track_payloads, `[[`, "cv_dt"), use.names = TRUE, fill = TRUE)
    base <- rbindlist(list(cv_base, base), use.names = TRUE, fill = TRUE)
  }
  out <- base[, .(
    obs = .N,
    firms = uniqueN(permno),
    first_year = min(year, na.rm = TRUE),
    last_year = max(year, na.rm = TRUE)
  ), by = .(track = response_track, csi_type, split, split_label, response = y)]
  totals <- base[, .(total = .N), by = .(track = response_track, split)]
  out <- totals[out, on = c("track", "split")]
  out[, share := obs / total]
  setcolorder(out, c("track", "csi_type", "split", "split_label", "response",
                     "obs", "firms", "first_year", "last_year", "total", "share"))
  setorder(out, track, response, factor(split, levels = c("cv", "test", "oos")))
  out[]
}

fn_cv_full_counts <- function(labels_dt) {
  full <- labels_dt[, .(
    Obs = .N,
    Firms = uniqueN(permno)
  ), by = .(`CSI type` = csi_type_short, Split = "Full", y)]

  cv <- rbindlist(lapply(track_payloads, `[[`, "cv_dt"), use.names = TRUE, fill = TRUE)
  cv <- cv[, .(
    Obs = .N,
    Firms = uniqueN(permno)
  ), by = .(`CSI type` = csi_type_short, Split = "CV", y)]

  out <- rbindlist(list(cv, full), use.names = TRUE)
  out[, Share := Obs / sum(Obs), by = .(`CSI type`, Split)]
  setcolorder(out, c("CSI type", "Split", "y", "Obs", "Share", "Firms"))
  setorder(out, `CSI type`, Split, y)
  out[]
}

OUT_DIR <- file.path(DIR_DESC_NEC, TRACK_FOLDER)
OUT_PATHS <- list(
  counts_cv_and_full = file.path(
    OUT_DIR, "csi_revised_label_scaffold_stats", "overview_counts_cv_and_full.csv"
  ),
  by_track_response = file.path(
    OUT_DIR, "csi_response_stats", "overview_by_track_response.csv"
  ),
  by_track_split_response = file.path(
    OUT_DIR, "csi_prediction_response_stats", "overview_by_track_split_response.csv"
  ),
  by_track_split_response_with_cv = file.path(
    OUT_DIR, "csi_prediction_response_stats_with_cv", "overview_by_track_split_response.csv"
  )
)

cat("\n[07_Response_Descriptive_Statistics.R] Planned inputs:\n")
for (i in seq_len(nrow(TRACK_META))) {
  p <- fn_required_paths(TRACK_META$track_folder[i])
  cat(sprintf("  %s:\n", TRACK_META$track_folder[i]))
  cat(sprintf("    labels  : %s\n", p$labels))
  cat(sprintf("    features: %s\n", p$features))
  cat(sprintf("    splits  : %s\n", p$splits))
}

cat("\n[07_Response_Descriptive_Statistics.R] Planned outputs:\n")
for (p in OUT_PATHS) cat(sprintf("  - %s\n", p))

track_payloads <- lapply(seq_len(nrow(TRACK_META)), function(i) {
  fn_load_track(TRACK_META[i])
})

labels_all <- rbindlist(lapply(track_payloads, `[[`, "labels"), use.names = TRUE, fill = TRUE)
split_all <- rbindlist(lapply(track_payloads, `[[`, "split_dt"), use.names = TRUE, fill = TRUE)

overview_counts_cv_and_full <- fn_cv_full_counts(labels_all)
overview_by_track_response <- fn_response_summary(labels_all)
overview_by_track_split_response <- fn_split_summary(split_all, include_cv = FALSE)
overview_by_track_split_response_with_cv <- fn_split_summary(split_all, include_cv = TRUE)

cat("\n[07_Response_Descriptive_Statistics.R] Count summary:\n")
print(overview_counts_cv_and_full)

fn_write_csv <- function(dt, path) {
  if (DRY_RUN) {
    cat(sprintf("  [dry-run] would write %s (%d rows)\n", path, nrow(dt)))
    return(invisible(path))
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  fwrite(dt, path)
  cat(sprintf("  wrote %s (%d rows)\n", path, nrow(dt)))
  invisible(path)
}

cat("\n[07_Response_Descriptive_Statistics.R] Write step:\n")
fn_write_csv(overview_counts_cv_and_full, OUT_PATHS$counts_cv_and_full)
fn_write_csv(overview_by_track_response, OUT_PATHS$by_track_response)
fn_write_csv(overview_by_track_split_response, OUT_PATHS$by_track_split_response)
fn_write_csv(overview_by_track_split_response_with_cv,
             OUT_PATHS$by_track_split_response_with_cv)

cat("[07_Response_Descriptive_Statistics.R] DONE:", format(Sys.time()), "\n")
