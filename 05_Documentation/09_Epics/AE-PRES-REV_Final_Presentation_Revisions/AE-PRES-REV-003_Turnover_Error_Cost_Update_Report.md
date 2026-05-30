# AE-PRES-REV-003 Turnover And Error-Cost Update Report

## Status

Completed.

## Source Gate

The source gate passed. Existing AE-INDEX-SUITE files were sufficient:

- Turnover source: `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/turnover_summary.csv`
- Winner source: `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- 20 bps winner turnover source: `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv`
- Error-cost sources: model-specific `error_cost_decomposition_by_crsp_universe.csv` files under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`

For the eight selected best strategies, OOS error-cost rows contained all required categories: `false_positive`, `false_negative`, `true_positive`, and `true_negative`.

## Deck Changes

Added two frames to the June final presentation:

1. `Turnover Effect`
   - Temporary CSI table.
   - Permanent CSI table.
   - Required columns: Universe, Best strategy, Ann. turnover, Geo ret. 0 bps, Geo ret. 10 bps, Delta from TC.
   - Interpretation: mid/small-cap turnover is higher, cost drag is larger where turnover is higher, and 0--20 bps costs do not change top winner rankings.

2. `Error-Cost Decomposition`
   - Temporary CSI table.
   - Permanent CSI table.
   - Required columns: Universe, Best rule, FP cost, FN cost, TP gain, TN gain, Net.
   - Matched selected best strategies by track, universe, model, threshold, lockout/rule, strategy id, and OOS period.
   - Category signs were preserved from the decomposition output. `Net` uses the source `difference_versus_benchmark` field.

Updated `SLIDE_DATA_SOURCES.md` with source-map rows for both new frames.

## Notes

No full deck compile was run. No PDF, data output, code, model, index, sensitivity, or pipeline script was modified or executed.
