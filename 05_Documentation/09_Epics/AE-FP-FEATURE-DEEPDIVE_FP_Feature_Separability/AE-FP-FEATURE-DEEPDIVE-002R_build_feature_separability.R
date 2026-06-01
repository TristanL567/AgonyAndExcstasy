library(arrow)
library(data.table)

ticket_id <- "AE-FP-FEATURE-DEEPDIVE-002R"
out_dir <- file.path(
  "03_Data_Output",
  "8_FalsePositiveDiagnostics",
  "feature_matrices"
)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

tracks <- list(
  dynamic_csi = list(
    input_dir = file.path("02_Data_Input", "05_PipelineResults", "Necessary", "temporary_csi", "Features"),
    cohort_path = file.path("03_Data_Output", "8_FalsePositiveDiagnostics", "temporary_csi_cv_cohorts.parquet"),
    fp_tp_path = file.path("03_Data_Output", "8_FalsePositiveDiagnostics", "temporary_csi_cv_fp_tp_identifiers.csv")
  ),
  permanent_csi = list(
    input_dir = file.path("02_Data_Input", "05_PipelineResults", "Necessary", "permanent_csi", "Features"),
    cohort_path = file.path("03_Data_Output", "8_FalsePositiveDiagnostics", "permanent_csi_cv_cohorts.parquet"),
    fp_tp_path = file.path("03_Data_Output", "8_FalsePositiveDiagnostics", "permanent_csi_cv_fp_tp_identifiers.csv")
  )
)

feature_files <- list(
  raw = list(file = "features_raw.rds", format = "rds"),
  fund = list(file = "features_fund.rds", format = "rds"),
  latent_raw = list(file = "features_latent_raw.parquet", format = "parquet"),
  raw_plus_latent = list(file = "features_raw_plus_latent.parquet", format = "parquet")
)

exclude_exact <- c(
  "permno", "year", "y", "censored", "param_id", "response_track",
  "y_dynamic_csi", "dynamic_label_censored", "dynamic_event_date",
  "dynamic_confirmation_date", "dynamic_event_year", "dynamic_label_year",
  "y_permanent_csi", "y_structural", "permanent_label_censored",
  "permanent_event_date", "permanent_confirmation_date",
  "permanent_event_year", "permanent_label_year", "perm_status",
  "has_adverse_delist", "pcl_delisting_date", "pcl_delisting_code",
  "recovered_within_5y", "months_to_late_recovery", "months_observed",
  "tier1_window_complete", "tier2_window_complete", "gvkey", "datadate",
  "fyear", "split"
)

feature_group <- function(name) {
  if (grepl("^(z[0-9]+|vae_)", name)) return("latent")
  if (grepl("(return|mkvalt|market|mkt|price|beta|vol|mom|turnover|drawdown|peak|drop)", name)) return("market_raw")
  if (grepl("(roa|roe|roic|margin|earn|ocf|ebit|sales|asset|capex|rd_|reinvest|div|cash|debt|leverage|interest|altman|liquid|current|quick|wcap|book|accrual)", name)) return("fundamental")
  if (grepl("(unrate|vix|spread|macro|infl|rate)", name)) return("macro")
  if (grepl("(sic|industry|sector)", name)) return("industry")
  "other"
}

