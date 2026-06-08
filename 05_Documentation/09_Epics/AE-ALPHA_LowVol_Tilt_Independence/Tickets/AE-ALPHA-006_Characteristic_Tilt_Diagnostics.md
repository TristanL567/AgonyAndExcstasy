# AE-ALPHA-006 Characteristic Tilt Diagnostics

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into overlap diagnostics, distributional plots, final thesis prose, presentation edits, or causal/factor-model claims.

## ticket_id

`AE-ALPHA-006`

## epic

`AE-ALPHA`

## goal

Diagnose whether CSI strategies, low-volatility `Q1`, high-volatility `Q5`, and the market benchmark differ systematically by observable firm characteristics. This ticket tests whether CSI performance may be related to simple volatility, size, sector, quality/profitability, leverage, liquidity, Altman Z, or market-value deterioration tilts.

## dependencies

- `AE-ALPHA-001` completed and validator-approved.
- `AE-ALPHA-002` completed and validator-approved.
- `AE-ALPHA-003` completed and validator-approved.
- `AE-ALPHA-004` completed and validator-approved.
- `AE-ALPHA-005` completed and validator-approved.
- Low-volatility target weights exist:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/weights/lowvol_target_weights.rds`
- Low-volatility quintile assignments exist:
  - `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/volatility_quintiles/lowvol_volatility_quintiles.rds`
- Existing CSI weights exist under:
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**/index_weights_by_crsp_universe.rds`
- Candidate annual feature files exist under:
  - `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/**`
  - `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/**`
- Monthly prices exist:
  - `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`

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
- Do not rerun AE-ALPHA-004 or AE-ALPHA-005 unless required inputs are missing or demonstrably invalid.
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
   - `AE-ALPHA-001_Completion_Report.md`
   - `AE-ALPHA-005_Completion_Report.md`
2. Create a dedicated diagnostic script under `01_Code/pipeline/**`.
   - Recommended name: `11H_Characteristic_Tilt_Diagnostics.R`
   - It should read existing weights/features and write characteristic diagnostics.
3. Define portfolio groups for comparison:
   - market benchmark;
   - low-volatility `Q1`;
   - low-volatility `Q5`;
   - existing CSI headline/best strategies if available from AE-ALPHA-004/005 outputs;
   - optionally all CSI strategies only if row volume is manageable and clearly labelled.
4. Use security-level weights to compute weighted-average characteristics by:
   - period;
   - index universe;
   - response track where applicable;
   - strategy/model where applicable;
   - transaction-cost bps where applicable only if weights differ by strategy source;
   - portfolio group.
5. Use annual/firm-year features with explicit no-look-ahead alignment.
   - For holding year `Y`, use features from signal/feature year `Y-1` where available, or document the exact field alignment used by existing 11C weights.
   - Do not use future feature values relative to holdings.
6. Include the following diagnostic families where fields exist:
   - volatility: `vol_12m`, `vol_60m`, and/or realized trailing volatility from `prices_monthly.rds`;
   - size: `log_mkvalt`, `log_at`, market cap;
   - sector: SIC-derived grouping from `siccd` / `sich`;
   - profitability/quality: `roa`, `roe`, `roic`, `gross_margin`, `ebitda_margin`, `ocf_margin`;
   - leverage/solvency: `leverage`, `net_debt_ebitda`, `interest_cov`, `current_ratio`, `quick_ratio`;
   - Altman Z: `altman_z` and available components;
   - market-value deterioration: `peak_drop_log_mkvalt`, `consec_decline_log_mkvalt`, `yoy_log_mkvalt`;
   - liquidity proxy: monthly `vol`, `shrout`, or a documented proxy if available.
7. If a required field is missing, record it in a missing-field manifest rather than failing the whole ticket.
8. Produce portfolio-level characteristic diagnostics:
   - weighted means;
   - weighted medians where feasible;
   - coverage counts and weight coverage;
   - differences versus benchmark;
   - differences versus `Q1`;
   - differences versus `Q5`.
9. Produce sector diagnostics:
   - portfolio sector weights;
   - active sector weights versus benchmark;
   - top sector overweights/underweights for CSI and `Q1`.
10. Keep interpretation neutral:
    - use phrases like `higher weighted average`, `lower exposure`, `possible tilt`;
    - avoid final language such as `CSI alpha is independent of quality` or `CSI is just low-vol`.
11. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `tilt_diagnostics/characteristic_field_manifest.{rds,csv}`
    - `tilt_diagnostics/portfolio_characteristic_summary.{rds,csv}`
    - `tilt_diagnostics/portfolio_characteristic_differences.{rds,csv}`
    - `tilt_diagnostics/sector_weight_summary.{rds,csv}`
    - `tilt_diagnostics/sector_active_weight_summary.{rds,csv}`
    - `reports/characteristic_tilt_diagnostics_report.md`
    - `reports/tilt_diagnostics_run_status.csv`
12. Produce a completion report with:
    - files created/edited;
    - generated outputs;
    - row counts;
    - fields included;
    - fields missing;
    - coverage notes;
    - neutral headline observations;
    - validator result.

## non_goals

- No overlap diagnostics between CSI exclusions and low-vol quintiles. That is AE-ALPHA-007.
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

- A dedicated diagnostic script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- Required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/**` and `reports/**`.
- Characteristic field manifest lists included and missing fields.
- Portfolio characteristic summary has nonzero rows.
- Portfolio characteristic differences include differences versus benchmark and at least one of `Q1`/`Q5`.
- Sector diagnostics exist or the report clearly states why sector diagnostics could not be produced.
- Report uses neutral wording and avoids final causal claims.
- Existing CSI outputs are not modified.
- Existing low-vol construction/performance outputs are not modified except for reading them.
- Completion report states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R')"
Rscript 01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R
```

If `Rscript` is unavailable, use:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics -Recurse
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports -Recurse
```

The validator should also run read-only checks confirming:

- characteristic summary has nonzero rows;
- field manifest has included and/or missing fields;
- differences include benchmark comparisons;
- sector diagnostics are present or explicitly documented as unavailable;
- no final-causal language appears in the report.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `fields_included`
- `fields_missing`
- `coverage_notes`
- `headline_findings_neutral`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-007 Overlap Diagnostics`

It should quantify overlap between CSI exclusions/weights and volatility quintiles, especially CSI exposure to `Q1` through `Q5` and CSI exclusions intersecting `Q5`.
