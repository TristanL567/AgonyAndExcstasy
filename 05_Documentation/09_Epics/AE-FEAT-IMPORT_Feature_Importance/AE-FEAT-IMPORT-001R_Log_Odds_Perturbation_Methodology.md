# AE-FEAT-IMPORT-001R Log-Odds Perturbation Methodology

## Status

Worker status: complete for methodology/readiness definition.

Local computation status: true AutoGluon model-based perturbation is blocked locally for all requested feature-set and CSI-track combinations because the local model-suite folder contains compact predictions, CV results, leaderboards, and summaries only. It does not contain full AutoGluon `ag_predictor` directories or predictor/model binaries.

## Scope

This ticket defines the feature-importance methodology for later computation. It does not compute final feature-importance tables, train models, evaluate models, regenerate pipelines, construct indexes, or compile presentations.

The required model families and tracks are:

- `raw` across `temporary_csi` and `permanent_csi`
- `fund` across `temporary_csi` and `permanent_csi`
- `latent_raw` across `temporary_csi` and `permanent_csi`
- `raw_plus_latent` across `temporary_csi` and `permanent_csi`

## Primary Metric

Use model-response perturbation in log-odds units, not coefficients and not a causal effect.

For each trained model, feature or group, and eligible row:

1. Score the unmodified CV/training-analysis matrix with the trained predictor to obtain `p_baseline`.
2. Perturb only the target feature or feature group, using rules defined below.
3. Re-score the perturbed matrix with the same frozen predictor to obtain `p_perturbed`.
4. Clip both probabilities before applying `logit`:
   - `p_clipped = min(max(p, eps), 1 - eps)`
   - default `eps = 1e-6`
5. Compute:
   - `delta_log_odds = logit(p_baseline_clipped) - logit(p_perturbed_clipped)`

Positive `delta_log_odds` means the baseline feature state raised predicted CSI risk relative to the perturbed counterfactual. Negative values mean the baseline state lowered predicted CSI risk relative to the perturbation.

The aggregation unit can be row-level, fold-level, track-level, family-level, point-in-time-ratio subset, or individual-feature level. Later tickets should report mean, median, quantiles, support, and sign share, not only a single average.

## AutoGluon Interpretation Boundary

AutoGluon ensembles do not provide one stable coefficient per feature. The final predictor can combine bagged, stacked, and weighted base models whose internal parameters are not comparable to a logistic-regression coefficient. Therefore, the perturbation metric is a model-response metric:

- It measures how the frozen fitted model's predicted probability changes when an input is changed.
- It is not a structural coefficient.
- It is not a causal effect.
- It is conditional on the model, preprocessing, feature correlations, and the perturbation design.

The local compact artifacts include predictions and leaderboards sufficient to summarize model performance, but not enough to recompute predictions under new input matrices. True perturbation requires loading each fitted `TabularPredictor` and calling `predict_proba` on baseline and perturbed feature matrices.

## Local Artifact Feasibility

The local inventory found no `ag_predictor` directories and no local predictor binaries such as `predictor.pkl`, `learner.pkl`, `trainer.pkl`, model `model.pkl`, or XGBoost `xgb.ubj` under `03_Data_Output/6_ModelSuite`.

Result: the next ticket cannot compute true model-based perturbation locally from the current compact model-suite artifacts.

Fallback path:

1. Preferred: retrieve the original AutoGluon predictor directories into an isolated ignored location outside the compact artifact bundle, then run perturbation against those frozen predictors.
2. If predictor retrieval is not available: open a separate approved surrogate or retrain ticket. That ticket must explicitly approve model training or surrogate fitting, define how it approximates the production models, and label outputs as surrogate importance rather than true AutoGluon perturbation.

## Leakage-Safe Data Boundary

Compute baseline and perturbed probabilities only on CV/training-analysis rows. Do not use test or OOS rows to fit perturbation replacement values, choose perturbation magnitudes, estimate missing-value distributions, calibrate clipping, select top features, or tune grouping choices.

Allowed analysis base:

- Training folds and validation/holdout rows generated within the training/CV design.
- Fold-local replacement statistics when fold-level analysis is available.
- Global training-only replacement statistics when only a single training-analysis matrix is available.

Disallowed:

- Any replacement value, imputation distribution, scaling parameter, or ranking threshold estimated from test years or OOS years.
- Any perturbation of `ag_preds_test*` or `ag_preds_oos*` compact prediction tables as a substitute for model re-scoring.
- Any interpretation that treats the perturbation output as a coefficient or causal mechanism.

## Perturbation Design

### Continuous Variables

Use training-only reference values. The default individual-feature perturbation sets a continuous feature to its training-median value within the relevant fold or training-analysis slice. For directional sensitivity, later tickets may also compute quantile moves such as p75 to p25 or p90 to p10, but the primary table should use one documented baseline-neutral replacement.

Rules:

- Preserve row count and identifiers.
- Do not recompute downstream derived features unless the target is an explicitly defined coherent group.
- Clip or winsorize only according to training-derived preprocessing rules already used by the model. Do not introduce new test-informed clipping.

### Missing Values

Missingness can be predictive in tree ensembles. The primary perturbation should preserve original missingness unless the feature itself is the missingness object under study.

Recommended variants:

- `median_if_observed`: replace observed values with the training median and leave missing values missing.
- `all_to_median`: replace both observed and missing values with the training median; report this only as a sensitivity because it removes missingness information.
- For binary missing indicators, set to training mode or zero according to the documented model matrix convention.

Every output row should record the missing policy.

### VAE Latent Features

For `latent_raw`, perturb latent dimensions `z1...zK` and `vae_recon_error` directly because the downstream AutoGluon model only sees the latent feature matrix. Do not claim that a latent-dimension perturbation maps cleanly to one raw accounting or price variable.

For `raw_plus_latent`, support both:

- raw-feature perturbations, holding latent features fixed, to measure marginal response to the raw feature as seen by the combined model;
- latent-group perturbation, setting all `z*` dimensions plus `vae_recon_error` to training medians, to estimate the added response of the latent block.

Do not regenerate latent features inside this ticket family unless a later ticket explicitly approves VAE artifact loading and encoding. Regenerating latent features from changed raw inputs would be a different intervention.

### Correlated Groups

Individual-feature perturbation can create unrealistic rows when features are highly correlated, such as leverage with net debt, or `roa` with profitability dynamics. Therefore, later outputs must include group-level perturbation for coherent groups:

- feature families from `AE-FEAT-IMPORT-001R_feature_family_mapping.csv`;
- point-in-time ratio subset;
- price momentum/volatility block;
- macro interaction block;
- all latent dimensions as a latent block;
- source-variable groups, such as base ratio plus `yoy_`, `accel_`, `expmean_`, `expvol_`, peak/trough, accounting momentum, and rolling statistics for the same source variable.

Group perturbation replaces all group members simultaneously using training-only reference values. Report individual-feature results as local model sensitivity, and group results as the preferred interpretation when correlation is material.

## Exactly 11 Feature Families

Use the companion mapping CSV as the canonical taxonomy. It defines exactly 11 families:

1. point_in_time_ratios
2. yoy_changes
3. acceleration
4. expanding_mean
5. expanding_volatility
6. peak_deterioration
7. trough_rise
8. consecutive_declines
9. accounting_momentum
10. rolling_window_statistics
11. price_momentum_volatility_and_macro_interactions

Ambiguous assignments are deliberately resolved by prefix-first rules for dynamic features and by a combined price/macro-interaction family to keep the taxonomy at exactly 11 families. Later outputs should add secondary labels such as `source_variable_family`, `is_price_derived`, `is_macro_interaction`, and `component_family` rather than creating extra primary families.

## Point-in-Time Ratio Subset

The point-in-time ratio subset is the base, unprefixed set from 06B feature engineering:

`earn_yld`, `ocf_per_share`, `roa`, `roe`, `roic`, `ebit_roa`, `gross_margin`, `ebitda_margin`, `ocf_margin`, `leverage`, `net_debt_ebitda`, `std_debt_pct`, `eff_int_rate`, `interest_cov`, `dd1_ratio`, `current_ratio`, `quick_ratio`, `cash_pct_act`, `wcap_ratio`, `bp_ratio`, `ev_to_sales`, `div_yield`, `mkt_to_book`, `accruals_ratio`, `asset_turnover`, `capex_intensity`, `rd_intensity`, `reinvest_rate`, `log_at`, `log_mkvalt`, `log_emp`, `rental_ratio`, `assets_per_emp`, `ni_per_emp`, `altman_z1`, `altman_z2`, `altman_z3`, `altman_z4`, `altman_z5`, `altman_z`, `invest_st_ratio`.

Training-only macro controls such as `fedfunds`, `gdp_growth`, `hy_spread`, `vix`, `term_spread`, `unrate`, `cpi_inflation`, `indpro_growth`, and `recession` should be flagged as point-in-time macro controls, but not included in the accounting-ratio subset unless the later ticket explicitly requests a broader point-in-time feature block.

## Individual-Feature Output Schema

Later computation should write an individual-feature table with these columns:

- `ticket_id`
- `run_id`
- `feature_set`
- `track`
- `model_artifact_path`
- `predictor_available`
- `analysis_split`
- `fold_id`
- `feature_name`
- `feature_family_id`
- `feature_family`
- `source_variable`
- `source_variable_family`
- `is_point_in_time_ratio`
- `is_price_derived`
- `is_macro_interaction`
- `is_latent_feature`
- `ambiguous_assignment`
- `ambiguity_note`
- `perturbation_unit`
- `perturbation_policy`
- `missing_policy`
- `baseline_reference`
- `replacement_value`
- `n_rows`
- `n_nonmissing_baseline`
- `baseline_p_mean`
- `perturbed_p_mean`
- `delta_log_odds_mean`
- `delta_log_odds_median`
- `delta_log_odds_p05`
- `delta_log_odds_p95`
- `delta_log_odds_abs_mean`
- `share_positive_delta`
- `probability_clip_eps`
- `created_utc`
- `notes`

For grouped outputs, replace `feature_name` with `group_name` and add `group_member_count` plus a semicolon-delimited `group_members` or a separate normalized membership table.

## Decision For Next Ticket

The next ticket cannot compute true model-based perturbation locally from the current workspace state. It should first retrieve the frozen AutoGluon predictor directories into an isolated ignored location, then compute perturbation. If retrieval is not possible, it should become an explicitly approved surrogate/retrain ticket and label the result accordingly.
