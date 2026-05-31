# AE-PRES-TC-CHECK-001 Evidence

## Scope

- Ticket executed: `AE-PRES-TC-CHECK-001`.
- Presentation source checked: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`.
- Source map checked/updated: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`.
- AEGIS reference loaded read-only from `C:/Users/Tristan Leiter/Documents/aegis-core`: `AEGIS.md`, swarm/ticket/epic contracts, master role, shared orchestration/apply-to-project runbooks, chart-worker role, ticket-scope-validation procedure, operating discipline, and transaction-cost execution reference.
- No model training, index construction, sensitivity generation, or `03_Data_Output/**` modification was run.

## Slide 21: Permanent CSI at 0 bps

Slide 21 uses the 0 bps OOS rows from `comparison/best_by_track_index_cost.csv` and model-specific `index_performance_gross_and_net_by_tc.csv` files.

| Universe | Benchmark display | Strategy display | Source strategy row | Delta policy |
|---|---:|---:|---|---|
| Total | 13.29% | 13.56% | `permanent_csi`, `raw_plus_latent`, `fpr5_permanent`, cost `0` | Strategy net return minus benchmark row |
| Large | 14.28% | 14.51% | `permanent_csi`, `raw_plus_latent`, `fpr5_permanent`, cost `0` | Strategy net return minus benchmark row |
| Mid | 9.65% | 10.39% | `permanent_csi`, `fund`, `fpr5_permanent`, cost `0` | Strategy net return minus benchmark row |
| Small | 7.65% | 7.98% | `permanent_csi`, `latent_raw`, `fpr3_permanent`, cost `0` | Strategy net return minus benchmark row |

Result: slide 21 is a true 0 bps table.

## Slide 22: Permanent CSI at 10 bps

Slide 22 strategy rows use 10 bps OOS net performance rows. Benchmark rows are intentionally held at the unfiltered 0 bps market-cap reference because the benchmark has no strategy cost overlay in the displayed comparison.

| Universe | Benchmark display | 10 bps strategy display | Source strategy row | Corrected delta vs unchanged benchmark |
|---|---:|---:|---|---:|
| Total | 13.29% | 13.55% | `permanent_csi`, `raw_plus_latent`, `fpr5_permanent`, cost `10` | +0.26pp |
| Large | 14.28% | 14.49% | `permanent_csi`, `raw_plus_latent`, `fpr5_permanent`, cost `10` | +0.22pp |
| Mid | 9.65% | 10.28% | `permanent_csi`, `fund`, `fpr5_permanent`, cost `10` | +0.62pp |
| Small | 7.65% | 7.90% | `permanent_csi`, `latent_raw`, `fpr3_permanent`, cost `10` | +0.24pp |

Result: slide 22 is not an accidental duplicate of slide 21. The values are visually close because 10 bps costs are small relative to annual returns, especially for Total and Large Cap.

## Gross Turnover Drag Check

Audited formula: expected annual drag at 10 bps is approximately `annualized gross turnover * 0.001`. Gross turnover is buy turnover plus sell turnover.

Source: `05_Documentation/09_Epics/AE-TC-AUDIT_Transaction_Cost_Audit/AE-TC-AUDIT-001_best_strategy_cost_drag_summary.csv`.

| Universe | Annualized gross turnover | Expected 10 bps drag | Observed 0-to-10 bps drop |
|---|---:|---:|---:|
| Total | 0.067995 | 0.000068 | 0.000076 |
| Large | 0.115137 | 0.000115 | 0.000129 |
| Mid | 1.062382 | 0.001062 | 0.001151 |
| Small | 0.757282 | 0.000757 | 0.000802 |

Result: observed annualized drops are consistent with audited gross buy-plus-sell turnover and 10 bps costs.

## Verification Commands

- `git status --short --branch`: confirmed branch `Development`; pre-existing unrelated dirty paths were present.
- `knitr::knit2pdf('FinalPresentation_TristanLeiter_h11815352.Rnw')`: passed and produced `FinalPresentation_TristanLeiter_h11815352.pdf`.
- Source-string check: passed for slide 22 benchmark rows, 10 bps strategy rows, corrected deltas, gross buy+sell wording, and annual-drag note.
- Generated TEX check: confirmed the compiled `FinalPresentation_TristanLeiter_h11815352.tex` contains the corrected slide 22 rows and gross buy+sell wording.
- `git diff --cached --name-only`: empty; no files are staged.

## Boundary Notes

- Did not edit `03_Data_Output/**`.
- Did not edit `07_CloudComputing/Validation/AE-VALIDATE/**`.
- Did not touch the deleted old `FinalPresentation` source.
- The June `.Rnw` had a pre-existing bootstrap-path hunk and adjacent transaction-cost wording changes in the working tree; these were preserved, not reverted.
- Compiling after the source edit updated the tracked June `.pdf` and `.tex` compile outputs.
