# AE-PRES-INDEX-REV-004 Validation Report

## Validator Decision

Status: approved.

The blocking validator accepts the `AE-PRES-INDEX-REV-004` slide update for scoped commit.

## Checks Run

### Permanent CSI OOS Result Rows

Command:

```powershell
Import-Csv 03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison\best_by_track_index_cost.csv
```

Filters checked:

- `response_track=permanent_csi`
- `transaction_cost_bps=10`
- universes `total_market`, `large_cap`, `mid_cap`, `small_cap`

Result:

- 4 rows found.
- Universes represented: `large_cap`, `mid_cap`, `small_cap`, `total_market`.
- Cost represented: `10`.
- Winners:
  - Total: `raw_plus_latent`, `fpr5_permanent`.
  - Large: `raw_plus_latent`, `fpr5_permanent`.
  - Mid: `fund`, `fpr5_permanent`.
  - Small: `latent_raw`, `fpr3_permanent`.

### Attribution And Reconciliation Rows

Command:

```powershell
Import-Csv 05_Documentation\09_Epics\AE-ATTRIB_Main_Index_Attribution\AE-ATTRIB-001_config_level_attribution.csv
```

Filters checked:

- `track=permanent CSI`
- `period=oos`
- `transaction_cost_bps=10`
- selected rows matching the result-slide winners

Result:

- Total `raw_plus_latent`, FPR5 permanent: 1 row, `reconciliation_pass=true`, alpha `+0.2584pp`.
- Large `raw_plus_latent`, FPR5 permanent: 1 row, `reconciliation_pass=true`, alpha `+0.2154pp`.
- Mid `fund`, FPR5 permanent: 1 row, `reconciliation_pass=true`, alpha `+0.6235pp`.
- Small `latent_raw`, FPR3 permanent: 1 row, `reconciliation_pass=true`, alpha `+0.2408pp`.

The diagnostic slide uses the accepted formula:

```text
TP gain + FP cost + retained-stock reweighting + transaction-cost effect + geometric adjustment = realized alpha
```

### Source Map

Command:

```powershell
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\SLIDE_DATA_SOURCES.md -Pattern '^\| (24|25|26|27|54) \|'
```

Result:

- Row 24 maps `Permanent CSI OOS Index Results at 10 bps` to exact comparison and model-specific performance files.
- Row 25 maps `Permanent CSI OOS Diagnostic and Active Contribution` to exact AE-ATTRIB and model-specific error-decomposition files.
- Later rows were renumbered down by two; bibliography is row 54.

### Slide Text And Overclaim Review

Command:

```powershell
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern 'Permanent CSI OOS Index Results at 10 bps|Permanent CSI OOS Diagnostic and Active Contribution|period=oos|transaction_cost_bps=10'
```

Result:

- New frame titles are present.
- Removed stale main-section permanent 0 bps result, separate error-cost diagnostic, separate realized attribution, and duplicate 10 bps result frame titles.
- Diagnostic interpretation avoids causal overclaiming and states Permanent CSI alpha is mainly retained-stock reweighting plus geometric effects after FP costs.

### Frame Balance

Command:

```powershell
Select-String FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern '\\begin\{frame\}' -AllMatches
Select-String FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern '\\end\{frame\}' -AllMatches
```

Result: `begin_frames=54`, `end_frames=54`, balanced.

### Scope And Must-Not-Touch Check

Commands:

```powershell
git diff --name-only -- 01_Code 02_Data_Input 03_Data_Output 04_Research 07_CloudComputing
git status --short -- 01_Code 02_Data_Input 03_Data_Output 04_Research 07_CloudComputing
git diff --cached --name-only
```

Result:

- No tracked diffs under `01_Code`, `02_Data_Input`, `03_Data_Output`, `04_Research`, or `07_CloudComputing`.
- `04_Research/` and `07_CloudComputing/Validation/AE-VALIDATE/` remain unrelated pre-existing untracked paths and were not touched, staged, or committed for this ticket.
- Staged-path check covered seven files; all staged files are inside the ticket's allowed areas and none are under must-not-touch prefixes.
- No model training, model evaluation, index construction, sensitivity, pipeline, or presentation compilation commands were run.

## Acceptance Criteria

- Permanent OOS result slide exists and is source-backed: passed.
- Permanent OOS diagnostic/contribution slide exists and is source-backed: passed.
- Permanent CSI OOS result rows are `transaction_cost_bps=10`: passed.
- All four universes are represented: passed.
- Diagnostic/contribution rows reconcile by accepted attribution formula: passed.
- `SLIDE_DATA_SOURCES.md` has updated rows for the changed slides: passed.
- Frame balance passes: passed.
- No staged or modified files outside allowed areas from this ticket: passed.

## Residual Risk

The full presentation was not compiled, per ticket instruction. Validation is source, scope, source-map, and frame-structure based.
