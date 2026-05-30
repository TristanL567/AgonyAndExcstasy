# AE-PRES-JUNE-005 Sensitivity And Robustness Update Report

Result: worker_complete_pending_validator

## Scope

Updated only the June final presentation sensitivity and robustness material. No sensitivity, model, index, evaluation, or pipeline computation was run.

## Frames Updated

- `Robustness I: Temporary CSI Sensitivity Grid`
- `Robustness II: Sensitivity Results and Limits`
- `Remaining Robustness Work`
- `Appendix A1: Temporary CSI Sensitivity Detail`

## Sensitivity Status Added

- Temporary-CSI C/M/T sensitivity analysis is completed locally.
- All 27 run IDs are represented.
- 24 runs are complete or safely reused.
- 3 runs are explicitly marked `blocked_partial`:
  - `C080_M000_T012`
  - `C080_M000_T018`
  - `C060_M020_T028`
- Download checksum failures: 0.

## Main Conclusions Added

- `C090_M000_T012` is the strongest overall composite configuration.
- `C060_M000_T012` is the AP winner.
- `C090_M020_T018` is strongest for 11C total-market benchmark-relative performance.
- Baseline `C080_M020_T018` remains defensible as a continuity baseline, but is not top-ranked.
- Stricter configurations generally reduce positives and prevalence; AP can fall as positives become rarer, while AUC/Brier and fixed-FPR recall can remain stable or improve.
- 11C benchmark-relative deltas remain positive for leading configurations but can shrink.

## Remaining Robustness Items Marked As Future Work

- permanent-CSI sensitivity grid;
- minimum-volatility benchmark;
- quality/risk-scaling benchmark;
- active CSI-probability weighting method;
- recovered bankrupt/insolvent firm diagnostic.

## Layout Risk

The sensitivity result table is compact and should be checked visually during the later full compile/QA ticket. No full deck compile was run in this ticket.
