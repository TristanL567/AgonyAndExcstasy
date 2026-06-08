# AE-ALPHA-004 Performance Metrics and Headline Tables

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into thesis interpretation, characteristic tilt diagnostics, overlap diagnostics, distributional charts, or presentation edits.

## ticket_id

`AE-ALPHA-004`

## epic

`AE-ALPHA`

## goal

Compute common performance metrics and headline comparison tables for the market benchmark, existing CSI strategies, and low-volatility quintile portfolios. This ticket creates the quantitative performance layer needed for later CSI-versus-low-volatility interpretation.

## dependencies

- `AE-ALPHA-001` completed and validator-approved.
- `AE-ALPHA-002` completed and validator-approved.
- `AE-ALPHA-003` completed and validator-approved.
- Low-volatility outputs exist under:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`
- Implementation spec exists:
  - `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_LowVol_Implementation_Spec.md`
- Existing CSI comparison outputs exist under:
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`

## allowed_areas

May create/edit code only under:

- `01_Code/pipeline/**`

May create generated alpha-validation outputs only under:

- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`

May create/update ticket reports only under:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/**`

Read-only inspection allowed under:

- `01_Code/**`
- `02_Data_Input/**`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**`

## must_not_touch

- Do not edit `02_Data_Input/**`.
- Do not overwrite or modify existing CSI outputs under `03_Data_Output/7_IndexConstructionValidation/**`.
- Do not rerun CSI index construction.
- Do not rerun low-volatility portfolio construction unless the existing AE-ALPHA-003 outputs are missing or demonstrably invalid.
- Do not run model training.
- Do not edit thesis files.
- Do not edit presentation files.
- Do not create final interpretation prose.
- Do not create charts.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Read:
   - `AE-ALPHA_LowVol_Implementation_Spec.md`
   - `AE-ALPHA-003_Completion_Report.md`
2. Create a dedicated performance script under `01_Code/pipeline/**`.
   - Recommended name: `11F_LowVol_Performance_Comparison.R`
   - It may reuse metric formulas from `11C_IndexConstruction_Revised.R`.
   - It should not modify `11C_IndexConstruction_Revised.R`.
3. Load low-volatility monthly returns from:
   - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/returns/lowvol_monthly_returns_gross_net_by_tc.rds`
4. Load low-volatility turnover/costs from:
   - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/turnover_costs/lowvol_turnover_costs_by_month.rds`
5. Load benchmark monthly returns from:
   - `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
6. Load existing CSI performance/returns outputs from:
   - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`
7. Decide the exact CSI comparison set from existing outputs:
   - recommended default: use available headline/best strategy rows from `comparison/` and `final_tables/` where possible;
   - if headline files are insufficient, use `index_performance_gross_and_net_by_tc` and preserve identifiers.
8. Compute or standardize performance metrics for low-volatility quintiles:
   - annualized geometric return;
   - annualized volatility;
   - Sharpe ratio;
   - maximum drawdown;
   - expected shortfall at 2.5 percent;
   - annualized turnover gross;
   - total transaction-cost drag.
9. Include benchmark metrics with transaction cost fixed at `0` bps.
10. Include low-volatility quintile metrics for transaction-cost bps:
    - `0`;
    - `5`;
    - `10`;
    - `20`.
11. Preserve existing CSI transaction-cost bps levels from source outputs.
12. Build headline comparison tables:
    - benchmark versus `Q1` through `Q5`;
    - CSI headline/best rows versus `Q1`;
    - CSI headline/best rows versus benchmark;
    - CSI headline/best rows versus `Q5`;
    - low-volatility spread `Q1 - Q5` where meaningful.
13. Do not write final interpretation beyond neutral table labels and status notes.
14. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `performance/lowvol_performance_summary.{rds,csv}`
    - `performance/benchmark_performance_summary.{rds,csv}`
    - `performance/csi_performance_extract.{rds,csv}`
    - `comparisons/benchmark_vs_lowvol_quintiles.{rds,csv}`
    - `comparisons/csi_vs_lowvol_headline.{rds,csv}`
    - `comparisons/lowvol_q1_minus_q5_spread.{rds,csv}`
    - `reports/performance_run_status.csv`
15. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - available universes;
    - transaction-cost settings present;
    - metric sanity checks;
    - known caveats.

## metric definitions

Use monthly returns and the following definitions unless 11C uses an exactly equivalent local helper:

```text
annualized_geometric_return = prod(1 + R_t)^(12 / n_months) - 1
annualized_volatility = sd(R_t) * sqrt(12)
Sharpe = mean(R_t - rf_monthly) / sd(R_t - rf_monthly) * sqrt(12)
max_drawdown = min(cumprod(1 + R_t) / cumulative_peak - 1)
ES_2.5% = mean(R_t | R_t <= quantile_2.5%(R_t))
annualized_turnover_gross = sum(turnover_gross_t) / max(n_months / 12, 1)
TC_drag = sum(transaction_cost_return_drag_t)
```

If risk-free handling is unavailable or inconsistent across sources, document the assumption and use the same convention as 11C.

## non_goals

- No low-volatility portfolio reconstruction unless AE-ALPHA-003 outputs are missing or invalid.
- No CSI reruns.
- No model training.
- No characteristic tilt diagnostics.
- No overlap diagnostics.
- No QQ/scatter/upside-downside charts.
- No final thesis interpretation.
- No thesis edits.
- No presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated performance comparison script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`.
- Low-volatility performance includes `Q1` through `Q5`.
- Low-volatility performance includes `0`, `5`, `10`, and `20` bps.
- Benchmark performance is present with `0` bps.
- CSI extract is present from existing outputs.
- Expected shortfall at 2.5 percent is computed for generated performance rows.
- Max drawdown is computed for generated performance rows.
- No generated outputs are written outside the approved alpha-validation root.
- Existing CSI outputs are not modified.
- Completion report exists and states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11F_LowVol_Performance_Comparison.R')"
Rscript 01_Code/pipeline/11F_LowVol_Performance_Comparison.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11F_LowVol_Performance_Comparison.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11F_LowVol_Performance_Comparison.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11F_LowVol_Performance_Comparison.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons -Recurse
```

The validator should also run read-only checks confirming:

- `Q1` through `Q5` are present;
- transaction-cost levels `0`, `5`, `10`, and `20` are present for low-volatility rows;
- benchmark rows exist;
- CSI extract rows exist;
- max drawdown and expected shortfall columns are finite where enough return observations exist.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `headline_row_counts`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-005 CSI versus Low-Volatility Interpretation Tables`

It should interpret whether CSI appears to add value beyond `Q1`, benchmark, and `Q5`, while still avoiding thesis/presentation edits.
