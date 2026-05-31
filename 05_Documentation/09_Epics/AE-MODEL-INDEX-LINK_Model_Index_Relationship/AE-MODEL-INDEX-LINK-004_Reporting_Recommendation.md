# AE-MODEL-INDEX-LINK-004 Reporting Recommendation

## Scope

This ticket converts the AE-MODEL-INDEX-LINK diagnostic evidence into a human-reviewed reporting recommendation. It does not edit the final presentation, code, model outputs, index outputs, sensitivity outputs, or data inputs.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `1056e2f`
- Ticket: `AE-MODEL-INDEX-LINK-004`
- Checkpoint status: human checkpoint was recorded as hit and approved before dispatch.

## Evidence Base

This recommendation uses the outputs from the first three tickets:

- `AE-MODEL-INDEX-LINK-001_Status_Quo_Diagnostic.md`
- `AE-MODEL-INDEX-LINK-002_Correlation_Analysis.md`
- `AE-MODEL-INDEX-LINK-002_metric_alpha_correlations.csv`
- `AE-MODEL-INDEX-LINK-003_Mechanism_Diagnostic.md`
- `AE-MODEL-INDEX-LINK-003_alignment_divergence_examples.csv`

## Recommended Reporting Position

Model metrics should be reported as **predictive-quality diagnostics**, not as direct portfolio-selection objectives. AP, AUC, and fixed-FPR recall show whether the model ranks CSI events well. Index alpha is the realized portfolio consequence after thresholding, lockout rules, market-cap weighting, universe selection, timing, turnover, and false-positive opportunity costs.

The correct reporting stance is:

> Model metrics screen for predictive quality; index alpha is the realized portfolio consequence after thresholding, weighting, timing, and costs.

This framing avoids overclaiming that a higher AP or AUC mechanically implies higher benchmark-relative returns.

## Status Quo Summary

The strongest linkage is temporary-CSI CMT sensitivity by `run_id`, because the completed/reused CMT runs link OOS AP, OOS AUC, and OOS R@FPR3 to total-market alpha. The model-suite linkage is also useful, but it is by model family and track rather than CMT run. Permanent-CSI CMT sensitivity remains unavailable.

Key status quo points:

- The main run `C080_M020_T018` is not an outlier.
- It is below median for total-market and large-cap alpha.
- It is above median for mid-cap and small-cap alpha.
- The AP winner is not the total-market alpha winner.
- The total-market alpha winner has lower AP but better portfolio realization.

## Correlation Evidence

For the 24 completed/reused temporary-CSI CMT runs:

| Metric vs total-market alpha | Pearson r | Spearman rho | Reporting interpretation |
|---|---:|---:|---|
| OOS AP | -0.042425 | -0.100870 | AP does not explain total-market alpha in this sample. |
| OOS AUC | 0.278420 | 0.297391 | AUC is weakly positive, but not decisive. |
| OOS R@FPR3 | 0.336036 | 0.320870 | Fixed-FPR recall is more aligned, but still incomplete. |

The practical implication is that the thesis should not choose or justify an index rule solely through AP. Model metrics and index performance should be presented as linked but distinct evaluation layers.

## Mechanism Evidence

The mechanism diagnostic identifies five channels that explain divergence:

1. **Threshold and lockout channel**: scores only affect portfolios when they cross the selected threshold and trigger an exclusion rule.
2. **Universe and market-cap channel**: the same predictions have different effects in total, large, mid, and small-cap universes.
3. **Error-cost channel**: false positives, false negatives, true positives, and true negatives differ in portfolio weight and return contribution.
4. **Turnover and transaction-cost channel**: turnover affects net returns, but current cost drag is not the main AP-alpha divergence driver.
5. **Model-family channel**: different feature families can win different universes, again showing that model metrics do not map one-to-one into portfolio outcomes.

Two concise examples should be used in reporting:

| Case | Run | OOS AP | Total-market alpha | Interpretation |
|---|---|---:|---:|---|
| AP winner | `C060_M000_T012` | 0.566 | 0.052pp | Best label-ranking result, not best portfolio result. |
| Alpha winner | `C090_M020_T018` | 0.274 | 0.226pp | Lower AP, but better realized total-market portfolio outcome. |
| Main run | `C080_M020_T018` | 0.308 | 0.065pp | Not an outlier; continuity baseline, not cherry-picked optimum. |

## What Can Be Claimed

It is safe to claim:

- Predictive metrics and index alpha are related but distinct objectives.
- AP alone does not explain benchmark-relative alpha across the 24 temporary-CSI CMT runs.
- The main CMT run is not an outlier in the sensitivity distribution.
- Index outcomes depend on thresholding, universe weights, timing, and portfolio return realization.
- Fixed-FPR recall appears more aligned with alpha than AP in this sample, but it is still not sufficient for selecting a portfolio rule.
- Sensitivity evidence supports robustness rather than replacing the accepted headline configuration.

## What Cannot Be Claimed

Do not claim:

- Higher AP causes higher alpha.
- The AP-best model is the best index strategy.
- Model metrics alone are sufficient to choose index-construction rules.
- The CMT alpha relationship generalizes to permanent CSI sensitivity, because permanent-CSI CMT sensitivity remains future work.
- The observed correlations are formal causal estimates; they are descriptive diagnostics over the available completed/reused runs.

## Recommended Wording

Suggested thesis/presentation wording:

> Predictive and portfolio performance are intentionally evaluated separately. AP and AUC measure whether the model ranks future CSI events well. The index result additionally depends on whether those scores cross the chosen threshold early enough, whether excluded firms carry meaningful index weight, and whether avoided firms subsequently underperform. In the temporary-CSI sensitivity grid, AP is not strongly correlated with total-market alpha, so we use model metrics as predictive diagnostics and index results as the final portfolio test.

Short slide version:

> Higher AP does not mechanically imply higher alpha: AP is label-weighted, while alpha is return-, timing-, threshold-, and market-cap-weighted.

## Reporting Recommendation

Use the current sensitivity chart pair as the main reporting device:

- Main slide: distribution of CMT index alpha with main run highlighted.
- Appendix/backup: AP versus total-market alpha scatter.

Do not add a new headline claim that AP predicts alpha. Instead, state that the sensitivity results support robustness and clarify that the main run is not an outlier or a cherry-picked optimum.

## Human Checkpoint Recommendation

The human should approve continuation to closeout if this reporting stance is acceptable:

- model metrics are predictive diagnostics;
- index construction is the realized portfolio test;
- AP-alpha divergence is expected and explainable;
- no presentation edits are required unless the human wants this wording inserted later.

## Scope Hygiene

No files under these must-not-touch areas were modified:

- `03_Data_Output/**`
- `06_Presentations/**`
- `01_Code/**`
- `02_Data_Input/**`
- `07_CloudComputing/**`

No model training, model evaluation, index construction, sensitivity scripts, Vast.ai access, or SSH commands were used.
