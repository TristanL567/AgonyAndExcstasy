# AE-SENS-002 Raw Feature Reuse Validation Report

## Status

Completed.

## Summary

Whole-file reuse of the existing `features_raw.rds` across all C/M/T label variants is not valid.

The valid implementation route is:

**Shared immutable covariate feature base plus per-grid label and split attachment.**

The existing pipeline can reuse the engineered covariate calculations, because C/M/T parameters are not used by `06_Merge.R`, `06B_FeatureEngineering.R`, or `08_Split.R` as feature-construction parameters. However, the existing `features_raw.rds` object cannot be reused directly across grid variants because it is built on an active label scaffold and embeds `y`, `censored`, `param_id`, response-track metadata, and event/label metadata. Splits must also be regenerated or reattached per grid label variant because the firm-level OOS split stratifies on `y`, and downstream split artifacts are row-aligned to the current `features_raw` rows.

## Findings

### 1. C/M/T affects event and label generation

`config.R` defines the base and grid C/M/T values:

- `CSI_BASE <- list(C = -0.80, M = -0.20, T = 18L)` in `01_Code/pipeline/config.R:808`.
- `CSI_GRID <- expand.grid(C = c(-0.60, -0.80, -0.90), M = c(0.00, -0.20, -0.30), T = c(12L, 18L, 24L), ...)` in `01_Code/pipeline/config.R:810-824`.

`05A_Dynamic_CSI_Label.R` passes C/M/T only into event detection:

- `fn_detect_events_one_firm(dt, C, M, T, ...)` uses `C` as the drawdown trigger threshold, `M` as the recovery ceiling, and `T` as the confirmation horizon in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:145-263`.
- `fn_detect_events(price_path, C, M, T, param_id, ...)` selects `confirm_date_T%03d` from `T` and records `param_id`, `C`, `M`, and `T` on event rows in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:330-362`.
- Base events use `CSI_BASE` in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:451-459`.
- Grid events and annual labels are generated only inside the optional `CSI_RUN_GRID` branch in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:490-530`.

Annual labels are produced from event rows:

