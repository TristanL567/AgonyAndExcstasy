# AE-PRES-JUNE-007 Compile And Visual QA Report

## Status

PASS.

The June final presentation was compiled from the Sweave/Beamer source and visually checked. The generated PDF is:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.pdf`

## Compile Workflow

Commands run from `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/`:

1. `Rscript -e "knitr::knit('FinalPresentation_TristanLeiter_h11815352.Rnw', output='FinalPresentation_TristanLeiter_h11815352.tex')"`
2. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`
3. `bibtex FinalPresentation_TristanLeiter_h11815352`
4. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`
5. `pdflatex -interaction=nonstopmode -halt-on-error FinalPresentation_TristanLeiter_h11815352.tex`

`latexmk` was attempted first, but MiKTeX could not write its user-level log file in the sandboxed app context. The explicit `pdflatex`/`bibtex` sequence completed successfully and produced the final PDF.

## Output

- PDF pages: 44
- Active frames in source: 44
- PDF size: 468,610 bytes
- Unresolved `??` placeholders in extracted PDF text: 0
- Fatal LaTeX errors: 0
- Undefined citation warnings after final pass: 0

## Visual QA

Rendered QA images were created under:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/visual_qa/`

Selected pages inspected covered title, dataset, sensitivity, model results, index results, transaction-cost, threshold/turnover, source-path appendix, future-work appendix, audit-map appendix, and bibliography pages.

One blocking visual issue was found and fixed:

- Appendix A18 source paths ran off the right edge.
- Fix: rewrote that slide to use a shared base folder plus shorter relative filenames.

One readability improvement was also made:

- The threshold-family table on the main threshold/turnover slide had a dense interpretation column.
- Fix: moved interpretation into a short paragraph below the table.

Remaining log warnings are small table overfull boxes, mostly from compact numeric tables and monospace model/config labels. The inspected rendered pages remain readable and no key table appears cut off.

## Source Map

`SLIDE_DATA_SOURCES.md` still covers all 44 active frames. All exact source paths referenced in the map resolve locally.

## Scope

Changed presentation files are limited to the June deck source and generated PDF/TEX artifacts. No data outputs, model scripts, index scripts, sensitivity scripts, or old `FinalPresentation/**` files were modified.

