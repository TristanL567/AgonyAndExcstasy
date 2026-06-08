# AE-ALPHA-008 Distributional Diagnostics

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into thesis writing, presentation edits, factor regressions, chart rendering, model training, or rerunning prior AE-ALPHA scripts.

## ticket_id

`AE-ALPHA-008`

## epic

`AE-ALPHA`

## goal

Create return-distribution diagnostics comparing the market benchmark, low-volatility quintiles, and selected CSI strategies. The purpose is to show whether observed strategy differences are driven by broad distribution shifts, downside months, tail losses, or benchmark-relative active returns.

This ticket should produce plot-ready and table-ready data only. It must not make final causal claims about alpha, quality, volatility, sector tilts, or inefficiency.

## dependencies

- `AE-ALPHA-003` completed and validator-approved.
- `AE-ALPHA-004` completed and validator-approved.
- `AE-ALPHA-005` completed and validator-approved.
- `AE-ALPHA-006` completed and validator-approved.
- `AE-ALPHA-007` completed and validator-approved.
- Low-volatility monthly returns exist:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/returns/lowvol_monthly_returns_gross_net_by_tc.rds`
- Benchmark monthly returns exist:
  - `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
- CSI performance extract exists:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/csi_performance_extract.rds`
- Existing CSI monthly return files exist under:
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**/index_returns_gross_and_net_by_tc.rds`

If optional prior ticket documents are unavailable in the active worktree, do not block on that alone. Use the generated alpha-validation outputs and this ticket envelope as the source of truth.

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
- Do not modify existing CSI outputs under `03_Data_Output/7_IndexConstructionValidation/**`.
- Do not rerun CSI index construction.
- Do not rerun low-volatility construction, performance, interpretation, tilt, or overlap diagnostics.
- Do not run model training.
- Do not create or render charts.
- Do not edit thesis files.
- Do not edit presentation files.
- Do not make final causal claims.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Create a dedicated distribution diagnostic script under `01_Code/pipeline/**`.
   - Recommended name: `11J_Distributional_Diagnostics.R`
2. The script must read existing artifacts only. It must not call or source scripts that regenerate low-volatility portfolios, CSI portfolios, model predictions, index construction, or previous diagnostics.
3. Build a unified monthly return panel containing at least:
   - market benchmark;
   - low-volatility `Q1`;
   - low-volatility `Q5`;
   - optional low-volatility `Q2`, `Q3`, `Q4` if already present in the input;
   - selected CSI headline/best strategies from `csi_performance_extract.rds`.
4. Use the same strategy-selection logic as the prior AE-ALPHA diagnostics where possible:
   - prefer rows marked `is_headline_20bps` and `is_best_by_track_index_cost`;
   - keep response track, universe, model/strategy metadata, transaction-cost bps, and source path.
5. Derive CSI monthly returns from existing `index_returns_gross_and_net_by_tc.rds` files referenced by `csi_performance_extract.rds` source paths. Do not rerun CSI construction.
6. Normalize return fields into a consistent schema:
   - `date`;
   - `qdate` where available;
   - `period`;
   - `response_track` where applicable;
   - `universe` / `index_id`;
   - `strategy_group` with values such as `benchmark`, `lowvol`, `csi`;
   - `strategy_id`;
   - `strategy_label`;
   - `transaction_cost_bps`;
   - `gross_return`;
   - `net_return`;
   - `benchmark_return`;
   - `active_return_gross`;
   - `active_return_net`.
7. Align all strategy returns to the matching benchmark by `date` and `index_id`.
8. Define periods consistently with AE-ALPHA performance outputs:
   - `full`;
   - `insample`;
   - `test`;
   - `oos`;
   Use the same date windows already used by existing performance summaries where discoverable. If exact windows are not directly available, infer them from the existing performance outputs and record the rule in the report.
9. Compute distribution diagnostics by strategy, universe, transaction-cost bps, and period:
   - mean monthly return;
   - median monthly return;
   - monthly volatility;
   - skewness;
   - excess kurtosis;
   - 2.5%, 5%, 50%, 95%, and 97.5% quantiles;
   - expected shortfall at 2.5%;
   - best and worst monthly return;
   - share of positive months;
   - mean active return versus benchmark;
   - active-return volatility;
   - tracking-error-like monthly standard deviation of active returns.
