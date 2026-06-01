# AE-FP-FEATURE-DEEPDIVE-003R Worker Completion Report

## status

completed, pending independent validator review.

## summary

The worker interpreted CV-only FP-vs-TP feature separability from completed `AE-FP-FEATURE-DEEPDIVE-002R` outputs. The report classifies supported mechanisms, separates matched model-family evidence from auxiliary/component feature-family evidence, and states the key guardrails: CV-only, association not causality, and no test/OOS inference.

## artifacts

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_FP_Mechanism_Interpretation.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_validation_report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_worker_completion_report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

## findings

- FP-vs-TP feature separation is moderate, not clean. Top matched-family abs SMDs are roughly `0.19` to `0.38`, while median matched-feature abs SMDs stay small in all slices.
- Market-stress/credit-spread evidence is the most repeatable strict-threshold mechanism, led by `hy_spread` in multiple temporary and permanent CSI `fpr3`/`fpr5` matched slices.
- Drawdown/volatility evidence is supported mainly by `max_dd_12m` and `vol_12m`, especially at `youden` and permanent `fpr1`.
- Firm-age/size/market-value ambiguity is supported by `lifetime_years` and market-value history variables, especially for permanent CSI and broader `youden` slices.
- Distress-lookalike evidence is partial: selected cash/liquidity/accounting variables separate FP from TP in some slices, but they do not dominate the overall matched-family evidence.
- Near-threshold/score-overlap is not directly tested by 002R; high feature overlap supports ambiguity but not a score-threshold claim.
- `fund` and `latent_raw` findings are auxiliary/component profiles, not standalone matched model-family FP/TP evidence.
- No causal claim is supported or made.

## next_recommended_role

validator

## changed_files

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_FP_Mechanism_Interpretation.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_validation_report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-003R_worker_completion_report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

## verification

- Confirmed branch context was `Development`.
- Read the 003R ticket envelope, epic envelope, ledger, and `.aegis/planner-config.yaml`.
- Read the 002R report, validation report, worker completion report, and local generated feature-contrast outputs.
- Verified 002R validation checks report CV-only cohorts, training-only feature sources, no test/OOS rows, feature-key uniqueness, and 23,440 contrast rows.
- Confirmed the new 003R documentation artifacts exist as ignored local files under the allowed documentation folder.
- Confirmed `git diff --name-only -- 03_Data_Output` returned empty.
- Confirmed `git diff --cached --name-only` returned empty.
- Did not edit `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, `06_Presentations/**`, or `07_CloudComputing/**`.
- Did not stage, commit, or push.

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Added a slide-ready FP mechanism interpretation, worker validation report, worker completion report, and ledger handoff rows for validator review.
- layer_touched: documentation
- layer_separation_preserved: true
