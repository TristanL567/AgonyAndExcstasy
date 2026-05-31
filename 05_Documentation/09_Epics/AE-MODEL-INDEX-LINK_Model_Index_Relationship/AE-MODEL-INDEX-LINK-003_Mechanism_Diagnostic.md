# AE-MODEL-INDEX-LINK-003 Mechanism Diagnostic

## Scope

This ticket diagnoses why model-performance metrics and index-construction outcomes align in some cases and diverge in others. It uses only existing local outputs and evidence read-only, and writes compact evidence under the AE-MODEL-INDEX-LINK documentation folder.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `3dc1bf5`
- Ticket: `AE-MODEL-INDEX-LINK-003`

## Starting Point From Ticket 002

For the 24 completed/reused temporary-CSI CMT runs, the direct correlation with total-market alpha is weak to moderate:

| Metric | Pearson r vs total-market alpha | Spearman rho | Mechanism implication |
|---|---:|---:|---|
| OOS AP | -0.042425 | -0.100870 | AP is not a portfolio objective. |
| OOS AUC | 0.278420 | 0.297391 | Ranking quality helps somewhat, but not deterministically. |
| OOS R@FPR3 | 0.336036 | 0.320870 | Fixed-FPR recall is more aligned with exclusion strategies, but still incomplete. |

## Mechanism Channels

### 1. Threshold And Lockout Channel

Model metrics are continuous ranking diagnostics. Index construction acts only after a score crosses a threshold and then applies a lockout rule. This means two CMT settings can have similar AP but different index results if their scores move different firms across the selected threshold.

Examples are recorded in `AE-MODEL-INDEX-LINK-003_alignment_divergence_examples.csv`:

- AP winner `C060_M000_T012`: OOS AP `0.566`, total-market alpha `0.052pp`, strategy `fpr3_5yr`.
- Alpha winner `C090_M020_T018`: OOS AP `0.274`, total-market alpha `0.226pp`, strategy `youden_5yr`.

### 2. Universe And Market-Cap Channel

The same prediction scores affect different portfolio weights in total, large, mid, and small universes. The main run is not an outlier, but its relative position changes by universe. Existing universe evidence shows it is below median in total/large cap and above median in mid/small cap.

This explains why a model can look only average on label metrics but still produce meaningful alpha in smaller universes where affected names carry different weights and returns.

### 3. Error-Cost Channel

AP does not distinguish true positives by portfolio weight or return magnitude. Error-cost decomposition separates true positives, false positives, false negatives, and true negatives. The examples file records FP/FN/TP/TN contribution rows for the AP winner, alpha winner, and main run where available.

The mechanism is direct: false positives can hurt by excluding firms that subsequently perform well, while true positives help only when the excluded firms carry meaningful weight and avoid future underperformance.

### 4. Turnover And Transaction-Cost Channel

Turnover and transaction costs affect net performance, but in current outputs they are not the main explanation for AP-alpha divergence. The highest observed annualized gross-turnover example in the transaction-cost grid is `latent_raw / mid_cap / youden_1yr` with turnover `1.157` and 20bps return loss `0.250pp`.

This is economically visible but smaller than the variation created by CMT setting, threshold, lockout, and universe choice.

### 5. Model-Family Channel

Model-suite outputs show that the best model family differs by track and universe. For example, at 20bps the final index-suite winners vary across raw, fund, latent_raw, and raw_plus_latent depending on track and universe. This again shows that portfolio performance is not a simple monotone transformation of one model metric.

## Alignment And Divergence Examples

The compact examples file contains 23 rows covering:

- AP winner versus alpha winner;
- main-run non-outlier position;
- universe-specific median comparisons;
- threshold/lockout examples;
- turnover and transaction-cost examples;
- FP/FN/TP/TN error-cost examples;
- model-family winner examples.

## Interpretation

The practical interpretation is that AP, AUC, and fixed-FPR recall are necessary diagnostics but not sufficient selection criteria for index construction. The model must rank risk well, but the portfolio only benefits when the selected threshold and lockout identify high-weight, return-relevant names early enough and without excessive false-positive opportunity cost.

This is why the sensitivity results should be framed as robustness evidence rather than a model-selection contest: the headline configuration is not an outlier, and different optimization objectives select different CMT settings.

## Recommendation For Ticket 004

Ticket 004 should convert this into a short write-up recommendation:

- One paragraph explaining AP-alpha divergence.
- One compact table with AP winner, alpha winner, and main run.
- One slide-ready statement: `Model metrics screen for predictive quality; index alpha is the realized portfolio consequence after thresholding, weighting, timing, and costs.`

## Scope Hygiene

No files under these must-not-touch areas were modified:

- `03_Data_Output/**`
- `06_Presentations/**`
- `01_Code/**`
- `02_Data_Input/**`
- `07_CloudComputing/**`

No model training, model evaluation, index construction, sensitivity scripts, Vast.ai access, or SSH commands were used.
