# AE-ALPHA-007 Overlap Diagnostics

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into distributional plots, final thesis prose, presentation edits, or causal/factor-model claims.

## ticket_id

`AE-ALPHA-007`

## epic

`AE-ALPHA`

## goal

Quantify overlap between CSI exclusions/retained weights and volatility quintiles. This ticket should show whether CSI exclusions concentrate in high-volatility `Q5`, whether CSI retained portfolios remain exposed to `Q1` through `Q5`, and whether CSI behaves like a pure high-volatility exclusion rule or selects a distinct set.

## dependencies

- `AE-ALPHA-001` completed and validator-approved.
- `AE-ALPHA-002` completed and validator-approved.
- `AE-ALPHA-003` completed and validator-approved.
- `AE-ALPHA-004` completed and validator-approved.
- `AE-ALPHA-005` completed and validator-approved.
- `AE-ALPHA-006` completed and validator-approved.
- Low-volatility quintile assignments exist:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/volatility_quintiles/lowvol_volatility_quintiles.rds`
- Existing CSI performance extract exists:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/csi_performance_extract.rds`
- Existing CSI weights exist under:
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**/index_weights_by_crsp_universe.rds`
- Benchmark constituent universe exists:
  - `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`

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
- Do not rerun low-volatility portfolio construction.
- Do not rerun AE-ALPHA-004/005/006 unless required inputs are missing or demonstrably invalid.
- Do not run model training.
- Do not create charts.
- Do not edit thesis files.
- Do not edit presentation files.
- Do not make final causal claims.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Read:
   - `AE-ALPHA_LowVol_Implementation_Spec.md`
   - `AE-ALPHA-005_Completion_Report.md`
   - `AE-ALPHA-006_Completion_Report.md`
2. Create a dedicated overlap diagnostic script under `01_Code/pipeline/**`.
   - Recommended name: `11I_CSI_LowVol_Overlap_Diagnostics.R`
   - It should read existing weights/quintiles and write overlap diagnostics.
3. Use low-volatility quintile assignments from:
   - `alpha_validation/volatility_quintiles/lowvol_volatility_quintiles.rds`
4. Use CSI headline/best strategy selection from:
   - `alpha_validation/performance/csi_performance_extract.rds`
   - Prefer the same headline/best strategy selection logic used in AE-ALPHA-006.
5. Derive firm-level CSI retained and excluded sets for each CSI strategy:
   - benchmark universe = `crsp_like_index_constituents_quarterly.rds` by `qdate`, `index_id`, `permno`;
   - retained set = firms present in the relevant CSI `index_weights_by_crsp_universe.rds`;
   - excluded set = benchmark universe minus retained set for the same `qdate`, `index_id`, and strategy.
6. Join benchmark, retained, and excluded firms to low-volatility quintile assignments by:
   - `qdate`;
   - `index_id`;
   - `permno`.
7. Compute name-count and benchmark-weight overlap diagnostics:
   - share of CSI-excluded names in each quintile `Q1` to `Q5`;
   - share of CSI-excluded benchmark weight in each quintile `Q1` to `Q5`;
   - specifically `Excluded_CSI ∩ Q5` as a share of CSI-excluded names and CSI-excluded benchmark weight;
   - specifically `Excluded_CSI ∩ Q1` as a low-volatility false-exclusion diagnostic.
8. Compute retained CSI portfolio exposure to volatility quintiles:
   - CSI retained portfolio weight in `Q1` to `Q5`;
   - benchmark weight in `Q1` to `Q5`;
   - active CSI weight versus benchmark by quintile.
9. Compute summary statistics by:
   - response track;
   - period if available;
   - index universe;
   - model family / analysis model;
   - strategy id;
   - transaction-cost bps where present;
   - qdate and aggregate full-sample summaries.
10. Keep interpretation neutral:
    - use phrases like `concentrated in Q5`, `partial overlap`, `retained exposure`, `active weight`;
    - avoid final language such as `CSI is just low-vol`, `CSI alpha is independent`, or `proves distinct signal`.
11. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `overlap_diagnostics/csi_exclusion_quintile_overlap.{rds,csv}`
    - `overlap_diagnostics/csi_retained_quintile_exposure.{rds,csv}`
    - `overlap_diagnostics/csi_active_quintile_exposure.{rds,csv}`
    - `overlap_diagnostics/overlap_summary_by_strategy.{rds,csv}`
    - `overlap_diagnostics/overlap_summary_by_track_universe.{rds,csv}`
    - `reports/overlap_diagnostics_report.md`
    - `reports/overlap_diagnostics_run_status.csv`
12. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - coverage notes;
    - neutral headline observations;
    - validation result.

## non_goals

- No characteristic tilt diagnostics. That was AE-ALPHA-006.
- No distributional charts. That is AE-ALPHA-008.
- No final thesis interpretation. That is AE-ALPHA-009.
- No factor regressions.
- No CSI reruns.
- No low-vol reruns.
- No model training.
- No thesis edits.
- No presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated overlap diagnostic script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/**` and `reports/**`.
- CSI exclusion overlap outputs have nonzero rows.
- CSI retained quintile exposure outputs have nonzero rows.
- `Q1` through `Q5` are represented where low-volatility assignment coverage allows.
- Summary tables include response track and index universe dimensions.
- Report uses neutral wording and avoids final causal claims.
- Existing CSI outputs are not modified.
- Existing low-vol construction/performance/tilt outputs are not modified except for reading them.
- Completion report states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R')"
Rscript 01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports -Recurse
```

The validator should also run read-only checks confirming:

- exclusion overlap rows are nonzero;
- retained exposure rows are nonzero;
- quintile labels include `Q1` through `Q5` where expected;
- summary tables include response track and index universe;
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
- `coverage_notes`
- `headline_findings_neutral`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-008 Distributional Diagnostics`

It should create return-distribution diagnostics such as benchmark-versus-strategy scatter inputs, QQ-plot inputs, active-return histograms, upside/downside capture, and tail-return comparisons.
