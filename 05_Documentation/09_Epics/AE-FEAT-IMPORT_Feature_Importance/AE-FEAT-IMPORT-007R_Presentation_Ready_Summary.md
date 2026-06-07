# AE-FEAT-IMPORT-007R Presentation-Ready Summary

## Scope

Feature-importance interpretation is complete across three layers: 11 feature families, individual PIT/base ratios, and all individual predictor-required features. Evidence is bounded GBM-only, CV/training-only, and based on log-odds model-response perturbation. It is not causal importance, not test/OOS inference, and not final full AutoGluon model-suite importance.

## Top Families By Track/Model

| track | model | top family 1 | top family 2 | top family 3 |
|---|---|---:|---:|---:|
| temporary CSI | fund | point_in_time_ratios (0.608822) | rolling_window_statistics (0.523451) | peak_deterioration (0.151633) |
| temporary CSI | latent_raw | vae_latent_features (1.729147) | n/a | n/a |
| temporary CSI | raw | price_momentum_volatility_and_macro_interactions (0.894894) | point_in_time_ratios (0.533468) | rolling_window_statistics (0.362126) |
| temporary CSI | raw_plus_latent | price_momentum_volatility_and_macro_interactions (0.201615) | point_in_time_ratios (0.154053) | rolling_window_statistics (0.142711) |
| permanent CSI | fund | point_in_time_ratios (0.568016) | rolling_window_statistics (0.503804) | peak_deterioration (0.096882) |
| permanent CSI | latent_raw | vae_latent_features (1.597626) | n/a | n/a |
| permanent CSI | raw | price_momentum_volatility_and_macro_interactions (0.732921) | point_in_time_ratios (0.539443) | rolling_window_statistics (0.320327) |
| permanent CSI | raw_plus_latent | price_momentum_volatility_and_macro_interactions (0.565535) | point_in_time_ratios (0.420421) | rolling_window_statistics (0.274420) |

Values are mean absolute delta log-odds from AE-FEAT-IMPORT-004R. `latent_raw` has only VAE latent/reconstruction inputs, so the canonical 11 raw/engineered families are not applicable there.

## Top PIT Ratios By Track/Model

| track | model | rank 1 | rank 2 | rank 3 | rank 4 | rank 5 |
|---|---|---:|---:|---:|---:|---:|
| temporary CSI | fund | earn_yld (0.133226) | altman_z2 (0.131259) | ocf_per_share (0.100598) | roic (0.066577) | roa (0.047686) |
| temporary CSI | raw | earn_yld (0.116904) | altman_z2 (0.101266) | ocf_per_share (0.100828) | roa (0.060287) | ocf_margin (0.042608) |
| temporary CSI | raw_plus_latent | earn_yld (0.036335) | roa (0.035832) | ocf_per_share (0.014428) | altman_z2 (0.010291) | ni_per_emp (0.008539) |
| permanent CSI | fund | earn_yld (0.156231) | ocf_per_share (0.127863) | altman_z2 (0.093687) | roa (0.090449) | roic (0.053138) |
| permanent CSI | raw | earn_yld (0.203904) | ocf_per_share (0.085857) | altman_z2 (0.084964) | ocf_margin (0.054100) | roa (0.039945) |
| permanent CSI | raw_plus_latent | earn_yld (0.149503) | ocf_per_share (0.077721) | altman_z2 (0.069392) | roa (0.044701) | ocf_margin (0.035100) |

Values are mean absolute delta log-odds from AE-FEAT-IMPORT-005R. PIT ratios are not applicable to latent_raw.

## Recurring Individual Features Across Models/Tracks

| feature | family | top-ten count | mean rank | mean abs delta | interpretation |
|---|---|---:|---:|---:|---|
| earn_yld | point_in_time_ratios | 6 | 2.50 | 0.132684 | Most stable PIT ratio; top ratio in all permanent CSI models |
| unrate | point_in_time_ratios | 6 | 2.83 | 0.109736 | Macro point-in-time control recurring in non-latent models |
| ocf_per_share | point_in_time_ratios | 5 | 4.40 | 0.098574 | Cash-flow valuation signal recurring across tracks |
| altman_z2 | point_in_time_ratios | 5 | 5.20 | 0.096114 | Retained-earnings-to-assets signal recurring across tracks |
| roll_min_3y_earn_yld | rolling_window_statistics | 5 | 7.80 | 0.056623 | Rolling earnings-yield deterioration/history signal |
| max_dd_12m | price_momentum_volatility_and_macro_interactions | 4 | 1.00 | 0.380155 | Dominant raw-style market drawdown feature |
| ann_return | price_momentum_volatility_and_macro_interactions | 3 | 7.33 | 0.076715 | Recurrent raw-style return feature |
| roa | point_in_time_ratios | 3 | 7.00 | 0.056994 | Profitability ratio recurring in PIT and all-feature layers |
| roll_mean_5y_earn_yld | rolling_window_statistics | 3 | 8.00 | 0.046891 | Long-window valuation history signal |
| vae_recon_error | vae_latent_features | 2 | 3.50 | 0.367603 | Latent-only reconstruction signal, important when raw features are absent |

Recurring counts are computed from AE-FEAT-IMPORT-006R top-ten individual-feature rankings across the eight model-track combinations.

## Narrative Takeaways

For temporary CSI, raw-style predictors are driven by market drawdown, volatility, and return/macro interaction features, while fund-only predictors are dominated by point-in-time ratios and rolling-window statistics. For permanent CSI, the same structure holds, but PIT ratios, especially `earn_yld`, are more prominent in raw and raw_plus_latent models.

VAE features are important in latent_raw models and much less important as marginal add-ons in raw_plus_latent. The evidence supports using VAE features as a compressed substitute representation rather than as the primary incremental interpretation story when raw/engineered predictors are already available.

## Required Caveat For Slides

All feature-importance claims should be labeled as bounded GBM-only, CV/training-only, log-odds perturbation evidence. They are not causal, not test/OOS evidence, and not final full AutoGluon model-suite importance.
