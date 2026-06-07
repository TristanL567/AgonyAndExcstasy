# AE-ALPHA Low-Volatility Implementation Specification

## Status

`specification_only`

This document converts the AE-ALPHA-001 source map into an implementation specification for later tickets. It does not implement portfolio construction, calculate returns or metrics, generate outputs, or modify source code.

## Scope

The AE-ALPHA low-volatility benchmark will compare existing CSI index-construction outputs against simple capitalization-weighted volatility quintile portfolios under aligned universe, timing, weighting, drift, turnover, transaction-cost, and metric definitions.

Headline comparison set:

- market-cap-weighted benchmark,
- existing CSI strategies from the 11C nonraw index suite,
- volatility quintiles `Q1` through `Q5`,
- primary contrasts: CSI versus `Q1`, CSI versus market benchmark, and CSI versus `Q5`.

## Required Input Sources

### Universe and benchmark alignment

Use the 11C index-replication input files as the canonical universe and benchmark sources:

- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
- `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`

`crsp_like_index_constituents_quarterly.rds` defines eligible CRSP-like index membership at each quarterly rebalance date. Required fields:

- `qdate`
- `index_id`
- `index_name`
- `permno`
- `security_mktcap`
- `weight`

`crsp_like_index_returns_monthly.rds` defines the aligned market benchmark monthly return series. Required fields:

- `date`
- `qdate`
- `index_id`
- `index_name`
- `port_ret`

`prices_monthly.rds` supplies firm-level returns and market capitalizations. Required fields:

- `permno`
- `date`
- `ret_adj`
- `mktcap`
- `dlret_applied`, if available for consistency with 11C drift logic.

### CSI comparison source

Use the existing CSI suite under:

`03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`

Canonical per-model/per-track files for later comparison:

- `index_returns_gross_and_net_by_tc.{rds,csv}`
- `index_weights_by_crsp_universe.{rds,csv}`
- `index_turnover_by_month.{rds,csv}`
- `index_performance_gross_and_net_by_tc.{rds,csv}`
- `index_exclusion_summary_by_crsp_universe.{rds,csv}`

The later comparison should preserve CSI outputs as read-only sources. Do not rerun or overwrite 11C outputs for this epic unless a later ticket explicitly authorizes it.

## Rebalance Cadence Decision

Default headline design: quarterly target formation, followed by monthly drifted returns.

Rationale:

- Existing 11C CSI index construction forms target weights at quarterly `qdate`s.
- Existing 11C returns are monthly drifted portfolios from those quarterly target weights.
- Using the same quarterly target formation makes CSI, market benchmark, and low-volatility quintiles comparable on timing, turnover, and transaction-cost exposure.
- The low-volatility benchmark is intended to test whether CSI adds information beyond a simple low-volatility sort, not whether monthly rebalancing itself adds value.

Tradeoff versus monthly literature-style construction:

- Baker, Bradley, and Wurgler-style low-volatility portfolios sort monthly, which is closer to the cited literature and gives more frequent signal refresh.
- Monthly formation can create higher turnover and different transaction-cost drag than CSI's quarterly target schedule.
- Monthly formation may be useful as a later sensitivity check, but it should not be the headline benchmark for CSI comparison unless the CSI strategy is also evaluated under comparable monthly timing.

Implementation requirement for later tickets:

- Build headline `Q1` through `Q5` targets only on quarterly constituent `qdate`s.
- Compute returns for months `date > qdate` and `date <= next_qdate`, matching the 11C holding-window convention.
- Optional monthly-sort diagnostics, if later authorized, must be labeled separately from the headline quarterly-aligned quintiles.

## Universe Definition

For each `qdate` and `index_id`, the low-volatility construction universe is the set of securities in `crsp_like_index_constituents_quarterly.rds` with valid `permno`.

Eligible securities for sorting must additionally have:

- at least 24 valid trailing monthly `ret_adj` observations before the rebalance month,
- finite trailing volatility,
- finite positive capitalization source for weighting.

Do not introduce securities outside the quarterly constituent file, even if they have valid returns in `prices_monthly.rds`.

The market benchmark for each `index_id` should be taken from `crsp_like_index_returns_monthly.rds`, not reconstructed for headline comparison, so the low-volatility benchmark stays aligned with the 11C benchmark source.

## Return Field

Use `ret_adj` from `prices_monthly.rds` for:

- trailing volatility estimation,
- realized monthly security returns in drifted quintile portfolios.

