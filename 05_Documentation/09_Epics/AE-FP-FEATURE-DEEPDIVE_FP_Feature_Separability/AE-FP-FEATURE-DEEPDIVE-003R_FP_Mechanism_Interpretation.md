# AE-FP-FEATURE-DEEPDIVE-003R FP Mechanism Interpretation

## Scope

This ticket interprets CV-only false-positive (FP) versus true-positive (TP) feature separability from completed `AE-FP-FEATURE-DEEPDIVE-002R` outputs. It does not edit slides, rerun models, use test/OOS rows, or make causal claims.

Primary evidence:

- `AE-FP-FEATURE-DEEPDIVE-002R_FP_TP_Feature_Separability_Report.md`
- local ignored CSV outputs under `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_*`

The interpretation is associative only: feature values are associated with CV FP versus TP cohort membership under existing AE-FP-DIAG model and threshold definitions. They do not establish that a feature caused a false positive.

## Bottom Line

The FP/TP feature contrast evidence supports moderate, not clean, separability. The most defensible slide-ready read is:

> CV false positives look partly like true distress cases on market stress, drawdown, volatility, age/scale, and macro-credit conditions, but the feature distributions still overlap strongly. The main mechanism is not a single accounting defect; it is mixed distress-lookalike and market-condition ambiguity, with threshold-specific stress variables becoming visible at stricter FPR cutoffs.

Quantitatively, the strongest matched-family top features have absolute standardized mean differences (SMDs) of about `0.19` to `0.38`, with rank-percentile gaps usually below `0.10`. KS-overlap values for the top matched separators remain high, roughly `0.84` to `0.90`, so the cohorts are not cleanly separable in feature space.

## Evidence Strength

Matched model-family contrasts are available for `raw` and `raw_plus_latent`. `fund` and `latent_raw` are auxiliary/component profiles, not standalone AE-FP-DIAG matched-family FP/TP evidence.

| track | feature set | threshold | matched features | max abs SMD | features abs SMD >= 0.30 | features abs SMD >= 0.20 | median abs SMD | read |
|---|---|---:|---:|---:|---:|---:|---:|---|
| temporary CSI | raw | fpr1 | 478 | 0.254 | 0 | 6 | 0.058 | weak-to-moderate, cash/age/volatility |
| temporary CSI | raw | fpr3 | 478 | 0.324 | 1 | 9 | 0.032 | moderate macro stress, otherwise diffuse |
| temporary CSI | raw | fpr5 | 478 | 0.332 | 1 | 10 | 0.030 | moderate macro stress, diffuse tail |
| temporary CSI | raw | youden | 478 | 0.371 | 2 | 26 | 0.032 | strongest but still overlapping |
| temporary CSI | raw_plus_latent | fpr1 | 503 | 0.272 | 0 | 5 | 0.055 | weak-to-moderate |
| temporary CSI | raw_plus_latent | fpr3 | 503 | 0.194 | 0 | 0 | 0.033 | not cleanly separable |
| temporary CSI | raw_plus_latent | fpr5 | 503 | 0.280 | 0 | 6 | 0.027 | weak-to-moderate |
| temporary CSI | raw_plus_latent | youden | 503 | 0.332 | 2 | 30 | 0.032 | moderate, drawdown-led |
| permanent CSI | raw | fpr1 | 478 | 0.257 | 0 | 7 | 0.052 | weak-to-moderate volatility/age |
| permanent CSI | raw | fpr3 | 478 | 0.294 | 0 | 7 | 0.035 | moderate macro stress |
| permanent CSI | raw | fpr5 | 478 | 0.299 | 0 | 10 | 0.033 | moderate macro stress |
| permanent CSI | raw | youden | 478 | 0.329 | 7 | 28 | 0.034 | strongest age/size/stress mix |
| permanent CSI | raw_plus_latent | fpr1 | 503 | 0.282 | 0 | 5 | 0.053 | weak-to-moderate age/scale |
| permanent CSI | raw_plus_latent | fpr3 | 503 | 0.298 | 0 | 4 | 0.039 | moderate macro stress |
| permanent CSI | raw_plus_latent | fpr5 | 503 | 0.321 | 1 | 7 | 0.031 | moderate macro stress |
| permanent CSI | raw_plus_latent | youden | 503 | 0.376 | 7 | 30 | 0.036 | strongest drawdown/age/market-value mix |

