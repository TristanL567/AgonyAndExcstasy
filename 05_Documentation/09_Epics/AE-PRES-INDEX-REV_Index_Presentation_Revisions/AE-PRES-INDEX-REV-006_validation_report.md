# AE-PRES-INDEX-REV-006 Validation Report

## Validator Decision

Status: approved.

The blocking validator accepts the `AE-PRES-INDEX-REV-006` slide update for scoped commit.

## Checks Run

### Transaction-Cost Robustness

Command:

```powershell
Import-Csv 03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison\best_by_track_index_cost.csv
```

Filters checked:

- `response_track in (dynamic_csi, permanent_csi)`
- `transaction_cost_bps in (5, 10, 20)`

Result:

- 24 rows found.
- Tracks represented: `dynamic_csi`, `permanent_csi`.
- Costs represented: `5`, `10`, `20`.
- Universes represented: `large_cap`, `mid_cap`, `small_cap`, `total_market`.
- Displayed winners remain the selected OOS winner rows at every displayed cost.

Cross-check:

- `transaction_cost_robustness_summary.csv` has `winner_changed_0_to_20_bps=False` for all eight OOS track-universe rows.

### Turnover Effect

Command:

```powershell
Import-Csv 03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison\best_by_track_index_cost.csv
```

Result:

- Turnover slide covers both OOS tracks and all four universes.
- It covers 5, 10, and 20 bps drag values.
- Highest displayed turnover and drag are in Mid and Small Cap:
  - Temporary Mid: turnover `105.9%`, drag `0.26/0.53/1.06pp` at 5/10/20 bps.
  - Permanent Mid: turnover `106.2%`, drag `0.27/0.53/1.06pp` at 5/10/20 bps.
  - Temporary Small: turnover `85.5%`, drag `0.21/0.43/0.85pp`.
  - Permanent Small: turnover `75.7%`, drag `0.19/0.38/0.76pp`.

### Threshold-Family / Turnover Interpretation

Commands:

```powershell
Import-Csv 03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\final_tables\threshold_family_summary_20bps.csv
Import-Csv 03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison\best_by_track_index_cost.csv
```

Result:

- Temporary CSI final selected rules: Youden 3yr for Total/Large/Small and FPR5 5yr for Mid.
- Permanent CSI final selected rules: FPR5 permanent for Total/Large/Mid and FPR3 permanent for Small.
- 20 bps family summary supports:
  - Temporary Youden mean best alpha `+0.3475pp`.
  - Permanent FPR3 mean best alpha `+0.3520pp`.
  - Permanent FPR5 mean best alpha `+0.3312pp`.
  - Permanent Youden mean best alpha `-0.2021pp`.

### Sensitivity Slides

Commands:

```powershell
Import-Csv 05_Documentation\09_Epics\AE-SENS-CHART_Sensitivity_Index_Charts\tables\universe_stability_summary.csv
Import-Csv 03_Data_Output\5_SensitivityAnalysis\presentation_ready\temporary_blocked_config_disclosure.csv
```

Result:

- Main sensitivity slide identifies temporary CSI only.
- Main-run comparison is present for Total, Large, Mid, and Small.
- Completed/reused run count is `24` for each universe.
- Main run is below median for Total and Large, above median for Mid and Small.
- Completed-run min/max ranges are positive for all four universes.
- Appendix A19 discloses three `blocked_partial` configurations:
  - `C080_M000_T012`
  - `C080_M000_T018`
  - `C060_M020_T028`
- The slides explicitly do not claim permanent-CSI sensitivity support.

### Source Map

Command:

```powershell
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\SLIDE_DATA_SOURCES.md -Pattern '^\| (28|29|30|31|52) \|'
```

Result:

- Row 28 maps transaction-cost robustness to 5/10/20 OOS cost rows and robustness cross-checks.
- Row 29 maps turnover effect to OOS winner turnover and 5/10/20 drag rows.
- Row 30 maps threshold-family interpretation to final 20 bps family and winner-turnover sources.
- Row 31 maps the main sensitivity slide to temporary-CSI stability evidence.
- Row 52 maps Appendix A19 to temporary-CSI sensitivity details, blocked cases, and temporary transaction-cost overlays.

### Frame Balance

Command:

```powershell
Select-String FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern '\\begin\{frame\}' -AllMatches
Select-String FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern '\\end\{frame\}' -AllMatches
```

Result: `begin_frames=56`, `end_frames=56`, balanced.

### Scope And Must-Not-Touch Check

Commands:

```powershell
git diff --name-only -- 01_Code 02_Data_Input 03_Data_Output 07_CloudComputing
git status --short -- 01_Code 02_Data_Input 03_Data_Output 07_CloudComputing
git diff --cached --name-only
```

Result:

- No tracked diffs under `01_Code`, `02_Data_Input`, `03_Data_Output`, or `07_CloudComputing` from this ticket.
- Pre-existing unrelated untracked paths under `07_CloudComputing/Validation/AE-VALIDATE/` were not touched, staged, or committed for this ticket.
- Staged-path check covers only allowed ticket paths.
- No model training, model evaluation, index construction, sensitivity, pipeline, or full deck compile command was run.

## Acceptance Criteria

- Transaction-cost robustness slide is source-backed and readable: passed.
- Turnover slide covers 5/10/20 bps and both OOS tracks: passed.
- Threshold-family / turnover interpretation is source-backed: passed.
- Sensitivity slides identify main-run comparison, key result, and limitations: passed.
- `SLIDE_DATA_SOURCES.md` updated for all changed slides: passed.
- Rnw frame balance passes: passed.
- Staged scope is limited to allowed areas: passed.

## Residual Risk

The full presentation was not compiled, per ticket instruction. Validation is source, scope, source-map, and frame-structure based.
