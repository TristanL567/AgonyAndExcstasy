# AE-PRES-JUNE-007 Compile Log Summary

## Final Build Result

Final build status: PASS.

Final PDF:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.pdf`

## Commands

| Step | Command family | Result |
|---:|---|---|
| 1 | `knitr::knit` | PASS |
| 2 | `pdflatex` initial pass | PASS |
| 3 | `bibtex` | PASS |
| 4 | `pdflatex` citation pass | PASS |
| 5 | `pdflatex` final pass | PASS |

## Final Log Checks

| Check | Result |
|---|---:|
| PDF pages | 44 |
| Fatal errors | 0 |
| Emergency stops | 0 |
| LaTeX errors | 0 |
| Undefined citation warnings after final pass | 0 |
| Rerun warnings after final pass | 0 |
| Overfull hbox warning count | 101 |
| Maximum overfull hbox | 24.18102 pt |

## Notes

MiKTeX emitted `log4cxx` warnings because it could not write user-level tool logs under `AppData` in the sandboxed execution context. These warnings did not prevent local PDF/log generation in the presentation folder and all compile commands used for the final build exited successfully.

Remaining overfull warnings are nonfatal and are associated with compact numeric tables or monospace labels. Visual QA did not find a remaining blocking cutoff after the Appendix A18 source-path fix.

