# AE-SLIDE-CLEANUP-002 Validation Report

## Validator decision

Approved for scoped commit.

## Checks

| Check | Result | Evidence |
|---|---:|---|
| Branch is `development-slides` | Pass | Verified before editing and before commit. |
| Frame 16 remains modelling summary | Pass | Frame 16 title remains `Modelling Summary: the Models Rank Implosion Risk Well`. |
| Frame 17 title is approved bridge title | Pass | Frame 17 title is `Why the Screen Cannot Be Perfect`. |
| Old VAE slide not reinserted | Pass | Frame 17 no longer contains VAE-result bullets. VAE slide is documented as deferred to AE-SLIDE-CLEANUP-003. |
| Rnw frame balance | Pass | 53 `\begin{frame}` and 53 `\end{frame}`. |
| Values generated from saved artifacts | Pass | `slide17_fp_bridge_values.tex` and `AE-SLIDE-CLEANUP-002_computed_metrics.csv` were generated from saved parquet prediction artifacts. |
| Tau is CV-only | Pass | Tau uses `ag_cv_results.parquet` only. |
| Test diagnostics are test-only | Pass | Test FPR, recall, TP, FP, overlap, and adjacent shares use `ag_preds_test_eval.parquet` only after tau is fixed. |
| No test labels used to calibrate tau | Pass | Test labels are not read until after tau is selected from CV. |
| Density plot exists and is nonblank | Pass | `slide17_fp_bridge_density.pdf` generated; PNG preview/render inspected. |
| Compile sanity check | Pass | Draft `knitr::knit2pdf` completed with only existing citation warnings. |
| Visual QA | Pass | Rendered page 17 shows title, plot, values, alert block, and visible footnote. |
| Forbidden scripts avoided | Pass | No model, index, evaluation, sensitivity, pipeline, or training scripts were run. |
| Non-Draft June Rnw untouched by this ticket | Pass | Existing non-Draft dirty state was left unstaged and was not edited by this ticket. |
| Staged scope is limited to allowed areas | Pass | AEGIS `validate_ticket_scope.py` passed for the 14 staged changed files using `AE-SLIDE-CLEANUP-002_scope_envelope.md`. |

## Computed values

| Metric | Value |
|---|---:|
| tau | 0.2171175479888916 |
| CV FPR at tau | 0.029998263486918267 |
| CV recall at tau | 0.23436999038153256 |
| test FPR at tau | 0.08678569364996822 |
| test recall at tau | 0.458955223880597 |
| test TP count | 369 |
| test FP count | 1502 |
| FP overlap with flagged TP score range | 100.0% |
| threshold-adjacent FP share | 10.8% |

Threshold-adjacent is defined as flagged false positives with score in `[tau, tau + 0.01]` and below the flagged-TP score 25th percentile, matching the prior AE-FP-DIAG potentially avoidable near-threshold definition. In this test row set, the same 162 FPs satisfy the simpler `[tau, tau + 0.01]` band and the stricter reused definition.

## Conclusion

AE-SLIDE-CLEANUP-002 satisfies the ticket scope and is approved for commit.
