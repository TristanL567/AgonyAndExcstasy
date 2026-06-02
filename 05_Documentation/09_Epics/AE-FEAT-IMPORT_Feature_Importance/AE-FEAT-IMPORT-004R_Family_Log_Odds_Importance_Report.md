# AE-FEAT-IMPORT-004R Family Log-Odds Importance Report

## Status

status: complete

This report summarizes family-level model-response log-odds perturbation importance for the bounded GBM-only AutoGluon predictor workspace prepared in AE-FEAT-IMPORT-003S.

The evidence is bounded GBM-only perturbation evidence. It is not point-in-time ratio importance, not individual-feature importance, not a causal effect, and not final full AutoGluon model-suite feature importance.

## Method

- Loaded each fitted `TabularPredictor` from `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`.
- Reconstructed the same training-analysis matrix shape used by `09C_AutoGluon.py`: feature file plus `split_labels_oot.parquet`, `split == train`, training-fitted winsorization, median imputation, and uniform quantile transform.
- Used 143,173 training/CV-analysis rows for every model-track combination.
- Computed baseline probabilities, clipped probabilities with `eps = 1e-6`, and transformed to logits.
- Perturbed one family at a time using deterministic per-feature permutation within training/CV blocks:
  `initial_train_1993_2001`, `cv_fold2_2002_2006`, `cv_fold3_2007_2010`, and `cv_fold4_holdout_2011_2015`.
- Recomputed probabilities and logits with the same frozen predictor.
- Computed `delta_log_odds = baseline_logit - perturbed_logit`.

## Output Coverage

| item | result |
|---|---:|
| model-track combinations attempted | 8 |
| canonical 11-family rows attempted | 88 |
| summary rows written | 98 |
| computed perturbation rows | 76 |
| row-delta parquet files written locally | 76 |
| training/CV rows used per combination | 143,173 |

The 22 canonical `no_features_in_predictor` rows are the 11 raw/engineered families for `latent_raw` in each track. `latent_raw` contains only `z1`-`z24` plus `vae_recon_error`, so those features were computed as a separate non-canonical `vae_latent_features` block and recorded in the unmapped audit.

## Ranked Summary

Top five computed family blocks by mean absolute delta log-odds:

