# AE-INDEX-SUITE-006 Raw Plus Latent Run Report

## Status

Result: `validator_passed`

Branch: `Development`

Output root:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\raw_plus_latent`

## AEGIS Reference

Before execution, `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced as read-only reference material. The AEGIS bootstrap contracts and master/orchestration runbooks were loaded. No `aegis-core` files were edited.

## Scope

This ticket ran exactly the required raw + latent model-track combinations:

- `MODEL=raw_plus_latent`, `RESPONSE_TRACK=dynamic_csi`
- `MODEL=raw_plus_latent`, `RESPONSE_TRACK=permanent_csi`

Both runs used the absolute isolated `MT_OUTPUT_DIR` shown above.

## Input Mirroring

Because 11C reads AutoGluon predictions through `MT_OUTPUT_DIR` when isolation is active, the required `raw_plus_latent` prediction files were mirrored into the isolated root under each track's `AutoGluon/ag_raw_plus_latent/` directory. Source model-suite files under `03_Data_Output/6_ModelSuite/raw_plus_latent/**` were read-only.

## Run Results

- `dynamic_csi`: exit code `0`, elapsed `5.81` minutes, return rows `13728`, turnover rows `13728`, transaction-cost performance rows `832`
- `permanent_csi`: exit code `0`, elapsed `2.27` minutes, return rows `4224`, turnover rows `4224`, transaction-cost performance rows `256`

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
| dynamic_csi   |                      0 | oos      | large_cap    | youden_5yr     | youden             | 5yr lockout       |                         0.14112   |           0.664333 |          -0.234361 |                      -0.00164873  |                   0.117581  |
| dynamic_csi   |                      0 | oos      | mid_cap      | fpr3_5yr       | fpr3               | 5yr lockout       |                         0.0992582 |           0.41928  |          -0.244477 |                       0.00272369  |                   1.05523   |
| dynamic_csi   |                      0 | oos      | small_cap    | youden_3yr     | youden             | 3yr lockout       |                         0.0829064 |           0.33552  |          -0.293345 |                       0.00635951  |                   0.854929  |
| dynamic_csi   |                      0 | oos      | total_market | youden_5yr     | youden             | 5yr lockout       |                         0.134747  |           0.626332 |          -0.23323  |                       0.00183958  |                   0.0866527 |
| dynamic_csi   |                     20 | oos      | large_cap    | youden_5yr     | youden             | 5yr lockout       |                         0.140857  |           0.663073 |          -0.234481 |                      -0.00163694  |                   0.117581  |
| dynamic_csi   |                     20 | oos      | mid_cap      | fpr3_5yr       | fpr3               | 5yr lockout       |                         0.0969814 |           0.409304 |          -0.244477 |                       0.00274982  |                   1.05523   |
| dynamic_csi   |                     20 | oos      | small_cap    | youden_3yr     | youden             | 3yr lockout       |                         0.0810896 |           0.328119 |          -0.293345 |                       0.00615321  |                   0.854929  |
| dynamic_csi   |                     20 | oos      | total_market | youden_5yr     | youden             | 5yr lockout       |                         0.134553  |           0.625395 |          -0.233326 |                       0.00179594  |                   0.0866527 |
| permanent_csi |                      0 | oos      | large_cap    | fpr3_permanent | fpr3               | Permanent removal |                         0.144135  |           0.663944 |          -0.246744 |                       0.0013667   |                   0.116182  |
| permanent_csi |                      0 | oos      | mid_cap      | fpr3_permanent | fpr3               | Permanent removal |                         0.0996123 |           0.421208 |          -0.243896 |                       0.00307784  |                   1.06375   |
| permanent_csi |                      0 | oos      | small_cap    | fpr1_permanent | fpr1               | Permanent removal |                         0.0772796 |           0.308869 |          -0.290839 |                       0.000732753 |                   0.750789  |
| permanent_csi |                      0 | oos      | total_market | fpr3_permanent | fpr3               | Permanent removal |                         0.134489  |           0.607438 |          -0.248802 |                       0.00158154  |                   0.0676696 |
| permanent_csi |                     20 | oos      | large_cap    | fpr3_permanent | fpr3               | Permanent removal |                         0.143875  |           0.662736 |          -0.246872 |                       0.00138092  |                   0.116182  |
| permanent_csi |                     20 | oos      | mid_cap      | fpr3_permanent | fpr3               | Permanent removal |                         0.0973167 |           0.411138 |          -0.243896 |                       0.00308514  |                   1.06375   |
| permanent_csi |                     20 | oos      | small_cap    | fpr1_permanent | fpr1               | Permanent removal |                         0.0756933 |           0.302632 |          -0.290839 |                       0.000756891 |                   0.750789  |
| permanent_csi |                     20 | oos      | total_market | fpr3_permanent | fpr3               | Permanent removal |                         0.134337  |           0.606735 |          -0.248885 |                       0.00158031  |                   0.0676696 |

Full compact evidence:

- `AE-INDEX-SUITE-006_raw_plus_latent_file_inventory.csv`
- `AE-INDEX-SUITE-006_raw_plus_latent_transaction_cost_check.csv`
- `AE-INDEX-SUITE-006_raw_plus_latent_turnover_check.csv`
- `AE-INDEX-SUITE-006_raw_plus_latent_universe_check.csv`
- `AE-INDEX-SUITE-006_raw_plus_latent_performance_snapshot.csv`
- `AE-INDEX-SUITE-006_raw_plus_latent_canonical_safety_check.csv`

## Canonical Safety

Generated output writes were limited to:

`03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/**`

Only compact evidence under `07_CloudComputing/Validation/AE-INDEX-SUITE/` is intended for commit. The isolated index output data remains uncommitted.

Known unrelated working tree items remain unstaged and outside this ticket:

- deleted presentation `.Rnw`
- old untracked AE-VALIDATE reports

## Readiness Decision

`PROCEED_TO_RAW_BENCHMARK_TRANSACTION_COST_OVERLAY`

The raw + latent index construction runs validated the model routing, transaction-cost overlays, turnover outputs, and universe coverage for both temporary and permanent CSI. Raw benchmark transaction-cost overlay can proceed next.
