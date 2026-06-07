# AE-FEAT-IMPORT-005R PIT Ratio Log-Odds Importance Report

## Status

status: complete

This report summarizes individual point-in-time/base ratio model-response log-odds perturbation importance for the bounded GBM-only AutoGluon predictor workspace prepared in AE-FEAT-IMPORT-003S.

The evidence is bounded GBM-only perturbation evidence. It is not all-feature individual importance, not a causal effect, and not final full AutoGluon model-suite feature importance.

## Method

- Loaded fitted `TabularPredictor` artifacts from `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`.
- Reconstructed the training/CV-analysis matrix with the same bounded preprocessing contract used in AE-FEAT-IMPORT-004R: feature file plus `split_labels_oot.parquet`, `split == train`, training-fitted winsorization, median imputation, and uniform quantile transform.
- Used 143,173 training/CV-analysis rows for each model-track combination.
- Limited perturbations to individual point-in-time/base ratio features.
- Computed baseline probabilities and clipped logits with `eps = 1e-6`.
- Perturbed one PIT ratio at a time using deterministic within-CV permutation with seed `20260602`.
- Recomputed probabilities/logits and computed `delta_log_odds = baseline_logit - perturbed_logit`.

## PIT Ratio Scope

The feature list is derived from AE-FEAT-IMPORT-001R's point-in-time ratio subset, 06B point-in-time ratio construction, and AE-FEAT-IMPORT-004R family evidence. `cash_div_cf` is included because 06B constructs it as a point-in-time financial ratio and 004R included it in the family-level point-in-time block.

Macro point-in-time controls from the broader 004R family block were excluded from this ticket's narrower ratio-only scope: `fedfunds`, `gdp_growth`, `hy_spread`, `vix`, `term_spread`, `unrate`, `cpi_inflation`, `indpro_growth`, `recession`, `d_unrate`, `d_hy_spread`, and `d_vix`.

## Output Coverage

| item | result |
|---|---:|
| model-track combinations audited | 8 |
| applicable combinations computed | 6 |
| latent_raw not-applicable combinations | 2 |
| expected PIT ratio features | 44 |
| PIT ratio features present per applicable predictor | 41 |
| summary rows written | 246 |
| local row-delta parquet files written | 246 |
| training/CV rows used per combination | 143,173 |

`latent_raw` was audited as not applicable for both tracks because its bounded predictors contain only latent dimensions and reconstruction error, not point-in-time/base ratios.

The three expected PIT ratios absent from every applicable bounded predictor are `altman_z1`, `altman_z3`, and `altman_z5`. These are recorded in `AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`.

## Temporary CSI Top Ratios

Top computed PIT ratios across applicable temporary CSI predictors:

| feature_set | feature | mean_abs_delta_log_odds | mean_signed_delta_log_odds |
|---|---|---:|---:|
| fund | earn_yld | 0.133226 | -0.016541 |
| fund | altman_z2 | 0.131259 | 0.012410 |
| raw | earn_yld | 0.116904 | -0.036516 |
| raw | altman_z2 | 0.101266 | 0.000826 |
| raw | ocf_per_share | 0.100828 | -0.016855 |
| fund | ocf_per_share | 0.100598 | -0.015449 |
| fund | roic | 0.066577 | -0.019458 |
| raw | roa | 0.060287 | -0.011149 |
| fund | roa | 0.047686 | -0.020152 |
| fund | ocf_margin | 0.046098 | -0.009075 |

### Temporary CSI by Feature Set

| feature_set | rank | feature | mean_abs_delta_log_odds | mean_signed_delta_log_odds |
|---|---:|---|---:|---:|
| fund | 1 | earn_yld | 0.133226 | -0.016541 |
| fund | 2 | altman_z2 | 0.131259 | 0.012410 |
| fund | 3 | ocf_per_share | 0.100598 | -0.015449 |
| fund | 4 | roic | 0.066577 | -0.019458 |
| fund | 5 | roa | 0.047686 | -0.020152 |
| raw | 1 | earn_yld | 0.116904 | -0.036516 |
| raw | 2 | altman_z2 | 0.101266 | 0.000826 |
| raw | 3 | ocf_per_share | 0.100828 | -0.016855 |
| raw | 4 | roa | 0.060287 | -0.011149 |
| raw | 5 | ocf_margin | 0.042608 | -0.006323 |
| raw_plus_latent | 1 | earn_yld | 0.036335 | -0.004244 |
| raw_plus_latent | 2 | roa | 0.035832 | -0.005591 |
| raw_plus_latent | 3 | ocf_per_share | 0.014428 | -0.001779 |
| raw_plus_latent | 4 | altman_z2 | 0.010291 | -0.001307 |
| raw_plus_latent | 5 | ni_per_emp | 0.008539 | -0.003894 |

