# AE-FP-FEATURE-DEEPDIVE-004R Closeout Report

## Scope

This closeout synthesizes completed `AE-FP-FEATURE-DEEPDIVE-002R`, completed `AE-FP-FEATURE-DEEPDIVE-003R`, and the local CV-only 002R feature contrast outputs. It is documentation-only. It does not edit slides, generated data, model code, input data, cloud assets, model training, index construction, sensitivity scripts, or pipeline scripts.

All findings are CV-only associations between observed feature values and FP-vs-TP cohort membership under existing AE-FP-DIAG cohort and threshold definitions. They are not causal mechanisms and do not make test/OOS performance claims.

## Evidence Base

- `AE-FP-FEATURE-DEEPDIVE-002R_FP_TP_Feature_Separability_Report.md`
- `AE-FP-FEATURE-DEEPDIVE-003R_FP_Mechanism_Interpretation.md`
- Local ignored 002R outputs under `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/`

The 002R validation checks report:

- AE-FP-DIAG cohort rows were CV rows (`split_source=cv`).
- RDS feature sources were filtered with training indices and parquet feature sources with `split == train`.
- No test or OOS rows were retained.
- 23,440 feature contrast rows were created.
- Join coverage was 100% for all FP/TP/FN/TN cohort slices and source feature families.

## Closeout Finding

False positives are moderately separable from true positives, but not cleanly separable. The strongest matched-family contrasts are concentrated in a small tail of features. Most feature distributions still overlap substantially.

The strongest matched-family top features have abs SMDs roughly in the `0.19` to `0.38` range, with rank-percentile gaps usually below `0.10`. Median abs SMDs across matched features are small in every slice, about `0.027` to `0.058`. Top-feature KS-overlap values remain high, generally around `0.84` to `0.90`.

This means the defensible presentation message is not "the model makes a specific error on one feature." It is:

> CV false positives often sit in a distress-like region of feature space, especially around macro-credit stress, volatility/drawdowns, firm age/scale, and market-value histories, but they are not cleanly separable from true positives.

## Separating Features

The most repeatable matched-family separators are:

| feature family | representative features | where strongest | closeout read |
|---|---|---|---|
| macro/credit stress | `hy_spread`, `vix`, `term_spread`, `interact_ret_vix`, `d_unrate` | strict FPR slices, especially `fpr3` and `fpr5` | Most stable strict-threshold FP-vs-TP signal. |
| drawdown/volatility | `max_dd_12m`, `max_dd_60m`, `vol_12m`, return acceleration variables | `youden` slices and permanent raw `fpr1` | FPs often look distressed through market-price deterioration. |
| firm age/scale/market value | `lifetime_years`, `log_mkvalt` histories, `roll_*_log_mkvalt`, `log_at` histories | permanent CSI and broader `youden` slices | Permanent CSI puts more weight on lifecycle and scale ambiguity. |
| accounting/liquidity distress lookalike | `roll_min_5y_cash_pct_act`, `roll_mean_5y_cash_pct_act`, `cash_pct_act`, `altman_z2`-related variables | temporary raw `fpr1` and selected tails | Supported, but not the dominant global explanation. |
| latent component profile | `z*` dimensions, `vae_recon_error` | raw-plus-latent component slices | Secondary/component evidence only; no standalone latent FP/TP cohort exists. |

## Feature Groups That Matter Most

The most important feature groups are threshold-dependent:

- Strict FPR slices (`fpr3`, `fpr5`) are most consistently macro/credit-driven, with `hy_spread` repeatedly leading or near-leading matched-family separation.
- Broader `youden` slices shift toward drawdown, age, scale, and market-value history features.
- Market raw variables matter across both tracks, especially volatility, return, and market-value histories.
- Fundamental/accounting features matter in selected tails, especially temporary raw `fpr1`, but they do not dominate the overall evidence.
- Latent features add component-level profile information in raw-plus-latent comparisons, but 002R/003R do not support a standalone latent-model FP mechanism.

## Temporary CSI

Temporary CSI shows a mixed mechanism:

- `raw/fpr1` is the clearest accounting/liquidity distress-lookalike slice, led by `roll_min_5y_cash_pct_act` with SMD `0.254`.
- `raw/fpr3` and `raw/fpr5` shift toward macro stress, led by `hy_spread` with SMDs `0.324` and `0.332`.
- `raw/youden` and `raw_plus_latent/youden` are drawdown-led, with `max_dd_12m` as the top separator.
- `raw_plus_latent/fpr3` is not clearly separable: the top matched feature has abs SMD below `0.20` and KS overlap above `0.90`.
- Temporary CSI therefore supports a distress-like ambiguity story, not a clean FP class.

## Permanent CSI

Permanent CSI is more stable around macro-credit and age/scale signals:

- `hy_spread` is the most stable strict-threshold separator across raw and raw-plus-latent `fpr3`/`fpr5`.
- `vol_12m` leads permanent raw `fpr1`, supporting a volatility/drawdown lookalike interpretation.
- `lifetime_years` leads permanent raw `youden` and permanent raw-plus-latent `fpr1`, pointing to firm-age/scale ambiguity.
- Permanent `youden` slices add market-value histories (`roll_*_log_mkvalt`) and drawdown variables, with stronger tail separation than most strict-FPR slices.
- Permanent CSI is still not cleanly separable because median matched-feature SMDs remain small and top-feature distributions still overlap strongly.

## Separability Versus Distress-Like Behavior

The closeout distinction is:

- Moderately separable: yes, in a limited tail of features and especially in macro-credit, drawdown, volatility, and age/scale variables.
- Cleanly separable: no. Most matched features have small SMDs, and the top separator distributions retain high overlap.
- Distress-like: yes, but not as a single mechanism. FPs resemble TPs along several distress-adjacent channels: credit-spread stress, market deterioration, volatility, older/larger firm histories, and selected accounting/liquidity profiles.
- Causal mechanism: no. The evidence is observational CV feature contrast evidence.

## Remaining Uncertainty

- No standalone `fund` or `latent_raw` AE-FP-DIAG CV FP/TP cohorts were available. Their evidence remains auxiliary/component-level.
- Score-distance-to-threshold was not directly tested by 002R/003R. High feature overlap is compatible with threshold ambiguity, but it is not a score-overlap test.
- The closeout makes no test/OOS inference. It is limited to CV/training-only feature evidence.
- Feature-family patterns are more reliable than isolated single-feature interpretations.

## Closeout Recommendation

Use the presentation-ready summary in `AE-FP-FEATURE-DEEPDIVE-004R_Presentation_Ready_Summary.md` as the final slide input. Do not edit slides in this ticket. The epic should be marked closed only after independent validator approval.
