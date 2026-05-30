# AE-PRES-REV-001 Validation Report

## Scope

Ticket scope was limited to the June final presentation modelling section, the June slide source map, and AE-PRES-REV evidence files.

## Static Checks

- Branch check: worker operated in the repository on branch `Development`.
- Main modelling table headers:
  - `Modelling II: Results Temporary CSI`: `Model`, `CV-AP`, `CV-AUC`, `CV-FPR3`, `Test-AP`, `Test-AUC`, `Test-FPR3`.
  - `Modelling III: Results Permanent-CSI`: `Model`, `CV-AP`, `CV-AUC`, `CV-FPR3`, `Test-AP`, `Test-AUC`, `Test-FPR3`.
- Modelling-section label check:
  - `AG Expanded Dataset` present.
  - `AG Base Dataset` present.
  - `AG Latent Dataset (VAE)` present.
  - `AG Exp. Dataset + VAE` present.
  - Legacy key labels `raw_plus_latent`, `latent_raw`, `\texttt{raw}`, `\texttt{fund}`, and `VAE-only` are absent from the active modelling section.
- Appendix coverage:
  - Appendix A10 retains temporary CV/test/OOS AP, AUC, R@FPR1, R@FPR3, R@FPR5, and Brier.
  - Appendix A11 retains permanent CV/test/OOS AP, AUC, R@FPR1, R@FPR3, R@FPR5, and Brier.
- Source map:
  - Updated rows for Modelling I-IV and Appendix A10-A12.
  - Added AE-PRES-REV-001 evidence references for label and table-column checks.

## AG/XGB Decision

All main modelling rows are labelled with `AG` because the source files summarize AutoGluon feature-set runs. `AE-MODEL-SUITE-007_model_family_winners.csv` shows `WeightedEnsemble_L2` as the top leaderboard model across track-feature-set rows. No standalone XGBoost-specific presentation row was confirmed, so no `XGB` prefix was used.

## Commands Run

- `git status --short --branch`
- `git diff -- 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `rg` searches for modelling frames, old labels, and metric-table text.
- PowerShell static checks for Modelling II/III table headers and revised labels.

The full deck was not compiled, per ticket constraint.

## Known Unrelated Dirty Files

The worker did not edit, stage, revert, or delete pre-existing unrelated dirty files:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw` deleted in worktree before this worker.
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.pdf` modified in worktree before this worker.
- `07_CloudComputing/Validation/AE-VALIDATE/` untracked before this worker.

## Result

Worker validation result: pass, pending independent validator review.
