# AE-FP-DIAG-006 Test-Set Index Construction Report

## Scope

This ticket validates and materializes test-set-only index-construction result
tables separate from OOS. It does not edit production index-construction code,
canonical index-construction outputs, input data, slide files, or cloud
validation artifacts.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\apply-to-project.md`

## Availability Finding

Separate test rows already existed inside the canonical
`index_performance_gross_and_net_by_tc.csv` files as `period = test`, but no
ticket-owned, isolated test-set package existed under
`03_Data_Output/9_TestIndexConstruction/` before this ticket.

The worker therefore copied only test-set slices into the ticket-owned output
area and left canonical output files unchanged.

## Outputs Created

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_returns_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_weights_summary_by_config.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_source_manifest.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`

## Coverage

| track | model | role | performance rows | model rows | benchmark rows | universes | thresholds | transaction costs | lockouts | months | OOS rows |
|---|---|---|---:|---:|---:|---|---|---|---|---:|---:|
| Temporary CSI | raw+latent | main non-raw | 272 | 256 | 16 | large, mid, small, total | fpr1, fpr3, fpr5, youden | 0, 5, 10, 20 bps | 1, 2, 3, 5 years | 48 | 0 |
| Temporary CSI | raw | raw comparator | 272 | 256 | 16 | large, mid, small, total | fpr1, fpr3, fpr5, youden | 0, 5, 10, 20 bps | 1, 2, 3, 5 years | 48 | 0 |
| Permanent CSI | raw+latent | main non-raw | 80 | 64 | 16 | large, mid, small, total | fpr1, fpr3, fpr5, youden | 0, 5, 10, 20 bps | permanent removal | 48 | 0 |
| Permanent CSI | raw | raw comparator | 80 | 64 | 16 | large, mid, small, total | fpr1, fpr3, fpr5, youden | 0, 5, 10, 20 bps | permanent removal | 48 | 0 |

The isolated return table contains 33,792 rows for years 2016 through 2019.
The compact holdings summary contains 704 grouped rows for holding years 2016
through 2019. Row-level holdings were intentionally summarized rather than
retained because the isolated row-level holdings file would be about 1.9 GB and
is not necessary for presentation or validation.

## OOS Exclusion Evidence

- Performance table: all rows have `period = test`; OOS period rows = `0`.
- Return table: years are `2016|2017|2018|2019`; rows with year >= 2020 = `0`.
- Holdings summary: holding years are `2016|2017|2018|2019`; rows with holding
  year >= 2020 = `0`.
- Validation checks: all 36 checks in
  `AE-FP-DIAG-006_validation_checks.csv` pass.

## Manual Checkpoint

The ticket envelope marks manual verification as required:

> Human/planner confirms whether generated test-set index tables should be added
> to presentation slides in ticket 007.

This report provides the generated test-set-only tables for that decision. No
slide files were edited in this ticket.

## Worker Completion Report

status: completed

summary: Internal data worker found that canonical index performance files
already carried separate `period = test` rows. It created ticket-owned isolated
test-set performance and return tables, a compact holdings summary, grid
summary, source manifest, and validation checks under
`03_Data_Output/9_TestIndexConstruction/`.

artifacts:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_returns_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_weights_summary_by_config.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_source_manifest.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-006_Test_Set_Index_Construction_Report.md`

findings:

- No blocker for test-set performance and return reporting.
- Row-level holdings were summarized, not retained, due size; the summary still
  validates test holding-year coverage and OOS exclusion.
- Manual planner/human decision remains for AE-FP-DIAG-007: whether and how to
  add the generated test-set tables to slides.

next_recommended_role: validator

changed_files:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_returns_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_weights_summary_by_config.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_source_manifest.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-006_Test_Set_Index_Construction_Report.md`
- `epics/AE-FP-DIAG/ledger.md`

verification:

- `git status --short`
- `git diff --name-only`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds isolated test-set index result tables, compact holdings
  summary, manifest, validation checks, and a concise availability/creation
  report.
- layer_touched: diagnostics
- layer_separation_preserved: true
