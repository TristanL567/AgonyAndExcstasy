# AE-FEAT-IMPORT-007R Closeout Report

## Status

status: worker_complete_pending_validation

This closeout synthesizes the completed feature-importance epic layers:

- AE-FEAT-IMPORT-004R: canonical 11-family log-odds perturbation importance.
- AE-FEAT-IMPORT-005R: individual point-in-time/base ratio log-odds perturbation importance.
- AE-FEAT-IMPORT-006R: all predictor-required individual-feature log-odds perturbation importance.

No new feature-importance computation was performed for AE-FEAT-IMPORT-007R. The report is an evidence-bound interpretation of existing compact reports, compact CSVs, audits, and local ignored output folders.

## Methodology Used

The three completed layers use the same bounded model-response perturbation design:

- Fitted bounded GBM-only AutoGluon `TabularPredictor` artifacts were loaded from the rebuilt feature-importance predictor workspace.
- The analysis matrix was reconstructed from the training split only: feature data joined to `split_labels_oot.parquet`, restricted to `split == train`, with the same training-fitted winsorization, median imputation, and uniform quantile transform contract used by the prior tickets.
- Each model-track combination used 143,173 training/CV-analysis rows.
- Baseline probabilities were converted to logits with probability clipping at `eps = 1e-6`.
- Feature families, PIT ratios, or individual features were perturbed by deterministic permutation within CV/training blocks:
  `initial_train_1993_2001`, `cv_fold2_2002_2006`, `cv_fold3_2007_2010`, and `cv_fold4_holdout_2011_2015`.
- Importance was summarized as `delta_log_odds = baseline_logit - perturbed_logit`, with rank interpretation based primarily on mean absolute delta log-odds.

The 007R synthesis read the completed reports and compact CSV evidence only. It did not run model training, feature-importance recomputation, evaluation, index construction, sensitivity scripts, pipeline regeneration, or presentation compilation.

## Evidence Boundary

These findings are bounded GBM-only predictor evidence. They are not final full AutoGluon model-suite importance, not causal effects, and not test/OOS inference.

The evidence is CV/training-only and no-leakage scoped because perturbations were evaluated on the reconstructed training/CV analysis matrix only, with preprocessing fitted inside the training contract used by the completed tickets. The outputs support interpretation planning and presentation synthesis, not final generalization claims.

Perturbation under correlated predictors can overstate or understate causal importance. When a feature has close substitutes, permutation can reduce apparent importance; when permutation creates implausible covariate combinations, it can inflate response magnitude. Signed means are diagnostic only: many leading signed deltas are negative, meaning the permutation often increased predicted risk relative to the observed baseline ordering under the ticket definition.

## Layer Completion

| layer | ticket | scope | completion evidence |
|---|---|---|---|
| Family level | AE-FEAT-IMPORT-004R | 11 canonical feature families plus VAE latent block where applicable | 8 model-track combinations audited; 76 computed perturbation rows; family summary and unmapped audit written |
| PIT ratio level | AE-FEAT-IMPORT-005R | Individual point-in-time/base ratios | 6 applicable raw/fund/raw_plus_latent combinations computed; latent_raw audited as not applicable; 246 summary rows written |
| Individual feature level | AE-FEAT-IMPORT-006R | Every predictor-required feature | 8 model-track combinations computed; 2,824 individual feature perturbation rows written |

## Temporary CSI Findings

Temporary CSI shows three recurring signals across the completed layers:

1. In raw-style models, price momentum, volatility, and macro-interaction features are the largest family-level and individual-feature drivers. The raw temporary CSI family block for `price_momentum_volatility_and_macro_interactions` has mean absolute delta log-odds 0.894894. The top raw individual feature is `max_dd_12m` with mean absolute delta 0.514328, followed by other market/volatility features such as `vol_60m`, `max_dd_60m`, `vol_12m`, `ann_return`, and `mom_6m`.
2. In fund-only temporary CSI, point-in-time ratios and rolling-window statistics dominate at the family layer. The top fund families are `point_in_time_ratios` at 0.608822 and `rolling_window_statistics` at 0.523451. At the PIT-ratio layer, `earn_yld`, `altman_z2`, `ocf_per_share`, `roic`, and `roa` are the leading ratios.
3. Raw-plus-latent temporary CSI keeps the same top raw/engineered families but with smaller perturbation magnitudes. Its top families are price/macro interactions, PIT ratios, and rolling statistics; its top individual features include `max_dd_12m`, `unrate`, rolling `earn_yld` statistics, `earn_yld`, and `roa`.