Do not use `ret_excl_div` for AE-ALPHA headline low-volatility construction.

## Volatility Signal

At each quarterly rebalance date `qdate`, estimate each security's total volatility from monthly adjusted returns available strictly before the rebalance month:

```text
sigma_i,qdate = sd(ret_adj_i over the last up to 60 valid monthly observations with date < qdate)
```

Rules:

- Use monthly `ret_adj`.
- Look back over at most 60 calendar months before `qdate`.
- Require at least 24 valid monthly returns.
- Use no return from `qdate` or any later month in the signal.
- Treat non-finite returns as missing for the signal window.
- Exclude securities with fewer than 24 valid returns or non-finite volatility from quintile assignment at that `qdate`.

The signal is total volatility, not beta, idiosyncratic volatility, or annualized volatility. Annualization is unnecessary for sorting because it is monotonic.

## Quintile Assignment

At each `qdate` and `index_id`, sort eligible securities by `sigma_i,qdate` ascending and assign five equal-count quintiles:

- `Q1`: lowest trailing volatility,
- `Q2`: second-lowest volatility,
- `Q3`: middle volatility,
- `Q4`: second-highest volatility,
- `Q5`: highest trailing volatility.

Equal-count rule:

- Quintiles should be as equal in security count as possible within each `qdate` and `index_id`.
- If the eligible count is not divisible by five, distribute the remainder deterministically across adjacent rank groups using the same ranking procedure for all universes.
- Resolve exact volatility ties deterministically with secondary sort keys: `sigma_i,qdate`, then descending capitalization source, then ascending `permno`.
- Do not use market-cap weights to define quintile breakpoints. Quintiles are count-sorted, then capitalization-weighted within each quintile.

## Capitalization Weighting

Use the quarterly constituent file as the default capitalization source for headline target weights:

1. Prefer `security_mktcap` when finite and positive.
2. If `security_mktcap` is unavailable for a row, use `weight` only to infer relative benchmark capitalization within the same `qdate` and `index_id`.
3. `prices_monthly.rds$mktcap` may be used only as a fallback after documenting the mismatch with the 11C constituent source.

For each quintile `Qk` at `qdate`:

```text
w_i,qdate^Qk = cap_i,qdate / sum_j_in_Qk cap_j,qdate
```

where `cap_i,qdate` is the selected positive capitalization source.

Rules:

- Target weights must sum to 1 within each `qdate`, `index_id`, and quintile.
- Exclude securities with missing or non-positive capitalization from that target portfolio.
- Preserve the benchmark universe identifier fields from the constituent source so later outputs can be joined to CSI and benchmark returns.

## Monthly Drifted Returns

Use monthly drifted-return mechanics consistent with 11C:

- Each quarterly target portfolio is held over monthly dates after `qdate` through the next `qdate`, inclusive of the endpoint convention used by 11C: `date > qdate` and `date <= next_qdate`.
- At the start of each holding month, merge current holdings to `prices_monthly.rds` returns for that month.
- Drop holdings without finite `ret_adj` for that month.
- Rescale surviving pre-return weights to sum to 1 before calculating monthly gross return.
- Monthly gross return is the weighted sum of realized `ret_adj`.
- After each month, drift holdings by multiplying pre-return weights by `1 + ret_adj`, drop non-finite or non-positive post-values, and renormalize to create the next month's pre-trade holdings.
- If `dlret_applied` is available, follow 11C behavior by excluding delisting-applied rows from the drifted carry-forward holdings after the realized return has been recognized.

Gross return formula:

```text
R_t^gross = sum_i w_i,t^- * ret_adj_i,t
```

where `w_i,t^-` is the rescaled pre-return weight after missing-return drops.

## Turnover and Transaction Costs

Turnover should be measured at rebalance months against drifted pre-trade holdings, consistent with 11C.

For each rebalance event:

```text
turnover_buy = sum_i max(w_i,target - w_i,pre_trade, 0)
turnover_sell = sum_i abs(min(w_i,target - w_i,pre_trade, 0))
turnover_gross = turnover_buy + turnover_sell
turnover_one_way = 0.5 * turnover_gross
```

For initial formation:

- pre-trade weights are zero,
- `turnover_basis = "initial_target_weights"`.

For subsequent rebalances:

- pre-trade weights are the holdings drifted through the previous holding window,
- `turnover_basis = "drifted_pre_trade_to_target"`.

