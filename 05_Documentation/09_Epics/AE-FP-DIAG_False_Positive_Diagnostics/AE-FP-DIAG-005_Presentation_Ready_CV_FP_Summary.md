# AE-FP-DIAG-005 Presentation-Ready CV False-Positive Summary

## Scope

This is a short, presentation-ready handoff for later slide work. It does not
edit slides. All statements are CV-only and summarize AE-FP-DIAG-002 through
AE-FP-DIAG-004 outputs only.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\apply-to-project.md`

## Slide Candidate 1: CV False Positives Are Mostly Ambiguous

| CV-only track and model | FPs | TPs | FPs within +0.01 of threshold | FPs overlapping TP score range | FPs at or above TP median | TP cost per 100 near-threshold FPs removed |
|---|---:|---:|---:|---:|---:|---:|
| Temporary CSI, raw+latent main model, FPR3 | 2,059 | 773 | 16.6% | 72.7% | 44.5% | 31.6 |
| Permanent CSI, raw+latent main model, FPR3 | 2,092 | 634 | 18.6% | 64.3% | 37.0% | 20.0 |
| Temporary CSI, raw comparator, FPR3 | 2,073 | 731 | 18.1% | 69.8% | 46.6% | 29.5 |
| Permanent CSI, raw comparator, FPR3 | 2,092 | 641 | 16.7% | 69.6% | 41.9% | 26.0 |

## Slide Candidate 2: Interpretation Guardrail

- CV-only result: the clearest supported FP mechanism is score-space ambiguity,
  not a clean feature-space defect.
- At FPR3, only 16.6% to 18.6% of FPs are narrowly threshold-adjacent; this is
  the candidate avoidable subset.
- Most FPs overlap the TP score distribution: 64.3% to 72.7% are at or above
  the TP lower quartile, and 37.0% to 46.6% are at or above the TP median.
- Raising thresholds can remove near-threshold FPs, but it also removes TPs:
  about 20.0 to 31.6 TPs per 100 near-threshold FPs removed in the main
  raw+latent models.
- Do not claim raw, fundamental, latent, or combined feature separability yet.
  AE-FP-DIAG-003 found no row-level CV feature matrices keyed by `permno` and
  `year` in allowed evidence.
- Do not assign label-window, macro/sector, or balance-sheet mechanisms from
  these outputs; they require evidence not present in the CV-only diagnostic
  outputs.

## One-Sentence Handoff

CV-only diagnostics suggest that most false positives are structurally
ambiguous in score space rather than easily removable: only a minority is
threshold-adjacent, while the majority overlaps true-positive scores, and
feature-level separability remains blocked by missing row-level CV feature
matrices.

## Source Artifacts

- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_summary_table.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_narrative_bullets.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_validation_checks.csv`

## Validation Summary

- No slide files were edited.
- No test/OOS rows, labels, outcomes, prediction files, or feature files were
  used.
- All numeric statements are labelled CV-only and derive from AE-FP-DIAG-004
  CV-only outputs.

## Worker Completion Report

status: completed

summary: Internal model-interpreter worker produced concise CV-only tables and
narrative bullets for later one- or two-slide presentation use. The summary
keeps the interpretation limited to score/threshold evidence and carries forward
the row-level feature-matrix blocker.

artifacts:

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-005_Presentation_Ready_CV_FP_Summary.md`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_summary_table.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_narrative_bullets.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_validation_checks.csv`

findings:

- Row-level raw, fundamental, latent, and combined feature separability remains
  blocked by missing CV feature matrices keyed by `permno` and `year`.
- Mechanisms requiring timing, sector, macro, or balance-sheet feature evidence
  are not assigned.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-005_Presentation_Ready_CV_FP_Summary.md`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_summary_table.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_presentation_narrative_bullets.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_validation_checks.csv`
- `epics/AE-FP-DIAG/ledger.md`

verification:

- `git status --short`
- `git diff --name-only`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-005_validation_checks.csv`

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds one short CV-only presentation handoff report, one compact
  table, one bullet CSV, and validation checks.
- layer_touched: diagnostics
- layer_separation_preserved: true
