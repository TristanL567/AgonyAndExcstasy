# AE-ALPHA-010 Validation Report

## Validator Result

Approved: all validation checks pass.

## Checks

| check | expected | actual | pass |
| --- | --- | --- | --- |
| risk_return_row_count | 64 rows | 64 rows | TRUE |
| risk_return_period_universe_coverage | Test and OOS x four universes | Total, Large, Mid, Small for test, oos | TRUE |
| risk_return_strategy_rows_per_period_universe | 8 rows per period/universe: benchmark, Q1-Q5, temporary CSI, permanent CSI | 8 | TRUE |
| overlap_row_count | 80 rows | 80 rows | TRUE |
| overlap_period_universe_track_quintile_coverage | Test and OOS x four universes x two CSI tracks x five quintiles | 5 | TRUE |
| cost_scope | Benchmark at 0 bps; low-vol and CSI at 20 bps | 0, 20 | TRUE |
| test_oos_only | Only test and oos periods in generated tables | oos, test | TRUE |
| source_summary_file | AE-ALPHA_Risk_Return_and_Overlap_Summary.md exists | created by AE-ALPHA-010 | TRUE |

## Scope Validation

Generated and documentation files are limited to the allowed AE-ALPHA documentation tree, including `Tables/` evidence paths. No presentation, writing, code, input, model, index-construction, data-output, or pipeline files were modified.

## Forbidden Runs

No model training, CSI index construction, low-volatility construction, sensitivity, evaluation, or pipeline scripts were run.
