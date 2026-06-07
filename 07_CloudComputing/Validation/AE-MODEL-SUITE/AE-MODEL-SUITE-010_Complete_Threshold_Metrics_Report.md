# AE-MODEL-SUITE-010 Complete Threshold Metrics Report

## Status

Decision: PASS - complete local threshold metrics were computed for all available non-raw prediction files, and raw was explicitly marked partial because raw prediction-level artifacts are not present locally.

Branch: validation-model-suite  
Base HEAD: 795e056 AE-MODEL-SUITE-009: close model suite epic  
Local input root: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite`  
Local derived output path: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite\derived_metrics`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, and branch-hygiene guidance was available and followed.

## Computed Coverage

Computed from local prediction parquet files:

- `fund`: CV, test, and OOS for temporary CSI and permanent CSI.
- `latent_raw`: CV, test, and OOS for temporary CSI and permanent CSI.
- `raw_plus_latent`: CV, test, and OOS for temporary CSI and permanent CSI.

Raw comparator status:

- `raw` remains partial for CV, test, and OOS for both tracks.
- Local raw prediction-level artifacts were not downloaded in AE-MODEL-SUITE-008.
- Existing retained raw compact evidence provides AP, AUC, and recall at FPR 3% only.
- Raw FPR 1%, raw FPR 5%, raw Brier, and raw labelled/positive/negative counts are marked missing rather than recomputed or downloaded.

## Metric Method

Metrics use labelled rows only. For each target false-positive rate, prediction scores are sorted descending and grouped by score threshold. The selected threshold is the lowest score whose cumulative false-positive count divided by `n_neg` remains less than or equal to the target FPR. Recall is then `true_positive_count_at_threshold / n_pos`.

## Compact Threshold Table

