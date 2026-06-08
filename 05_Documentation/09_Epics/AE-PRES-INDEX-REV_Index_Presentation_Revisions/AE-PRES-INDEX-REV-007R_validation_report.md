# AE-PRES-INDEX-REV-007R Validation Report

## Validator approval

Status: approved for scoped commit.

Validator approval is blocking for this repair ticket. The checks below were completed before staging and commit.

## Checks

| Check | Status | Evidence |
|---|---|---|
| Two Temporary CSI test slides inserted immediately after slide 23 | Pass | PDF text extraction shows slide 23 OOS diagnostic, slide 24 Temporary CSI test result, slide 25 Temporary CSI test diagnostic, slide 26 Permanent CSI OOS. |
| Test result rows use `period=test` and `transaction_cost_bps=10` | Pass | On-slide test-set check, source-map row 24, and source traceability record the filters. |
| Total, Large, Mid, Small represented | Pass | Inserted result and diagnostic tables include all four universes. |
| Attribution/contribution rows reconcile or use accepted formula | Pass | Inserted diagnostic slide uses the accepted TP gain + FP cost + reweighting + TC + geo adjustment formula; rows reconcile to displayed alpha within rounding. |
| Main-suite `period=test` attribution caveat visible on-slide and in evidence | Pass | Slide 25 contains the attribution caveat; `AE-PRES-INDEX-REV-007R_test_attribution_caveat.md` records it. |
| `SLIDE_DATA_SOURCES.md` updated and aligned | Pass | Source-map rows increased from 56 to 58; rows 24--25 inserted and prior rows shifted. |
| Rnw frame balance | Pass | 58 `\begin{frame}` markers and 58 `\end{frame}` markers. |
| Temporary compile | Pass | Compiled to `AE-PRES-INDEX-REV-007R_compile_qa` with 58 pages. |
| Visual QA | Pass | Rendered and inspected pages 23--26; no clipping or ordering issue found. |
| Forbidden scripts | Pass | No model, index, evaluation, sensitivity, or pipeline scripts were run. |
| Staged scope limited to allowed areas | Pass | Staged paths are limited to the Rnw, source map, 007R evidence, ticket YAML, and ledger. |

## Non-blocking notes

- The first compile attempt to `C:\tmp` failed because the sandbox could not write the requested directory and TeX interpreted a backslash path as control sequences. The successful compile used the allowed epic evidence directory with forward-slash paths.
- MiKTeX emitted non-blocking local user-log write warnings.
- The tracked final PDF/TeX outputs were not updated because they are outside this ticket's allowed write list.