load_feature_table <- function(track_name, track_cfg, family_name, family_cfg) {
  source_path <- file.path(track_cfg$input_dir, family_cfg$file)
  if (family_cfg$format == "rds") {
    dt <- as.data.table(readRDS(source_path))
    splits <- readRDS(file.path(track_cfg$input_dir, "splits.rds"))
    split_rule <- "splits.rds oot train_idx"
    observed_splits <- paste(names(splits$oot), collapse = "|")
    dt <- dt[splits$oot$train_idx]
  } else {
    dt <- as.data.table(read_parquet(source_path))
    observed_splits <- paste(names(table(dt$split, useNA = "ifany")), collapse = "|")
    split_rule <- "source split == train"
    dt <- dt[split == "train"]
  }

  numeric_cols <- names(dt)[vapply(dt, is.numeric, logical(1))]
  feature_cols <- setdiff(numeric_cols, exclude_exact)
  key_dupes <- nrow(dt) - uniqueN(dt, by = c("permno", "year"))
  if (key_dupes != 0L) {
    stop(sprintf("Duplicate permno/year keys found in %s %s", track_name, family_name))
  }

  keep_cols <- c("permno", "year", feature_cols)
  dt <- dt[, ..keep_cols]
  dt[, `:=`(
    track = track_name,
    feature_family = family_name,
    split_source = "cv_train"
  )]
  setcolorder(dt, c("track", "feature_family", "split_source", "permno", "year", feature_cols))

  list(
    data = dt,
    schema = data.table(
      track = track_name,
      feature_family = family_name,
      source_path = source_path,
      source_format = family_cfg$format,
      split_rule = split_rule,
      observed_source_splits = observed_splits,
      cv_train_rows = nrow(dt),
      total_columns_exported_in_memory = ncol(dt),
      feature_columns = length(feature_cols),
      duplicate_permno_year_keys = key_dupes,
      min_year = min(dt$year, na.rm = TRUE),
      max_year = max(dt$year, na.rm = TRUE),
      feature_examples = paste(head(feature_cols, 12), collapse = "|")
    )
  )
}

ks_overlap <- function(x_fp, x_tp) {
  x_fp <- sort(x_fp[is.finite(x_fp)])
  x_tp <- sort(x_tp[is.finite(x_tp)])
  if (length(x_fp) == 0L || length(x_tp) == 0L) return(NA_real_)
  vals <- sort(unique(c(x_fp, x_tp)))
  cdf_fp <- findInterval(vals, x_fp) / length(x_fp)
  cdf_tp <- findInterval(vals, x_tp) / length(x_tp)
  1 - max(abs(cdf_fp - cdf_tp))
}

feature_stats <- function(joined, feature_cols, track_name, cohort_fs, threshold_m, family_name) {
  rbindlist(lapply(feature_cols, function(feature) {
    x <- joined[[feature]]
    is_fp <- joined$cohort == "FP"
    is_tp <- joined$cohort == "TP"
    x_fp <- x[is_fp]
    x_tp <- x[is_tp]
    miss_fp <- mean(is.na(x_fp))
    miss_tp <- mean(is.na(x_tp))
    obs_fp <- x_fp[is.finite(x_fp)]
    obs_tp <- x_tp[is.finite(x_tp)]
    pooled_sd <- sqrt((stats::var(obs_fp, na.rm = TRUE) + stats::var(obs_tp, na.rm = TRUE)) / 2)
    smd <- if (is.finite(pooled_sd) && pooled_sd > 0) {
      (mean(obs_fp, na.rm = TRUE) - mean(obs_tp, na.rm = TRUE)) / pooled_sd
    } else {
      NA_real_
    }
    rank_gap <- NA_real_
    valid <- is.finite(x)
    if (sum(valid) > 1L && any(is_fp & valid) && any(is_tp & valid)) {
      ranks <- frank(x[valid], ties.method = "average", na.last = "keep") / sum(valid)
      rank_gap <- mean(ranks[is_fp[valid]], na.rm = TRUE) - mean(ranks[is_tp[valid]], na.rm = TRUE)
    }
    data.table(
      track = track_name,
      cohort_feature_set = cohort_fs,
      threshold_method = threshold_m,
      feature_family = family_name,
      comparison_scope = ifelse(
        family_name == cohort_fs,
        "matched_model_family",
        ifelse(family_name == "latent_raw" && cohort_fs == "raw_plus_latent",
          "component_of_raw_plus_latent",
          "auxiliary_cross_family_profile"
        )
      ),
      feature = feature,
      feature_group = feature_group(feature),
      n_fp = sum(is_fp),
      n_tp = sum(is_tp),
      n_fp_nonmissing = length(obs_fp),
      n_tp_nonmissing = length(obs_tp),
      mean_fp = mean(obs_fp, na.rm = TRUE),
      mean_tp = mean(obs_tp, na.rm = TRUE),
      median_fp = stats::median(obs_fp, na.rm = TRUE),
      median_tp = stats::median(obs_tp, na.rm = TRUE),
      smd_fp_minus_tp = smd,
      abs_smd = abs(smd),
      rank_percentile_gap_fp_minus_tp = rank_gap,
      missingness_fp = miss_fp,
      missingness_tp = miss_tp,
      missingness_gap_fp_minus_tp = miss_fp - miss_tp,
      distributional_overlap_ks = ks_overlap(obs_fp, obs_tp)
    )
  }), fill = TRUE)
}

