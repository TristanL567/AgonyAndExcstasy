# AE-PRES-INDEX-REV-007R Temporary Test Insert Report

## Scope

- Epic: AE-PRES-INDEX-REV
- Ticket: AE-PRES-INDEX-REV-007R
- Branch: development-slides
- Timestamp: 2026-06-06T21:28:05+02:00

This repair inserted the Temporary CSI test-set 10 bps block immediately after the current slide 23 in the June final presentation source. The existing OOS and permanent CSI slides were not removed.

## AEGIS materials loaded

- `C:/Users/Tristan Leiter/Documents/aegis-core/AEGIS.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/epic-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/ticket-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/swarm-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/execution/runbooks/multi-master-dispatch.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/master/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/code-validator/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/procedures/ticket-scope-validation/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/procedures/clean-commit/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/execution/runbooks/clean-commit.md`

No active AEGIS presentation/source-map-specific skill contract was found. The repair follows the local presentation/source-map pattern established by earlier AE-PRES-INDEX-REV tickets.

## Inserted slides

Inserted immediately after slide 23:

1. Slide 24: `Temporary CSI Test-Set Index Results at 10 bps`
2. Slide 25: `Temporary CSI Test Diagnostic and Active Contribution`

The result slide uses isolated 2016--2019 test-set rows at `period=test` and `transaction_cost_bps=10`, includes benchmark and best-strategy rows, and covers Total, Large, Mid, and Small.

The diagnostic/contribution slide uses reconciled AE-ATTRIB main-suite `period=test` attribution rows for the same selected temporary-CSI strategies. The provenance caveat is visible on-slide and recorded separately in `AE-PRES-INDEX-REV-007R_test_attribution_caveat.md`.

## Source-map update

`SLIDE_DATA_SOURCES.md` was updated as follows:

- inserted row 24 for the Temporary CSI test-set result slide;
- inserted row 25 for the Temporary CSI test diagnostic/contribution slide;
- renumbered prior rows 24--56 to 26--58.

Final source-map row count after repair: 58.

## Compile and visual QA

The deck was compiled to an allowed evidence directory, not to the tracked presentation PDF/TeX outputs:

`05_Documentation/09_Epics/AE-PRES-INDEX-REV_Index_Presentation_Revisions/AE-PRES-INDEX-REV-007R_compile_qa/`

Temporary compile status: pass.

Temporary compile page count: 58.

Visual QA rendered and inspected pages 23--26:

- page 23: Temporary CSI OOS Diagnostic and Active Contribution
- page 24: Temporary CSI Test-Set Index Results at 10 bps
- page 25: Temporary CSI Test Diagnostic and Active Contribution
- page 26: Permanent CSI OOS Index Results at 10 bps

Visual QA result: pass. The inserted slides are readable and not clipped; surrounding slides remain intact.

## Scope note

The allowed presentation writes for this ticket are limited to the Rnw source and source map. Therefore the tracked final PDF/TeX outputs were not updated in this repair commit. A closeout refresh should follow this repair so final artifact counts supersede the earlier AE-PRES-INDEX-REV-008 56-page closeout evidence.