The median matched-feature SMD is small in every slice (`0.027` to `0.058`). The case for separability comes from a limited set of tail features, not broad feature-family separation.

## Temporary CSI Interpretation

Temporary CSI matched-family separators vary by threshold:

| feature set | threshold | strongest matched feature | group | FP | TP | SMD FP-TP | rank gap | KS overlap | interpretation |
|---|---|---|---|---:|---:|---:|---:|---:|---|
| raw | fpr1 | `roll_min_5y_cash_pct_act` | fundamental | 690 | 286 | 0.254 | 0.072 | 0.857 | distress-lookalike balance-sheet liquidity profile |
| raw | fpr3 | `hy_spread` | macro | 2,073 | 731 | 0.324 | 0.070 | 0.866 | market-stress/credit-spread FP environment |
| raw | fpr5 | `hy_spread` | macro | 3,446 | 1,065 | 0.332 | 0.078 | 0.857 | market-stress/credit-spread FP environment |
| raw | youden | `max_dd_12m` | other | 18,265 | 2,682 | 0.371 | 0.094 | 0.859 | drawdown/volatility-like distress signal |
| raw_plus_latent | fpr1 | `expvol_altman_z` | market_raw | 690 | 306 | -0.272 | -0.050 | 0.873 | weak-to-moderate market/accounting interaction |
| raw_plus_latent | fpr3 | `interact_ret_vix` | macro | 2,059 | 773 | -0.194 | -0.053 | 0.902 | not clearly separable |
| raw_plus_latent | fpr5 | `hy_spread` | macro | 3,453 | 1,117 | 0.280 | 0.063 | 0.884 | moderate credit-spread stress |
| raw_plus_latent | youden | `max_dd_12m` | other | 18,568 | 2,717 | 0.332 | 0.085 | 0.880 | drawdown-driven ambiguity |

Temporary CSI mechanism read:

- `raw` strict FPR slices show a shift from accounting/liquidity distress-lookalike at `fpr1` to macro-credit stress at `fpr3` and `fpr5`.
- `youden` is dominated by drawdown evidence (`max_dd_12m`), consistent with broad market-price deterioration making non-event firms look distressed to the model.
- `raw_plus_latent` is less clean around `fpr3` because the top matched feature has abs SMD below `0.20` and KS overlap above `0.90`.
- Latent component evidence is mostly weaker than matched raw/raw-plus-latent evidence. It profiles component behavior but does not create standalone latent-model FP/TP evidence.

## Permanent CSI Interpretation

Permanent CSI matched-family separators are similar but put more weight on firm age/scale and market-value history:

| feature set | threshold | strongest matched feature | group | FP | TP | SMD FP-TP | rank gap | KS overlap | interpretation |
|---|---|---|---|---:|---:|---:|---:|---:|---|
| raw | fpr1 | `vol_12m` | market_raw | 697 | 270 | 0.257 | 0.071 | 0.886 | volatility/drawdown lookalike |
| raw | fpr3 | `hy_spread` | macro | 2,092 | 641 | 0.294 | 0.074 | 0.870 | market-stress/credit-spread FP environment |
| raw | fpr5 | `hy_spread` | macro | 3,482 | 909 | 0.299 | 0.079 | 0.865 | market-stress/credit-spread FP environment |
| raw | youden | `lifetime_years` | other | 17,473 | 2,127 | 0.329 | 0.094 | 0.854 | firm-age/scale ambiguity |
| raw_plus_latent | fpr1 | `lifetime_years` | other | 696 | 294 | 0.282 | 0.079 | 0.872 | firm-age/scale ambiguity |
| raw_plus_latent | fpr3 | `hy_spread` | macro | 2,092 | 634 | 0.298 | 0.073 | 0.886 | market-stress/credit-spread FP environment |
| raw_plus_latent | fpr5 | `hy_spread` | macro | 3,478 | 905 | 0.321 | 0.083 | 0.870 | market-stress/credit-spread FP environment |
| raw_plus_latent | youden | `max_dd_12m` | other | 18,639 | 2,163 | 0.376 | 0.095 | 0.860 | drawdown/age/market-value ambiguity |

Permanent CSI mechanism read:

- `hy_spread` is the most stable strict-threshold separator across raw and raw-plus-latent at `fpr3` and `fpr5`.
- `lifetime_years`, `log_mkvalt` histories, and related scale/history features become important especially at `youden`, supporting a firm-age/size/market-value mechanism.
- `max_dd_12m` and `vol_12m` support a drawdown/volatility mechanism, but the overlap values remain high enough that this should be described as ambiguity, not a clean FP class.
- `raw_plus_latent` does not eliminate ambiguity. The latent group has lower median abs SMD than macro or market/other groups in most slices, though `vae_recon_error` appears in the permanent `youden` tail as a component-level signal.

## Mechanism Classification

| mechanism | support level | evidence | interpretation guardrail |
|---|---|---|---|
| market-stress/credit-spread | supported, moderate | `hy_spread` is top in temporary raw `fpr3/fpr5`, temporary raw-plus-latent `fpr5`, permanent raw `fpr3/fpr5`, and permanent raw-plus-latent `fpr3/fpr5`; abs SMD about `0.28` to `0.33` in these slices. | Association with FP cohort membership during CV only; not evidence that credit spreads caused FP labels. |
| drawdown/volatility | supported, moderate | `max_dd_12m` leads `youden` for temporary raw, temporary raw-plus-latent, and permanent raw-plus-latent; `vol_12m` leads permanent raw `fpr1`. | Stronger in broader `youden` slices; strict FPR slices are more macro-credit oriented. |
| firm-age/size/market-value | supported, moderate | `lifetime_years` leads permanent raw `youden` and permanent raw-plus-latent `fpr1`; market-value history variables appear among top tail features, especially in `youden`. | This is feature-family evidence, not proof of a separate causal lifecycle channel. |
| distress-lookalike | partially supported | Cash/liquidity/accounting features such as `roll_min_5y_cash_pct_act`, `roll_mean_5y_cash_pct_act`, `cash_pct_act`, and `altman_z2`-related variables appear in top or group-level tails. | We can say FPs resemble distressed firms on selected accounting/financial health variables, but not that accounting features dominate overall. |
| near-threshold/score-overlap | not directly tested by 002R | 002R reports feature overlaps, not score-distance-to-threshold metrics. High KS overlap in the strongest feature contrasts is consistent with ambiguity but is not a score-overlap test. | Do not claim threshold crowding unless score-distribution evidence is brought in by a separate ticket. |
| ambiguous/not clearly separable | strongly supported | Median matched-feature abs SMD is small in every slice; top-feature KS overlap remains high; many top contrasts are below abs SMD `0.30`. | This is the safest global classification. |

## Matched Families Versus Auxiliary Families

Matched-family evidence:

- `raw` cohort labels compared against `raw` features.
- `raw_plus_latent` cohort labels compared against `raw_plus_latent` features.
- These are the primary evidence for FP/TP mechanism interpretation.

Auxiliary/component evidence:

- `fund` features are cross-family profiles against available `raw` or `raw_plus_latent` cohorts because AE-FP-DIAG did not provide standalone `fund` FP/TP CV cohorts.
- `latent_raw` is a component profile, and only `raw_plus_latent` supports a component-of-model interpretation. There is no standalone AE-FP-DIAG `latent_raw` FP/TP cohort in 002R.
- Claims about `fund` or `latent_raw` should be phrased as supporting profiles, not independent model-family findings.

## Slide-Ready Statements

- "FPs are moderately, not cleanly, separable from TPs in CV feature space."
- "The most repeatable strict-threshold FP mechanism is market stress: `hy_spread` repeatedly separates FPs from TPs at `fpr3` and `fpr5`."
- "Broader `youden` slices shift toward drawdown, age, size, and market-value history, suggesting distress-lookalike ambiguity rather than one accounting failure mode."
- "Latent features add component-level signals, but 002R does not support a standalone latent-model FP mechanism."
- "All statements are CV-only associations, not causal or test/OOS performance claims."

## Limitations

- No test or OOS rows were used or interpreted.
- No standalone `fund` or `latent_raw` AE-FP-DIAG CV FP/TP cohort labels were available.
- The report interprets numeric feature contrasts only.
- Score-distance and threshold-crowding mechanisms were not directly tested by 002R.
- The evidence is observational and CV-only; it supports association, not causality.