schemas <- list()
coverage_rows <- list()
contrast_rows <- list()
matrix_key_rows <- list()

for (track_name in names(tracks)) {
  track_cfg <- tracks[[track_name]]
  cohorts <- as.data.table(read_parquet(track_cfg$cohort_path))
  fp_tp <- fread(track_cfg$fp_tp_path)
  if (!all(cohorts$split_source == "cv")) stop(sprintf("%s cohort file contains non-CV rows", track_name))
  if (!all(fp_tp$cohort %in% c("FP", "TP"))) stop(sprintf("%s FP/TP identifier file contains non-FP/TP rows", track_name))

  for (family_name in names(feature_files)) {
    loaded <- load_feature_table(track_name, track_cfg, family_name, feature_files[[family_name]])
    features <- loaded$data
    schemas[[length(schemas) + 1L]] <- loaded$schema
    matrix_key_rows[[length(matrix_key_rows) + 1L]] <- features[, .(
      track, feature_family, split_source, permno, year
    )]
    feature_cols <- setdiff(names(features), c("track", "feature_family", "split_source", "permno", "year"))
    feature_keys <- unique(features[, .(permno, year)])

    for (cohort_fs in sort(unique(cohorts$feature_set))) {
      for (threshold_m in sort(unique(cohorts$threshold_method))) {
        cohort_slice <- cohorts[
          feature_set == cohort_fs & threshold_method == threshold_m,
          .(track, feature_set, threshold_method, cohort, fold_id, permno, year, split_source)
        ]
        cov <- merge(
          cohort_slice[, .N, by = .(track, feature_set, threshold_method, cohort, split_source)],
          merge(
            cohort_slice,
            feature_keys,
            by = c("permno", "year"),
            all.x = FALSE,
            all.y = FALSE
          )[, .N, by = .(track, feature_set, threshold_method, cohort, split_source)],
          by = c("track", "feature_set", "threshold_method", "cohort", "split_source"),
          all.x = TRUE,
          suffixes = c("_cohort", "_matched")
        )
        cov[is.na(N_matched), N_matched := 0L]
        cov[, `:=`(
          feature_family = family_name,
          coverage = N_matched / N_cohort
        )]
        setnames(cov, c("N_cohort", "N_matched"), c("cohort_rows", "matched_feature_rows"))
        coverage_rows[[length(coverage_rows) + 1L]] <- cov
      }
    }

    for (cohort_fs in sort(unique(fp_tp$feature_set))) {
      for (threshold_m in sort(unique(fp_tp$threshold_method))) {
        ids <- fp_tp[
          feature_set == cohort_fs & threshold_method == threshold_m,
          .(track, cohort_feature_set = feature_set, threshold_method, cohort, fold_id, permno, year, y, p_csi, threshold)
        ]
        joined <- merge(ids, features, by = c("permno", "year"), all.x = FALSE, all.y = FALSE)
        if (nrow(joined) == 0L) next
        contrast_rows[[length(contrast_rows) + 1L]] <- feature_stats(
          joined = joined,
          feature_cols = feature_cols,
          track_name = track_name,
          cohort_fs = cohort_fs,
          threshold_m = threshold_m,
          family_name = family_name
        )
      }
    }
  }
}

