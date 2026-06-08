# AE-INDEX-VALIDATE-002 Excluded Firm Return Diagnostic

## Scope And Evidence

Ticket: `AE-INDEX-VALIDATE-002`

Question: diagnose whether excluded false-positive firms underperform retained firms despite not becoming labelled CSI events.

Evidence used:

- `AE-INDEX-VALIDATE-001_selected_strategy_attribution.csv`, restricted to the selected OOS best-strategy rows.
- Source decomposition files listed in those selected rows.
- `AE-ATTRIB-001_*` attribution evidence.
- `01_Code/pipeline/11C_IndexConstruction_Revised.R` for field interpretation only; no code was modified or run.

No model training, model evaluation, index-construction rerun, sensitivity script, pipeline regeneration, or presentation compile was run.

## Measurement Definition

The source decomposition files do not provide a direct investable return series for the excluded false-positive basket or retained true-negative basket. They provide monthly weighted category return contributions, then annualize those category contribution paths.

The compact CSV therefore reports a diagnostic return proxy:

`category annualized contribution / average category portfolio weight`

For false positives, the proxy uses `category_benchmark_annualized_contribution / portfolio_weight_affected`, because false positives are excluded from the filtered strategy and have zero filtered weight.

For retained true negatives, the proxy uses `category_filtered_annualized_contribution / filtered_portfolio_weight`, because retained true negatives absorb filtered strategy weight after exclusions.

This is an evidence-bound proxy for group economic performance, not an exact standalone geometric return for a separately investable FP or TN portfolio. The exact decomposition fields remain the direct evidence for attribution: `fp_exclusion_cost`, `tp_exclusion_gain`, and `retained_stock_reweighting_effect`.

## Temporary CSI Results

| universe | selected row | FP proxy | retained TN proxy | FP vs TN | FP vs strategy gross | FP exclusion cost | retained reweighting |
|---|---:|---:|---:|---:|---:|---:|---:|
| large_cap | fund / youden_3yr | 25.89% | 23.06% | +2.83pp | +11.46pp | -1.50pp | +1.24pp |
| mid_cap | fund / fpr5_5yr | -4.46% | 21.20% | -25.66pp | -14.62pp | +0.05pp | +0.27pp |
| small_cap | raw_plus_latent / youden_3yr | 21.11% | 21.16% | -0.06pp | +12.81pp | -4.00pp | +3.94pp |
| total_market | fund / youden_3yr | 24.76% | 22.80% | +1.96pp | +11.04pp | -2.03pp | +1.79pp |

Temporary CSI answer:

- False-positive exclusions underperform retained true negatives in 2 of 4 selected temporary rows: mid cap and small cap. They do not underperform retained true negatives in large cap or total market.
- False-positive exclusions underperform the retained portfolio only in the selected mid-cap row when compared with the strategy gross or net geometric return. They outperform the selected strategy gross return proxy in large, small, and total market.
- False positives are economically weak only in the selected mid-cap row, where the FP benchmark contribution is negative and exclusion creates a small positive FP exclusion effect. In large, small, and total market, FP exclusion is an opportunity cost, not evidence of FP weakness.
- The selected temporary rows are compatible with a broader quality-screen interpretation only in a qualified sense: retained-stock reweighting is positive in all four rows and offsets FP costs in the higher-alpha rows, but FP performance is not uniformly weak.

## Permanent CSI Results

| universe | selected row | FP proxy | retained TN proxy | FP vs TN | FP vs strategy gross | FP exclusion cost | retained reweighting |
|---|---:|---:|---:|---:|---:|---:|---:|
| large_cap | raw_plus_latent / fpr5_permanent | 18.56% | 23.47% | -4.91pp | +4.05pp | -0.26pp | +0.30pp |
| mid_cap | fund / fpr5_permanent | 13.06% | 21.30% | -8.23pp | +2.67pp | -0.55pp | +0.90pp |
| small_cap | latent_raw / fpr3_permanent | 15.74% | 20.63% | -4.89pp | +7.76pp | -0.74pp | +1.02pp |
| total_market | raw_plus_latent / fpr5_permanent | 21.19% | 22.98% | -1.80pp | +7.63pp | -0.49pp | +0.52pp |

Permanent CSI answer:

- False-positive exclusions underperform retained true negatives in all 4 selected permanent rows.
- False-positive exclusions do not underperform the retained portfolio in any selected permanent row using the strategy gross or net geometric return comparison.
- False positives are economically weaker than retained true negatives, but not economically weak in absolute terms: their contribution-per-weight proxies are positive and above the selected strategy gross return in all four rows.
- Permanent CSI alpha is compatible with a broader distress/quality-screen interpretation in the narrow sense that non-event firms excluded by the model underperform retained non-event firms. The evidence does not support a causal claim that exclusion caused alpha, and it does not show that false positives were negative-return firms.

## Direct Answers

Do false-positive exclusions underperform retained true negatives?

Partly. They underperform retained true negatives in 6 of 8 selected rows: all four permanent CSI rows plus temporary mid cap and small cap. They do not underperform retained true negatives in temporary large cap or temporary total market.

Do false-positive exclusions underperform the retained portfolio?

Mostly no. Using the selected strategy gross and net geometric return as the retained-portfolio comparator, false positives underperform only in temporary mid cap. In the other 7 selected rows, the false-positive return proxy is above the retained strategy return.

Are false positives economically weak even though they are not labelled CSI?

Not uniformly. The temporary mid-cap false-positive group is economically weak by this diagnostic, with a negative contribution-per-weight proxy and a positive FP exclusion effect. Permanent false positives are weaker than retained true negatives but still positive-return groups by the available proxy. Temporary large, small, and total-market false positives are not weak relative to the retained strategy return, and their exclusion is measured as an opportunity cost.

Is observed alpha compatible with broader distress/quality-screen interpretation?

Yes, but only with explicit uncertainty. The selected rows show positive retained-stock reweighting effects in every universe and FP underperformance versus retained TNs in most rows, especially permanent CSI. That is compatible with a model acting partly as a broader distress or quality screen among non-event firms. However, FP exclusion costs are often negative, meaning excluded non-event firms frequently contributed positively in the benchmark. The evidence supports a quality-screen-compatible interpretation, not a pure event-avoidance interpretation and not a causal claim.

## Limitations

- The available decomposition files annualize category contribution paths. They do not preserve all monthly category paths needed to construct exact standalone FP, TN, TP, and FN geometric returns without a new derived methodology.
- TP and FN return proxies are unstable where affected weights are tiny. Several selected OOS rows have near-zero CSI-event weights, so TP/FN proxy magnitudes should not be over-interpreted.
- The label distinction remains strict: false positives are non-CSI under the active label definition. Economic underperformance versus retained true negatives does not make them labelled CSI events.
- This ticket diagnoses realized return patterns in existing output. It does not establish causality.

## Artifacts

- `AE-INDEX-VALIDATE-002_excluded_vs_retained_summary.csv`
- `AE-INDEX-VALIDATE-002_Excluded_Firm_Return_Diagnostic.md`
- `AE-INDEX-VALIDATE-002_worker_completion_report.md`