For non-rebalance months:

- turnover fields should be zero,
- `turnover_basis = "no_rebalance"`.

Transaction-cost rules:

- Market benchmark: `0` bps only.
- Low-volatility quintiles: required levels `5`, `10`, and `20` bps.
- Include optional `0` bps low-volatility diagnostic for gross/net parity checks.

Net return formula:

```text
transaction_cost_return_drag_t = turnover_gross_t * transaction_cost_bps / 10000
R_t^net = R_t^gross - transaction_cost_return_drag_t
```

Use `turnover_gross` for transaction-cost drag to match existing 11C output semantics.

## Performance Metrics

Compute the following metrics for market benchmark, CSI strategies, and low-volatility quintiles in later tickets:

- geometric return,
- annualized volatility,
- Sharpe ratio,
- maximum drawdown,
- expected shortfall at 2.5 percent,
- turnover,
- transaction-cost drag.

Metric definitions should match 11C:

```text
annualized_geometric_return = prod(1 + R_t)^(12 / n_months) - 1
annualized_volatility = sd(R_t) * sqrt(12)
Sharpe = mean(R_t - rf_monthly) / sd(R_t - rf_monthly) * sqrt(12)
max_drawdown = min(cumprod(1 + R_t) / cumulative_peak - 1)
ES_2.5% = mean(R_t | R_t <= quantile_2.5%(R_t))
annualized_turnover_gross = sum(turnover_gross_t) / max(n_months / 12, 1)
TC_drag = sum(transaction_cost_return_drag_t)
```

Use net returns for net performance metrics and gross returns for gross-return diagnostics. Benchmark transaction-cost drag is zero by definition.

## Sector and Characteristic Alignment

Sector and characteristic diagnostics are not part of AE-ALPHA-003 headline portfolio construction, but later diagnostics should be alignable from this contract.

Sector source:

- Use SIC-derived sector grouping from available `sich` or `siccd` fields in pipeline panel/features files.
- Because no dedicated monthly sector file was found in AE-ALPHA-001, sector assignment must be lagged or carried forward from firm-year data into monthly holdings.

Characteristic source:

- Use existing CSI feature outputs under:
  - `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/`
  - `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/`

Later diagnostics should align firm-year features to monthly holdings using only information available before the holding month. Candidate diagnostic families include:

- size and market value: `log_mkvalt`, `log_at`, `mkt_to_book`,
- volatility: `vol_12m`, `vol_60m`, and realized trailing `ret_adj` volatility,
- solvency and leverage: `leverage`, `net_debt_ebitda`, `interest_cov`, `current_ratio`, `quick_ratio`,
- profitability and quality: `roa`, `roe`, `roic`, `gross_margin`, `ebitda_margin`, `ocf_margin`,
- Altman Z: `altman_z` and component fields,
- deterioration proxies: `peak_drop_*`, `consec_decline_*`, `yoy_*`, `accel_*`,
- liquidity proxies: monthly `vol` and `shrout` from `prices_monthly.rds`, if later specified.

## Future Output Contract

Later implementation tickets should write generated AE-ALPHA outputs only under:

`03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

Recommended output groups:

- `inputs_manifest/`
- `volatility_quintiles/`
- `weights/`
- `returns/`
- `turnover_costs/`
- `performance/`
- `comparisons/`
- `tilt_diagnostics/`
- `overlap_diagnostics/`
- `figures/`
- `reports/`

Required later file families:

- volatility signal and quintile assignments by `qdate`, `index_id`, `permno`,
- target weights by `qdate`, `index_id`, `quintile`, `permno`,
- monthly gross and net returns by `date`, `rebalance_date`, `index_id`, `quintile`, `transaction_cost_bps`,
- monthly turnover and transaction-cost drag,
- performance metrics by period, universe, portfolio, and transaction-cost level,
- CSI-versus-low-volatility comparison tables.

Every generated output should include enough identifiers to join against 11C CSI outputs:

- `track`, where applicable,
- `index_id`,
- `index_name`,
- `date`,
- `qdate` or `rebalance_date`,
- `portfolio_id` or `strategy_id`,
- `transaction_cost_bps`.

## Non-Goals

This specification does not:

- construct volatility quintile portfolios,
- calculate returns or performance metrics,
- generate files under `03_Data_Output`,
- change 11C CSI code,
- edit thesis or presentation files,
- stage, commit, or push changes.
