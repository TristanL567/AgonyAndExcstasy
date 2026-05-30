# AE-INDEX-SUITE-007A FPR5 Implementation Report

Result: validator_passed

## Scope

This ticket adds `fpr5` threshold support to `01_Code/pipeline/11C_IndexConstruction_Revised.R`. It is an implementation-only ticket: no full 11C run, model training, evaluation, sensitivity script, or pipeline regeneration was executed.

## Code Change

The 11C threshold grid now includes:

- `youden`
- `fpr1`
- `fpr3`
- `fpr5`

`fpr5` is implemented through the same fixed-FPR threshold selection path as `fpr1` and `fpr3`, using `FIXED_FPR_LEVELS <- c(fpr1 = 0.01, fpr3 = 0.03, fpr5 = 0.05)`.

The duplicate `fpr1`/`fpr3` row-building logic was replaced with a small loop over `FIXED_FPR_LEVELS`, so existing fixed-FPR behavior is preserved while extending the grid to `fpr5`.

## Grid Impact

Temporary CSI retains lockouts:

- 1 year
- 2 years
- 3 years
- 5 years

Future temporary CSI 11C runs will therefore produce `4 x 4 = 16` threshold-lockout combinations per model/index/cost setting.

Permanent CSI keeps the existing absorbing permanent-removal rule. Future permanent CSI 11C runs will apply `youden`, `fpr1`, `fpr3`, and `fpr5` to that permanent-removal rule.

## Preserved Contracts

The following contracts remain intact:

- model routing: `raw`, `fund`, `latent_raw`, `raw_plus_latent`
- raw default behavior when `MODEL` is unset
- output isolation via `MT_OUTPUT_DIR`
- transaction-cost variants: `0`, `5`, `10`, `20` bps
- turnover outputs: `index_turnover_by_month` and `index_turnover_summary`
- gross/net cost outputs: `index_returns_gross_and_net_by_tc` and `index_performance_gross_and_net_by_tc`
- sensitivity-mode behavior was not edited

## Static Validation

Validation performed:

- R parse/syntax check only: `R_PARSE_OK`
- static threshold-grid check: `AE-INDEX-SUITE-007A_static_threshold_grid_check.csv`
- static output-contract check: `AE-INDEX-SUITE-007A_output_contract_check.csv`

No output files under canonical `03_Data_Output/**` were written by this ticket.

## Conclusion

`fpr5` threshold support is implemented. After validator approval, AE-INDEX-SUITE-007B can rerun the necessary isolated index outputs to include `fpr5` alongside `youden`, `fpr1`, and `fpr3`.
