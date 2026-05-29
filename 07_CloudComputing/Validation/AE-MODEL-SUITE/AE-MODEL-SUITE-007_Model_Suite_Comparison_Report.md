# AE-MODEL-SUITE-007 Model Suite Comparison Report

## Status

Decision: PASS - all four revised-dataset feature sets are represented for both CSI tracks and compared using compact committed evidence.

Branch: validation-model-suite  
Base HEAD: e97cf64 AE-MODEL-SUITE-006: rerun raw plus latent models  
Raw comparator: AE-VALIDATE-004R optional-library raw rerun at `db61acf` on `origin/validation`  
Remote execution: none  
Scripts run: none

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, and branch-hygiene guidance was available and followed.

## Source Evidence

| Feature set | Source | Commit | Notes |
|---|---|---|---|
| raw | AE-VALIDATE-004R | db61acf | Revised-dataset optional-library raw rerun from `origin/validation`; read with `git show`, no merge performed. |
| fund | AE-MODEL-SUITE-004 | 63d70f2 | Fundamentals-only AutoGluon rerun on revised dataset. |
| latent_raw | AE-MODEL-SUITE-005 | 3d125ad | VAE-only rerun on regenerated VAE features. |
| raw_plus_latent | AE-MODEL-SUITE-006 | e97cf64 | Raw plus regenerated VAE feature rerun. |

All four feature sets are represented for `dynamic_csi`/temporary CSI and `permanent_csi`/permanent CSI.

## Temporary CSI Comparison

| Feature set | CV AP | CV AUC | CV R@FPR3 | Test AP | Test AUC | Test R@FPR3 | OOS AP | OOS AUC | OOS R@FPR3 | Best family | Best model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| raw | 0.2166 | 0.8732 | 0.2471 | 0.1985 | 0.8766 | 0.2002 | 0.3084 | 0.8961 | 0.2547 | WeightedEnsemble | WeightedEnsemble_L2 |
| fund | 0.2101 | 0.8663 | 0.2371 | 0.1656 | 0.8538 | 0.1517 | 0.2526 | 0.8686 | 0.1795 | WeightedEnsemble | WeightedEnsemble_L2 |
| latent_raw | 0.1759 | 0.8448 | 0.1872 | 0.1501 | 0.8438 | 0.1294 | 0.2813 | 0.8626 | 0.2274 | WeightedEnsemble | WeightedEnsemble_L2 |
| raw_plus_latent | 0.2171 | 0.8744 | 0.2513 | 0.1864 | 0.8741 | 0.1779 | 0.3152 | 0.8950 | 0.2632 | WeightedEnsemble | WeightedEnsemble_L2 |

## Permanent CSI Comparison

| Feature set | CV AP | CV AUC | CV R@FPR3 | Test AP | Test AUC | Test R@FPR3 | OOS AP | OOS AUC | OOS R@FPR3 | Best family | Best model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| raw | 0.1929 | 0.8789 | 0.2658 | 0.1416 | 0.8810 | 0.1808 | 0.0323 | 0.8081 | 0.0119 | WeightedEnsemble | WeightedEnsemble_L2 |
| fund | 0.1892 | 0.8723 | 0.2527 | 0.1289 | 0.8627 | 0.1697 | 0.0281 | 0.7798 | 0.0030 | WeightedEnsemble | WeightedEnsemble_L2 |
| latent_raw | 0.1468 | 0.8467 | 0.2012 | 0.1115 | 0.8496 | 0.1513 | 0.0482 | 0.8337 | 0.1484 | WeightedEnsemble | WeightedEnsemble_L2 |
| raw_plus_latent | 0.1983 | 0.8793 | 0.2664 | 0.1415 | 0.8838 | 0.2011 | 0.0311 | 0.8032 | 0.0208 | WeightedEnsemble | WeightedEnsemble_L2 |

## Deltas Versus Raw

