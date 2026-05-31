# AE-FP-DIAG-004 False-Positive Mechanism Assessment

## Scope

This ticket assesses whether CV false positives look detectably different,
ambiguous, or likely unavoidable using only AE-FP-DIAG-002 and AE-FP-DIAG-003
CV-only outputs. It does not read or join test/OOS labels, outcomes, prediction
rows, or feature rows. It does not edit slides, code, input data, presentation
outputs, or cloud-validation artifacts.

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

## Inputs Used

- `03_Data_Output/8_FalsePositiveDiagnostics/temporary_csi_cv_cohorts.parquet`
- `03_Data_Output/8_FalsePositiveDiagnostics/permanent_csi_cv_cohorts.parquet`
- `03_Data_Output/8_FalsePositiveDiagnostics/cv_cohort_counts.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_cv_fp_tp_profile_contrasts.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-003_FP_TP_Feature_Profile_Report.md`

## Outputs

- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_summary_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_mass_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_unsupported_mechanism_categories.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-004_FP_Mechanism_Assessment.md`

## Method

The available evidence supports only score/profile mechanisms:

- distance above the decision threshold;
- overlap between FP scores and the same configuration's TP score distribution;
- how many TPs would be lost by raising the same threshold by 0.01 or 0.02.

The mechanism categories are intentionally conservative:

- `potentially_avoidable_near_threshold`: FP score is within 0.01 probability
  points above threshold and below the TP lower-quartile score.
- `structurally_ambiguous_lower_tp_score_overlap`: FP score is at or above the
  TP 25th percentile but below the TP median.
- `structurally_ambiguous_high_score_tp_overlap`: FP score is at or above the
  TP median.
- `borderline_score_only_ambiguous`: FP is within 0.02 above threshold but not
  inside the stricter near-threshold class.
- `unresolved_score_only_false_positive`: available score/key metadata do not
  support a more specific category.

These are score-space categories, not causal mechanisms.

## Temporary CSI

At the deck-priority FPR3 threshold, temporary CSI FPs are not cleanly
separable from TPs in available score space.

| feature set | FP count | near-threshold FP share | FP share >= TP q25 | FP share >= TP median | TP lost per near-threshold FP removed by +0.01 threshold |
|---|---:|---:|---:|---:|---:|
| raw_plus_latent | 2,059 | 16.6% | 72.7% | 44.5% | 0.316 |
| raw | 2,073 | 18.1% | 69.8% | 46.6% | 0.295 |

Interpretation:

- A modest minority of FPs is threshold-adjacent and plausibly avoidable by a
  small threshold raise, but doing so would also remove true positives.
- The larger mass overlaps the TP score distribution, including 44.5% to 46.6%
  at or above the TP median. This is the strongest available evidence for
  structural ambiguity in the current CV-only output space.
- Because AE-FP-DIAG-003 found no row-level input-feature matrices in allowed
  evidence, this ticket cannot say whether those score-overlap FPs are
  separable by raw, fundamental, latent, or combined feature families.

## Permanent CSI

At the FPR3 threshold, permanent CSI shows the same broad pattern, with a
slightly smaller high-score overlap share for `raw_plus_latent`.

| feature set | FP count | near-threshold FP share | FP share >= TP q25 | FP share >= TP median | TP lost per near-threshold FP removed by +0.01 threshold |
|---|---:|---:|---:|---:|---:|
| raw_plus_latent | 2,092 | 18.6% | 64.3% | 37.0% | 0.200 |
| raw | 2,092 | 16.7% | 69.6% | 41.9% | 0.260 |

Interpretation:

- Near-threshold FP mass is again a minority: 16.7% to 18.6% at FPR3.
- The majority of FPs overlaps the lower TP score range, and 37.0% to 41.9% are
  at or above the TP median.
- Raising the threshold by 0.01 would remove the near-threshold subset but also
  lose TPs; the observed tradeoff is milder for permanent `raw_plus_latent`
  than for temporary CSI.

## Mechanism Support Matrix

| candidate mechanism | status | evidence boundary |
|---|---|---|
| High-score near-miss / TP score lookalike | Supported in score space | Many FPs overlap the same configuration's TP score distribution. |
| Potentially avoidable threshold-adjacent FP | Supported as an upper-bound candidate | Near-threshold FP mass can be removed by a small threshold raise, with measurable TP loss. |
| Label-window mismatch | Not assigned | Requires event timing or alternate label-window evidence not present in 002/003 outputs. |
| Macro/sector distress lookalike | Not assigned | Requires sector, macro, or row-level feature evidence not available in 002/003. |
| Balance-sheet distress without labelled CSI | Blocked | Requires row-level fundamental features; AE-FP-DIAG-003 documented those as missing. |
| Likely noise | Not strongly assigned | Remaining score-only unresolved mass may include noise, but the available evidence is insufficient for a stronger claim. |

## Answer To Ticket Question

The CV false positives are not shown to be feature-separable by the evidence
available to this ticket. In the available score/profile space, most FPs are
ambiguous rather than clearly avoidable: they either overlap TP score ranges or
sit outside the narrow near-threshold band. The only quantified potentially
avoidable mass is the near-threshold subset, roughly 16.6% to 18.6% at FPR3
across the in-scope configurations.

Strong claims about raw, fundamental, latent, or combined feature separability
remain blocked until row-level CV feature matrices keyed by `permno` and `year`
are available in allowed evidence.

## Validation Summary

Validation checks confirm:

- both source cohort files carry only `split_source = cv`;
- no test/OOS rows, labels, outcomes, prediction files, or feature files were
  used;
- mechanism categories are based only on threshold margin and TP score overlap;
- unsupported mechanisms are listed separately rather than assigned.

## Worker Completion Report

status: completed_with_blocker

summary: Internal model-interpreter worker quantified FP threshold proximity,
TP score overlap, and small threshold-raise tradeoffs for temporary and
permanent CSI using only AE-FP-DIAG-002/003 CV-only outputs. The report
classifies only score-supported mechanisms and preserves the AE-FP-DIAG-003
blocker on input-feature separability.

artifacts:

- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_summary_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_mass_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_unsupported_mechanism_categories.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-004_FP_Mechanism_Assessment.md`

findings:

- Row-level raw, fundamental, latent, and combined input-feature separability
  remains blocked by missing allowed evidence.
- Label-window, macro/sector, and balance-sheet mechanisms were not assigned
  because 002/003 outputs do not contain the required evidence.

next_recommended_role: validator

changed_files:

- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_summary_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_mechanism_mass_by_config.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_unsupported_mechanism_categories.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-004_FP_Mechanism_Assessment.md`
- `epics/AE-FP-DIAG/ledger.md`

verification:

- `git status --short`
- `git diff --name-only`
- CV-only validation checks in
  `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-004_validation_checks.csv`

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds a score/profile-only FP mechanism assessment, mechanism
  mass tables, unsupported mechanism table, and validation checks.
- layer_touched: diagnostics
- layer_separation_preserved: true
