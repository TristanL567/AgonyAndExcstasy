# AE-FEAT-IMPORT-006R Individual Feature Log-Odds Importance Report

## Status

status: complete

This report summarizes model-response log-odds perturbation importance for every predictor-required individual feature across the bounded GBM-only AutoGluon predictor workspace prepared in AE-FEAT-IMPORT-003S.

The evidence is bounded GBM-only perturbation evidence. It is not a causal effect and not final full AutoGluon model-suite feature importance.

## Method

- Loaded fitted `TabularPredictor` artifacts from `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`.
- Reconstructed the training/CV-analysis matrix with the same bounded preprocessing contract used in AE-FEAT-IMPORT-004R and AE-FEAT-IMPORT-005R: feature file plus `split_labels_oot.parquet`, `split == train`, training-fitted winsorization, median imputation, and uniform quantile transform.
- Used `143,173` training/CV-analysis rows for each model-track combination.
- Computed baseline probabilities and clipped logits with `eps = 1e-06`.
- Perturbed one predictor-required feature at a time using deterministic within-CV permutation with seed `20260602`.
- Recomputed probabilities/logits and computed `delta_log_odds = baseline_logit - perturbed_logit`.
- Wrote compact all-feature outputs. Row-level deltas were intentionally not written because all-feature row deltas would be unbounded for this ticket: `2,824` feature perturbations times `143,173` rows would produce `404,320,552` row-delta records.

## Output Coverage

| item | result |
|---|---:|
| model-track combinations computed | 8 |
| individual feature perturbation rows | 2,824 |
| mapped canonical-family rows | 2,716 |
| latent/VAE rows | 100 |
| unmapped rows | 8 |
| training/CV rows used per combination | 143,173 |

## Temporary CSI Top Features By Model

