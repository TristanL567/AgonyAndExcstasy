# AE-INDEX-SUITE-002 Implementation Report

## Status

Result: `validator_passed`

Branch: `Development`

Scope implemented:

- 11C model routing for `raw`, `fund`, `latent_raw`, and `raw_plus_latent`
- transaction-cost return/performance overlays for `0`, `5`, `10`, and `20` bps
- monthly turnover outputs and turnover summary outputs
- static/parse validation only; no full index construction run

## AEGIS Reference

Before implementation, `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced as read-only reference material. The ticket was executed under the Master-Agent / validator-blocking workflow requested by the user. No `aegis-core` files were edited.

## Code Change Summary

Changed file:

- `01_Code/pipeline/11C_IndexConstruction_Revised.R`

No other code files were edited.

### Model Routing

The previous hardcoded raw-only routing was replaced with explicit `MODEL` selection. The default remains `raw`:

- `MODEL` unset -> `raw`
- `raw` -> `ag_raw`, output directory `11c_index_revised`
- `fund` -> `ag_fund`, output directory `11c_index_revised_fund`
- `latent_raw` -> `ag_latent_raw`, output directory `11c_index_revised_latent_raw`
- `raw_plus_latent` -> `ag_raw_plus_latent`, output directory `11c_index_revised_raw_plus_latent`

Unsupported `MODEL` values now stop with an explicit supported-values message. Legacy aliases used elsewhere in the repo are accepted where relevant: `M1`, `M3`, `M4`, `raw_latent`, and `raw+latent`.

The mapping was verified against `09C_AutoGluon.py`, which writes prediction tables under `AutoGluon/ag_{MODEL}`.

### Output Isolation

The script now honors an absolute `MT_OUTPUT_DIR` directly in 11C by rebasing the output tree under:

`<MT_OUTPUT_DIR>/3_Modelling_Results/Necessary/<track>/`

This preserves the canonical raw behavior when `MT_OUTPUT_DIR` is unset, while allowing later validation/index-suite tickets to write under isolated output roots.

### Transaction Costs

The implementation constructs gross portfolios once, computes turnover once, and expands returns/performance over:

- `0` bps
- `5` bps
- `10` bps
- `20` bps

Formula:

`transaction_cost_return_drag = turnover_gross * transaction_cost_bps / 10000`

`net_return = gross_return - transaction_cost_return_drag`

Costs apply to gross turnover, so buys and sells are both included.

### Turnover Basis

The implementation uses drifted pre-trade holdings where available. For the first portfolio formation, pre-trade weights are zero and the row is labelled as initial formation.

Turnover fields:

- `turnover_buy`
- `turnover_sell`
- `turnover_gross`
- `turnover_one_way`
- `is_initial_formation`
- `turnover_basis`

`turnover_basis` is either `initial_target_weights`, `drifted_pre_trade_to_target`, or `no_rebalance`.

## Output Contract

New or extended outputs are documented in:

- `AE-INDEX-SUITE-002_Output_Contract.csv`

Expected new output families:

- `index_turnover_by_month.{rds,csv}`
- `index_turnover_summary.{rds,csv}`
- `index_returns_gross_and_net_by_tc.{rds,csv}`
- `index_performance_gross_and_net_by_tc.{rds,csv}`

Existing gross-return outputs remain present for backward compatibility.

## Validation Performed

Validation performed:

- R parse validation of `01_Code/pipeline/11C_IndexConstruction_Revised.R`
- static checks for supported `MODEL` values
- static checks for exact transaction-cost bps values
- static checks for required output filenames and turnover fields
- git diff check limited to the allowed 11C script and AE-INDEX-SUITE evidence

Commands intentionally not run:

- full `11C_IndexConstruction_Revised.R`
- `09C_AutoGluon.py`
- `10_Evaluation.R`
- pipeline regeneration scripts
- sensitivity scripts

## Canonical Output Safety

No canonical `03_Data_Output/**` files were modified. This ticket only changes 11C code support and writes scoped evidence under:

- `07_CloudComputing/Validation/AE-INDEX-SUITE/`

Known unrelated working tree items remain outside ticket scope and must not be staged:

- deleted presentation file under `06_Presentations/**`
- pre-existing untracked AE-VALIDATE reports

## Limitations For AE-INDEX-SUITE-003

- This ticket did not run full index construction, by design.
- AE-INDEX-SUITE-003 should run a small isolated smoke or pilot execution before the full non-raw index suite.
- If later runs require exact target branch parity with older validation output roots, the runner should set absolute `MT_OUTPUT_DIR`.

## Readiness

AE-INDEX-SUITE-002 passed blocking validator review. The implementation is ready for AE-INDEX-SUITE-003 isolated execution validation.
