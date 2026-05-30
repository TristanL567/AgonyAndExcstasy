# AE-INDEX-SUITE-003 Pilot Run Report

## Status

Result: `validator_passed`

Branch: `Development`

Pilot combination run exactly once:

- `MODEL=raw_plus_latent`
- `RESPONSE_TRACK=dynamic_csi`

Pilot output root:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\pilot`

11C output directory:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\pilot\3_Modelling_Results\Necessary\temporary_csi\11c_index_revised_raw_plus_latent`

## AEGIS Reference

Before execution, `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced as read-only reference material. The ticket was executed under the requested worker -> validator gate. No `aegis-core` files were edited.

## Preflight

- Branch confirmed as `Development`.
- Local `raw_plus_latent` temporary CSI prediction files existed under `03_Data_Output/6_ModelSuite/raw_plus_latent/temporary_csi/`.
- `MT_OUTPUT_DIR` was absolute and pointed to the isolated pilot root.
- A minimal input mirror of the required prediction files was created under the pilot root because 11C routes prediction reads through `MT_OUTPUT_DIR` when output isolation is active.
- No remote/Vast.ai execution was used.

## Command Shape

The single allowed local command shape was:

```text
MODEL=raw_plus_latent
RESPONSE_TRACK=dynamic_csi
MT_OUTPUT_DIR=<absolute isolated pilot root>
Rscript 01_Code/pipeline/11C_IndexConstruction_Revised.R
```

No `09C_AutoGluon.py`, `10_Evaluation.R`, sensitivity script, model training, or pipeline regeneration command was run.

## Run Result

- Exit code: `0`
- Elapsed minutes reported by 11C: `6.45`
- Threshold rows: `3`
- Weight rows: `7309681`
- Return rows: `13728`
- Turnover rows: `13728`
- Transaction-cost return rows: `54912`
- Performance rows: `208`
- Transaction-cost performance rows: `832`

## Output Families Created

See `AE-INDEX-SUITE-003_pilot_output_contract_check.csv` and `AE-INDEX-SUITE-003_pilot_file_inventory.csv`.

All expected legacy and new output families were created, including:

- `index_turnover_by_month`
- `index_turnover_summary`
- `index_returns_gross_and_net_by_tc`
- `index_performance_gross_and_net_by_tc`

## Transaction-Cost Validation

Transaction-cost variants found:

- returns: `0, 5, 10, 20` bps
- performance: `0, 5, 10, 20` bps

The transaction-cost formula sample check passed with maximum drag error `8.819984673169579e-17` and maximum net-return error `8.604228440844963e-16`.

## Turnover Validation

Turnover outputs are present and populated. Required fields exist:

- `turnover_buy`
- `turnover_sell`
- `turnover_gross`
- `turnover_one_way`

Initial portfolio formation is labelled separately with `is_initial_formation` and `turnover_basis`.

Turnover basis after initial formation: `drifted_pre_trade_to_target`.

## Universe Coverage

All four required universes are represented:

- `total_market`
- `large_cap`
- `mid_cap`
- `small_cap`

See `AE-INDEX-SUITE-003_pilot_universe_check.csv`.

## Canonical Safety

The only generated output writes were under:

`03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/pilot/**`

No canonical production output paths were modified. `git status -- 03_Data_Output` showed no tracked changes.

Known unrelated working tree items remain unstaged and outside this ticket:

- deleted presentation `.Rnw`
- old untracked AE-VALIDATE reports

## Readiness Decision

`PROCEED_TO_BROADER_NONRAW_INDEX_RUNS`

The AE-INDEX-SUITE-002 implementation works on real `raw_plus_latent` temporary CSI predictions in an isolated pilot run. Broader non-raw 11C runs can proceed in the next ticket using the same absolute `MT_OUTPUT_DIR` isolation pattern.