| track | model | rank | family | n_features | mean_abs_delta | mean_signed_delta |
|---|---|---:|---|---:|---:|---:|
| dynamic_csi | fund | 1 | point_in_time_ratios | 53 | 0.608822 | -0.121406 |
| dynamic_csi | fund | 2 | rolling_window_statistics | 180 | 0.523451 | -0.083157 |
| dynamic_csi | fund | 3 | peak_deterioration | 18 | 0.151633 | -0.021186 |
| dynamic_csi | fund | 4 | expanding_volatility | 38 | 0.097549 | 0.004797 |
| dynamic_csi | fund | 5 | yoy_changes | 38 | 0.093633 | -0.015336 |
| dynamic_csi | latent_raw | 1 | vae_latent_features | 25 | 1.729147 | 0.015169 |
| dynamic_csi | raw | 1 | price_momentum_volatility_and_macro_interactions | 16 | 0.894894 | -0.208007 |
| dynamic_csi | raw | 2 | point_in_time_ratios | 53 | 0.533468 | -0.102864 |
| dynamic_csi | raw | 3 | rolling_window_statistics | 180 | 0.362126 | -0.127364 |
| dynamic_csi | raw | 4 | expanding_volatility | 40 | 0.081687 | -0.000638 |
| dynamic_csi | raw | 5 | expanding_mean | 40 | 0.055426 | -0.020565 |
| dynamic_csi | raw_plus_latent | 1 | price_momentum_volatility_and_macro_interactions | 16 | 0.201615 | 0.020550 |
| dynamic_csi | raw_plus_latent | 2 | point_in_time_ratios | 53 | 0.154053 | -0.011602 |
| dynamic_csi | raw_plus_latent | 3 | rolling_window_statistics | 180 | 0.142711 | -0.013462 |
| dynamic_csi | raw_plus_latent | 4 | yoy_changes | 40 | 0.008596 | -0.002361 |
| dynamic_csi | raw_plus_latent | 5 | expanding_mean | 40 | 0.004047 | -0.000898 |
| permanent_csi | fund | 1 | point_in_time_ratios | 53 | 0.568016 | -0.149699 |
| permanent_csi | fund | 2 | rolling_window_statistics | 180 | 0.503804 | -0.157176 |
| permanent_csi | fund | 3 | peak_deterioration | 18 | 0.096882 | -0.020746 |
| permanent_csi | fund | 4 | yoy_changes | 38 | 0.071128 | -0.022201 |
| permanent_csi | fund | 5 | price_momentum_volatility_and_macro_interactions | 5 | 0.056752 | -0.007218 |
| permanent_csi | latent_raw | 1 | vae_latent_features | 25 | 1.597626 | -0.033250 |
| permanent_csi | raw | 1 | price_momentum_volatility_and_macro_interactions | 16 | 0.732921 | -0.156088 |
| permanent_csi | raw | 2 | point_in_time_ratios | 53 | 0.539443 | -0.153093 |
| permanent_csi | raw | 3 | rolling_window_statistics | 180 | 0.320327 | -0.124828 |
| permanent_csi | raw | 4 | expanding_mean | 40 | 0.056827 | -0.018936 |
| permanent_csi | raw | 5 | expanding_volatility | 40 | 0.041721 | -0.000602 |
| permanent_csi | raw_plus_latent | 1 | price_momentum_volatility_and_macro_interactions | 16 | 0.565535 | -0.066579 |
| permanent_csi | raw_plus_latent | 2 | point_in_time_ratios | 53 | 0.420421 | -0.094827 |
| permanent_csi | raw_plus_latent | 3 | rolling_window_statistics | 180 | 0.274420 | -0.082401 |
| permanent_csi | raw_plus_latent | 4 | yoy_changes | 40 | 0.023420 | -0.006551 |
| permanent_csi | raw_plus_latent | 5 | peak_deterioration | 18 | 0.022378 | 0.001007 |

Full ranked evidence is in `AE-FEAT-IMPORT-004R_family_importance_summary.csv`.

## Interpretation

For temporary CSI, the strongest raw-model signal is the combined price momentum, volatility, and macro interaction family. In the fund-only model, point-in-time ratios and rolling-window statistics dominate. In raw-plus-latent, the same raw families remain dominant but with smaller perturbation magnitudes than in raw alone.

For permanent CSI, the same broad pattern holds. Price/macro interaction features dominate raw and raw-plus-latent models, while point-in-time ratios and rolling-window statistics dominate fund-only models.

VAE latent features matter strongly when the model sees only latent inputs: mean absolute delta log-odds is 1.729147 for temporary CSI and 1.597626 for permanent CSI. In raw-plus-latent, the latent block is much smaller: 0.002833 for temporary CSI and 0.017474 for permanent CSI. Within this bounded workspace, latent features appear useful as a compressed substitute feature space, but add little marginal response when the raw/engineered feature families are already available.

Most top signed means are negative. That means the deterministic within-CV permutation often increased predicted risk relative to the observed baseline distribution. The ranking should therefore be read primarily through absolute log-odds response magnitude, with signed means used as directional diagnostics rather than family quality scores.

## Unmapped Audit

Unmapped required predictor features were not silently dropped. They were recorded in `AE-FEAT-IMPORT-004R_unmapped_feature_audit.csv` and, where present, computed as an `unmapped_features` block:

- `siccd` in raw and fund models.
- `fyear` and `siccd` in raw-plus-latent models.
- `z1`-`z24` and `vae_recon_error` as latent features outside the canonical 11 raw/engineered families.

## Caveat

All results are conditional on the rebuilt bounded GBM-only predictor workspace from AE-FEAT-IMPORT-003S. They should support interpretation planning, not claims about the full final model suite.