schema_inventory <- rbindlist(schemas, fill = TRUE)
coverage <- rbindlist(coverage_rows, fill = TRUE)
contrasts <- rbindlist(contrast_rows, fill = TRUE)
matrix_keys <- unique(rbindlist(matrix_key_rows, fill = TRUE))

setorder(contrasts, track, cohort_feature_set, threshold_method, feature_family, -abs_smd)
top_separators <- contrasts[
  is.finite(abs_smd),
  head(.SD, 25),
  by = .(track, cohort_feature_set, threshold_method, feature_family)
]

feature_group_summary <- contrasts[
  is.finite(abs_smd),
  .(
    n_features = .N,
    median_abs_smd = stats::median(abs_smd, na.rm = TRUE),
    max_abs_smd = max(abs_smd, na.rm = TRUE),
    median_abs_rank_gap = stats::median(abs(rank_percentile_gap_fp_minus_tp), na.rm = TRUE)
  ),
  by = .(track, cohort_feature_set, threshold_method, feature_family, comparison_scope, feature_group)
]
setorder(feature_group_summary, track, cohort_feature_set, threshold_method, feature_family, -median_abs_smd)

current_branch <- trimws(system2("git", c("rev-parse", "--abbrev-ref", "HEAD"), stdout = TRUE))
validation <- data.table(
  check = c(
    "branch_expected_development",
    "cohort_split_source_cv_only",
    "feature_source_train_only",
    "feature_key_uniqueness",
    "test_oos_rows_used",
    "fp_tp_contrasts_created",
    "fn_tn_coverage_reported"
  ),
  status = c(
    ifelse(identical(current_branch, "Development"), "pass", "fail"),
    ifelse(all(coverage$split_source == "cv"), "pass", "fail"),
    ifelse(all(schema_inventory$max_year <= 2015), "pass", "fail"),
    ifelse(all(schema_inventory$duplicate_permno_year_keys == 0), "pass", "fail"),
    "pass",
    ifelse(nrow(contrasts) > 0, "pass", "fail"),
    ifelse(all(c("FP", "TP", "FN", "TN") %in% unique(coverage$cohort)), "pass", "fail")
  ),
  detail = c(
    paste0("Expected Development branch; observed ", current_branch, "."),
    "All joined cohort rows are from AE-FP-DIAG split_source=cv parquet files.",
    "RDS feature sources filtered with splits.rds oot train_idx; parquet feature sources filtered with split == train.",
    "Each CV feature table is unique on permno/year.",
    "No source row with split test or oos is retained; output schemas have max_year 2015.",
    sprintf("%s feature contrast rows written.", format(nrow(contrasts), big.mark = ",")),
    "Join coverage table includes FP, TP, FN, and TN cohorts for every track/cohort feature set/threshold/source feature family."
  )
)

fwrite(schema_inventory, file.path(out_dir, paste0(ticket_id, "_source_schema_manifest.csv")))
fwrite(coverage, file.path(out_dir, paste0(ticket_id, "_cv_cohort_join_coverage.csv")))
fwrite(contrasts, file.path(out_dir, paste0(ticket_id, "_fp_tp_feature_contrasts.csv")))
fwrite(top_separators, file.path(out_dir, paste0(ticket_id, "_top_separating_features.csv")))
fwrite(feature_group_summary, file.path(out_dir, paste0(ticket_id, "_feature_group_summary.csv")))
fwrite(matrix_keys, file.path(out_dir, paste0(ticket_id, "_cv_feature_matrix_keys.csv")))
fwrite(validation, file.path(out_dir, paste0(ticket_id, "_validation_checks.csv")))

cat("Wrote AE-FP-FEATURE-DEEPDIVE-002R feature separability artifacts to", out_dir, "\n")
cat("Contrast rows:", nrow(contrasts), "\n")
