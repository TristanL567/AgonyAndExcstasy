# AE-PRES-INDEX-REV-005 Validation Report

## Validator Decision

Status: approved.

The blocking validator accepts the `AE-PRES-INDEX-REV-005` slide update for scoped commit.

## Checks Run

### Permanent CSI Test Result Rows

Command:

```powershell
Import-Csv 03_Data_Output\9_TestIndexConstruction\AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv
```

Filters checked:

- `track=permanent_csi`
- `period=test`
- `transaction_cost_bps=10`

Result:

- 40 rows found for the permanent-CSI test 10 bps subset.
- Best-strategy universes represented: `large_cap`, `mid_cap`, `small_cap`, `total_market`.
- Benchmark universes represented: `large_cap`, `mid_cap`, `small_cap`, `total_market`.
- Cost represented: `10`.
- Selected winners:
  - Total: `raw_plus_latent`, `youden_permanent`, alpha `+0.4468pp` versus benchmark.
  - Large: `raw_plus_latent`, `youden_permanent`, alpha `+0.2581pp` versus benchmark.
  - Mid: `raw_plus_latent`, `youden_permanent`, alpha `+0.4267pp` versus benchmark.
  - Small: `raw_plus_latent`, `youden_permanent`, alpha `+0.8272pp` versus benchmark.

### Isolated Test Package Validation

Commands:

```powershell
Import-Csv 03_Data_Output\9_TestIndexConstruction\AE-FP-DIAG-006_test_index_grid_summary.csv
Import-Csv 03_Data_Output\9_TestIndexConstruction\AE-FP-DIAG-006_validation_checks.csv
```

Result:

- `track=permanent_csi`, `model=raw_plus_latent`, `period=test`.
- `performance_rows=80`, `model_performance_rows=64`, `benchmark_rows=16`.
- `universes=large_cap|mid_cap|small_cap|total_market`.
- `transaction_cost_bps=0|5|10|20`.
- `oos_rows=0`.
- Validation checks pass for `permanent_csi_raw_plus_latent_performance_periods=test` and `permanent_csi_raw_plus_latent_performance_oos_rows=0`.

### Attribution And Reconciliation Rows

Command:

```powershell
Import-Csv 05_Documentation\09_Epics\AE-ATTRIB_Main_Index_Attribution\AE-ATTRIB-001_config_level_attribution.csv
```

Filters checked:

- `track=permanent CSI`
- `response_track=permanent_csi`
- `period=test`
- `transaction_cost_bps=10`
- `model=raw_plus_latent`
- `threshold_method=youden`
- `strategy_id=youden_permanent`

Result:

- 4 rows found.
- Universes represented: `large_cap`, `mid_cap`, `small_cap`, `total_market`.
- `reconciliation_pass=true` for all four rows.
- `reconciliation_error=0.00000000000000` for all four rows.
- Realized alpha:
  - Total: `+0.43897pp`.
  - Large: `+0.24554pp`.
  - Mid: `+0.33381pp`.
  - Small: `+0.76032pp`.

The diagnostic slide uses the accepted formula:

```text
TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha
```

### Attribution Caveat

Result:

- In-slide caveat is present on the diagnostic/contribution slide.
- Evidence caveat is documented in `AE-PRES-INDEX-REV-005_test_attribution_caveat.md`.
- `SLIDE_DATA_SOURCES.md` row 27 identifies the diagnostic source as main-suite `period=test` attribution rather than standalone isolated `9_TestIndexConstruction` diagnostics.

### Source Map

Command:

```powershell
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\SLIDE_DATA_SOURCES.md -Pattern '^\| (26|27|56) \|'
```

Result:

- Row 26 maps `Permanent CSI Test-Set Index Results at 10 bps` to the isolated AE-FP-DIAG-006 test files.
- Row 27 maps `Permanent CSI Test-Set Diagnostic and Active Contribution` to the AE-ATTRIB main-suite period=test attribution files with caveat.
- Bibliography is row 56 after later rows were renumbered by +2.

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
git diff --name-only -- 01_Code 02_Data_Input 03_Data_Output 04_Research 07_CloudComputing
git status --short -- 01_Code 02_Data_Input 03_Data_Output 04_Research 07_CloudComputing
git diff --cached --name-only
```

Result:

- No tracked diffs under `01_Code`, `02_Data_Input`, `03_Data_Output`, `04_Research`, or `07_CloudComputing` from this ticket.
- Pre-existing unrelated untracked paths under `04_Research/` and `07_CloudComputing/Validation/AE-VALIDATE/` were not touched, staged, or committed for this ticket.
- Staged-path check covers the allowed Rnw file, source-map file, five ticket evidence files, and epic ledger only.
- No model training, model evaluation, index construction, sensitivity, pipeline, or presentation compilation commands were run.

## Acceptance Criteria

- Permanent CSI test-set result slide exists and is source-backed: passed.
- Permanent CSI test-set diagnostic/contribution slide exists and is source-backed with caveat: passed.
- Permanent CSI test rows use `period=test` and `transaction_cost_bps=10`: passed.
- All four universes are represented: passed.
- Attribution/contribution rows reconcile by the accepted attribution formula: passed.
- `SLIDE_DATA_SOURCES.md` has updated rows for the changed slides: passed.
- Frame balance passes: passed.
- Staged scope is limited to allowed areas: passed.

## Residual Risk

The full presentation was not compiled, per ticket instruction. Validation is source, scope, source-map, and frame-structure based.