| model | rank | feature | family | mapping | mean_abs_delta | mean_signed_delta |
| --- | --- | --- | --- | --- | --- | --- |
| fund | 1 | unrate | point_in_time_ratios | mapped | 0.181169 | -0.003239 |
| fund | 2 | earn_yld | point_in_time_ratios | mapped | 0.133226 | -0.016541 |
| fund | 3 | altman_z2 | point_in_time_ratios | mapped | 0.131259 | 0.012410 |
| fund | 4 | ocf_per_share | point_in_time_ratios | mapped | 0.100598 | -0.015449 |
| fund | 5 | peak_drop_log_mkvalt | peak_deterioration | mapped | 0.096438 | -0.018903 |
| fund | 6 | roll_min_5y_earn_yld | rolling_window_statistics | mapped | 0.085964 | 0.018339 |
| fund | 7 | roll_min_3y_earn_yld | rolling_window_statistics | mapped | 0.066969 | -0.013704 |
| fund | 8 | roll_sd_5y_earn_yld | rolling_window_statistics | mapped | 0.066756 | 0.008457 |
| fund | 9 | roic | point_in_time_ratios | mapped | 0.066577 | -0.019458 |
| fund | 10 | roll_mean_5y_earn_yld | rolling_window_statistics | mapped | 0.064572 | -0.004966 |
| latent_raw | 1 | z4 | vae_latent_features | latent_vae | 1.224502 | -0.001251 |
| latent_raw | 2 | z13 | vae_latent_features | latent_vae | 0.624911 | -0.018981 |
| latent_raw | 3 | z14 | vae_latent_features | latent_vae | 0.375973 | 0.012900 |
| latent_raw | 4 | vae_recon_error | vae_latent_features | latent_vae | 0.333634 | 0.024645 |
| latent_raw | 5 | z1 | vae_latent_features | latent_vae | 0.296258 | 0.015751 |
| latent_raw | 6 | z22 | vae_latent_features | latent_vae | 0.155962 | 0.003798 |
| latent_raw | 7 | z21 | vae_latent_features | latent_vae | 0.128207 | 0.006966 |
| latent_raw | 8 | z10 | vae_latent_features | latent_vae | 0.122053 | 0.003974 |
| latent_raw | 9 | z20 | vae_latent_features | latent_vae | 0.114137 | 0.002072 |
| latent_raw | 10 | z23 | vae_latent_features | latent_vae | 0.098809 | 0.000913 |
| raw | 1 | max_dd_12m | price_momentum_volatility_and_macro_interactions | mapped | 0.514328 | -0.106599 |
| raw | 2 | vol_60m | price_momentum_volatility_and_macro_interactions | mapped | 0.168438 | -0.030162 |
| raw | 3 | unrate | point_in_time_ratios | mapped | 0.142726 | -0.003373 |
| raw | 4 | earn_yld | point_in_time_ratios | mapped | 0.116904 | -0.036516 |
| raw | 5 | max_dd_60m | price_momentum_volatility_and_macro_interactions | mapped | 0.109262 | -0.012978 |
| raw | 6 | altman_z2 | point_in_time_ratios | mapped | 0.101266 | 0.000826 |
| raw | 7 | ocf_per_share | point_in_time_ratios | mapped | 0.100828 | -0.016855 |
| raw | 8 | vol_12m | price_momentum_volatility_and_macro_interactions | mapped | 0.091372 | -0.021393 |
| raw | 9 | ann_return | price_momentum_volatility_and_macro_interactions | mapped | 0.088644 | -0.026814 |
| raw | 10 | mom_6m | price_momentum_volatility_and_macro_interactions | mapped | 0.080310 | -0.009245 |
| raw_plus_latent | 1 | max_dd_12m | price_momentum_volatility_and_macro_interactions | mapped | 0.157034 | 0.034659 |
| raw_plus_latent | 2 | unrate | point_in_time_ratios | mapped | 0.045594 | -0.002425 |
| raw_plus_latent | 3 | roll_mean_3y_earn_yld | rolling_window_statistics | mapped | 0.045311 | -0.004054 |
| raw_plus_latent | 4 | earn_yld | point_in_time_ratios | mapped | 0.036335 | -0.004244 |
| raw_plus_latent | 5 | roa | point_in_time_ratios | mapped | 0.035832 | -0.005591 |
| raw_plus_latent | 6 | roll_mean_5y_earn_yld | rolling_window_statistics | mapped | 0.029656 | 0.001964 |
| raw_plus_latent | 7 | roll_min_3y_earn_yld | rolling_window_statistics | mapped | 0.023408 | 0.001519 |
| raw_plus_latent | 8 | term_spread | point_in_time_ratios | mapped | 0.023403 | -0.001342 |
| raw_plus_latent | 9 | interact_roa_gdp | price_momentum_volatility_and_macro_interactions | mapped | 0.023320 | -0.005063 |
| raw_plus_latent | 10 | roll_mean_3y_roa | rolling_window_statistics | mapped | 0.020745 | -0.004115 |

## Permanent CSI Top Features By Model