| Feature set | Track | Split | Availability | AP | AUC | Brier | R@FPR1 | R@FPR3 | R@FPR5 | Labelled | Pos | Neg |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| fund | permanent_csi | cv | computed | 0.1785 | 0.8677 | 0.0299 | 0.1033 | 0.2379 | 0.3469 | 72223.0000 | 2459.0000 | 69764.0000 |
| fund | permanent_csi | oos | computed | 0.0281 | 0.7798 | 0.0232 | 0.0000 | 0.0030 | 0.0297 | 26400.0000 | 337.0000 | 26063.0000 |
| fund | permanent_csi | test | computed | 0.1289 | 0.8627 | 0.0293 | 0.0627 | 0.1697 | 0.2620 | 18053.0000 | 542.0000 | 17511.0000 |
| fund | temporary_csi | cv | computed | 0.1923 | 0.8446 | 0.0374 | 0.0830 | 0.2206 | 0.3229 | 72223.0000 | 3119.0000 | 69104.0000 |
| fund | temporary_csi | oos | computed | 0.2526 | 0.8686 | 0.0526 | 0.0598 | 0.1795 | 0.3017 | 18502.0000 | 1170.0000 | 17332.0000 |
| fund | temporary_csi | test | computed | 0.1656 | 0.8538 | 0.0392 | 0.0585 | 0.1517 | 0.2413 | 18111.0000 | 804.0000 | 17307.0000 |
| latent_raw | permanent_csi | cv | computed | 0.1426 | 0.8460 | 0.0308 | 0.0732 | 0.1960 | 0.2908 | 72223.0000 | 2459.0000 | 69764.0000 |
| latent_raw | permanent_csi | oos | computed | 0.0482 | 0.8337 | 0.0166 | 0.0504 | 0.1484 | 0.2226 | 26400.0000 | 337.0000 | 26063.0000 |
| latent_raw | permanent_csi | test | computed | 0.1115 | 0.8496 | 0.0280 | 0.0424 | 0.1513 | 0.2546 | 18053.0000 | 542.0000 | 17511.0000 |
| latent_raw | temporary_csi | cv | computed | 0.1659 | 0.8454 | 0.0380 | 0.0670 | 0.1706 | 0.2735 | 72223.0000 | 3119.0000 | 69104.0000 |
| latent_raw | temporary_csi | oos | computed | 0.2813 | 0.8626 | 0.0518 | 0.1009 | 0.2274 | 0.3556 | 18502.0000 | 1170.0000 | 17332.0000 |
| latent_raw | temporary_csi | test | computed | 0.1501 | 0.8438 | 0.0394 | 0.0410 | 0.1294 | 0.2264 | 18111.0000 | 804.0000 | 17307.0000 |
| raw | permanent_csi | cv | partial_compact_summary_only | 0.1929 | 0.8789 | NA | NA | 0.2658 | NA | NA | NA | NA |
| raw | permanent_csi | oos | partial_compact_summary_only | 0.0323 | 0.8081 | NA | NA | 0.0119 | NA | NA | NA | NA |
| raw | permanent_csi | test | partial_compact_summary_only | 0.1416 | 0.8810 | NA | NA | 0.1808 | NA | NA | NA | NA |
| raw | temporary_csi | cv | partial_compact_summary_only | 0.2166 | 0.8732 | NA | NA | 0.2471 | NA | NA | NA | NA |
| raw | temporary_csi | oos | partial_compact_summary_only | 0.3084 | 0.8961 | NA | NA | 0.2547 | NA | NA | NA | NA |
| raw | temporary_csi | test | partial_compact_summary_only | 0.1985 | 0.8766 | NA | NA | 0.2002 | NA | NA | NA | NA |
| raw_plus_latent | permanent_csi | cv | computed | 0.1883 | 0.8719 | 0.0297 | 0.1196 | 0.2578 | 0.3680 | 72223.0000 | 2459.0000 | 69764.0000 |
| raw_plus_latent | permanent_csi | oos | computed | 0.0311 | 0.8032 | 0.0207 | 0.0000 | 0.0208 | 0.0653 | 26400.0000 | 337.0000 | 26063.0000 |
| raw_plus_latent | permanent_csi | test | computed | 0.1415 | 0.8838 | 0.0283 | 0.0609 | 0.2011 | 0.3155 | 18053.0000 | 542.0000 | 17511.0000 |
| raw_plus_latent | temporary_csi | cv | computed | 0.2114 | 0.8667 | 0.0368 | 0.0981 | 0.2478 | 0.3581 | 72223.0000 | 3119.0000 | 69104.0000 |
| raw_plus_latent | temporary_csi | oos | computed | 0.3152 | 0.8950 | 0.0494 | 0.1051 | 0.2632 | 0.4128 | 18502.0000 | 1170.0000 | 17332.0000 |
| raw_plus_latent | temporary_csi | test | computed | 0.1864 | 0.8741 | 0.0394 | 0.0634 | 0.1779 | 0.2749 | 18111.0000 | 804.0000 | 17307.0000 |

## Outputs

Ignored local derived outputs:

- `03_Data_Output/6_ModelSuite/derived_metrics/complete_threshold_metrics_long.csv`
- `03_Data_Output/6_ModelSuite/derived_metrics/complete_threshold_metrics_wide.csv`
- `03_Data_Output/6_ModelSuite/derived_metrics/threshold_metric_availability.csv`

Committed compact evidence:

- `AE-MODEL-SUITE-010_Complete_Threshold_Metrics_Report.md`
- `AE-MODEL-SUITE-010_threshold_metric_availability.csv`
- `AE-MODEL-SUITE-010_threshold_metric_validation.csv`

## Validation

- Non-raw computed combinations: 18.
- Raw partial combinations: 6.
- No files were deleted or pruned.
- No model training was run.
- `09C_AutoGluon.py`, `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, pipeline regeneration, sensitivity scripts, and index construction were not run.
- Vast.ai/remote was not used or mutated in this ticket.
- No files under `02_Data_Input/**` were modified.
- Existing model-suite files under `03_Data_Output/6_ModelSuite` were not deleted or overwritten; only the new `derived_metrics` folder was added.

## Caveats

Raw threshold metrics remain partial until raw prediction-level artifacts are explicitly downloaded or recomputed in a separately scoped ticket. This ticket intentionally did neither.

CV metrics in this ticket are computed from the retained `ag_cv_results.parquet` rows as pooled labelled-row metrics. They may differ from earlier 09C compact CV summaries where 09C reported per-fold averaged CV metrics.