## Permanent CSI Top Ratios

Top computed PIT ratios across applicable permanent CSI predictors:

| feature_set | feature | mean_abs_delta_log_odds | mean_signed_delta_log_odds |
|---|---|---:|---:|
| raw | earn_yld | 0.203904 | -0.068563 |
| fund | earn_yld | 0.156231 | -0.056849 |
| raw_plus_latent | earn_yld | 0.149503 | -0.033236 |
| fund | ocf_per_share | 0.127863 | -0.032761 |
| fund | altman_z2 | 0.093687 | 0.022681 |
| fund | roa | 0.090449 | -0.024284 |
| raw | ocf_per_share | 0.085857 | -0.017666 |
| raw | altman_z2 | 0.084964 | 0.003090 |
| raw_plus_latent | ocf_per_share | 0.077721 | -0.016902 |
| raw_plus_latent | altman_z2 | 0.069392 | 0.010548 |

### Permanent CSI by Feature Set

| feature_set | rank | feature | mean_abs_delta_log_odds | mean_signed_delta_log_odds |
|---|---:|---|---:|---:|
| fund | 1 | earn_yld | 0.156231 | -0.056849 |
| fund | 2 | ocf_per_share | 0.127863 | -0.032761 |
| fund | 3 | altman_z2 | 0.093687 | 0.022681 |
| fund | 4 | roa | 0.090449 | -0.024284 |
| fund | 5 | roic | 0.053138 | -0.008778 |
| raw | 1 | earn_yld | 0.203904 | -0.068563 |
| raw | 2 | ocf_per_share | 0.085857 | -0.017666 |
| raw | 3 | altman_z2 | 0.084964 | 0.003090 |
| raw | 4 | ocf_margin | 0.054100 | -0.007984 |
| raw | 5 | roa | 0.039945 | -0.010089 |
| raw_plus_latent | 1 | earn_yld | 0.149503 | -0.033236 |
| raw_plus_latent | 2 | ocf_per_share | 0.077721 | -0.016902 |
| raw_plus_latent | 3 | altman_z2 | 0.069392 | 0.010548 |
| raw_plus_latent | 4 | roa | 0.044701 | -0.011367 |
| raw_plus_latent | 5 | ocf_margin | 0.035100 | -0.005343 |

## Interpretation

`earn_yld` is the most recurrent high-impact ratio. It appears in the top ten for all six applicable model-track combinations and is the top ratio for all permanent CSI models and for temporary CSI fund/raw models.

`ocf_per_share`, `altman_z2`, and `roa` also recur in the top ten for all six applicable combinations. This points to profitability/cash-flow valuation, retained-earnings-to-assets, and asset-return ratios as the most stable PIT-ratio logit response drivers in the bounded workspace.

For temporary CSI, fund and raw predictors show larger individual PIT-ratio responses than raw-plus-latent. For permanent CSI, PIT-ratio responses are larger overall, especially `earn_yld`, which reaches mean absolute delta log-odds of 0.203904 in raw, 0.156231 in fund, and 0.149503 in raw-plus-latent.

Most leading signed means are negative. Under the ticket's definition `delta_log_odds = baseline_logit - perturbed_logit`, negative signed means indicate that deterministic within-CV permutation often increased predicted risk relative to observed baseline ordering. Rankings should therefore be read primarily by absolute log-odds response magnitude, with signed means used as diagnostics.

## Artifacts

- Full compact summary: `AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv`
- Coverage audit: `AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`
- Reproducible script: `AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py`
- Local full outputs: `03_Data_Output/10_FeatureImportance/pit_ratio_importance/`

## Caveat

All results are conditional on the rebuilt bounded GBM-only predictor workspace from AE-FEAT-IMPORT-003S. They should support model interpretation planning, not claims about the full final model suite.
