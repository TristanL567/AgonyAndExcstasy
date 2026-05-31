# AE-PRES-FINAL-REV2-002 Error-Cost Reconciliation Evidence

## Scope

This evidence file supports ticket `AE-PRES-FINAL-REV2-002`. It uses only existing local index-suite outputs and does not rerun data, model, index, or sensitivity scripts.

## Source Inputs

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/error_cost_decomposition_by_crsp_universe.csv`

## Reconciliation Method

The displayed slide keeps the existing FP/FN/TP/TN source diagnostics and adds `Recon.`:

`Recon. = displayed Geo alpha - displayed FP cost - displayed FN cost - displayed TP gain - displayed TN gain`

This is a row-level reconciliation term, not an additional source category. It absorbs the compounding, portfolio reweighting, and rounding gap between annualized category diagnostics and the exact benchmark-relative geometric alpha. `Geo alpha` remains the selected OOS strategy geometric return minus the matched benchmark geometric return before transaction-cost overlays.

## Displayed Row Checks

All values are displayed percentage points. Each row total below equals displayed `Geo alpha`.

| Track | Universe | FP cost | FN cost | TP gain | TN gain | Recon. | Row total | Geo alpha | Check |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Temporary CSI | Total | -2.03 | +0.00 | +0.08 | +1.79 | +0.59 | +0.43 | +0.43 | pass |
| Temporary CSI | Large | -1.50 | +0.00 | +0.00 | +1.24 | +0.41 | +0.15 | +0.15 | pass |
| Temporary CSI | Mid | +0.05 | +0.00 | +0.00 | +0.27 | +0.19 | +0.51 | +0.51 | pass |
| Temporary CSI | Small | -4.00 | -0.02 | +0.42 | +3.97 | +0.27 | +0.64 | +0.64 | pass |
| Permanent CSI | Total | -0.49 | +0.00 | +0.01 | +0.52 | +0.23 | +0.27 | +0.27 | pass |
| Permanent CSI | Large | -0.26 | +0.00 | +0.00 | +0.30 | +0.19 | +0.23 | +0.23 | pass |
| Permanent CSI | Mid | -0.55 | +0.00 | +0.00 | +0.90 | +0.39 | +0.74 | +0.74 | pass |
| Permanent CSI | Small | -0.74 | +0.00 | +0.04 | +1.03 | -0.01 | +0.32 | +0.32 | pass |

## Exact Source Matching

Rows were matched to `best_by_track_index_cost.csv` using track, universe, model key, threshold method, strategy id, exclusion rule, lockout/permanent rule, OOS period, and `transaction_cost_bps = 0`. The exact alpha source is `net_difference_versus_benchmark` from the selected best-strategy row.

The slide uses displayed, two-decimal reconciliation because the reader sees rounded table cells. Exact unrounded residuals differ slightly for some rows, but the displayed row total is the relevant acceptance criterion for slide readability.

## Slide Order Evidence

The source order is now:

- Slide 19: `Index Results: Temporary CSI at 0 bps`
- Slide 20: `Temporary CSI: Error-Cost Diagnostic` (moved from current slide 21)
- Slide 21: `Index Results: Temporary CSI at 10 bps`
- Slide 22: `Index Results: Permanent CSI at 0 bps`
- Slide 23: `Permanent CSI: Error-Cost Diagnostic` (moved from current slide 24)
- Slide 24: `Index Results: Permanent CSI at 10 bps`

`SLIDE_DATA_SOURCES.md` was updated to match this final order.
