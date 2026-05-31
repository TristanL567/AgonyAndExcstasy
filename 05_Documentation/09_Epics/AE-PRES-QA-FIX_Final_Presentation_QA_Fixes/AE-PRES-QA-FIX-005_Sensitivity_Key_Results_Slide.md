# AE-PRES-QA-FIX-005 Sensitivity Key Results Slide

## Scope

Ticket AE-PRES-QA-FIX-005 updated the June final presentation sensitivity chart slide. No sensitivity, model, index, or data scripts were run.

## Slide Update

The existing slide after the threshold-family/turnover slide, `Sensitivity: Main Run Versus C/M/T Grid`, now contains:

- Chart 1: `chart1_sensitivity_stability_distribution.png`
- A compact key-results table by universe.
- The required message that the accepted main run is inside the completed-run distribution, not an outlier.
- The interpretation that sensitivity changes magnitude more than direction.

## Key Table Values

Values are benchmark-relative geometric return deltas in percentage points, sourced from `universe_stability_summary.csv`.

| Universe | Runs | Main | Median | Range |
|---|---:|---:|---:|---:|
| Total | 24 | 0.06 | 0.10 | 0.02--0.23 |
| Large | 24 | 0.04 | 0.07 | 0.02--0.19 |
| Mid | 24 | 0.18 | 0.13 | 0.03--0.33 |
| Small | 24 | 0.38 | 0.18 | 0.03--0.66 |

## Source Map

`SLIDE_DATA_SOURCES.md` row 28 was updated to document the chart, table source, and blocked-config caveat.

## Scope Hygiene

No files under `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` were modified.
