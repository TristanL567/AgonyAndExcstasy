# AE-PRES-INDEX-REV-003 Validation Report

## Validator Decision

Status: approved.

The blocking validator accepts the `AE-PRES-INDEX-REV-003` slide update for scoped commit.

## Checks Run

### Result Rows

Command:

```powershell
Import-Csv 03_Data_Output\9_TestIndexConstruction\AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv
```

Filters checked:

- `track=dynamic_csi`
- `period=test`
- `transaction_cost_bps=10`
- universes `total_market`, `large_cap`, `mid_cap`, `small_cap`
- benchmark rows `strategy_id=bench_mw`
- best non-benchmark rows by `net_difference_versus_benchmark`

Result:

- Total: best row `raw_plus_latent`, `youden_3yr`, `period=test`, `transaction_cost_bps=10`.
- Large: best row `raw_plus_latent`, `youden_3yr`, `period=test`, `transaction_cost_bps=10`.
- Mid: best row `raw`, `youden_5yr`, `period=test`, `transaction_cost_bps=10`.
- Small: best row `raw_plus_latent`, `youden_2yr`, `period=test`, `transaction_cost_bps=10`.
- Benchmark rows are duplicated by source model family in the isolated file, but each universe has one unique benchmark net return; the slide displays the shared benchmark value once per universe.

### Attribution Rows

Command:

```powershell
Import-Csv 05_Documentation\09_Epics\AE-ATTRIB_Main_Index_Attribution\AE-ATTRIB-001_config_level_attribution.csv
```

Filters checked:

- `track=temporary CSI`
- `period=test`
- `transaction_cost_bps=10`
- selected rows matching the result-slide winners

Result:

- Total `raw_plus_latent`, Youden/3yr: 1 row, `reconciliation_pass=true`.
- Large `raw_plus_latent`, Youden/3yr: 1 row, `reconciliation_pass=true`.
- Mid `raw`, Youden/5yr: 1 row, `reconciliation_pass=true`.
- Small `raw_plus_latent`, Youden/2yr: 1 row, `reconciliation_pass=true`.

### Caveat And Overclaim Review

Commands:

```powershell
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern 'Temporary CSI Test-Set|standalone AE-FP-DIAG-006|period=test|period=oos'
Select-String -LiteralPath 06_Presentations\02_FinalPresentation\Necessary\FinalPresentation_June\SLIDE_DATA_SOURCES.md -Pattern '^\| (20|21|22|23|56) \|'
```

Result:

- Result slide states isolated 2016--2019 test rows and zero OOS rows.
- Diagnostic slide states it is not a standalone AE-FP-DIAG-006 test diagnostic build and uses main-suite `period=test` attribution.
- The test diagnostic interpretation avoids direct causal event-avoidance claims and frames contribution terms conservatively.
- `SLIDE_DATA_SOURCES.md` rows 20 and 21 point to exact result and attribution source files.
- OOS references found by search are in the explicit test-versus-OOS caveat or in the following OOS slides, not in displayed test values.

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

- No tracked diffs under `01_Code`, `02_Data_Input`, `03_Data_Output`, or `07_CloudComputing`.
- `07_CloudComputing/Validation/AE-VALIDATE/` remains an unrelated pre-existing untracked path and was not touched, staged, or committed for this ticket.
- Staged-path check covered eight files; all staged files are inside allowed areas and none are under must-not-touch prefixes.
- The reusable AEGIS `validate_ticket_scope.py --staged` helper was attempted, but it expects Markdown YAML front matter and rejected this repository's plain `.yaml` ticket envelope. The staged-path check above was therefore performed directly against the ticket's declared allowed and protected prefixes.
- No data-generating, model training, model evaluation, index construction, sensitivity, pipeline, or regeneration scripts were run.

## Acceptance Criteria

- Changed slides use temporary-CSI test sources only: passed.
- Result table uses isolated test-output files where available: passed.
- Diagnostic/contribution slide using main-suite `period=test` rows states the source caveat: passed.
- No OOS values are used as test values: passed.
- 10 bps strategy rows are used: passed.
- Benchmark rows are handled consistently: passed.
- Source-map rows point to exact files: passed.
- No `03_Data_Output/**` files were modified, staged, or committed: passed.
- No code/input/cloud files were modified by this ticket: passed.
- Slide text avoids overclaiming where test attribution provenance is partial: passed.

## Residual Risk

The deck was not fully compiled as part of this ticket. Validation is source and structure based. The existing dirty generated `.tex`, `.pdf`, and `.bbl` files in the June presentation folder were left untouched and are not part of the ticket commit.