| model | rank | feature | family | mapping | mean_abs_delta | mean_signed_delta |
| --- | --- | --- | --- | --- | --- | --- |
| fund | 1 | earn_yld | point_in_time_ratios | mapped | 0.156231 | -0.056849 |
| fund | 2 | ocf_per_share | point_in_time_ratios | mapped | 0.127863 | -0.032761 |
| fund | 3 | unrate | point_in_time_ratios | mapped | 0.106096 | -0.003181 |
| fund | 4 | altman_z2 | point_in_time_ratios | mapped | 0.093687 | 0.022681 |
| fund | 5 | roll_min_5y_earn_yld | rolling_window_statistics | mapped | 0.090676 | -0.005706 |
| fund | 6 | roa | point_in_time_ratios | mapped | 0.090449 | -0.024284 |
| fund | 7 | roll_mean_3y_earn_yld | rolling_window_statistics | mapped | 0.074628 | -0.001330 |
| fund | 8 | roll_min_3y_roa | rolling_window_statistics | mapped | 0.071990 | -0.020153 |
| fund | 9 | roll_min_3y_earn_yld | rolling_window_statistics | mapped | 0.067035 | -0.019545 |
| fund | 10 | roll_mean_5y_ocf_per_share | rolling_window_statistics | mapped | 0.067028 | -0.025750 |
| latent_raw | 1 | z6 | vae_latent_features | latent_vae | 1.075366 | -0.023000 |
| latent_raw | 2 | z18 | vae_latent_features | latent_vae | 0.556799 | -0.026137 |
| latent_raw | 3 | vae_recon_error | vae_latent_features | latent_vae | 0.401572 | 0.003327 |
| latent_raw | 4 | z9 | vae_latent_features | latent_vae | 0.309301 | -0.000683 |
| latent_raw | 5 | z10 | vae_latent_features | latent_vae | 0.275710 | -0.001022 |
| latent_raw | 6 | z24 | vae_latent_features | latent_vae | 0.171980 | 0.000483 |
| latent_raw | 7 | z23 | vae_latent_features | latent_vae | 0.147570 | 0.000434 |
| latent_raw | 8 | z3 | vae_latent_features | latent_vae | 0.129416 | 0.003132 |
| latent_raw | 9 | z13 | vae_latent_features | latent_vae | 0.117516 | 0.002422 |
| latent_raw | 10 | z1 | vae_latent_features | latent_vae | 0.115074 | -0.008159 |
| raw | 1 | max_dd_12m | price_momentum_volatility_and_macro_interactions | mapped | 0.444823 | -0.063852 |
| raw | 2 | earn_yld | point_in_time_ratios | mapped | 0.203904 | -0.068563 |
| raw | 3 | vol_60m | price_momentum_volatility_and_macro_interactions | mapped | 0.121987 | -0.031701 |
| raw | 4 | unrate | point_in_time_ratios | mapped | 0.111171 | -0.008527 |
| raw | 5 | mom_6m | price_momentum_volatility_and_macro_interactions | mapped | 0.088940 | -0.012730 |
| raw | 6 | ocf_per_share | point_in_time_ratios | mapped | 0.085857 | -0.017666 |
| raw | 7 | ann_return | price_momentum_volatility_and_macro_interactions | mapped | 0.085111 | -0.030051 |
| raw | 8 | altman_z2 | point_in_time_ratios | mapped | 0.084964 | 0.003090 |
| raw | 9 | roll_min_3y_earn_yld | rolling_window_statistics | mapped | 0.070717 | -0.024148 |
| raw | 10 | max_dd_60m | price_momentum_volatility_and_macro_interactions | mapped | 0.068616 | -0.012885 |
| raw_plus_latent | 1 | max_dd_12m | price_momentum_volatility_and_macro_interactions | mapped | 0.404436 | -0.013334 |
| raw_plus_latent | 2 | earn_yld | point_in_time_ratios | mapped | 0.149503 | -0.033236 |
| raw_plus_latent | 3 | ocf_per_share | point_in_time_ratios | mapped | 0.077721 | -0.016902 |
| raw_plus_latent | 4 | unrate | point_in_time_ratios | mapped | 0.071663 | -0.005830 |
| raw_plus_latent | 5 | altman_z2 | point_in_time_ratios | mapped | 0.069392 | 0.010548 |
| raw_plus_latent | 6 | ann_return | price_momentum_volatility_and_macro_interactions | mapped | 0.056388 | -0.015983 |
| raw_plus_latent | 7 | roll_min_3y_earn_yld | rolling_window_statistics | mapped | 0.054987 | -0.017759 |
| raw_plus_latent | 8 | roll_mean_5y_earn_yld | rolling_window_statistics | mapped | 0.046446 | 0.001757 |
| raw_plus_latent | 9 | roll_mean_3y_ocf_per_share | rolling_window_statistics | mapped | 0.045429 | -0.017550 |
| raw_plus_latent | 10 | roa | point_in_time_ratios | mapped | 0.044701 | -0.011367 |

