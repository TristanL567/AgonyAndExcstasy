# AE-ALPHA-009 Thesis-Ready Evidence Summary

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into thesis editing, presentation editing, new modelling, factor regressions, chart rendering, or rerunning prior AE-ALPHA scripts.

## ticket_id

`AE-ALPHA-009`

## epic

`AE-ALPHA`

## goal

Create a neutral, thesis-ready evidence summary that synthesizes AE-ALPHA-004 through AE-ALPHA-008. The output should help the human decide what can be claimed about CSI, market benchmarks, and low-volatility quintiles, without writing directly into the thesis or presentation.

The summary must separate:

- performance evidence;
- low-volatility comparison evidence;
- characteristic tilt evidence;
- CSI/low-volatility overlap evidence;
- distributional evidence;
- remaining limitations and non-claims.

## dependencies

- `AE-ALPHA-004` completed and validator-approved.
- `AE-ALPHA-005` completed and validator-approved.
- `AE-ALPHA-006` completed and validator-approved.
- `AE-ALPHA-007` completed and validator-approved.
- `AE-ALPHA-008` completed and validator-approved.
- Existing alpha-validation outputs exist under:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/**`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/**`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/**`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/**`
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/**`

If an optional prior completion report is missing from the active worktree, do not block solely on that. Use generated alpha-validation outputs and this ticket envelope as the source of truth.

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
- Do not rerun low-volatility construction, performance, interpretation, tilt, overlap, or distribution diagnostics.
- Do not run model training.
- Do not run factor regressions.
- Do not create or render charts.
- Do not edit thesis files under `08_Writting/**`.
- Do not edit presentation files under `06_Presentations/**`.
- Do not make final causal claims.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Create a dedicated synthesis script under `01_Code/pipeline/**`.
   - Recommended name: `11K_Thesis_Evidence_Summary.R`
2. The script must read existing AE-ALPHA outputs only. It must not call or source scripts that regenerate prior outputs.
3. Build a consolidated evidence table with one row per evidence item. Required fields:
   - `evidence_id`;
   - `research_question_area`;
   - `evidence_family`;
   - `source_artifact`;
   - `track`;
   - `universe`;
   - `period`;
   - `transaction_cost_bps`;
   - `comparison`;
   - `metric`;
   - `value`;
   - `benchmark_or_reference`;
   - `direction`;
   - `claim_support_level`;
   - `interpretation_guardrail`;
   - `limitation`.
4. Map evidence to the thesis question areas:
   - `main_rq`: crash-filtered index versus market benchmark and low-volatility strategies;
   - `sq_autoencoder`: whether autoencoder features improve predictive performance relative to raw data;
   - `sq_volatility_comparison`: whether CSI differs from a simple low-volatility/high-volatility rule;
   - `sq_features`: which characteristic families appear related to CSI exclusions or retained portfolios;
   - `limitations`: what cannot be claimed from current outputs.
5. Use AE-ALPHA-004 performance outputs to summarize:
   - benchmark performance;
   - low-volatility Q1-Q5 performance;
   - selected CSI performance;
   - CSI versus benchmark and CSI versus Q1 where available;
   - geometric return, volatility, Sharpe ratio, max drawdown, expected shortfall 2.5%, and turnover where available.
6. Use AE-ALPHA-005 comparison outputs to summarize:
   - CSI versus benchmark flags;
   - CSI versus Q1 low-volatility flags;
   - CSI versus Q5 high-volatility flags;
   - low-volatility anomaly pattern by quintile.
7. Use AE-ALPHA-006 tilt diagnostics to summarize:
   - volatility exposure;
   - size exposure;
   - sector exposure;
   - profitability/quality exposure;
   - leverage/solvency exposure;
   - liquidity exposure where available.
8. Use AE-ALPHA-007 overlap diagnostics to summarize:
   - share of CSI exclusions in Q5;
   - share of CSI exclusions in Q1;
   - CSI retained weights across Q1-Q5;
   - CSI active weight versus benchmark across Q1-Q5.
9. Use AE-ALPHA-008 distribution diagnostics to summarize:
   - downside capture;
   - upside capture;
   - benchmark-tail behavior;
   - active-return distribution;
   - Q-Q/scatter data availability.
10. Produce a concise interpretation memo with sections:
    - `What the current evidence supports`;
    - `What the current evidence does not support`;
    - `How to phrase the low-volatility comparison`;
    - `How to phrase CSI alpha carefully`;
    - `Remaining robustness checks`;
    - `Suggested thesis table list`.
11. Keep wording neutral and thesis-ready:
    - acceptable: `supports descriptive evidence`, `consistent with`, `suggests`, `does not rule out`, `requires caution`;
    - forbidden: `proves alpha`, `proves independence`, `causal`, `final thesis conclusion`, `CSI is just low-vol`, `CSI is not low-vol`.
12. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `evidence_summary/thesis_evidence_map.{rds,csv}`
    - `evidence_summary/research_question_evidence_matrix.{rds,csv}`
    - `evidence_summary/performance_evidence_summary.{rds,csv}`
    - `evidence_summary/tilt_overlap_distribution_evidence_summary.{rds,csv}`
    - `evidence_summary/suggested_thesis_tables.{rds,csv}`
    - `reports/thesis_ready_evidence_summary.md`
    - `reports/thesis_ready_evidence_run_status.csv`
13. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - research-question coverage;
    - neutral headline findings;
    - limitations;
    - validation result.

## non_goals

- No thesis text edits.
- No presentation edits.
- No chart rendering.
- No new statistics beyond descriptive synthesis of existing AE-ALPHA outputs.
- No factor regressions.
- No model training.
- No CSI reruns.
- No low-volatility reruns.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated synthesis script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary/**` and `reports/**`.
- Evidence map contains nonzero rows for performance, comparison, tilt, overlap, and distribution evidence families.
- Research-question evidence matrix covers `main_rq`, `sq_autoencoder`, `sq_volatility_comparison`, `sq_features`, and `limitations`.
- Suggested thesis table list has nonzero rows.
- Memo uses neutral wording and avoids final causal claims.
- Existing AE-ALPHA outputs are read-only and not modified except for the new evidence-summary output root.
- No thesis files, presentation files, data inputs, CSI construction outputs, or model outputs are edited.
- Completion report states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11K_Thesis_Evidence_Summary.R')"
Rscript 01_Code/pipeline/11K_Thesis_Evidence_Summary.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11K_Thesis_Evidence_Summary.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11K_Thesis_Evidence_Summary.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11K_Thesis_Evidence_Summary.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/evidence_summary -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports -Filter '*thesis_ready*'
```

The validator should also run read-only checks confirming:

- evidence families include performance, comparison, tilt, overlap, and distribution;
- research-question areas include `main_rq`, `sq_autoencoder`, `sq_volatility_comparison`, `sq_features`, and `limitations`;
- suggested thesis tables are populated;
- the memo contains limitation language;
- no final-causal language appears in the memo or report;
- no chart files were created;
- no thesis or presentation files were edited.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `row_counts`
- `research_question_coverage`
- `headline_findings_neutral`
- `limitations`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next step should be a human decision point:

- either stop the AE-ALPHA epic and review the evidence manually;
- or open a new epic for thesis-table rendering and slide/thesis integration.
