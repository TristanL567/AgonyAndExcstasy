# AE-PRES-ATTRIB-001 Slide Update Report

## Scope
AE-PRES-ATTRIB-001 added realized active attribution slides immediately after the existing diagnostic error-cost slides in the June final presentation.

## Branch and inputs
- Branch: Development
- Attribution source: `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- Reconciliation source: `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- Report source: `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_Main_Index_Attribution_Report.md`

## Slide changes
- Inserted `Temporary CSI: Realized Active Attribution` directly after `Temporary CSI: Error-Cost Diagnostic`.
- Inserted `Permanent CSI: Realized Active Attribution` directly after `Permanent CSI: Error-Cost Diagnostic`.
- Updated `SLIDE_DATA_SOURCES.md` with two new source-map rows and renumbered later rows.

## Attribution framework
The new slides use realized active attribution from AE-ATTRIB-001:

`TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha`

TP and FP are direct exclusion effects. FN and TN are not direct realized-alpha columns; they are diagnostic labels and affect realized alpha indirectly through retained-stock reweighting when the remaining portfolio is reweighted.

## Displayed rows
Rows were selected to match the adjacent headline/error-cost strategy rows for OOS results at 10 bps:

- Temporary CSI: total market, large cap, mid cap, small cap.
- Permanent CSI: total market, large cap, mid cap, small cap.

Displayed values are percentage-point rounded. In a few rows the displayed geometric adjustment was rounded to preserve visible row-level reconciliation on the slide.

## Validation summary
- Protected paths were not edited.
- No model, index, sensitivity, or pipeline scripts were run.
- Source-map entries point to AE-ATTRIB-001 evidence files.
- Deck compile and visual QA results are recorded in `AE-PRES-ATTRIB-001_validation_checks.csv` after validation.

## Compile and visual QA
- Compile workflow: knitr, then two `pdflatex` passes.
- Final PDF: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.pdf`.
- Page count: 55.
- Visual QA rendered pages 20 through 26 under `05_Documentation/09_Epics/AE-PRES-ATTRIB_Realized_Attribution_Slides/visual_qa/`.
- Visual QA result: pass. New slides 21 and 25 are readable and adjacent diagnostic slides 20 and 24 remain intact.

## Rounding note
The exact AE-ATTRIB-001 source values reconcile in decimal-return units. Slide values are displayed in percentage points; geometric-adjustment display values were rounded for visible row-level reconciliation in the slide table.
