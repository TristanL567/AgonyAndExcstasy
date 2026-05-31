# AE-PRES-FINAL-REV2-003 Model Label Cleanup Evidence

## Scope

Cleaned user-facing model/dataset labels in the June final presentation source, especially slide 25, without editing model scripts, data, index outputs, sensitivity scripts, or `03_Data_Output`.

## Label replacements

| Technical key previously shown | Accepted display label used |
|---|---|
| `raw` | AG Expanded Dataset where shown as an AutoGluon model row; Expanded Dataset in generic dataset context |
| `fund` | AG Base Dataset |
| `latent_raw` | AG Latent Dataset (VAE) |
| `raw_plus_latent` | AG Exp. Dataset + VAE |

## Edited presentation areas

- Slide 18 signal-discipline bullet now lists the accepted AG dataset names instead of technical score keys.
- Slide 25 transaction-cost robustness table now uses AG dataset labels for both 0 bps and 20 bps winner columns.
- Appendix A13 final-grid model list now uses accepted display labels and keeps the XGB caveat source-backed.
- Appendix A14 and A16 winner tables now use accepted AG dataset labels instead of technical keys.
- Appendix A15 source-path navigation describes selected error-cost files by accepted AG dataset labels.
- `SLIDE_DATA_SOURCES.md` row 42 now records the accepted display labels while preserving technical source paths.

## Validation

- `rg -n "texttt\\{(raw|fund|latent\\\\_raw|raw\\\\_plus\\\\_latent)\\}|raw_plus_latent|latent_raw|\\bfund\\b|\\braw\\b" 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw` returned no remaining technical-key table labels; remaining hits are prose uses of raw/non-raw or source-path references, not slide-25 winner labels.
- `rg -n "raw_plus_latent|latent_raw|\\bfund\\b|\\braw\\b" 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md` shows technical keys only inside source file paths or data-source references; row 42 now uses accepted display labels.
- Rebuilt `FinalPresentation_TristanLeiter_h11815352.pdf` from the June `.Rnw` source with `knitr::knit2pdf`.
- Rendered slide 25 from the rebuilt PDF and visually confirmed the table uses AG Base Dataset, AG Exp. Dataset + VAE, and AG Latent Dataset (VAE) without overflow.
- Extracted slide 25 text from the rebuilt PDF and confirmed the visible winner labels use accepted AG names, not technical keys.
- No XGB labels were introduced.
