# AE-INDEX-SUITE-007B Full Grid Rerun Report

Result: validator_passed

## Scope

This ticket reran isolated 11C index construction for all four model families (`raw`, `fund`, `latent_raw`, `raw_plus_latent`) and both CSI tracks (`dynamic_csi`, `permanent_csi`) so the index grid includes `fpr5` alongside `youden`, `fpr1`, and `fpr3`.

No model training, evaluation script, sensitivity script, or pipeline regeneration was run.

## Output Root

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite`

All generated index outputs are under model-specific subfolders of this isolated root.

## Run Summary

- run_count=8; all_exit_zero=True; threshold_grid_all_pass=True; tc_all_pass=True; turnover_all_pass=True; universe_all_pass=True

Run manifest: `AE-INDEX-SUITE-007B_run_manifest.csv`

## Threshold Grid

Temporary CSI contains all `4 x 4 = 16` threshold-lockout combinations per model. Permanent CSI contains all four threshold methods with the permanent-removal rule.

## Transaction Costs And Turnover

Transaction-cost variants are exactly `0`, `5`, `10`, and `20` bps for every model-track pair. Turnover outputs are populated and include `turnover_buy`, `turnover_sell`, `turnover_gross`, and `turnover_one_way`.

## Universe Coverage

All four universes are represented for every model-track pair: `total_market`, `large_cap`, `mid_cap`, and `small_cap`.

## Raw Input Note

The raw isolated 11C root was prepared from local raw model-suite prediction artifacts. The raw `ag_preds_train_boundary.parquet` was derived under the isolated raw root as the 2015 slice of the local raw CV predictions, because the downloaded raw comparator folder retained CV/test/OOS predictions but not the boundary parquet. No model training or remote download was performed.

## Evidence Files

- `AE-INDEX-SUITE-007B_run_manifest.csv`
- `AE-INDEX-SUITE-007B_threshold_grid_check.csv`
- `AE-INDEX-SUITE-007B_transaction_cost_check.csv`
- `AE-INDEX-SUITE-007B_turnover_check.csv`
- `AE-INDEX-SUITE-007B_universe_check.csv`
- `AE-INDEX-SUITE-007B_performance_snapshot.csv`
- `AE-INDEX-SUITE-007B_canonical_safety_check.csv`

## Conclusion

The full isolated index grid has been rerun with `fpr5`. AE-INDEX-SUITE-008 final model/index comparison can proceed after validator approval.
