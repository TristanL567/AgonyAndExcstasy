# AE-PRES-REV-002 Validation Report

## Static Checks Run

- Confirmed branch status reports `Development`.
- Confirmed all four revised index-result frames exist in the June `.Rnw`.
- Confirmed each revised frame uses the required LaTeX-safe header:
  - `Universe`
  - `Strategy`
  - `Geo ret.`
  - `Ann. SD`
  - `Sharpe Ratio`
  - `Max DD`
  - `ES 2.5%`
  - `Delta pp`
- Confirmed `SLIDE_DATA_SOURCES.md` includes source rows for the four revised index-result frames.
- Confirmed no compile was run.
- Confirmed no model, index, sensitivity, or pipeline scripts were run.

## Data Validation

The table values were read from:

- `best_by_track_index_cost.csv` for best-strategy selection.
- matching OOS rows in model-specific `index_performance_gross_and_net_by_tc.csv` files for Geo ret., Ann. SD, Sharpe Ratio, Max DD, ES 2.5%, and Delta pp.
- matching OOS benchmark rows with `model_key=bench` and `strategy_id=bench_mw` for benchmark rows.

Four benchmark-versus-best-strategy tables are present:

- Temporary CSI, 0 bps.
- Temporary CSI, 10 bps.
- Permanent CSI, 0 bps.
- Permanent CSI, 10 bps.

Each table includes benchmark and best-strategy rows for:

- Total.
- Large.
- Mid.
- Small.

## Scope Check

Expected in-scope modified files:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-002_*`

Known unrelated dirty files remain outside this worker ticket:

- old deleted `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`
- pre-existing June PDF modification
- untracked `07_CloudComputing/Validation/AE-VALIDATE/`

## Not Run

- Full deck compile.
- PDF generation.
- `11C_IndexConstruction_Revised.R`.
- Model training.
- Evaluation.
- Sensitivity scripts.
- Pipeline scripts.
