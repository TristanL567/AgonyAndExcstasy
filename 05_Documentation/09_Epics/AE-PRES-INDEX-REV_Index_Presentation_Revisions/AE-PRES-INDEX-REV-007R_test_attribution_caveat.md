# AE-PRES-INDEX-REV-007R Test Attribution Caveat

## Caveat

The inserted Temporary CSI test result slide uses isolated `03_Data_Output/9_TestIndexConstruction` test-set result rows. The inserted diagnostic/contribution slide does not come from a standalone isolated test diagnostic build in that package.

Instead, the diagnostic view uses reconciled AE-ATTRIB main-suite `period=test` attribution rows for the same selected temporary-CSI strategies at `transaction_cost_bps=10`.

## On-slide text

The inserted diagnostic slide states:

> The result table above is from isolated test-output files. This diagnostic view is not a standalone AE-FP-DIAG-006 test diagnostic build; it uses reconciled main-suite `period=test` attribution rows for the same temporary-CSI strategies.

## Interpretation boundary

The inserted slide frames the test-window result as contribution-based, not causal. It states that gains mostly come from retained-stock reweighting and geometric effects after false-positive costs, with TP exclusion most visible in Small Cap.

## Reconciliation

The displayed contribution rows use:

`TP gain + FP cost + retained-stock reweighting + transaction-cost effect + geometric adjustment = realized alpha`

Rows reconcile within displayed rounding.
