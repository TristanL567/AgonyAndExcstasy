# AE-ALPHA-001 Source Mapping and Artifact Discovery

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The worker must stay read-only. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into implementation, code edits, portfolio construction, metric computation, or output generation.

## ticket_id

`AE-ALPHA-001`

## epic

`AE-ALPHA`

## goal

Map the exact local inputs, existing outputs, and code paths needed to implement the low-volatility quintile benchmark and compare it against existing CSI index strategies. This is a read-only discovery ticket.

## dependencies

- Repository: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy`
- Epic file exists: `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_Epic.md`
- Current CSI index outputs and code may already exist locally.
- No cloud instance is required for this ticket.

## allowed_areas

Read-only inspection allowed under:

- `01_Code/**`
- `02_Data_Input/**`
- `03_Data_Output/**`
- `05_Documentation/09_Epics/**`
- `06_Presentations/**` only if needed to locate already-used index result sources
- `08_Writting/**` only if needed for thesis framing

May create or update only the completion report for this ticket under:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-001_Completion_Report.md`

## must_not_touch

- Do not edit code.
- Do not edit data.
- Do not edit existing model or index outputs.
- Do not run portfolio construction.
- Do not run model training.
- Do not regenerate figures, tables, slides, PDFs, or thesis files.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not commit.
- Do not stage files.

## requirements

1. Identify existing CSI index-construction scripts relevant to benchmark, strategy returns, portfolio weights, turnover, and transaction-cost logic.
2. Identify existing monthly return inputs suitable for volatility estimation.
3. Identify the best available market-cap or benchmark-weight input for cap-weighting volatility quintiles.
4. Identify whether monthly sector classifications exist and where.
5. Identify available characteristic variables for later tilt diagnostics:
   - trailing volatility,
   - drawdown,
   - size,
   - liquidity,
   - leverage,
   - profitability or quality proxies,
   - Altman Z,
   - market-value deterioration.
6. Identify current CSI strategy output files needed for comparison:
   - monthly returns,
   - weights,
   - excluded firms or selected firms,
   - turnover,
   - transaction-cost settings,
   - benchmark returns.
7. Identify whether existing functions already compute:
   - geometric return,
   - annualized volatility,
   - Sharpe ratio,
   - maximum drawdown,
   - expected shortfall,
   - turnover,
   - transaction-cost drag.
8. Identify the safest output paths for later generated alpha-validation files under:

   `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

9. Note any missing artifacts that would block implementation tickets.
10. Produce a concise report with exact file paths and recommended next ticket scope.

## non_goals

- No volatility quintile construction.
- No return calculations.
- No metric calculations.
- No code edits.
- No figure generation.
- No thesis or presentation edits.
- No cloud setup.
- No branch switching.
- No commits.

## acceptance_criteria

The completion report must include:

- exact candidate input paths for monthly returns,
- exact candidate input paths for market caps or benchmark weights,
- exact candidate paths for CSI strategy returns and/or weights,
- exact code files/functions that currently implement CSI index construction,
- exact code files/functions that currently implement transaction costs and turnover,
- availability assessment for sector and characteristic diagnostics,
- list of missing or ambiguous inputs,
- recommended scope for `AE-ALPHA-002`,
- explicit statement that no implementation, edits, staging, commits, or output regeneration occurred.

## manual_verification_required

Yes. The Master Agent must route the worker report through a blocking validator.

## verification_commands

The worker should run read-only commands only. Suggested commands:

```powershell
git status --short --branch
rg -n "turnover|transaction|bps|cost|Sharpe|max drawdown|drawdown|expected shortfall|geometric|annualized|benchmark|weight|market cap|mkvalt|sector|sic|naics|gics" 01_Code 05_Documentation 06_Presentations
rg --files 02_Data_Input 03_Data_Output | rg "return|returns|weight|weights|benchmark|index|turnover|transaction|sector|sic|naics|gics|feature|panel|mkvalt|market"
```

The validator should confirm:

```powershell
git status --short --branch
git diff --stat
```

Expected: no source/data/output changes except the optional allowed completion report.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `key_paths`
- `missing_or_ambiguous_inputs`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-002 Low-Volatility Specification Finalization`

It should convert the discovered file map into a precise implementation specification before any code is edited.
