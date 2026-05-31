# AE-PRES-FINAL-REV2-009 Error-Cost Decomposition Audit

## Scope

This ticket audited the final presentation error-cost diagnostic slides and the underlying FP/FN/TP/TN decomposition sources. It did not rerun model training, model evaluation, index construction, sensitivity scripts, or pipeline scripts.

- Branch: `Development`
- Starting HEAD: `4011311`
- Affected slides: `Temporary CSI: Error-Cost Diagnostic`; `Permanent CSI: Error-Cost Diagnostic`
- Protected data and code paths were inspected read-only only.

## Sources Inspected

- `01_Code/pipeline/11C_IndexConstruction_Revised.R` read-only, to inspect how the decomposition is computed.
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- Model-specific `error_cost_decomposition_by_crsp_universe.csv` files for selected temporary and permanent CSI best strategies.
- Prior evidence: `AE-PRES-FINAL-REV2-002_Error_Cost_Reconciliation_Evidence.md`

## Cause Of The Previous `Recon.` Column

The previous `Recon.` column existed because the four source diagnostics are not a complete additive geometric-return attribution.

In `11C_IndexConstruction_Revised.R`, each firm-month is assigned to one of four classification buckets:

- false positive
- false negative
- true positive
- true negative

For each bucket, the code computes monthly category return differences and then annualizes each bucket independently:

`annualized_geometric_return_contribution = fn_ann_geo(category_return_difference)`

The displayed `Geo alpha` is different:

`Geo alpha = filtered annualized geometric return - benchmark annualized geometric return`

Those two constructions are not algebraically additive. Independently compounded category return-difference series do not sum to the difference between two full-portfolio geometric returns. The gap is therefore a geometric compounding and portfolio-weight interaction adjustment, with small additional display-rounding effects.

This is not only a rounding issue, and it is not evidence that a classification category is missing from the four FP/FN/TP/TN labels.

## Final Slide Formula

The slides now use:

`FP cost + FN cost + TP gain + TN gain + Geo adj. = Geo alpha`

where:

`Geo adj. = Geo alpha - FP cost - FN cost - TP gain - TN gain`

`Geo adj.` is labelled as the geometric compounding/weight-interaction adjustment. This is more precise than the previous unexplained `Recon.` label.

## Why Four Columns Alone Are Not Used

The preferred four-column exact attribution cannot be produced from the retained slide source fields without changing the decomposition methodology or retaining/recomputing monthly category return paths. The available compact source files retain annualized category diagnostics and full-portfolio geometric alpha, not a Shapley-style or log-return additive attribution that would allocate the compounding interaction back into FP/FN/TP/TN.

Allocating the adjustment into one of the four FP/FN/TP/TN columns would make those columns less interpretable because it would mix classification-bucket diagnostics with geometric compounding effects. A named fifth term is therefore the defensible presentation choice.

## Row-Level Checks

The row-level arithmetic used on the slides is documented in:

`AE-PRES-FINAL-REV2-009_reconciliation_checks.csv`

All displayed rows pass:

`FP cost + FN cost + TP gain + TN gain + Geo adj. = Geo alpha`

The four FP/FN/TP/TN columns alone do not exactly sum to alpha, and the check file marks that explicitly.

## Presentation Changes

- Replaced `Recon.` with `Geo adj.` on the temporary and permanent CSI error-cost slides.
- Replaced the slide subtitle with `OOS contribution diagnostic with geometric attribution adjustment`.
- Replaced the footnote explanation with a direct formula-based explanation.
- Updated the source footnotes to reference this audit.
- Updated `SLIDE_DATA_SOURCES.md` to describe the term as a geometric adjustment rather than a reconciliation catch-all.

## Validation Notes

The final decomposition is not a pure four-column attribution. It is a four-bucket diagnostic plus a named geometric adjustment:

`FP + FN + TP + TN + Geo adj. = Geo alpha`

This is the mathematically defensible result given the retained local evidence.
