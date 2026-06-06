# AE-PRES-INDEX-REV-001 Proposed Revised Index Section Order

1. Index Construction I: From Score to Portfolio Weight.
2. Index Construction II: Four Benchmark Universes.
3. Temporary CSI OOS, 10 bps result.
4. Temporary CSI OOS, combined error-cost and realized contribution.
5. Temporary CSI test, 10 bps result.
6. Temporary CSI test, diagnostic/contribution view with explicit source caveat.
7. Permanent CSI OOS, 10 bps result.
8. Permanent CSI OOS, combined error-cost and realized contribution.
9. Permanent CSI test, 10 bps result.
10. Permanent CSI test, diagnostic/contribution view with explicit source caveat.
11. Transaction-cost robustness across OOS temporary and permanent CSI.
12. Turnover effect at 5, 10, and 20 bps across OOS temporary and permanent CSI.
13. Threshold-family and turnover interpretation.
14. Sensitivity: main run versus temporary C/M/T grid, with main results foregrounded.

Notes:

- Move the current 0 bps OOS result slides to appendix or replace their main-section role with 10 bps versions, because the planned section foregrounds net 10 bps performance.
- Keep the existing source-navigation appendix frame for auditability, but do not let it interrupt the main result sequence.
- The test diagnostic/contribution slides should either carry a visible caveat that they use main-suite `period=test` attribution/decomposition rows, or wait for a new data-preparation ticket that emits standalone test-only diagnostic artifacts under `03_Data_Output/9_TestIndexConstruction`.
