# AE-TEMP-CSI-RECON-001 Validation Report

Date: 2026-06-12
Validator status: self-validation complete; independent validator approval pending and blocking commit.

## Checks

| Check | Result | Evidence |
| --- | --- | --- |
| AEGIS core and relevant role/skill instructions loaded | Pass | Listed in the reconciliation report |
| No relevant AEGIS role/skill contract missing | Pass | Master, planner, worker, validator, ticket-scope, model-output interpretation, clean-commit loaded |
| Presentation files not edited | Pass | Evidence-only patch under `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/` |
| `01_Code/**` not edited | Pass | Read-only inspection only |
| `02_Data_Input/**` not edited | Pass | Read-only inspection only |
| `03_Data_Output/**` not edited | Pass | Read-only inspection only |
| No model/index/evaluation/sensitivity/pipeline/training scripts run | Pass | No execution of project scripts; only read-only shell/R source checks |
| No deck compile run | Pass | No compile command executed |
| No Vast/SSH operation run | Pass | No SSH or Vast command executed |
| Slide 6 count source-backed | Pass | `overview_counts_cv_and_full.csv`, `overview_by_track_response.csv`, `labels_base.rds` |
| Slide 8 count source-backed | Pass | `temporary_csi_crsp_default_overlap_summary.csv`, methodology notes |
| Unit mismatch reconciled | Pass | `AE-TEMP-CSI-RECON-001_count_bridge.csv` |
| Count bridge includes old/final y rows and gross-to-net terminal-failure categories | Pass | Count bridge CSV |
| Unit definitions created | Pass | Unit definitions CSV |
| Slide claims audit created | Pass | Slide claims audit CSV |
| Validator approval before commit | Pending | No commit created |

## Key Count Validation

- Final temporary CSI positives on the model-ready scaffold: 8,517.
- Same-scaffold old confirmed-only positives: 8,217.
- Same-scaffold terminal-failure net positive-row addition: 300.
- Confirmed-only source/event cells shown in the before diagnostic: 8,369.
- CRSP 572-574 default firms: 629.
- Confirmed-only detected default firms: 151.
- Terminal-failure-inclusive detected default firms: 545.
- Gross unique-firm detection increase: 394.

## Scope Note

The worktree had unrelated dirty files before this evidence task. They were not edited, staged, or committed for this ticket. This ticket's new files are limited to:

- `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/AE-TEMP-CSI-RECON-001_Reconciliation_Report.md`
- `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/AE-TEMP-CSI-RECON-001_count_bridge.csv`
- `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/AE-TEMP-CSI-RECON-001_unit_definitions.csv`
- `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/AE-TEMP-CSI-RECON-001_slide_claims_audit.csv`
- `05_Documentation/09_Epics/AE-TEMP-CSI-RECON_Temporary_CSI_Count_Reconciliation/AE-TEMP-CSI-RECON-001_validation_report.md`

Current `.gitignore` ignores `05_Documentation/**`, so these evidence files do not appear in normal `git status`. If a validator approves commit, the commit step should use a scoped forced add for only the five files above.

## Commit Status

No commit was created. Validator approval is blocking under the ticket instructions.