- `fn_events_to_annual()` creates a `(permno, year)` panel and sets positives/censored labels from event rows in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:365-383`.
- In that function, events are aligned to `year = trigger_year - 1L` in `01_Code/pipeline/05A_Dynamic_CSI_Label.R:372-375`.

### 2. Label-to-feature attachment keys are `permno` and `year`

The active model-ready label table is validated to contain `permno`, `year`, and `y` in `01_Code/pipeline/06_Merge.R:419-429`.

The label scaffold is keyed at `(permno, year)`:

- The scaffold is built from monthly price observability and returns rows with `permno` and `year` in `01_Code/pipeline/06_Merge.R:41-98`.
- Duplicate label keys are rejected with `anyDuplicated(labels[, .(permno, year)])` in `01_Code/pipeline/06_Merge.R:441-445`.

Dynamic label attachment uses:

- `label_year = trigger_year - LABEL_EVENT_YEAR_LAG` in `01_Code/pipeline/06_Merge.R:126-132`.
- Positive labels attach with `on = .(permno, year = label_year)` in `01_Code/pipeline/06_Merge.R:136-144`.
- Censoring attaches with `on = .(permno, year = label_year)` in `01_Code/pipeline/06_Merge.R:146-153`.
- `LABEL_EVENT_YEAR_LAG <- 1L` and `LABEL_ALIGNMENT_METHOD <- "event_year_minus_1"` are defined in `01_Code/pipeline/config.R:850-854`.

Feature-side joins also use the same annual keys:

- Fundamentals join on `by = c("permno", "year")` in `01_Code/pipeline/06_Merge.R:554`.
- Macro joins on `by = "year"` in `01_Code/pipeline/06_Merge.R:555`.
- Annual price summaries join on `by = c("permno", "year")` in `01_Code/pipeline/06_Merge.R:556`.
- Universe metadata joins on `by = "permno"` in `01_Code/pipeline/06_Merge.R:557`.
- Price feature engineering joins rolling price features back on `by = c("permno", "year")` in `01_Code/pipeline/06B_FeatureEngineering.R:563-575`.

Therefore, the exact label-to-feature join key for grid attachment should be:

`(permno, year)`, where `year` is the annual label year and dynamic CSI events use `label_year = trigger_year - LABEL_EVENT_YEAR_LAG`.

### 3. Engineered covariates are not directly C/M/T-derived

Code search found no C/M/T parameter use in `06_Merge.R`, `06B_FeatureEngineering.R`, or `08_Split.R` other than unrelated comment letters. The pipeline stages after label generation do not compute feature values from `C`, `M`, or `T`.

`06_Merge.R` builds the annual panel by copying active labels and adding fundamentals, macro, annual price summaries, and universe metadata in `01_Code/pipeline/06_Merge.R:552-557`.

`06B_FeatureEngineering.R` states and implements backward-looking feature construction:

- Inputs are `PATH_PANEL_RAW` and `PATH_PRICES_MONTHLY` in `01_Code/pipeline/06B_FeatureEngineering.R:10-16`.
- It explicitly states no feature at year `t` uses information from year `t` onward in `01_Code/pipeline/06B_FeatureEngineering.R:31-35`.
- Price features are joined by `(permno, year)` in `01_Code/pipeline/06B_FeatureEngineering.R:563-575`.

This supports reuse of a C/M/T-invariant covariate panel. It does not support direct reuse of the current label-bearing `features_raw.rds` file.

### 4. Existing `features_raw.rds` embeds labels and variant-dependent metadata

`features_raw` includes ID and label columns:

- `id_cols` include `permno`, `year`, `y`, `censored`, `param_id`, `response_track`, dynamic/permanent label columns, event dates, event years, and label years in `01_Code/pipeline/06B_FeatureEngineering.R:674-690`.
- `features_raw <- panel[, ..keep_cols]` and `saveRDS(features_raw, PATH_FEATURES_RAW)` are in `01_Code/pipeline/06B_FeatureEngineering.R:691-698`.
- Duplicate key and valid `y` assertions are run on `features_raw` in `01_Code/pipeline/06B_FeatureEngineering.R:812-820`.

Because `features_raw` carries `y`, `censored`, `param_id`, and event metadata, it is a label-attached modeling table, not an immutable covariate-only feature base.

### 5. Sample construction can vary with labels

`06_Merge.R` starts from `panel <- copy(labels)` before adding covariates in `01_Code/pipeline/06_Merge.R:552-557`. The current label scaffold is based on observable `(permno, year)` rows, but label status still affects the attached `y`, `censored`, event metadata, and final usable training rows after downstream `!is.na(y)` filters.

Therefore:

- Covariate values can be reused.
- The label-attached sample cannot be treated as a single immutable `features_raw` across all variants unless the implementation first separates a common covariate base from variant labels.

### 6. Splits are variant-dependent artifacts in the current pipeline

`08_Split.R` reads `PATH_FEATURES_RAW`, sorts by `(permno, year)`, and reports `y` counts in `01_Code/pipeline/08_Split.R:125-152`.

OOT temporal split labels are determined by `features$year` in `01_Code/pipeline/08_Split.R:171-201`, so the calendar assignment itself is invariant for rows present in the feature base.

However, the firm-level OOS split stratifies on label prevalence:

- `firm_profile <- features[, .(y_firm = as.integer(any(y == 1L, na.rm = TRUE) == 1L)), by = permno]` in `01_Code/pipeline/08_Split.R:274-277`.
- Stratified train/test firm assignment uses `y_firm` in `01_Code/pipeline/08_Split.R:289-321`.

Saved split artifacts are row-aligned to the active `features_raw`:

- `splits` stores index vectors and metadata including `features_path = PATH_FEATURES_RAW` in `01_Code/pipeline/08_Split.R:611-668`.
- `split_labels_oot.parquet` and `split_labels_oos.parquet` are exported with `(permno, year, split, eval_split)` or `(permno, year, split)` from current `features` rows in `01_Code/pipeline/08_Split.R:707-723`.

Thus split artifacts should be generated or attached per grid variant after the variant label table is joined.

## Route Decision

Use **shared immutable covariate feature base plus per-grid label/split attachment**.

Implementation route to name in downstream tickets:

1. Build or materialize a C/M/T-invariant covariate base with one row per `(permno, year)` and no label columns such as `y`, `censored`, `param_id`, event dates, event years, label years, or response-track label metadata.
2. For each C/M/T grid variant, derive annual labels from that variant's event table using `(permno, label_year)` where `label_year = trigger_year - LABEL_EVENT_YEAR_LAG`.
3. Attach variant labels to the covariate base by `(permno, year)`.
4. Regenerate or attach row-aligned split artifacts per variant. OOT calendar splits may reuse deterministic year rules, but saved indices/parquets must align to the variant-attached modeling table. Firm-level OOS splits must be recomputed per variant because stratification uses `y`.

Fallback full per-grid dataset route is only necessary if the implementation cannot separate the covariate base from the current label-bearing `features_raw` pipeline outputs. In that case, each grid variant must rebuild its own full `panel_raw`, `features_raw`, and split artifacts.

## Artifacts

- Created: `07_CloudComputing/Validation/AE-SENS/AE-SENS-002_Raw_Feature_Reuse_Validation_Report.md`

No data, code, model output, cloud host, or large artifact was modified.

## Verification

Lightweight verification only. No full grid run, no model training, no pipeline regeneration, and no large `.rds` or parquet artifact reads were performed.

Commands run:

```powershell
Get-Content -Path '05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets/AE-SENS-002_Raw_Feature_Reuse_Validation.md'
rg -n "CENSOR|CONTROL|MATCH|censor|control|match|LABEL_EVENT_YEAR_LAG|label_year|features_raw|left_join|inner_join|permno|year| y\b|splits|split" 01_Code/pipeline
git status --short
rg -n "PARAM_|CMT|param_id|LABEL_EVENT_YEAR_LAG|label_year|trigger_year|events|censored|labels_model_ready|permno|year|dynamic" 01_Code/pipeline/05A_Dynamic_CSI_Label.R
rg -n "labels_model_ready|PATH_LABELS|PATH_FEATURES_RAW|features_raw|merge|join|left_join|inner_join|permno|year| y\b|censored|param_id|all\.x|by =" 01_Code/pipeline/06_Merge.R 01_Code/pipeline/06B_FeatureEngineering.R
rg -n "PATH_FEATURES_RAW|PATH_SPLITS|features_raw|readRDS|split|eval_split|cv|permno|year| y\b|is\.na\(y\)|complete|train|test|oos|setorder" 01_Code/pipeline/08_Split.R
rg -n "LABEL_ALIGNMENT_METHOD|LABEL_EVENT_YEAR_LAG|PARAM_C|PARAM_M|PARAM_T|CMT|PATH_LABELS|PATH_FEATURES_RAW|PATH_SPLITS|DIR_FEATURES_TRACK|SPLIT" 01_Code/pipeline/config.R
$p='01_Code/pipeline/05A_Dynamic_CSI_Label.R'; $lines=Get-Content $p; for($i=140;$i -le 383;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }
$p='01_Code/pipeline/06_Merge.R'; $lines=Get-Content $p; for($i=1;$i -le 35;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }; for($i=107;$i -le 179;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }; for($i=419;$i -le 559;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }
$p='01_Code/pipeline/06B_FeatureEngineering.R'; $lines=Get-Content $p; foreach($range in @(@(1,52),@(563,578),@(671,698),@(812,820))){ for($i=$range[0];$i -le $range[1];$i++){ '{0}:{1}' -f $i,$lines[$i-1] } }
$p='01_Code/pipeline/08_Split.R'; $lines=Get-Content $p; foreach($range in @(@(125,152),@(171,201),@(270,321),@(401,445),@(611,723))){ for($i=$range[0];$i -le $range[1];$i++){ '{0}:{1}' -f $i,$lines[$i-1] } }
$p='01_Code/pipeline/06_Merge.R'; $lines=Get-Content $p; for($i=37;$i -le 105;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }; for($i=560;$i -le 588;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }
$p='01_Code/pipeline/config.R'; $lines=Get-Content $p; foreach($range in @(@(230,250),@(690,750),@(845,855),@(930,970))){ for($i=$range[0];$i -le $range[1];$i++){ '{0}:{1}' -f $i,$lines[$i-1] } }
rg -n "CSI_GRID|PARAM_C|PARAM_M|PARAM_T|CSI_RUN_GRID|expand.grid|data.table\(" 01_Code/pipeline/config.R 01_Code/pipeline/05A_Dynamic_CSI_Label.R
Get-ChildItem -Path '07_CloudComputing/Validation/AE-SENS' -Force | Select-Object Mode,Length,LastWriteTime,Name
$p='01_Code/pipeline/config.R'; $lines=Get-Content $p; for($i=800;$i -le 843;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }
$p='01_Code/pipeline/05A_Dynamic_CSI_Label.R'; $lines=Get-Content $p; for($i=429;$i -le 532;$i++){ '{0}:{1}' -f $i,$lines[$i-1] }
rg -n "\bC\b|\bM\b|\bT\b|CSI_GRID|CSI_BASE|PARAM_C|PARAM_M|PARAM_T" 01_Code/pipeline/06_Merge.R 01_Code/pipeline/06B_FeatureEngineering.R 01_Code/pipeline/08_Split.R
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD
```

Git status summary at start:

```text
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

Git status summary after report creation:

```text
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-002_Raw_Feature_Reuse_Validation_Report.md
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

Branch and HEAD verified:

```text
development-sensitivity
1f59337
```

## Changed Files

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-002_Raw_Feature_Reuse_Validation_Report.md`

Unrelated untracked file left untouched:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`

## Next Recommended Role

Implementation worker for the next AE-SENS ticket that materializes the shared covariate base and per-grid label/split attachment route, if that ticket is approved.

## Human Readability

The report is written as a route decision memo. The headline decision appears in the summary, the join keys are stated explicitly, and the supporting evidence is organized by pipeline stage with file and line references.
