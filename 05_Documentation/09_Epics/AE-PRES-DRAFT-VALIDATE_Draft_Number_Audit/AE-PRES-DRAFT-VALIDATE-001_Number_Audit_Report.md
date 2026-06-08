# AE-PRES-DRAFT-VALIDATE-001 Number Audit Report

## Ticket

- Epic: AE-PRES-DRAFT-VALIDATE
- Ticket: AE-PRES-DRAFT-VALIDATE-001
- Branch: development-slides
- Timestamp: 2026-06-07T16:36:32+02:00
- Target: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/Draft`

## AEGIS materials loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\multi-master-dispatch.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\code-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\clean-commit\SKILL.md`

No dedicated AEGIS presentation/source-map validation role or skill contract was found in `aegis-core`; the audit used the explicit ticket requirements plus the general AEGIS validator and scope procedures.

## Scope and method

No presentation files were edited and the Draft deck was not compiled. The audit inspected the Draft Rnw/PDF/TeX read-only, extracted slide titles, and cross-checked displayed values against source CSVs under `03_Data_Output`, `05_Documentation/09_Epics`, and `07_CloudComputing/Validation`.

The Draft PDF reports 53 pages. The Draft Rnw contains 52 frames. Numeric slide references in this report use the visible Draft PDF footer/page number, so the highest-priority slide 25 is:

`Impact of transaction costs: the winners are unchanged`

## Slide 25 conclusion

Slide 25 is valid for the audited numeric claims.

All displayed active-alpha values at 5/10/20 bps match `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv` under rounding. The `unchanged` ranking claim is supported by the same file and by `final_tables/transaction_cost_robustness_summary.csv`, where winner-change flags are false for the selected temporary and permanent OOS winner rows.

The only caveat is labeling: the slide calls the values `Active alpha`, while the source field is `net_difference_versus_benchmark`. That is acceptable if the deck consistently defines active alpha as benchmark-relative annualized geometric return difference.

## Mismatches and stale-value findings

The high-priority slide 25 passed, but the surrounding Draft slides include stale or mixed numeric content:

- Slide 21, Temporary-CSI OOS: Total and Large mostly match, but displayed alpha is stale by rounding convention (`+0.42` vs source `+0.43`; `+0.14` vs source `+0.15`). Mid and Small have larger stale values: source is Mid `9.5 -> 10.0`, `+0.51`, not displayed `9.7 -> 10.1`, `+0.39`; source is Small `7.6 -> 8.2`, `+0.63`, not displayed `7.7 -> 8.2`, `+0.55`.
- Slide 22, Permanent-CSI OOS: several displayed values are stale. Source is Mid `+0.74`, not `+0.62`; Small `+0.32`, not `+0.24`; Large `+0.23`, not `+0.22`; Total rounds closer to `+0.27`, not `+0.26`.
- Slide 28, Sensitivity: the slide text says the range plot is across `permanent-CSI` iterations, but the source tables are temporary-CSI sensitivity outputs. The numeric ranges match the temporary-CSI source, not permanent CSI. This is a material wording/source-support mismatch.
- Slide 20 mixes result claims from different later slides. The OOS bar values inherit the stale OOS deltas noted for slides 21-22, while the `Test Total Sharpe 0.89 -> 1.00` claim matches the Permanent-CSI test slide rather than the temporary test values implied by the adjacent bar legend.

## Checked slides

Slides 20-28 were audited. Detailed per-value classifications are in:

- `AE-PRES-DRAFT-VALIDATE-001_slide_number_checks.csv`
- `AE-PRES-DRAFT-VALIDATE-001_slide25_deep_dive.csv`

Lower-priority slides outside 20-28 were not audited in this ticket.

## Source files used

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/transaction_cost_robustness_summary.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/transaction_cost_impact.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/threshold_family_summary_20bps.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/universe_stability_summary.csv`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/sensitivity_index_stability_table.csv`

## Validation summary

- Presentation files modified: no.
- `03_Data_Output/**` modified: no.
- Forbidden scripts run: no.
- Deck compile run: no.
- Slide 25 deep dive completed: yes.
- All checked rows include displayed value, source value, source path, and status: yes.
