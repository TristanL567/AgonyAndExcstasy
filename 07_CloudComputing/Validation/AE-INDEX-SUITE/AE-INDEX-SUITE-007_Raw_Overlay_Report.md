# AE-INDEX-SUITE-007 Raw Overlay Report

Result: validator_passed

## Scope

This ticket created raw benchmark transaction-cost and turnover overlay outputs comparable to the non-raw AE-INDEX-SUITE runs. It covers both `dynamic_csi` and `permanent_csi`, all four CRSP-like universes, and transaction-cost assumptions of 0, 5, 10, and 20 bps.

Sensitivity analysis is excluded. No model training, evaluation script, pipeline regeneration, or non-raw model run was executed.

## Source Decision

Existing revised raw benchmark 11C outputs were reused from the local raw benchmark preservation folder. The preserved raw benchmark contains monthly raw index weights and monthly returns for both tracks, so an isolated raw 11C rerun was not needed.

| track         | track_folder   | source_dir                                                                                                                                                                  | decision                    | weights_exists   | returns_exists   | performance_exists   | all_universes_in_returns   | turnover_possible   | tc_overlay_possible   | raw_11c_rerun_needed   | source_universes                         |
|:--------------|:---------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------|:-----------------|:-----------------|:---------------------|:---------------------------|:--------------------|:----------------------|:-----------------------|:-----------------------------------------|
| dynamic_csi   | temporary_csi  | C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\raw_benchmark\raw_preservation_20260529\raw_11c_index_revised\temporary_csi | reused_existing_raw_outputs | True             | True             | True                 | True                       | True                | True                  | False                  | large_cap|mid_cap|small_cap|total_market |
| permanent_csi | permanent_csi  | C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\raw_benchmark\raw_preservation_20260529\raw_11c_index_revised\permanent_csi | reused_existing_raw_outputs | True             | True             | True                 | True                       | True                | True                  | False                  | large_cap|mid_cap|small_cap|total_market |

## Output Location

Raw overlay outputs were written only under:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\raw_overlay`

The output tree mirrors the 11C validation layout and adds gross/net return, gross/net performance, and turnover outputs for the raw benchmark.

## Overlay Results

| track         | returns_tc_exists   | performance_tc_exists   |   returns_rows |   performance_rows | returns_bps   | performance_bps   | bps_exact   | required_fields_present   | formula_check_pass   |   max_drag_formula_abs_error |   max_net_formula_abs_error |
|:--------------|:--------------------|:------------------------|---------------:|-------------------:|:--------------|:------------------|:------------|:--------------------------|:---------------------|-----------------------------:|----------------------------:|
| dynamic_csi   | True                | True                    |          54912 |                832 | 0|5|10|20     | 0|5|10|20         | True        | True                      | True                 |                  9.90148e-17 |                 7.77156e-16 |
| permanent_csi | True                | True                    |          16896 |                256 | 0|5|10|20     | 0|5|10|20         | True        | True                      | True                 |                  1.00072e-16 |                 9.99201e-16 |

## Turnover Validation

Turnover is based on changed portfolio weights using drifted pre-trade weights derived from prior-month weights and monthly price returns. Initial portfolio formation is labelled separately via `is_initial_formation`.

| track         | turnover_by_month_exists   | turnover_summary_exists   |   turnover_rows |   turnover_summary_rows | required_fields_present   | required_fields_non_empty   |   initial_formation_rows |   recurring_rows | turnover_basis_values                                           |
|:--------------|:---------------------------|:--------------------------|----------------:|------------------------:|:--------------------------|:----------------------------|-------------------------:|-----------------:|:----------------------------------------------------------------|
| dynamic_csi   | True                       | True                      |           13728 |                      52 | True                      | True                        |                       52 |            13676 | drifted_pre_trade_to_target|initial_target_weights|no_rebalance |
| permanent_csi | True                       | True                      |            4224 |                      16 | True                      | True                        |                       16 |             4208 | drifted_pre_trade_to_target|initial_target_weights|no_rebalance |

## Universe Coverage

All four universes are represented for both tracks: `total_market`, `large_cap`, `mid_cap`, and `small_cap`.

| track         | universe     |   legacy_performance_rows |   returns_tc_rows |   performance_tc_rows |   turnover_rows | represented   |
|:--------------|:-------------|--------------------------:|------------------:|----------------------:|----------------:|:--------------|
| dynamic_csi   | large_cap    |                        52 |             13728 |                   208 |            3432 | True          |
| dynamic_csi   | mid_cap      |                        52 |             13728 |                   208 |            3432 | True          |
| dynamic_csi   | small_cap    |                        52 |             13728 |                   208 |            3432 | True          |
| dynamic_csi   | total_market |                        52 |             13728 |                   208 |            3432 | True          |
| permanent_csi | large_cap    |                        16 |              4224 |                    64 |            1056 | True          |
| permanent_csi | mid_cap      |                        16 |              4224 |                    64 |            1056 | True          |
| permanent_csi | small_cap    |                        16 |              4224 |                    64 |            1056 | True          |
| permanent_csi | total_market |                        16 |              4224 |                    64 |            1056 | True          |

## Headline Performance Snapshot

The snapshot below records the top non-benchmark raw strategy by net Sharpe where available for 0 and 20 bps. Full compact values are in `AE-INDEX-SUITE-007_raw_overlay_performance_snapshot.csv`.

| track         | universe     |   transaction_cost_bps | strategy   | model_key   | score_column   | score_value   | gross_mean_monthly_return   | net_mean_monthly_return   | gross_sharpe_ann   | net_sharpe_ann   | gross_max_drawdown   |   net_max_drawdown |
|:--------------|:-------------|-----------------------:|:-----------|:------------|:---------------|:--------------|:----------------------------|:--------------------------|:-------------------|:-----------------|:---------------------|-------------------:|
| dynamic_csi   | large_cap    |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.514707 |
| dynamic_csi   | mid_cap      |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.548881 |
| dynamic_csi   | small_cap    |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.539494 |
| dynamic_csi   | total_market |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.518767 |
| dynamic_csi   | large_cap    |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.514924 |
| dynamic_csi   | mid_cap      |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.550556 |
| dynamic_csi   | small_cap    |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.540964 |
| dynamic_csi   | total_market |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.518875 |
| permanent_csi | large_cap    |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.514567 |
| permanent_csi | mid_cap      |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.548137 |
| permanent_csi | small_cap    |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.537015 |
| permanent_csi | total_market |                      0 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.518297 |
| permanent_csi | large_cap    |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.514783 |
| permanent_csi | mid_cap      |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.549813 |
| permanent_csi | small_cap    |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.538475 |
| permanent_csi | total_market |                     20 | fpr1       | raw         |                |               |                             |                           |                    |                  |                      |          -0.518404 |

## Canonical Safety

Writes were limited to the isolated raw overlay root and the scoped AE-INDEX-SUITE-007 evidence files. Canonical production index outputs were not modified by this ticket. The existing unrelated dirty presentation deletion and unrelated untracked AE-VALIDATE files remain outside scope and unstaged.

## Conclusion

The raw benchmark is now comparable to `fund`, `latent_raw`, and `raw_plus_latent` under the same transaction-cost levels, turnover definitions, universe coverage, and gross/net performance format. Final model/index comparison can proceed after validator approval.
