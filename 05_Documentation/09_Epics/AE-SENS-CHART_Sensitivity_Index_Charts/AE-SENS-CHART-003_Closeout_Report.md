# AE-SENS-CHART-003 Closeout Report

## Scope

AE-SENS-CHART-003 is a documentation and evidence-only closeout for the sensitivity chart epic. No presentation files, data outputs, code, model outputs, index outputs, or sensitivity outputs were modified in this ticket.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `09b23cd`
- Prior pushed integration commit: `09b23cd AE-SENS-CHART-002: integrate sensitivity stability charts`

## Ticket Completion Checklist

| Ticket | Status | Evidence |
|---|---|---|
| AE-SENS-CHART-001 | Complete | Drafted sensitivity stability charts, chart source map, validation checks, and supporting tables. |
| AE-SENS-CHART-001R | Complete | Refined Chart 2 and recorded interpretation in `AE-SENS-CHART-001R_Chart_Interpretation.md`. |
| AE-SENS-CHART-002 | Complete | Integrated approved charts into the June final presentation and compiled a 50-page PDF. |
| AE-SENS-CHART-003 | Complete | This closeout report, validation checks, and slide traceability close the epic. |

## Final Deck Files

All required final deck files exist:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.pdf`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

Final counts:

- PDF pages: 50
- Rnw active frames: 50
- Source-map rows: 50

## Final Slide And Chart Placement

| Slide | Frame title | Placement | Chart |
|---:|---|---|---|
| 27 | Sensitivity: Main Run Versus C/M/T Grid | Main section, immediately after the main index-construction results and interpretation block | `charts/chart1_sensitivity_stability_distribution.png` |
| 30 | Appendix: Model AP Versus Index Alpha | Appendix / backup, after the temporary CSI sensitivity detail frame | `charts/chart2_model_vs_index_sensitivity_scatter_refined.png` |

## Final Robustness Interpretation

The closed chart epic supports these final messages:

- The accepted main run is not an outlier in the completed temporary-CSI C/M/T sensitivity grid.
- The main run is below the median for Total Market and Large Cap, and above the median for Mid Cap and Small Cap.
- Sensitivity changes magnitude more than direction across universes.
- AP and index alpha are related but not identical objectives.
- The sensitivity results are robustness evidence, not a replacement for the headline accepted configuration.

## Source Traceability Summary

The source map contains rows for both added chart slides:

- Slide 27 maps to `chart1_sensitivity_stability_distribution.png`, `universe_stability_summary.csv`, `sensitivity_index_stability_table.csv`, and `AE-SENS-CHART-001R_Chart_Interpretation.md`.
- Slide 30 maps to `chart2_model_vs_index_sensitivity_scatter_refined.png`, local sensitivity presentation-ready summaries, and `AE-SENS-CHART-001R_Chart_Interpretation.md`.

The chart files, supporting tables, and interpretation report exist under:

- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/`

## Residual Limitations

- Scope is temporary CSI only.
- Three C/M/T configurations remain `blocked_partial`: `C080_M000_T012`, `C080_M000_T018`, and `C060_M020_T028`.
- Permanent-CSI sensitivity remains future work and is not presented as completed.
- The sensitivity grid is a robustness layer and remains separate from the accepted-label AE-INDEX-SUITE full index grid.

## Scope Hygiene

- No `03_Data_Output/**` files were modified, staged, or committed in this ticket.
- No model training, index construction, sensitivity scripts, Vast.ai, or SSH were used.
- Known unrelated dirty files remain unstaged and untouched.

## Closeout Status

AE-SENS-CHART is closed.
