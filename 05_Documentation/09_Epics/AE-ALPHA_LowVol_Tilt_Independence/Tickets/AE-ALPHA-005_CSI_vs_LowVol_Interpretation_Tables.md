# AE-ALPHA-005 CSI versus Low-Volatility Interpretation Tables

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into characteristic tilt diagnostics, overlap diagnostics, distributional plots, thesis edits, presentation edits, or final thesis prose.

## ticket_id

`AE-ALPHA-005`

## epic

`AE-ALPHA`

## goal

Create neutral interpretation tables that answer whether existing CSI headline/best strategies outperform the low-volatility `Q1` portfolio, the market benchmark, and the high-volatility `Q5` portfolio on the agreed performance metrics. This ticket should summarize patterns, not make final thesis claims.

## dependencies

- `AE-ALPHA-001` completed and validator-approved.
- `AE-ALPHA-002` completed and validator-approved.
- `AE-ALPHA-003` completed and validator-approved.
- `AE-ALPHA-004` completed and validator-approved.
- Required AE-ALPHA-004 outputs exist:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/lowvol_performance_summary.rds`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/benchmark_performance_summary.rds`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/csi_performance_extract.rds`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/benchmark_vs_lowvol_quintiles.rds`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/csi_vs_lowvol_headline.rds`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/lowvol_q1_minus_q5_spread.rds`

## allowed_areas

May create/edit code only under:

- `01_Code/pipeline/**`

May create generated alpha-validation outputs only under:

- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`

May create/update ticket reports only under:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/**`

Read-only inspection allowed under:

- `01_Code/**`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**`

## must_not_touch

- Do not edit `02_Data_Input/**`.
- Do not modify existing CSI outputs under `03_Data_Output/7_IndexConstructionValidation/**`.
- Do not rerun CSI index construction.
- Do not rerun low-volatility portfolio construction.
- Do not recompute AE-ALPHA-004 performance metrics unless the AE-ALPHA-004 outputs are missing or demonstrably invalid.
- Do not run model training.
- Do not create charts.
- Do not edit thesis files.
- Do not edit presentation files.
- Do not create final thesis conclusion prose.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Read:
   - `AE-ALPHA_LowVol_Implementation_Spec.md`
   - `AE-ALPHA-004_Completion_Report.md`
2. Create a dedicated interpretation-table script under `01_Code/pipeline/**`.
   - Recommended name: `11G_CSI_LowVol_Interpretation_Tables.R`
   - It should read AE-ALPHA-004 outputs and write derived interpretation tables.
   - It should not modify `11F_LowVol_Performance_Comparison.R`.
3. Load `csi_vs_lowvol_headline.rds` and verify it contains CSI, `Q1`, benchmark, and `Q5` metric columns.
4. Load `benchmark_vs_lowvol_quintiles.rds` and `lowvol_q1_minus_q5_spread.rds`.
5. Create binary and numeric comparison flags for each CSI headline/best row:
   - CSI annualized geometric return greater than `Q1`;
   - CSI Sharpe ratio greater than `Q1`;
   - CSI max drawdown less severe than `Q1`;
   - CSI expected shortfall less severe than `Q1`;
   - CSI annualized geometric return greater than benchmark;
   - CSI Sharpe ratio greater than benchmark;
   - CSI annualized geometric return greater than `Q5`;
   - CSI Sharpe ratio greater than `Q5`.
6. Define less-severe tail-risk comparisons carefully:
   - max drawdown values are negative, so less severe means `CSI max_drawdown > comparator max_drawdown`;
   - expected shortfall values are negative, so less severe means `CSI ES_2.5% > comparator ES_2.5%`.
7. Create a neutral classification field, for example:
   - `beats_q1_on_return_and_sharpe`;
   - `beats_benchmark_but_not_q1`;
   - `underperforms_q1`;
   - `mixed`.
8. Summarize by:
   - period;
   - response track;
   - index universe;
   - transaction-cost bps;
   - model family / analysis model;
   - headline source.
9. Produce low-volatility anomaly summary tables:
   - `Q1` versus benchmark;
   - `Q1` versus `Q5`;
   - `Q5` versus benchmark;
   - by period, universe, and transaction-cost bps.
10. Keep wording neutral:
    - use terms such as `outperforms in this metric`, `underperforms`, `mixed`, `requires tilt diagnostics`;
    - avoid final causal language such as `proves alpha`, `proves inefficiency`, or `independent of low-volatility`.
11. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `comparisons/csi_lowvol_metric_flags.{rds,csv}`
    - `comparisons/csi_lowvol_summary_by_track_universe.{rds,csv}`
    - `comparisons/csi_lowvol_summary_by_period_cost.{rds,csv}`
    - `comparisons/lowvol_anomaly_summary.{rds,csv}`
    - `reports/csi_lowvol_interpretation_report.md`
    - `reports/interpretation_run_status.csv`
12. The markdown report should include only:
    - run status;
    - input files used;
    - table row counts;
    - neutral summary of metric patterns;
    - caveats;
    - explicit statement that characteristic tilt diagnostics and overlap diagnostics remain future tickets.
13. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - metric-flag sanity checks;
    - caveats;
    - validation result.

## non_goals

- No low-volatility portfolio reconstruction.
- No performance metric recomputation except light consistency checks.
- No CSI reruns.
- No model training.
- No characteristic tilt diagnostics.
- No overlap diagnostics.
- No distributional charts.
- No thesis edits.
- No presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated interpretation script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`.
- `csi_lowvol_metric_flags` contains numeric differences and boolean flags for CSI versus `Q1`, benchmark, and `Q5`.
- Summary tables include period, universe, response track, and transaction-cost dimensions where applicable.
- `lowvol_anomaly_summary` includes `Q1` versus benchmark and `Q1` versus `Q5`.
- The markdown report uses neutral wording and does not make final thesis claims.
- Existing CSI outputs are not modified.
- Existing low-volatility construction outputs are not modified except for reading them.
- Completion report exists and states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R')"
Rscript 01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11G_CSI_LowVol_Interpretation_Tables.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports -Recurse
```

The validator should also run read-only checks confirming:

- metric flag outputs contain CSI-vs-Q1, CSI-vs-benchmark, and CSI-vs-Q5 columns;
- boolean flags are not all `NA`;
- summary tables have nonzero rows;
- report avoids final causal language such as `proves alpha` or `proves inefficiency`.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `headline_findings_neutral`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-006 Characteristic Tilt Diagnostics`

It should test whether CSI, `Q1`, and benchmark portfolios differ systematically by volatility, size, sector, quality/profitability, leverage, liquidity, Altman Z, and market-value deterioration.
