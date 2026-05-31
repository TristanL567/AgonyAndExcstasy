# AE-PRES-FINAL-QA-002 Error-Cost Decomposition Audit

## Scope

This ticket audits the presentation's temporary and permanent CSI error-cost
tables against the existing index-construction source files. It does not modify
source outputs, rerun index construction, or create any `03_Data_Output` files.

## Source Files

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- model-specific `error_cost_decomposition_by_crsp_universe.csv` files under
  `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`

## Audit Result

The displayed `Net` value is the correct geometric-return alpha:

`strategy annualized geometric return - benchmark annualized geometric return`

for the same track, universe, strategy, model, and OOS period before cost
overlays.

The FP/FN/TP/TN fields are source-provided annualized category diagnostics. They
are useful for interpreting where opportunity costs and gains arise, but they
are not additive under geometric compounding and portfolio reweighting. Therefore
they should not be presented as components that exactly sum to geometric alpha.

## Presentation Fix

The presentation was updated as follows:

- Slide title changed from `Error-Cost Decomposition` to `Error-Cost Diagnostic`.
- Table subtitle now states that the FP/FN/TP/TN fields are non-additive
  contribution diagnostics.
- The `Net` column was renamed `Geo alpha`.
- The explanatory note now states that `Geo alpha` is exact, while FP/FN/TP/TN
  are annualized category diagnostics and are not additive under geometric
  compounding.
- `SLIDE_DATA_SOURCES.md` was updated for slides 21 and 24.

## Reconciliation Evidence

The audit CSV
`AE-PRES-FINAL-QA-002_error_cost_reconciliation_audit.csv` records the displayed
rows, component sums, exact geometric alpha, and residuals. Most rows do not
reconcile by summation, which is why the slide now labels the table as a
non-additive diagnostic instead of an additive decomposition.

## Conclusion

The final slide language no longer makes the misleading claim that FP/FN/TP/TN
components exactly sum to geometric alpha. The table remains useful as a
diagnostic explanation of error-cost channels, while the exact portfolio result
is shown separately as `Geo alpha`.
