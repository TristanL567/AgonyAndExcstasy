# AE-ALPHA-002 Low-Volatility Specification Finalization

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The worker may write only the specification and completion report listed in `allowed_areas`. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into implementation, code edits, return calculations, portfolio construction, output generation, or thesis writing.

## ticket_id

`AE-ALPHA-002`

## epic

`AE-ALPHA`

## goal

Convert the AE-ALPHA-001 source map into a precise implementation specification for volatility quintile portfolio construction and CSI-vs-low-volatility comparison. This ticket decides the exact universe, timing, return field, volatility signal, weighting, transaction-cost, turnover, metric, sector, and characteristic-alignment rules before any implementation begins.

## dependencies

- `AE-ALPHA-001` is completed and validator-approved.
- Completion report exists:
  - `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-001_Completion_Report.md`
- Epic exists:
  - `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_Epic.md`
- No cloud instance is required.

## allowed_areas

Read-only inspection allowed under:

- `01_Code/**`
- `02_Data_Input/**`
- `03_Data_Output/**`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**`

May create or update only:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_LowVol_Implementation_Spec.md`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-002_Completion_Report.md`

## must_not_touch

- Do not edit code.
- Do not edit data.
- Do not edit existing CSI model/index outputs.
- Do not generate volatility quintile outputs.
- Do not calculate portfolio returns.
- Do not calculate performance metrics.
- Do not regenerate figures, tables, slides, PDFs, or thesis files.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not commit.
- Do not stage files.

## requirements

The worker must write a specification that resolves the following design choices.

### 1. Universe and benchmark alignment

Specify how to use:

- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
- `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`

The spec must decide how quarterly index membership maps to monthly volatility sorting and monthly returns.

The spec must explicitly cover the available index universes:

- total market,
- large cap,
- mid cap,
- small cap,
- any exact `index_id` / `index_name` values discovered in the inputs.

### 2. Rebalance cadence

Resolve the AE-ALPHA-001 ambiguity:

- Baker/Bradley/Wurgler use monthly quintile formation.
- Existing CSI 11C uses quarterly target weights with monthly drifted returns.

The spec must choose one primary cadence for the low-volatility portfolios and justify it.

Recommended default:

- use quarterly target formation for comparability with CSI 11C if CSI-vs-low-vol is the primary thesis comparison;
- optionally allow a later monthly-literature robustness variant if needed.

If the worker recommends monthly formation instead, the spec must explain how the monthly low-vol series remains comparable to quarterly CSI.

### 3. Return field and volatility signal

Specify:

- monthly return field: `ret_adj` from `prices_monthly.rds`;
- volatility signal: trailing standard deviation of monthly `ret_adj`;
- lookback: up to 60 months;
- minimum valid return history: 24 months;
- no look-ahead: use only returns before the formation date;
- missing-return handling;
- extreme-return handling, if any.

Formula:

```text
sigma_i,t = sd(r_i,t-60, ..., r_i,t-1)
```

### 4. Quintile construction

Specify:

- five equal-count quintiles;
- `Q1` = lowest volatility;
- `Q5` = highest volatility;
- tie handling;
- handling firms with insufficient history;
- whether quintiles are formed within each index universe separately;
- whether quintiles are formed globally then intersected with each index universe.

Recommended default:

- form quintiles separately within each index universe and formation date.

### 5. Weighting

Specify whether target weights use:

- `security_mktcap` or `weight` from quarterly constituents; or
- monthly `mktcap` from prices.

Recommended default:

- use current index constituent weights / security market caps at formation dates for CSI comparability;
- reweight within each quintile by market cap.

Formula:

```text
w_i,t^Qk = ME_i,t / sum_j_in_Qk ME_j,t
```

### 6. Monthly drifted returns

Specify how portfolio returns are computed between formation dates:

- target weights at rebalance,
- monthly drifted holdings,
- realized monthly `ret_adj`,
- treatment of delistings and missing returns,
- consistency with 11C drifted-return logic.

### 7. Turnover and transaction costs

Specify:

- turnover formula,
- initial formation treatment,
- transaction-cost rates for volatility quintiles: `5`, `10`, `20` bps;
- whether to also include `0` bps for diagnostics;
- benchmark transaction cost: `0` bps;
- CSI transaction-cost comparison source: existing CSI output files, not recomputed in this ticket.

Turnover formula:

```text
Turnover_t = 0.5 * sum_i abs(w_i,t^new - w_i,t^old_drifted)
```

Net return formula:

```text
R_t^net = R_t^gross - transaction_cost_bps / 10000 * Turnover_t
```

### 8. Performance metrics

Specify exact formulas and annualization conventions for:

- geometric return,
- annualized volatility,
- Sharpe ratio,
- maximum drawdown,
- expected shortfall at 2.5 percent,
- annualized turnover,
- transaction-cost drag.

Expected shortfall:

```text
ES_2.5% = mean(R_t | R_t <= quantile_2.5%(R_t))
```

The spec should recommend reusing `11C_IndexConstruction_Revised.R` formulas where possible.

### 9. CSI comparison source

Specify which existing CSI outputs should be used as comparison inputs, including exact path patterns under:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`

The spec must state whether comparison will focus on:

- all CSI strategies,
- headline winners,
- raw-only strategies,
- model families,
- threshold families.

Recommended default:

- first compare against existing headline/best strategy outputs;
- then keep broader grid comparison as a later extension if needed.

### 10. Sector and characteristic alignment

Specify how later diagnostics should align annual/fiscal features to monthly or quarterly holdings:

- sector from `siccd` / `sich`;
- trailing volatility and drawdown from monthly returns;
- size from market cap;
- liquidity proxy from monthly `vol` / `shrout`, if used;
- quality/profitability/leverage/Altman Z from annual feature files;
- lagging rule to avoid look-ahead.

### 11. Output contract

Define expected future output files under:

`03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

At minimum, specify future files for:

- inputs manifest,
- volatility signal panel,
- quintile membership,
- quintile weights,
- monthly gross returns,
- turnover and transaction-cost drag,
- net returns by transaction-cost setting,
- performance summary,
- CSI-vs-low-vol comparison table.

## non_goals

- No implementation.
- No code edits.
- No portfolio construction.
- No return calculation.
- No performance calculation.
- No output generation under `03_Data_Output`.
- No chart generation.
- No thesis/presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- `AE-ALPHA_LowVol_Implementation_Spec.md` exists.
- The spec resolves every design choice listed in `requirements`.
- The spec contains exact input paths and exact future output paths.
- The spec explicitly states the selected rebalance cadence and why.
- The spec states how the low-vol portfolios will be comparable to CSI.
- The spec states how transaction costs and turnover will be computed.
- The spec states how expected shortfall at 2.5 percent will be computed.
- The spec lists open risks or assumptions, if any.
- The completion report states that no code, data, generated output, staging, commit, thesis, or presentation edits occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Get-Content 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-001_Completion_Report.md
Get-Content 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_Epic.md
Select-String -Path 01_Code/pipeline/11C_IndexConstruction_Revised.R -Pattern "fn_turnover_event|TRANSACTION_COST_BPS|fn_expected_shortfall|fn_ann_geo|fn_perf|PATH_11C_RETURNS|PATH_11C_WEIGHTS"
```

Suggested validator commands:

```powershell
git status --short --branch
git diff --stat
Test-Path 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_LowVol_Implementation_Spec.md
```

Expected: only the allowed spec and completion report are changed/created.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `selected_design`
- `open_assumptions`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-003 Volatility Quintile Portfolio Construction`

It should implement the portfolio builder exactly according to `AE-ALPHA_LowVol_Implementation_Spec.md`.