The PIT layer aligns with the family and individual layers: `earn_yld`, `altman_z2`, `ocf_per_share`, and `roa` are prominent PIT ratios, and those same names recur in the all-feature top-ten summaries where applicable. The individual-feature layer also clarifies that the broader PIT family includes macro point-in-time controls such as `unrate`, which is top-ten across all six non-latent model-track combinations.

## Permanent CSI Findings

Permanent CSI has a similar structure but larger PIT-ratio responses in several raw and raw-plus-latent settings:

1. Raw-style permanent CSI again emphasizes price momentum, volatility, and macro interactions. The raw family block reaches mean absolute delta 0.732921, and `max_dd_12m` remains the top raw individual feature at 0.444823.
2. PIT ratios become especially strong for permanent CSI. `earn_yld` is the top PIT ratio in all three applicable permanent CSI models, with mean absolute deltas 0.156231 in fund, 0.203904 in raw, and 0.149503 in raw_plus_latent. `ocf_per_share`, `altman_z2`, `roa`, and `ocf_margin` also recur.
3. In fund-only permanent CSI, point-in-time ratios and rolling statistics again dominate the family layer, at 0.568016 and 0.503804 respectively. Individual top features are heavily profitability, cash-flow, valuation, and rolling earnings-yield oriented.
4. In raw-plus-latent permanent CSI, price/macro interactions remain first at the family layer, but PIT ratios remain substantial. The top individual features are `max_dd_12m`, `earn_yld`, `ocf_per_share`, `unrate`, and `altman_z2`.

Across permanent CSI, the PIT evidence is directionally consistent with the family and all-feature layers: point-in-time ratios are a top family, leading PIT ratios occupy repeated individual-feature top-ten positions, and raw-style models additionally depend on market drawdown/volatility features.

## VAE Feature Interpretation

VAE features matter strongly when the model sees only latent inputs. At the family layer, `vae_latent_features` has mean absolute delta log-odds 1.729147 for temporary CSI latent_raw and 1.597626 for permanent CSI latent_raw. At the individual-feature layer, the top latent_raw features are large: temporary CSI `z4` reaches 1.224502 and permanent CSI `z6` reaches 1.075366. `vae_recon_error` is also top-four in both latent_raw tracks.

VAE features matter much less as marginal add-ons in raw_plus_latent models. The family-level latent block is small relative to raw/engineered families in raw_plus_latent, and individual latent features generally rank behind `max_dd_12m`, PIT ratios, macro controls, and rolling statistics. The consistent interpretation is that latent features are useful as a compressed substitute feature space, but add limited incremental model response once the raw and engineered predictors are already present.

## Cross-Layer Alignment

The three layers align on the main interpretation:

- Family layer: the dominant raw-style families are price momentum/volatility/macro interactions, point-in-time ratios, and rolling-window statistics.
- PIT layer: the most stable PIT ratios are `earn_yld`, `ocf_per_share`, `altman_z2`, and `roa`; permanent CSI shows especially large `earn_yld` responses.
- Individual-feature layer: repeated top-ten features include `earn_yld`, `unrate`, `ocf_per_share`, `altman_z2`, `roll_min_3y_earn_yld`, and `max_dd_12m`.

The PIT results are not isolated from the other evidence. They explain why point-in-time ratios rank highly at the family layer and why individual all-feature top-ten lists repeatedly include valuation, profitability, cash-flow, and macro point-in-time controls. The all-feature layer also shows that raw-style models rely on market drawdown and volatility features that sit outside the narrower PIT-ratio ticket scope.

## Limitations

- Results are bounded GBM-only predictors, not final full AutoGluon suite importance.
- Results are CV/training-only evidence; no test/OOS inference is claimed.
- The perturbation design is model-response importance, not causal importance.
- Correlated predictors can cause permutation importance to overstate or understate causal or economic importance.
- Signed deltas should be treated as directional diagnostics rather than quality scores; ranks use absolute log-odds response magnitude.
- The PIT-ratio layer excludes latent_raw because the latent-only predictors contain only VAE dimensions and reconstruction error, not PIT/base ratios.

## Validator Notes

AE-FEAT-IMPORT-007R should remain pending validator/master closure. This worker did not mark the epic closed and did not change the envelope status.

Allowed writes performed for this ticket:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-007R_Closeout_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-007R_Presentation_Ready_Summary.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-007R_source_map.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-007R_worker_completion_report.md`
- Optional ledger row in `epics/AE-FEAT-IMPORT/ledger.md`
