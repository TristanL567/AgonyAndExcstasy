# AE-PRES-JUNE-002 Dataset And Methodology Update Report

## Scope

Updated only the June final-presentation source:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

No model-result, index-result, sensitivity-result, or appendix-result slides were updated. The only index-construction edits are methodology/rule text on the score-to-portfolio and universe-methodology frames.

## Slides Updated

See `AE-PRES-JUNE-002_Changed_Slides.csv` for the full slide list.

The edited/added frames are:

- Dataset
- Methodology I: Response Variable Classification
- Applying the classification: Temporary CSI
- Applying the classification: Permanent CSI
- Methodology II: ``Temporary-CSI''
- Methodology III: ``Permanent-CSI''
- Modelling I: Setup and Feature Engineering
- Index Construction I: From Score to Portfolio Weight
- Index Construction II: Four Benchmark Universes

## Corrected Count Tables

Temporary CSI now reports the corrected full/train/test/OOS counts:

- Full: 188,460 observable rows; 171,269 y=0; 8,517 y=1; 8,674 y=NA; 179,786 labelled; 4.74% prevalence.
- Train/CV: 143,173 observable rows; 136,630 y=0; 6,543 y=1; 0 y=NA; 143,173 labelled; 4.57% prevalence.
- Test: 18,111 observable rows; 17,307 y=0; 804 y=1; 0 y=NA; 18,111 labelled; 4.44% prevalence.
- OOS: 27,176 observable rows; 17,332 y=0; 1,170 y=1; 8,674 y=NA; 18,502 labelled; 6.32% prevalence.

Permanent CSI now reports the corrected full/train/test/OOS counts:

- Full: 188,460 observable rows; 181,368 y=0; 6,258 y=1; 834 y=NA; 187,626 labelled; 3.34% prevalence.
- Train/CV: 143,173 observable rows; 137,794 y=0; 5,379 y=1; 0 y=NA; 143,173 labelled; 3.76% prevalence.
- Test: 18,111 observable rows; 17,511 y=0; 542 y=1; 58 y=NA; 18,053 labelled; 3.00% prevalence.
- OOS: 27,176 observable rows; 26,063 y=0; 337 y=1; 776 y=NA; 26,400 labelled; 1.28% prevalence.

## Methodology Corrections

- Observable scaffold means required CRSP monthly return and market-cap scaffold are present.
- y=NA rows are retained as observable firm-years and excluded from supervised training/evaluation metrics.
- Temporary CSI uses the accepted positive event statuses and terminal-failure route.
- Temporary CSI marks censored triggers plus unavailable 2025 event-year labels as y=NA.
- Permanent CSI uses event-window-only unresolved PCL windows as y=NA.
- Permanent CSI does not use broad no-trigger calendar censoring.
- Model-family setup now names the final feature keys: `raw`, `fund`, `latent_raw`, and `raw_plus_latent`.
- Index-construction methodology now names Youden/FPR1/FPR3/FPR5 thresholds and 0/5/10/20 bps cost overlays without changing result slides.

## Layout Risk

No full compile was run in this ticket. A new permanent-CSI count slide was added rather than crowding temporary and permanent counts into one frame. The main residual layout risk is minor: the updated feature-set labels in the modelling-setup TikZ frame are longer than the May labels and should be visually checked in AE-PRES-JUNE-007.
