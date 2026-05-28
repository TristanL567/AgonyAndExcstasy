# AE-SENS-006 Pilot Comparison Go/No-Go Report

## Status

AE-SENS-006 completed as a no-run comparison gate. The two AE-SENS-005 pilot configurations are complete, internally coherent, and plausible enough to proceed to the full 27-config grid.

Final decision: **PROCEED**

## AEGIS Reference

Before execution, the worker cross-referenced `C:\Users\Tristan Leiter\Documents\aegis-core` as read-only material. The relevant AEGIS master/worker/validator rules were found and applied: one ticket at a time, scoped execution, validator blocking by default, and no protected-path edits.

## Branch and Inputs

- Branch: `development-sensitivity`
- Required base: `9b14afd` or descendant
- Observed HEAD at ticket start: `9b14afd`
- Primary evidence: compact AE-SENS-005 artifacts under `07_CloudComputing/Validation/AE-SENS/`
- Remote inspection: read-only summary extraction only, used because local compact evidence did not contain score quantiles, Brier scores, threshold rows, exclusion aggregates, or error-cost aggregates.
- Remote endpoint and key material: not recorded in this report or comparison artifacts.

No model training, evaluation script, 11C script, AE-SENS runner, full grid, or pipeline regeneration was run in this ticket.

## Pilot Configurations

| Role | Run ID | C | M | T |
|---|---|---:|---:|---:|
| baseline | `C080_M020_T018` | -0.80 | -0.20 | 18 |
| stricter long-window | `C090_M020_T028` | -0.90 | -0.20 | 28 |

Both run IDs completed all four AE-SENS-005 pilot steps: run-specific labels/features, raw AutoGluon, compact raw evaluation, and 11C index construction.

## Label Comparison

| Metric | Baseline | Stricter | Delta | Delta % |
|---|---:|---:|---:|---:|
| observable rows | 188,460 | 188,460 | 0 | 0.00% |
| y=0 | 171,269 | 174,722 | 3,453 | 2.02% |
| y=1 | 8,517 | 5,013 | -3,504 | -41.14% |
| y=NA | 8,674 | 8,725 | 51 | 0.59% |
| labelled rows | 179,786 | 179,735 | -51 | -0.03% |
| prevalence | 4.7373% | 2.7891% | -1.9482 pp | -41.12% |

The stricter C threshold and longer recovery window reduce positives sharply while leaving the observable scaffold stable. This direction is expected: a deeper drawdown trigger plus a longer recovery allowance should classify fewer firm-years as temporary CSI.

## Raw Model Comparison

| Set | AP baseline | AP stricter | AP delta | AUC baseline | AUC stricter | AUC delta | Brier baseline | Brier stricter |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| test_eval | 0.1978 | 0.1559 | -0.0419 | 0.8766 | 0.8952 | 0.0187 | 0.0389 | 0.0260 |
| oos_eval | 0.3077 | 0.1578 | -0.1498 | 0.8961 | 0.9050 | 0.0089 | 0.0498 | 0.0256 |
| cv | 0.2027 | 0.1626 | -0.0402 | 0.8620 | 0.8938 | 0.0318 | 0.0371 | 0.0234 |
| train_boundary | 0.1861 | 0.1243 | -0.0617 | 0.8931 | 0.9155 | 0.0225 | 0.0271 | 0.0169 |

Best leaderboard model for both runs was `WeightedEnsemble_L2`. Optional model-family evidence confirms LightGBM, CatBoost, FastAI, and XGBoost were available and fit in both pilots, with no missing-import skip recorded.

AP declines in the stricter run, which is plausible because the positive class is materially rarer. AUC and Brier improve because the stricter label definition produces lower base rates and more separable score ranking/calibration behavior. This is not an implementation blocker.

## Prediction Distributions

Mean predicted CSI scores fell across all splits:

| Set | Mean baseline | Mean stricter | Delta | Median baseline | Median stricter | Delta |
|---|---:|---:|---:|---:|---:|---:|
| test_eval | 0.0631 | 0.0405 | -0.0226 | 0.0133 | 0.0041 | -0.0093 |
| oos_eval | 0.0474 | 0.0294 | -0.0180 | 0.0118 | 0.0037 | -0.0081 |
| cv | 0.0475 | 0.0243 | -0.0233 | 0.0153 | 0.0040 | -0.0113 |
| train_boundary | 0.0408 | 0.0246 | -0.0162 | 0.0094 | 0.0030 | -0.0064 |

The lower score distribution is directionally consistent with the reduced stricter-label prevalence. Max scores are slightly higher in held-out evaluation splits, but upper-tail quantiles and means mostly decline; this does not undermine the pilot.

## Thresholds and Recall

| Threshold method | Threshold baseline | Threshold stricter | CV recall baseline | CV recall stricter | CV precision baseline | CV precision stricter |
|---|---:|---:|---:|---:|---:|---:|
| fpr1 | 0.2656 | 0.1945 | 0.0911 | 0.1190 | 0.2925 | 0.2475 |
| fpr3 | 0.2176 | 0.1429 | 0.2302 | 0.2674 | 0.2585 | 0.1950 |
| youden | 0.0548 | 0.0206 | 0.8467 | 0.9067 | 0.1301 | 0.0887 |

Thresholds recalibrate downward under the stricter definition, while recall rises and precision falls at comparable FPR controls. This is plausible given the lower positive count and lower score distribution.

## 11C Index Outcomes

Best OOS Sharpe strategy by index:

| Index | Baseline return | Stricter return | Return delta | Baseline Sharpe | Stricter Sharpe | Sharpe delta | Benchmark-relative delta |
|---|---:|---:|---:|---:|---:|---:|---:|
| large_cap | 0.1446 | 0.1433 | -0.0013 | 0.6786 | 0.6709 | -0.0078 | -0.0013 |
| mid_cap | 0.1003 | 0.0982 | -0.0021 | 0.4233 | 0.4154 | -0.0079 | -0.0021 |
| small_cap | 0.0841 | 0.0776 | -0.0064 | 0.3397 | 0.3134 | -0.0264 | -0.0064 |
| total_market | 0.1377 | 0.1355 | -0.0022 | 0.6366 | 0.6251 | -0.0116 | -0.0022 |

The stricter run still produces positive best-strategy benchmark-relative deltas in all four indices, but the deltas are smaller than baseline. Exclusion summaries show broadly similar or modestly higher best-strategy excluded weights for large/mid-cap and slightly lower small-cap excluded weights. Error-cost aggregates show fewer true-positive and false-negative firm-months in the stricter run, consistent with fewer positive labels.

## Plausibility Assessment

The stricter long-window configuration behaves as expected:

- The same observable scaffold is preserved.
- CSI positives and prevalence decline materially.
- Predicted score distributions shift downward.
- AP declines because the positive class is much rarer.
- AUC and Brier improve, consistent with lower base rate and clearer ranking/calibration.
- 11C benchmark-relative improvements shrink but do not reverse.
- Optional model families are available.
- Output paths remain isolated by run ID.
- Canonical-output fingerprints from AE-SENS-005 matched before and after the pilot.

No evidence suggests methodology invalidity or unsafe path routing.

## Decision

**PROCEED**

Authorize AE-SENS-007 full 27-config grid execution, using the validated run-id-isolated raw-only runner and the same compact evidence capture pattern. Preserve the full-grid ticket boundaries: temporary CSI only unless explicitly scoped otherwise, no canonical output writes, and no unrelated AE-VALIDATE blocker artifacts.

## Artifacts

- `AE-SENS-006_label_count_comparison.csv`
- `AE-SENS-006_model_metric_comparison.csv`
- `AE-SENS-006_prediction_distribution_comparison.csv`
- `AE-SENS-006_11c_comparison.csv`
- `AE-SENS-006_go_nogo_decision.csv`
- `AE-SENS-006_score_distribution_raw.csv`
- `AE-SENS-006_thresholds_raw.csv`
- `AE-SENS-006_exclusion_raw.csv`
- `AE-SENS-006_error_cost_raw.csv`
- `AE-SENS-006_brier_raw.csv`
- `AE-SENS-006_leaderboard_raw.csv`
