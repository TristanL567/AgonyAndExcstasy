# AE-INDEX-SUITE-004 Fund Run Report

## Status

Result: `validator_passed`

Branch: `Development`

Output root:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\fund`

## AEGIS Reference

Before execution, `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced as read-only reference material. The AEGIS bootstrap contracts and master/orchestration runbooks were loaded. No `aegis-core` files were edited.

## Scope

This ticket ran exactly the required successful fund model-track combinations:

- `MODEL=fund`, `RESPONSE_TRACK=dynamic_csi`
- `MODEL=fund`, `RESPONSE_TRACK=permanent_csi`

Both runs used the absolute isolated `MT_OUTPUT_DIR` shown above.

A first local invocation used a malformed path while setting up dynamic CSI and failed before loading prediction files or producing index outputs. The stray setup log was removed, and the two required fund runs were then executed successfully under the correct isolated root. No canonical output files were modified.

## Input Mirroring

Because 11C reads AutoGluon predictions through `MT_OUTPUT_DIR` when isolation is active, the required fund prediction files were mirrored into the isolated fund root under each track's `AutoGluon/ag_fund/` directory. Source model-suite files under `03_Data_Output/6_ModelSuite/fund/**` were read-only.

## Run Results

- `dynamic_csi`: exit code `0`, elapsed `5.73` minutes, return rows `13728`, turnover rows `13728`, transaction-cost performance rows `832`
- `permanent_csi`: exit code `0`, elapsed `2.10` minutes, return rows `4224`, turnover rows `4224`, transaction-cost performance rows `256`

## Validation Summary

- Transaction-cost variants found for both tracks: `0`, `5`, `10`, `20` bps.
- Turnover outputs are present and non-empty for both tracks.
- Required turnover fields are present: `turnover_buy`, `turnover_sell`, `turnover_gross`, `turnover_one_way`.
- Gross/net return outputs include `gross_return`, `net_return`, `transaction_cost_bps`, and `transaction_cost_return_drag`.
- All four universes are represented for both tracks: `total_market`, `large_cap`, `mid_cap`, `small_cap`.

## Headline OOS Performance Snapshot

Best OOS strategy by net Sharpe for each universe at 0 bps and 20 bps:

| track         |   transaction_cost_bps | period   | index_id     | strategy_id    | threshold_method   | rule_label        |   net_annualized_geometric_return |   net_sharpe_ratio |   net_max_drawdown |   net_difference_versus_benchmark |   annualized_turnover_gross |
|:--------------|-----------------------:|:---------|:-------------|:---------------|:-------------------|:------------------|----------------------------------:|-------------------:|-------------------:|----------------------------------:|----------------------------:|
| dynamic_csi   |                      0 | oos      | large_cap    | youden_3yr     | youden             | 3yr lockout       |                         0.1443    |           0.677854 |          -0.238899 |                        0.00153096 |                   0.130353  |
| dynamic_csi   |                      0 | oos      | mid_cap      | youden_5yr     | youden             | 5yr lockout       |                         0.0985204 |           0.421883 |          -0.240502 |                        0.0019859  |                   1.05969   |
| dynamic_csi   |                      0 | oos      | small_cap    | youden_5yr     | youden             | 5yr lockout       |                         0.0817458 |           0.330397 |          -0.296816 |                        0.00519887 |                   0.862912  |
| dynamic_csi   |                      0 | oos      | total_market | youden_3yr     | youden             | 3yr lockout       |                         0.13722   |           0.63556  |          -0.23782  |                        0.00431316 |                   0.103738  |
| dynamic_csi   |                     20 | oos      | large_cap    | youden_3yr     | youden             | 3yr lockout       |                         0.144007  |           0.676464 |          -0.239025 |                        0.00151344 |                   0.130353  |
| dynamic_csi   |                     20 | oos      | mid_cap      | fpr3_3yr       | fpr3               | 3yr lockout       |                         0.0976621 |           0.411698 |          -0.24483  |                        0.00343051 |                   1.06196   |
| dynamic_csi   |                     20 | oos      | small_cap    | youden_5yr     | youden             | 5yr lockout       |                         0.0799166 |           0.322975 |          -0.296816 |                        0.00498015 |                   0.862912  |
| dynamic_csi   |                     20 | oos      | total_market | youden_3yr     | youden             | 3yr lockout       |                         0.136988  |           0.634442 |          -0.237933 |                        0.00423064 |                   0.103738  |
| permanent_csi |                      0 | oos      | large_cap    | fpr3_permanent | fpr3               | Permanent removal |                         0.144525  |           0.66594  |          -0.246702 |                        0.00175594 |                   0.117084  |
| permanent_csi |                      0 | oos      | mid_cap      | fpr3_permanent | fpr3               | Permanent removal |                         0.103523  |           0.438502 |          -0.24509  |                        0.00698881 |                   1.06182   |
| permanent_csi |                      0 | oos      | small_cap    | fpr1_permanent | fpr1               | Permanent removal |                         0.0779505 |           0.311713 |          -0.291212 |                        0.00140363 |                   0.758429  |
| permanent_csi |                      0 | oos      | total_market | fpr3_permanent | fpr3               | Permanent removal |                         0.135013  |           0.609974 |          -0.248078 |                        0.00210579 |                   0.0686622 |
| permanent_csi |                     20 | oos      | large_cap    | fpr3_permanent | fpr3               | Permanent removal |                         0.144262  |           0.664723 |          -0.24683  |                        0.00176806 |                   0.117084  |
| permanent_csi |                     20 | oos      | mid_cap      | fpr3_permanent | fpr3               | Permanent removal |                         0.101224  |           0.428459 |          -0.24509  |                        0.00699198 |                   1.06182   |
| permanent_csi |                     20 | oos      | small_cap    | fpr1_permanent | fpr1               | Permanent removal |                         0.076347  |           0.305402 |          -0.291212 |                        0.00141054 |                   0.758429  |
| permanent_csi |                     20 | oos      | total_market | fpr3_permanent | fpr3               | Permanent removal |                         0.134859  |           0.609261 |          -0.248161 |                        0.00210225 |                   0.0686622 |

Full compact evidence:

- `AE-INDEX-SUITE-004_fund_file_inventory.csv`
- `AE-INDEX-SUITE-004_fund_transaction_cost_check.csv`
- `AE-INDEX-SUITE-004_fund_turnover_check.csv`
- `AE-INDEX-SUITE-004_fund_universe_check.csv`
- `AE-INDEX-SUITE-004_fund_performance_snapshot.csv`
- `AE-INDEX-SUITE-004_fund_canonical_safety_check.csv`

## Canonical Safety

Generated output writes were limited to:

`03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/**`

Only compact evidence under `07_CloudComputing/Validation/AE-INDEX-SUITE/` is intended for commit. The isolated index output data remains uncommitted.

Known unrelated working tree items remain unstaged and outside this ticket:

- deleted presentation `.Rnw`
- old untracked AE-VALIDATE reports

## Readiness Decision

`PROCEED_TO_LATENT_RAW_INDEX_CONSTRUCTION`

The fund index construction runs validated the model routing, transaction-cost overlays, turnover outputs, and universe coverage for both temporary and permanent CSI. `latent_raw` can proceed next using the same isolated-root pattern.