## Repeated Top Features

Features recurring in top-ten positions across model-track combinations:

| feature | family | mapping | top10_count | mean_rank | mean_abs_delta | max_abs_delta |
| --- | --- | --- | --- | --- | --- | --- |
| earn_yld | point_in_time_ratios | mapped | 6 | 2.500000 | 0.132684 | 0.203904 |
| unrate | point_in_time_ratios | mapped | 6 | 2.833333 | 0.109736 | 0.181169 |
| ocf_per_share | point_in_time_ratios | mapped | 5 | 4.400000 | 0.098574 | 0.127863 |
| altman_z2 | point_in_time_ratios | mapped | 5 | 5.200000 | 0.096114 | 0.131259 |
| roll_min_3y_earn_yld | rolling_window_statistics | mapped | 5 | 7.800000 | 0.056623 | 0.070717 |
| max_dd_12m | price_momentum_volatility_and_macro_interactions | mapped | 4 | 1.000000 | 0.380155 | 0.514328 |
| ann_return | price_momentum_volatility_and_macro_interactions | mapped | 3 | 7.333333 | 0.076715 | 0.088644 |
| roa | point_in_time_ratios | mapped | 3 | 7.000000 | 0.056994 | 0.090449 |
| roll_mean_5y_earn_yld | rolling_window_statistics | mapped | 3 | 8.000000 | 0.046891 | 0.064572 |
| z13 | vae_latent_features | latent_vae | 2 | 5.500000 | 0.371214 | 0.624911 |
| vae_recon_error | vae_latent_features | latent_vae | 2 | 3.500000 | 0.367603 | 0.401572 |
| z1 | vae_latent_features | latent_vae | 2 | 7.500000 | 0.205666 | 0.296258 |
| z10 | vae_latent_features | latent_vae | 2 | 6.500000 | 0.198881 | 0.275710 |
| vol_60m | price_momentum_volatility_and_macro_interactions | mapped | 2 | 2.500000 | 0.145213 | 0.168438 |
| z23 | vae_latent_features | latent_vae | 2 | 8.500000 | 0.123189 | 0.147570 |
| max_dd_60m | price_momentum_volatility_and_macro_interactions | mapped | 2 | 7.500000 | 0.088939 | 0.109262 |
| roll_min_5y_earn_yld | rolling_window_statistics | mapped | 2 | 5.500000 | 0.088320 | 0.090676 |
| mom_6m | price_momentum_volatility_and_macro_interactions | mapped | 2 | 7.500000 | 0.084625 | 0.088940 |
| roll_mean_3y_earn_yld | rolling_window_statistics | mapped | 2 | 5.000000 | 0.059970 | 0.074628 |
| z4 | vae_latent_features | latent_vae | 1 | 1.000000 | 1.224502 | 1.224502 |

## Mapping Coverage

| track | model | mapped | unmapped | latent/VAE | required_features |
| --- | --- | --- | --- | --- | --- |
| dynamic_csi | fund | 440.000000 | 1.000000 | 0.000000 | 441.000000 |
| dynamic_csi | latent_raw | 0.000000 | 0.000000 | 25.000000 | 25.000000 |
| dynamic_csi | raw | 459.000000 | 1.000000 | 0.000000 | 460.000000 |
| dynamic_csi | raw_plus_latent | 459.000000 | 2.000000 | 25.000000 | 486.000000 |
| permanent_csi | fund | 440.000000 | 1.000000 | 0.000000 | 441.000000 |
| permanent_csi | latent_raw | 0.000000 | 0.000000 | 25.000000 | 25.000000 |
| permanent_csi | raw | 459.000000 | 1.000000 | 0.000000 | 460.000000 |
| permanent_csi | raw_plus_latent | 459.000000 | 2.000000 | 25.000000 | 486.000000 |