10. Compute upside and downside capture against the benchmark:
    - upside months: benchmark return > 0;
    - downside months: benchmark return < 0;
    - upside capture = mean(strategy return in upside months) / mean(benchmark return in upside months);
    - downside capture = mean(strategy return in downside months) / mean(benchmark return in downside months);
    - report counts of upside and downside months.
11. Compute tail-state diagnostics:
    - benchmark bottom 2.5% months;
    - benchmark bottom 5% months;
    - strategy mean return in those months;
    - strategy active return in those months;
    - number of tail months.
12. Create Q-Q and scatter plot input data, but do not render charts:
    - Q-Q data: empirical quantile pairs for benchmark return versus each selected strategy return;
    - scatter data: benchmark monthly return versus strategy monthly return, including active return and period labels.
13. Keep interpretation neutral:
    - acceptable wording: `distributional comparison`, `downside capture`, `tail-state behavior`, `active return pattern`;
    - forbidden wording: `proves alpha`, `proves independence`, `CSI is just low-vol`, `CSI is not low-vol`, `causal`, `final thesis conclusion`.
14. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `distribution_diagnostics/monthly_return_panel.{rds,csv}`
    - `distribution_diagnostics/distribution_summary_by_strategy.{rds,csv}`
    - `distribution_diagnostics/active_return_summary.{rds,csv}`
    - `distribution_diagnostics/upside_downside_capture.{rds,csv}`
    - `distribution_diagnostics/tail_state_summary.{rds,csv}`
    - `distribution_diagnostics/qq_plot_data.{rds,csv}`
    - `distribution_diagnostics/scatter_plot_data.{rds,csv}`
    - `reports/distribution_diagnostics_report.md`
    - `reports/distribution_diagnostics_run_status.csv`
15. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - period alignment rule;
    - selected strategy coverage;
    - neutral headline observations;
    - validation result.

## non_goals

- No low-volatility portfolio rerun.
- No CSI index-construction rerun.
- No model training.
- No factor regression.
- No characteristic tilt diagnostics.
- No overlap diagnostics.
- No chart rendering.
- No thesis edits.
- No presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated distribution diagnostic script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/**` and `reports/**`.
- The monthly return panel includes benchmark, low-volatility `Q1`, low-volatility `Q5`, and selected CSI strategies.
- Output tables include `index_id` or equivalent universe, period, strategy group, strategy id, and transaction-cost bps where applicable.
- Benchmark-relative active returns are computed using matched `date` and `index_id`.
- Upside/downside capture outputs have nonzero upside and downside month counts.
- Tail-state outputs have nonzero benchmark-tail month counts.
- Q-Q and scatter output tables exist as data only; no chart files are created.
- Report uses neutral wording and avoids final causal claims.
- Existing CSI outputs are not modified.
- Existing low-volatility outputs are not modified except for reading them.
- Completion report states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11J_Distributional_Diagnostics.R')"
Rscript 01_Code/pipeline/11J_Distributional_Diagnostics.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11J_Distributional_Diagnostics.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11J_Distributional_Diagnostics.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11J_Distributional_Diagnostics.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports -Recurse
```

The validator should also run read-only checks confirming:

- monthly return panel contains `benchmark`, `lowvol`, and `csi` strategy groups;
- low-volatility `Q1` and `Q5` are represented;
- selected CSI strategies are represented;
- active returns are finite for matched strategy-benchmark months;
- upside/downside capture has nonzero month counts;
- tail-state summary has nonzero benchmark-tail month counts;
- no chart files were created;
- no final-causal language appears in the report.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `row_counts`
- `period_alignment_rule`
- `selected_strategy_coverage`
- `headline_findings_neutral`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-009 Thesis-Ready Evidence Summary`

It should synthesize AE-ALPHA-004 through AE-ALPHA-008 into neutral thesis-ready evidence tables and a short interpretation memo, without editing thesis or presentation source files.
