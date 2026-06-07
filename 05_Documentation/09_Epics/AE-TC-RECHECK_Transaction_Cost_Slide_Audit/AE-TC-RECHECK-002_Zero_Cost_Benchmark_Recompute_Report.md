# AE-TC-RECHECK-002 Zero-Cost Benchmark Recompute Report

## Ticket

- Epic: AE-TC-RECHECK
- Ticket: AE-TC-RECHECK-002
- Branch: development-slides
- Generated: 2026-06-07T18:06:47+02:00
- Scope: documentation/evidence recomputation only; no presentation or data-output files edited.

## Active-Alpha Definition

Corrected active alpha is computed as:

`strategy net annualized geometric return after transaction costs - zero-cost benchmark annualized geometric return`

The benchmark is the ordinary market-cap-weighted benchmark without a transaction-cost overlay. The strategy pays transaction costs because it trades away from benchmark weights. This means the benchmark term is fixed for a given universe/period, while the strategy net return declines with higher transaction-cost assumptions.

## Source Rows

The eight selected OOS strategies were located in saved `index_performance_gross_and_net_by_tc.csv` files. No index construction, model training, evaluation, sensitivity, or pipeline script was run.

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`

For each selected row, the recomputation used:

- `benchmark_gross_annualized_geometric_return` as the zero-cost benchmark geometric return;
- `net_annualized_geometric_return` as the strategy net geometric return at 5, 10, and 20 bps;
- `annualized_turnover_gross * transaction_cost_bps / 10000 * 100` as expected annual transaction-cost drag in percentage points.

## Corrected Slide-Ready Values

| Track | Universe | 5 bps | 10 bps | 20 bps | Monotone? |
|---|---:|---:|---:|---:|---|
| Temporary CSI | Total | 0.43 | 0.42 | 0.41 | True |
| Temporary CSI | Large | 0.15 | 0.14 | 0.12 | True |
| Temporary CSI | Mid | 0.45 | 0.39 | 0.28 | True |
| Temporary CSI | Small | 0.59 | 0.55 | 0.45 | True |
| Permanent CSI | Total | 0.26 | 0.26 | 0.25 | True |
| Permanent CSI | Large | 0.22 | 0.22 | 0.20 | True |
| Permanent CSI | Mid | 0.68 | 0.62 | 0.51 | True |
| Permanent CSI | Small | 0.28 | 0.24 | 0.16 | True |

The full 24-row recomputation is in `AE-TC-RECHECK-002_corrected_slide_values.csv`.

## Difference Versus Current Slide

The current slide values match the prior source definition, which subtracts a transaction-cost-adjusted benchmark. Under the corrected definition, active alpha declines more visibly as transaction costs rise, especially for high-turnover mid/small-cap strategies. The largest 20 bps corrections are:

- Temporary CSI Mid: current +0.51 pp, corrected +0.28 pp.
- Permanent CSI Mid: current +0.74 pp, corrected +0.51 pp.
- Temporary CSI Small: current +0.62 pp, corrected +0.45 pp.
- Permanent CSI Small: current +0.32 pp, corrected +0.16 pp.

## Winner-Ranking Check

The selected OOS winner remains unchanged under the corrected active-alpha definition. The reason is ranking invariance: within each track/universe/cost slice, subtracting the zero-cost benchmark from every candidate is subtracting the same constant. Therefore the ranking by corrected active alpha is identical to the ranking by strategy net return, and also preserves the original winner selection that subtracted the costed benchmark constant within the same slice.

## Monotonicity Check

All eight fixed selected strategies are weakly declining from 5 to 10 to 20 bps under the corrected zero-cost benchmark definition. The monotonicity details are in `AE-TC-RECHECK-002_monotonicity_checks.csv`.

## Scope Notes

- Presentation files were not edited.
- `03_Data_Output/**` files were read only and not modified.
- No forbidden model, index, evaluation, sensitivity, or pipeline script was run.
- The only computation was a read-only CSV reconciliation helper over saved outputs.
