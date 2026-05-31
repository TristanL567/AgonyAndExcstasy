# AE-PRES-QA-FIX-006 Appendix Flow Restructure

## Scope

Ticket AE-PRES-QA-FIX-006 restructured the appendix in the June final presentation. No analytical outputs were created, and no computation scripts were run.

## Final Appendix Flow

The appendix now follows the requested presentation logic:

1. Dataset and labels:
   - Appendix A1: Delisting and Bankruptcy Detection
   - Appendix A2: Revised Annual Prevalence
   - Appendix A3: Cleaned Label Counts
   - Appendix A4: Descriptive Statistics -- Market Cap
   - Appendix A5: Descriptive Statistics -- Other Medians
2. Feature/model setup:
   - Appendix A6: CV Folds, Leakage Controls, and Training Metric
   - Appendix A7: Feature Family Inventory
   - Appendix A8: VAE Architecture Details
3. CV/test metrics and model diagnostics:
   - Appendix A9: Temporary CSI CV/Test/OOS Model Metrics
   - Appendix A10: Permanent CSI CV/Test/OOS Model Metrics
   - Appendix A11: Model Family Winners
4. OOS robustness:
   - Appendix A12: Model Metric Caveats and OOS Robustness
5. Index construction:
   - Appendix A13: Final Index Grid Contract
   - Appendix A14: 20 bps Winners With Benchmarks
6. Error decomposition:
   - Appendix A15: Error Decomposition and Index Source Paths
7. Transaction costs and turnover:
   - Appendix A16: Transaction-Cost Robustness
   - Appendix A17: Threshold Family and Turnover Summary
8. Sensitivity:
   - Appendix A18: Temporary CSI Sensitivity Detail
9. Model-index linkage:
   - Appendix A19: Model AP Versus Index Alpha
10. Future work and source audit:
   - Appendix A20: Future Robustness and Extensions
   - Appendix A21: Slide-to-Source Audit Map

## Source Map

`SLIDE_DATA_SOURCES.md` was reordered and retitled to match the deck appendix order. The bibliography remains row 51.

## Scope Hygiene

No files under `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` were modified.
