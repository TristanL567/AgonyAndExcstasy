# AE-INDEX-VALIDATE-001 Attribution State Audit

## Scope

This audit reads the existing index-construction and AE-ATTRIB attribution artifacts only. It does not rerun models, rebuild indices, regenerate sensitivity outputs, or modify data, code, presentation, or cloud-validation paths.

Primary selection rule: the selected main OOS active-attribution rows are the rows identified by `AE-ATTRIB-001_Main_Index_Attribution_Report.md` at `period=oos` and `transaction_cost_bps=10`, across Temporary CSI and Permanent CSI for Total, Large, Mid, and Small universes.

## Source Files Used

- `epics/AE-INDEX-VALIDATE/tickets/AE-INDEX-VALIDATE-001.yaml`
- `01_Code/pipeline/11C_IndexConstruction_Revised.R`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_Main_Index_Attribution_Report.md`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/headline_winners_20bps.csv`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

## Index-Construction Timing And Mechanics

The index construction in `11C_IndexConstruction_Revised.R` maps quarterly index membership to a forward holding year:

- At each quarterly rebalance date `qdate`, `holding_year = year(qdate + 1 month)`.
- The model signal year is `signal_year = holding_year - 1`.
- Temporary CSI uses lockout rules of 1, 2, 3, or 5 years. For a given signal year, a firm is excluded if it has a model probability at or above the threshold in the relevant signal-year window. For example, a 3-year lockout checks signal years from `signal_year - 2` through `signal_year`.
- Permanent CSI uses absorbing permanent removal. For a given signal year, the exclusion check spans from the first available signal year through the current signal year.
- The benchmark is the unfiltered market-cap-weighted CRSP-like universe for Total, Large, Mid, and Small indices.
- The filtered portfolio removes model-flagged constituents and renormalizes retained benchmark weights to sum to one. In the code, retained `filtered_weight = benchmark_weight / sum(benchmark_weight)` within the rebalance group.
- Returns are monthly drifted portfolios from quarterly rebalance weights. Transaction-cost overlays are applied to strategy turnover; benchmark returns are the market-cap reference.

## Selected OOS Rows

The selected attribution table is written to:

`05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/AE-INDEX-VALIDATE-001_selected_strategy_attribution.csv`

All eight selected rows are available. All eight pass reconciliation with zero source reconciliation error:

`TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha`.

Values below are annualized geometric-return units, shown in percentage points for readability.

| Track | Universe | Model / strategy | Cost bps | Benchmark | Strategy net | Alpha | TP gain | FP cost | Retained reweight | TC effect | Geo adj. | TP wgt | FP wgt | FN wgt | TN wgt |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Temporary CSI | Large | Base Dataset / youden_3yr | 10 | 14.28 | 14.42 | 0.14 | -0.00 | -1.50 | 1.24 | -0.01 | 0.42 | 0.01 | 5.73 | 0.00 | 62.52 |
| Temporary CSI | Mid | Base Dataset / fpr5_5yr | 10 | 9.65 | 10.05 | 0.39 | -0.00 | 0.05 | 0.27 | -0.11 | 0.18 | 0.05 | 1.18 | 0.01 | 66.93 |
| Temporary CSI | Small | Exp. Dataset + VAE / youden_3yr | 10 | 7.65 | 8.20 | 0.55 | 0.42 | -4.00 | 3.94 | -0.09 | 0.27 | 0.41 | 18.01 | 0.04 | 49.44 |
| Temporary CSI | Total | Base Dataset / youden_3yr | 10 | 13.29 | 13.71 | 0.42 | 0.08 | -2.03 | 1.79 | -0.01 | 0.59 | 0.11 | 8.06 | 0.02 | 60.02 |
| Permanent CSI | Large | Exp. Dataset + VAE / fpr5_permanent | 10 | 14.28 | 14.49 | 0.22 | 0.00 | -0.26 | 0.30 | -0.01 | 0.18 | 0.00 | 1.37 | 0.00 | 66.90 |
| Permanent CSI | Mid | Base Dataset / fpr5_permanent | 10 | 9.65 | 10.28 | 0.62 | 0.00 | -0.55 | 0.90 | -0.12 | 0.39 | 0.00 | 4.06 | 0.01 | 64.11 |
| Permanent CSI | Small | Latent Dataset (VAE) / fpr3_permanent | 10 | 7.65 | 7.90 | 0.24 | 0.04 | -0.74 | 1.02 | -0.08 | -0.00 | 0.03 | 4.60 | 0.03 | 63.24 |
| Permanent CSI | Total | Exp. Dataset + VAE / fpr5_permanent | 10 | 13.29 | 13.55 | 0.26 | 0.01 | -0.49 | 0.52 | -0.01 | 0.22 | 0.01 | 2.32 | 0.01 | 65.87 |