Deltas versus raw are retained in `AE-MODEL-SUITE-007_metric_deltas_vs_raw.csv`. On the shared metrics:

- Temporary CSI: `raw_plus_latent` improved CV AP by +0.0005 and OOS AP by +0.0068 versus raw, but raw retained the best test AP, test AUC, and OOS AUC.
- Temporary CSI: `fund` and `latent_raw` underperformed raw on AP/AUC across the main test and OOS metrics.
- Permanent CSI: `raw_plus_latent` improved CV AP by +0.0054 versus raw, but raw remained stronger on test AP, OOS AP, and OOS AUC.
- Permanent CSI: `latent_raw` improves OOS AP/AUC/recall versus raw but is much weaker on CV/test metrics; `raw_plus_latent` slightly improves CV AP/test AUC but does not improve OOS AP/AUC versus raw.

## Best Model Choice By Objective

| Track | AP-oriented | AUC-oriented | OOS robustness | Conservative/reporting | Recommended later index-construction input |
|---|---|---|---|---|---|
| dynamic_csi | raw_plus_latent | raw | raw | raw | raw_plus_latent, with raw retained as benchmark comparator |
| permanent_csi | latent_raw on OOS AP; raw_plus_latent on CV AP | raw_plus_latent on test AUC; latent_raw on OOS AUC | latent_raw | raw | raw_plus_latent as primary non-raw challenger; latent_raw as OOS robustness sensitivity |

The conservative/reporting choice favors metrics that remain comparable with the AE-VALIDATE raw evidence and avoid over-weighting a single split. For temporary CSI, `raw_plus_latent` adds enough OOS AP signal to justify rerunning index construction as the main non-raw candidate. For permanent CSI, no non-raw model cleanly dominates: `latent_raw` is strongest OOS but weak in CV/test, while `raw_plus_latent` is the stronger non-raw CV/test candidate.

## Model-Family Interpretation

Weighted ensembles dominated the top leaderboard rank for every feature set and both tracks. The strongest base learners were consistently tree-based: LightGBM variants, CatBoost, ExtraTrees, and RandomForest. XGBoost was trained or considered but did not dominate the top ranks. NeuralNetFastAI and NeuralNetTorch were present in the model family metadata, but they were not the leading standalone families.

VAE-only (`latent_raw`) does not add enough temporary CSI signal by itself, but it does show permanent CSI OOS robustness despite weak CV/test performance. Raw plus VAE (`raw_plus_latent`) adds modest temporary CSI AP signal and modest permanent CSI CV/test signal.

## Metric Availability And Comparability Caveats

The raw comparator comes from the revised-dataset AE-VALIDATE optional-library rerun, but its committed compact metric snapshot only contains AP, AUC, and recall at FPR 3% for CV/test/OOS. FPR 1%, FPR 5%, Brier, and positive-count fields are therefore recorded as `NA` for raw where unavailable. Non-raw 09C compact evidence contains a richer per-split metric set.

`10_Evaluation.R` was not run for this ticket, and raw-plus-latent evaluation remains limited to 09C compact outputs until the evaluation registry is explicitly extended in a later scoped ticket.

## Final Recommendation

For later index-construction reruns:

- Temporary CSI: run index construction for `raw_plus_latent` and compare against the AE-VALIDATE raw index evidence. The AP gain is small but directionally useful on OOS AP.
- Permanent CSI: keep raw as the reporting baseline, but if non-raw index construction is run, use `raw_plus_latent` as the primary non-raw challenger and `latent_raw` as an OOS-robustness sensitivity rather than treating either as a clean replacement.
- Do not advance `fund` or `latent_raw` as primary downstream model inputs unless a later interpretability-only or ablation ticket needs them.

## Validation

Validation checks are retained in `AE-MODEL-SUITE-007_validation_checks.csv`. No model training, evaluation, index construction, pipeline regeneration, sensitivity scripts, or remote commands were run for this ticket. No `02_Data_Input/**` or `03_Data_Output/**` files were modified.
