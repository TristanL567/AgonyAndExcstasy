# AE-TC-AUDIT-001 Transaction Cost Audit Report

## Scope

This worker pass audited existing AE-INDEX-SUITE outputs only. It did not rerun `01_Code/pipeline/11C_IndexConstruction_Revised.R`, index construction, model training, evaluation, sensitivity, or presentation scripts.

Evidence files produced in this folder:

- `AE-TC-AUDIT-001_transaction_cost_math_check.csv`
- `AE-TC-AUDIT-001_yearly_turnover_by_best_strategy.csv`
- `AE-TC-AUDIT-001_best_strategy_cost_drag_summary.csv`
- `AE-TC-AUDIT-001_validation_report.md`

## Formula Audit

The transaction-cost implementation in `01_Code/pipeline/11C_IndexConstruction_Revised.R` is internally consistent.

- `fn_turnover_event()` computes `delta_w = target_w - pre_trade_w`, then `turnover_buy = sum(pmax(delta_w, 0))`, `turnover_sell = sum(abs(pmin(delta_w, 0)))`, and `turnover_gross = turnover_buy + turnover_sell` around lines 568-584.
- The pre-trade weights are drifted holdings from the previous rebalance period, not target-to-target weights. The code carries `pre_trade_holdings <- holdings` after monthly return drift and labels non-initial turnover basis as `drifted_pre_trade_to_target`.
- Monthly gross return is computed from drifted/rescaled pre-return weights as `gross_return <- sum(active$w_pre * active$ret, na.rm = TRUE)`.
- Transaction cost drag is computed as `transaction_cost_return_drag := turnover_gross * transaction_cost_bps / 10000`, so bps are divided by 10,000.
- Net return is computed once as `net_return := gross_return - transaction_cost_return_drag`.

Interpretation: transaction costs are charged on traded weight only. Both buys and sells are charged because `turnover_gross` is the sum of buy turnover plus sell turnover. `turnover_one_way` is reported separately and is not used for the transaction-cost drag.

## Math Check

For the selected final best strategy per track and universe, using the 20 bps best-strategy selection, monthly checks were run for 10 bps and 20 bps:

`expected_drag = turnover_gross * transaction_cost_bps / 10000`

`net_return_check = gross_return - expected_drag`

All 16 checks passed. Each check covered 264 monthly rows after de-duplicating overlapping model-output copies. Maximum absolute drag and net-return errors were floating-point residuals only, on the order of `1e-18` or smaller.

## Why The Impact Is Small

The cost impact is small because the assumed costs are small and the selected strategies generally do not turn over enough to create large annual drag.

At 20 bps, a strategy with 100% annualized gross turnover has a simple arithmetic drag of about:

`1.00 * 20 / 10000 = 0.0020`, or 20 bps per year.

The largest selected strategies have annualized gross turnover around 0.76-1.06, implying simple 20 bps drag around 15-21 bps per year. The observed annualized net-return drops are close to that, slightly higher because the reported net returns are geometric annualized returns over the selected OOS window.

Lower-turnover large-cap and total-market strategies have annualized gross turnover around 0.07-0.13, implying simple 20 bps drag of only about 1-3 bps per year. Their observed 0-to-20 bps net-return drops are correspondingly tiny.

## Cost Drag Summary

Final best strategies were taken from `comparison/best_by_track_index_cost.csv` at 20 bps. The matched selection period in the model-specific performance files is `oos` for all eight track/universe combinations.

| track | index_id | model_key | strategy_id | annualized gross turnover | simple drag at 20 bps | observed 0-to-20 bps annualized drop |
|---|---|---|---|---:|---:|---:|
| permanent_csi | mid_cap | fund | fpr5_permanent | 1.0624 | 0.0021 | 0.0023 |
| dynamic_csi | mid_cap | fund | fpr5_5yr | 1.0586 | 0.0021 | 0.0023 |
| dynamic_csi | small_cap | raw_plus_latent | youden_3yr | 0.8549 | 0.0017 | 0.0018 |
| permanent_csi | small_cap | latent_raw | fpr3_permanent | 0.7573 | 0.0015 | 0.0016 |
| dynamic_csi | large_cap | fund | youden_3yr | 0.1304 | 0.0003 | 0.0003 |
| permanent_csi | large_cap | raw_plus_latent | fpr5_permanent | 0.1151 | 0.0002 | 0.0003 |
| dynamic_csi | total_market | fund | youden_3yr | 0.1037 | 0.0002 | 0.0002 |
| permanent_csi | total_market | raw_plus_latent | fpr5_permanent | 0.0680 | 0.0001 | 0.0002 |

The highest-turnover universes are mid-cap first, then small-cap. Large-cap and total-market turnover is much lower, so their transaction-cost impact is expected to be barely visible at 10-20 bps.

## Yearly Turnover Values To Inspect First

The largest yearly gross turnover rows are mostly initial or high-rebalance years. The first year includes initial formation, which charges buys for the initial portfolio build and should be interpreted separately from recurring rebalance turnover.

| track | index_id | year | yearly gross turnover | yearly buy | yearly sell |
|---|---|---:|---:|---:|---:|
| permanent_csi | mid_cap | 2003 | 1.7067 | 1.3533 | 0.3533 |
| dynamic_csi | mid_cap | 2003 | 1.7034 | 1.3517 | 0.3517 |
| permanent_csi | small_cap | 2003 | 1.5432 | 1.2716 | 0.2716 |
| dynamic_csi | small_cap | 2003 | 1.4675 | 1.2338 | 0.2338 |
| permanent_csi | large_cap | 2003 | 1.1070 | 1.0535 | 0.0535 |
| dynamic_csi | large_cap | 2003 | 1.0901 | 1.0450 | 0.0450 |
| dynamic_csi | total_market | 2003 | 1.0489 | 1.0244 | 0.0244 |
| permanent_csi | total_market | 2003 | 1.0483 | 1.0242 | 0.0242 |

After 2003, the larger rows to inspect are mid-cap around 2008-2009 and 2020-2022, plus dynamic small-cap in 2021. These rows are listed in `AE-TC-AUDIT-001_yearly_turnover_by_best_strategy.csv`.

## Findings

1. No evidence of bps scaling error was found. The implementation divides transaction-cost bps by 10,000.
2. No evidence of double counting was found. Net return subtracts `transaction_cost_return_drag` once.
3. No evidence of undercharging relative to the documented formula was found. Costs use `turnover_gross`, which includes both buys and sells.
4. Costs are applied to traded weight only, based on drifted pre-trade holdings versus target weights at rebalance events.
5. The apparent small impact is consistent with the turnover levels and 10-20 bps assumptions. Mid-cap and small-cap have visible but still modest drag; large-cap and total-market drag is very small.

## Assumptions

- The final best strategy per track/universe is the 20 bps row in `comparison/best_by_track_index_cost.csv`.
- Cost-drag summary metrics use the performance period that exactly matches the 20 bps best-strategy row. This matched `oos` for all eight final best strategies.
- Overlapping duplicated model-output rows were de-duplicated by full strategy/date identity before monthly and yearly aggregation.

## Conclusion

The transaction-cost math appears correct and the small transaction-cost impact is plausible. At 20 bps, even 100% annualized gross turnover produces only about 20 bps of simple annual drag. The selected mid-cap strategies are the highest-turnover cases and show the largest observed drag, while large-cap and total-market strategies turn over too little for 10-20 bps costs to materially change annualized returns.