## Interpretation Of What The Attribution Proves

The attribution proves that the selected model-filtered OOS index rows outperform their market-cap-weighted benchmarks after the specified transaction-cost overlay, and that the realized alphas reconcile to the existing AE-ATTRIB components.

It does not prove that alpha mainly comes from directly avoiding realized CSI or permanent-loss events. The direct TP exclusion term is small in most selected rows:

- Permanent CSI: TP gain is exactly zero for Large and Mid, 0.04pp for Small, and 0.01pp for Total.
- Temporary CSI: TP gain is negative or near zero for Large and Mid, 0.42pp for Small, and 0.08pp for Total.

The larger terms are usually FP exclusion costs, retained-stock reweighting effects, and geometric adjustment. Permanent CSI is especially consistent with retained-constituent reweighting: retained reweighting is 0.30pp, 0.90pp, 1.02pp, and 0.52pp across Large, Mid, Small, and Total. These retained effects are partly offset by FP costs and transaction costs, then combined with a geometric adjustment.

## Event Avoidance, Quality Screen, Or Reweighting

The current evidence supports this hierarchy:

1. Direct event-avoidance alpha is not the dominant explanation for the selected permanent-CSI rows. TP benchmark weights are tiny and TP gains are near zero.
2. Temporary CSI has one selected row with meaningful direct TP gain, Small at 0.42pp, but even there the FP cost is -4.00pp and the retained-stock reweighting effect is 3.94pp. The net result is not a simple avoided-event story.
3. Broader distress or quality-screen alpha is plausible, because a model-filtered index may retain and upweight firms with better realized returns, but the current attribution does not test factor specificity.
4. Retained-constituent reweighting is the strongest directly supported mechanical interpretation. It explains where the active return shows up after excluded stocks are removed and remaining stocks are renormalized.
5. Generic reweighting remains unresolved. The existing attribution does not show whether comparable alpha would arise from random, size-matched, sector-matched, or quality-factor-matched exclusions.

## Validation Of The Core Statement

The statement is valid:

Near-zero TP gain does not automatically invalidate the index result, but it invalidates a pure claim that the strategy outperforms mainly by avoiding realized CSI or permanent-loss events.

Reason: realized alpha is the full filtered portfolio return minus the benchmark return after transaction costs, not only the return contribution of excluded true positives. A strategy can outperform by excluding low-return false positives less severely than expected, by upweighting retained winners, or through portfolio-level geometric compounding. However, if the TP exclusion term is near zero, the evidence cannot support a thesis-safe claim that outperformance is primarily from realized event avoidance.

## Strongest Criticism To Test Next

The strongest criticism is model-specificity:

The observed CSI index alpha may be reproducible by non-model exclusions that create similar size, sector, distress, quality, or turnover tilts. The next test should compare the selected CSI strategies against random, size-matched, sector-matched, size-sector matched, and quality-factor matched placebo exclusions with the same exclusion intensity by universe, period, and cost.

This is stronger than a simple "TP gain is near zero" criticism because it attacks the economic interpretation of the full portfolio result while accepting that the selected rows did outperform.

## Thesis-Safe Interpretation

A thesis-safe statement is:

The model-filtered CSI index strategies produce positive selected OOS alpha versus market-cap-weighted benchmarks in the audited rows, and the attribution reconciles exactly to direct TP/FP exclusion effects, retained-stock reweighting, transaction costs, and a geometric adjustment. The strongest evidence is not that the strategy mainly profits by directly avoiding realized CSI or permanent-loss events. Instead, especially for permanent CSI, the alpha is mostly located in retained-constituent reweighting and portfolio-level compounding after exclusions. This remains economically relevant for an investable screening strategy, but model-specificity must be tested against matched placebo exclusions before claiming that the alpha is uniquely caused by CSI prediction rather than generic reweighting or quality/distress tilts.

## Caveats For Validator

- This worker did not inspect or regenerate RDS internals beyond the existing CSV-level outputs.
- The selected attribution rows are the AE-ATTRIB OOS 10 bps rows, because that is the completed active-attribution selection documented by AE-ATTRIB and the slide source map.
- The final table `headline_winners_20bps.csv` uses a 20 bps headline selection and is useful background, but it is not the source of the selected active-attribution rows audited here.
- The compounding/geometric adjustment is a reconciliation term from AE-ATTRIB, not a behavioral category.
