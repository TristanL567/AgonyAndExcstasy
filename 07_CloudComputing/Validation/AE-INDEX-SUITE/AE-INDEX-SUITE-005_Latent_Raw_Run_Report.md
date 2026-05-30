# AE-INDEX-SUITE-005 Latent Raw Run Report

## Status

Result: `validator_passed`

Branch: `Development`

Output root:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\latent_raw`

## AEGIS Reference

Before execution, `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced as read-only reference material. The AEGIS bootstrap contracts and master/orchestration runbooks were loaded. No `aegis-core` files were edited.

## Scope

This ticket ran exactly the required VAE-only model-track combinations:

- `MODEL=latent_raw`, `RESPONSE_TRACK=dynamic_csi`
- `MODEL=latent_raw`, `RESPONSE_TRACK=permanent_csi`

Both runs used the absolute isolated `MT_OUTPUT_DIR` shown above.

## Input Mirroring

Because 11C reads AutoGluon predictions through `MT_OUTPUT_DIR` when isolation is active, the required `latent_raw` prediction files were mirrored into the isolated root under each track's `AutoGluon/ag_latent_raw/` directory. Source model-suite files under `03_Data_Output/6_ModelSuite/latent_raw/**` were read-only.

## Run Results

- `dynamic_csi`: exit code `0`, elapsed `6.51` minutes, return rows `13728`, turnover rows `13728`, transaction-cost performance rows `832`
- `permanent_csi`: exit code `0`, elapsed `2.40` minutes, return rows `4224`, turnover rows `4224`, transaction-cost performance rows `256`

## Validation Summary

- Transaction-cost variants found for both tracks: `0`, `5`, `10`, `20` bps.
- Turnover outputs are present and non-empty for both tracks.
- Required turnover fields are present: `turnover_buy`, `turnover_sell`, `turnover_gross`, `turnover_one_way`.
- Gross/net return outputs include `gross_return`, `net_return`, `transaction_cost_bps`, and `transaction_cost_return_drag`.
- All four universes are represented for both tracks: `total_market`, `large_cap`, `mid_cap`, `small_cap`.

## Headline OOS Performance Snapshot

Best OOS strategy by net Sharpe for each universe at 0 bps and 20 bps:

| track         |   transaction_cost_bps | period   | index_id     | strategy_id      | threshold_method   | rule_label        |   net_annualized_geometric_return |   net_sharpe_ratio |   net_max_drawdown |   net_difference_versus_benchmark |   annualized_turnover_gross |
|:--------------|-----------------------:|:---------|:-------------|:-----------------|:-------------------|:------------------|----------------------------------:|-------------------:|-------------------:|----------------------------------:|----------------------------:|
| dynamic_csi   |                      0 | oos      | large_cap    | fpr3_5yr         | fpr3               | 5yr lockout       |                         0.143656  |           0.662138 |          -0.243875 |                       0.000887482 |                   0.118573  |
| dynamic_csi   |                      0 | oos      | mid_cap      | fpr1_5yr         | fpr1               | 5yr lockout       |                         0.0986931 |           0.415862 |          -0.245264 |                       0.00215863  |                   1.06712   |
| dynamic_csi   |                      0 | oos      | small_cap    | youden_1yr       | youden             | 1yr lockout       |                         0.0800555 |           0.321211 |          -0.301145 |                       0.00350865  |                   0.940847  |
| dynamic_csi   |                      0 | oos      | total_market | youden_3yr       | youden             | 3yr lockout       |                         0.131833  |           0.606213 |          -0.244721 |                      -0.00107404  |                   0.121278  |
| dynamic_csi   |                     20 | oos      | large_cap    | fpr3_5yr         | fpr3               | 5yr lockout       |                         0.14339   |           0.660901 |          -0.244004 |                       0.000896305 |                   0.118573  |
| dynamic_csi   |                     20 | oos      | mid_cap      | fpr1_5yr         | fpr1               | 5yr lockout       |                         0.0963917 |           0.405812 |          -0.245264 |                       0.00216015  |                   1.06712   |
| dynamic_csi   |                     20 | oos      | small_cap    | youden_1yr       | youden             | 1yr lockout       |                         0.0780579 |           0.313285 |          -0.301145 |                       0.00312144  |                   0.940847  |
| dynamic_csi   |                     20 | oos      | total_market | youden_3yr       | youden             | 3yr lockout       |                         0.131561  |           0.604899 |          -0.244868 |                      -0.00119563  |                   0.121278  |
| permanent_csi |                      0 | oos      | large_cap    | youden_permanent | youden             | Permanent removal |                         0.139725  |           0.669329 |          -0.215503 |                      -0.00304322  |                   0.111027  |
| permanent_csi |                      0 | oos      | mid_cap      | fpr3_permanent   | fpr3               | Permanent removal |                         0.1003    |           0.422566 |          -0.247297 |                       0.00376526  |                   1.05228   |
| permanent_csi |                      0 | oos      | small_cap    | fpr3_permanent   | fpr3               | Permanent removal |                         0.0797567 |           0.318061 |          -0.292589 |                       0.0032098   |                   0.757282  |
| permanent_csi |                      0 | oos      | total_market | youden_permanent | youden             | Permanent removal |                         0.13297   |           0.627611 |          -0.216745 |                       6.31144e-05 |                   0.0946143 |
| permanent_csi |                     20 | oos      | large_cap    | youden_permanent | youden             | Permanent removal |                         0.139476  |           0.668088 |          -0.215629 |                      -0.00301761  |                   0.111027  |
| permanent_csi |                     20 | oos      | mid_cap      | fpr3_permanent   | fpr3               | Permanent removal |                         0.098027  |           0.412679 |          -0.247297 |                       0.00379544  |                   1.05228   |
| permanent_csi |                     20 | oos      | small_cap    | fpr3_permanent   | fpr3               | Permanent removal |                         0.0781535 |           0.311822 |          -0.292589 |                       0.00321707  |                   0.757282  |
| permanent_csi |                     20 | oos      | total_market | youden_permanent | youden             | Permanent removal |                         0.132758  |           0.626548 |          -0.216855 |                       1.00834e-06 |                   0.0946143 |

Full compact evidence:

- `AE-INDEX-SUITE-005_latent_raw_file_inventory.csv`
- `AE-INDEX-SUITE-005_latent_raw_transaction_cost_check.csv`
- `AE-INDEX-SUITE-005_latent_raw_turnover_check.csv`
- `AE-INDEX-SUITE-005_latent_raw_universe_check.csv`
- `AE-INDEX-SUITE-005_latent_raw_performance_snapshot.csv`
- `AE-INDEX-SUITE-005_latent_raw_canonical_safety_check.csv`

## Canonical Safety

Generated output writes were limited to:

`03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/**`

Only compact evidence under `07_CloudComputing/Validation/AE-INDEX-SUITE/` is intended for commit. The isolated index output data remains uncommitted.

Known unrelated working tree items remain unstaged and outside this ticket:

- deleted presentation `.Rnw`
- old untracked AE-VALIDATE reports

## Readiness Decision

`PROCEED_TO_RAW_PLUS_LATENT_INDEX_CONSTRUCTION`

The VAE-only index construction runs validated the model routing, transaction-cost overlays, turnover outputs, and universe coverage for both temporary and permanent CSI. `raw_plus_latent` can proceed next using the same isolated-root pattern.
