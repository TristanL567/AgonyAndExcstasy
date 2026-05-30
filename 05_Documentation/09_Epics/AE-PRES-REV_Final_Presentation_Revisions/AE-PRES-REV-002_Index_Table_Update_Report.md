# AE-PRES-REV-002 Index Table Update Report

## Status

Completed worker pass. The June final presentation index-result section now presents benchmark-versus-best-strategy tables for:

- Temporary CSI at 0 bps.
- Temporary CSI at 10 bps.
- Permanent CSI at 0 bps.
- Permanent CSI at 10 bps.

No deck compile was run. No index construction, model training, sensitivity, or pipeline scripts were run.

## Scope

Edited only:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

Created AE-PRES-REV-002 evidence under:

- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/`

The pre-existing unstaged bootstrap-path hunk at the top of the June `.Rnw` was preserved in the working tree. It was not created for this ticket.

## Data Sources

Best strategy selection comes from:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`

Table performance fields come from matching OOS rows in the model-specific:

- `index_performance_gross_and_net_by_tc.csv`

Metric mapping:

- `Geo ret.` = `net_annualized_geometric_return`
- `Ann. SD` = `net_annualized_sd`
- `Sharpe Ratio` = `net_sharpe_ratio`
- `Max DD` = `net_max_drawdown`
- `ES 2.5%` = `net_expected_shortfall_2p5`
- `Delta pp` = `net_difference_versus_benchmark` in percentage points

Benchmark rows use source performance rows with `model_key=bench` and `strategy_id=bench_mw` at the matching transaction-cost level. Benchmark `Delta pp` is shown as `0.00pp`.

## Presentation Changes

The prior 20 bps headline winner slides were replaced with four main index-result tables. Each table uses the required columns:

`Universe`, `Strategy`, `Geo ret.`, `Ann. SD`, `Sharpe Ratio`, `Max DD`, `ES 2.5%`, `Delta pp`.

Each table has eight rows:

- Four benchmark rows.
- Four best-strategy rows.
- Universes: Total, Large, Mid, Small.

Strategy labels follow AE-PRES-REV-001 naming:

- `AG Expanded Dataset`
- `AG Base Dataset`
- `AG Latent Dataset (VAE)`
- `AG Exp. Dataset + VAE`

No XGB-specific rows were used or labelled.

## Appendix Coverage

The detailed appendix remains in place for the full index grid:

- Costs: 0, 5, 10, and 20 bps.
- Threshold methods: Youden, FPR1, FPR3, FPR5.
- Temporary lockouts: 1, 2, 3, and 5 years.
- Permanent rule: permanent removal.
- Model families: raw, fund, latent_raw, raw_plus_latent, shown with presentation labels in the main tables.

`SLIDE_DATA_SOURCES.md` now maps the four new index-result frames to the exact comparison and model-specific performance files.
