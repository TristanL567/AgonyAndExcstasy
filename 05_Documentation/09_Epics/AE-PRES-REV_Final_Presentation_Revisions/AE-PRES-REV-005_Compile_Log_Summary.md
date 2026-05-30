# AE-PRES-REV-005 Compile Log Summary

## Commands Run

Working directory for LaTeX passes:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June`

Commands:

1. `& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "setwd('C:/Users/Tristan Leiter/Documents/AgonyAndExcstasy/06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June'); knitr::knit('FinalPresentation_TristanLeiter_h11815352.Rnw', output='FinalPresentation_TristanLeiter_h11815352.tex')"`
2. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`
3. `bibtex FinalPresentation_TristanLeiter_h11815352`
4. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`
5. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`

The sequence was repeated after scoped layout fixes.

## Result

- `knitr::knit()` succeeded and wrote `FinalPresentation_TristanLeiter_h11815352.tex`.
- BibTeX succeeded and read `references.bib`.
- Final pdflatex pass succeeded.
- Output: `FinalPresentation_TristanLeiter_h11815352.pdf`
- Page count: 48
- PDF size: 483,868 bytes

## Log Checks

No fatal compile errors were found for:

- `Fatal error`
- `Emergency stop`
- `Undefined control sequence`
- citation warnings
- unresolved cross-reference rerun warnings

Remaining LaTeX warnings are compact-table font/overfull warnings. Visual QA confirmed the required inspected tables and slides are readable and not cut off.

MiKTeX emitted private `log4cxx` log-write warnings after successful commands. These did not block output generation.