Unmapped required predictor features are retained in the computation and audit rather than silently dropped. In this workspace, unmapped rows are metadata-like numeric inputs such as `siccd` and, in raw-plus-latent, `fyear`.

## Interpretation

For temporary CSI, the strongest individual-feature responses are:

| model | feature | family | mean_abs_delta | mean_signed_delta |
| --- | --- | --- | --- | --- |
| latent_raw | z4 | vae_latent_features | 1.224502 | -0.001251 |
| latent_raw | z13 | vae_latent_features | 0.624911 | -0.018981 |
| raw | max_dd_12m | price_momentum_volatility_and_macro_interactions | 0.514328 | -0.106599 |
| latent_raw | z14 | vae_latent_features | 0.375973 | 0.012900 |
| latent_raw | vae_recon_error | vae_latent_features | 0.333634 | 0.024645 |

For permanent CSI, the strongest individual-feature responses are:

| model | feature | family | mean_abs_delta | mean_signed_delta |
| --- | --- | --- | --- | --- |
| latent_raw | z6 | vae_latent_features | 1.075366 | -0.023000 |
| latent_raw | z18 | vae_latent_features | 0.556799 | -0.026137 |
| raw | max_dd_12m | price_momentum_volatility_and_macro_interactions | 0.444823 | -0.063852 |
| raw_plus_latent | max_dd_12m | price_momentum_volatility_and_macro_interactions | 0.404436 | -0.013334 |
| latent_raw | vae_recon_error | vae_latent_features | 0.401572 | 0.003327 |

The all-feature layer aligns with AE-FEAT-IMPORT-004R and AE-FEAT-IMPORT-005R: point-in-time ratios and rolling-window statistics remain important in fund and raw models, while price momentum, volatility, and macro-interaction features are strong in raw-style models. Among top-ten slots across all model-track combinations, `27` are point-in-time ratio features and `80` map to the canonical 11-family taxonomy.

VAE latent features are material when the model sees only latent inputs. The strongest latent/VAE individual features are:

| model | track | rank | feature | mean_abs_delta | mean_signed_delta |
| --- | --- | --- | --- | --- | --- |
| latent_raw | dynamic_csi | 1 | z4 | 1.224502 | -0.001251 |
| latent_raw | permanent_csi | 1 | z6 | 1.075366 | -0.023000 |
| latent_raw | dynamic_csi | 2 | z13 | 0.624911 | -0.018981 |
| latent_raw | permanent_csi | 2 | z18 | 0.556799 | -0.026137 |
| latent_raw | permanent_csi | 3 | vae_recon_error | 0.401572 | 0.003327 |
| latent_raw | dynamic_csi | 3 | z14 | 0.375973 | 0.012900 |
| latent_raw | dynamic_csi | 4 | vae_recon_error | 0.333634 | 0.024645 |
| latent_raw | permanent_csi | 4 | z9 | 0.309301 | -0.000683 |

In raw-plus-latent models, latent/VAE features are computed individually, but their ranks are generally behind raw/engineered features. This is consistent with the family-level 004R finding that latent features are useful as a compressed substitute feature space and less dominant when raw/engineered predictors are available.

Most leading signed means are negative. Under the ticket definition `delta_log_odds = baseline_logit - perturbed_logit`, negative signed means indicate deterministic within-CV permutation often increased predicted risk relative to observed baseline ordering. Rankings should therefore be read primarily by absolute log-odds response magnitude, with signed means used as directional diagnostics.

## Artifacts

- Full compact summary: `AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- Feature-family mapping coverage audit: `AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- Reproducible script: `AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- Local full compact outputs: `03_Data_Output/10_FeatureImportance/individual_feature_importance/`

## Caveat

All results are conditional on the rebuilt bounded GBM-only predictor workspace from AE-FEAT-IMPORT-003S. They should support model interpretation planning, not claims about the full final model suite.
