# AE-ALPHA Epic

## ticket_id

`AE-ALPHA`

## title

CSI Alpha Tilt Independence and Low-Volatility Quintile Benchmarking

## goal

Test whether CSI index performance is distinct from simple low-volatility, size, sector, and quality tilts by comparing market-weighted benchmarks, existing CSI strategies, and volatility-sorted quintile portfolios under the same universe, timing, weighting, turnover, and transaction-cost logic.

## research motivation

The thesis should not claim that CSI filtering proves persistent alpha unless the result survives simple tilt-based alternatives. The central validation question is:

> Does the CSI model add economically useful information beyond mechanical volatility control, generic quality tilts, size tilts, sector concentration, and benchmark reweighting?

The direct low-volatility comparison is not a time-series volatility-scaling test. It is a cross-sectional portfolio-sort benchmark:

- Market benchmark: fully invested market-cap-weighted universe.
- CSI strategy: existing CSI index construction, left unchanged.
- Low-volatility benchmark: market-cap-weighted volatility quintile portfolios, formed from trailing historical firm-level volatility.

This makes the comparison economically aligned with the CSI index construction. The core thesis test becomes:

> Does CSI select a better investable portfolio than a simple low-volatility sort?

## development branch

Validated changes for this epic should be committed on:

`development-lowvol`

Commit messages should include:

- epic id: `AE-ALPHA`
- ticket id
- short description

Example:

`AE-ALPHA-001 map inputs for low-vol tilt validation`

## source-paper methodology to incorporate

### Blitz and van Vliet low-volatility sort

Blitz and van Vliet (2007) motivate the low-volatility effect by sorting stocks on historical volatility and comparing low-risk and high-risk portfolios. Their implementation uses:

- monthly portfolio formation,
- historical volatility as the ranking signal,
- past 3-year volatility of weekly returns,
- decile portfolios,
- equal weighting in the reported main results,
- monthly rebalancing,
- transaction costs ignored,
- performance comparison using return, volatility, Sharpe ratio, beta/alpha, up/down market months, and maximum drawdown,
- controls using factor regressions and double sorts on size and book-to-market.

For this thesis, Blitz and van Vliet are used primarily as the conceptual low-volatility effect citation. The exact implementation is adapted to the current CSI index setting by using market-cap weights and five volatility quintiles.

### Baker, Bradley, and Wurgler volatility quintiles

Baker, Bradley, and Wurgler (2011; local file version labelled 2010) provide the closer implementation template for this epic. Their low-risk portfolio construction uses:

- CRSP monthly returns,
- monthly sorting into five volatility or beta groups,
- all stocks and a large-cap universe restricted to the top 1000 stocks by market capitalization,
- at least 24 months of return history,
- up to 60 months of trailing monthly returns to estimate total volatility or beta,
- capitalization weights within each quintile,
- monthly rebalancing,
- no transaction costs in the reported quintile exercise.

This epic adopts their quintile structure and capitalization-weighted construction because it fits the current index-construction framework better than equal-weighted deciles.

## adopted low-volatility benchmark specification

At rebalance month `t`, estimate trailing total volatility for firm `i` using monthly returns available before the rebalance:

```text
sigma_i,t = sd(r_i,t-60, ..., r_i,t-1)
```

Implementation requirements:

- use up to 60 months of trailing monthly returns,
- require at least 24 valid monthly returns,
- use only returns known before the rebalance month,
- sort eligible firms into five equal-count volatility quintiles,
- `Q1` is lowest volatility,
- `Q5` is highest volatility,
- calculate market-cap weights within each quintile.

For quintile `Qk`, the portfolio weight is:

```text
w_i,t^Qk = ME_i,t / sum_j_in_Qk ME_j,t
```

The benchmark has zero transaction costs. The CSI strategy keeps its existing transaction-cost setup. Volatility quintile portfolios must be evaluated at:

- 5 bps,
- 10 bps,
- 20 bps.

Turnover is:

```text
Turnover_t = 0.5 * sum_i abs(w_i,t^new - w_i,t^old_drifted)
```

Net return is:

```text
R_t^net = R_t^gross - cost_bps * Turnover_t
```

## required headline comparisons

Compare:

- market-weighted benchmark,
- existing CSI strategies,
- volatility `Q1` through `Q5`,
- especially `CSI` versus `Q1`,
- especially `CSI` versus `Q5`,
- optionally CSI versus characteristic-matched placebo portfolios in a later ticket.

## required performance metrics

For each benchmark/strategy/quintile:

- geometric return,
- annualized volatility,
- Sharpe ratio,
- maximum drawdown,
- expected shortfall at 2.5 percent,
- turnover,
- transaction-cost drag.

Expected shortfall:

```text
ES_2.5% = mean(R_t | R_t <= quantile_2.5%(R_t))
```

## interpretation logic

The low-volatility quintile benchmark supports the thesis interpretation as follows:

- If CSI behaves like `Q1`, CSI performance may mostly be a low-volatility tilt.
- If CSI beats `Q1`, CSI may add information beyond low volatility.
- If `Q5` performs poorly, the low-volatility anomaly background is present in the sample.
- If CSI avoids many `Q5` firms but performs better than simply holding `Q1`, CSI may be identifying structural impairment rather than volatility per se.
- If CSI does not beat `Q1`, the thesis should frame CSI as a more complex but not necessarily superior screening method.

## ticket roadmap

### AE-ALPHA-001 Source Mapping and Artifact Discovery

Read-only discovery. Identify all input files, existing CSI outputs, return series, weights, market caps, sector data, and firm characteristics needed to run the epic. No implementation.

### AE-ALPHA-002 Low-Volatility Specification Finalization

Write the exact implementation specification after source mapping: universe, eligible return field, market-cap field, rebalance dates, lookback window, minimum history, quintile sorting, tie handling, missing-data handling, transaction-cost assumptions, and output paths.

### AE-ALPHA-003 Volatility Quintile Portfolio Construction

Implement the volatility quintile portfolio builder. Produce monthly gross returns, net returns, weights, turnover, transaction-cost drag, and membership files for `Q1` through `Q5`.

### AE-ALPHA-004 Performance Metrics and Headline Tables

Compute geometric return, annualized volatility, Sharpe ratio, maximum drawdown, expected shortfall at 2.5 percent, turnover, and transaction-cost drag for benchmark, CSI, and volatility quintiles.

### AE-ALPHA-005 CSI versus Low-Volatility Interpretation Tables

Create comparison tables focused on `CSI` versus `Q1`, `CSI` versus market benchmark, and `CSI` versus `Q5`. State whether CSI appears to add information beyond a low-volatility tilt.

### AE-ALPHA-006 Characteristic Tilt Diagnostics

Compare benchmark, CSI, `Q1`, and `Q5` on size, sector weights, trailing volatility, drawdown, liquidity, leverage, profitability/quality proxies, Altman Z, and market-value deterioration.

### AE-ALPHA-007 Overlap Diagnostics

Compute overlap between CSI exclusions and volatility quintiles, especially:

```text
Overlap_Q5 = |Excluded_CSI intersect Q5| / |Excluded_CSI|
```

Also compute CSI portfolio exposure to each volatility quintile by weight.

### AE-ALPHA-008 Distributional Diagnostics

Produce return-distribution diagnostics: benchmark-versus-strategy scatter plots, QQ plots, active-return histograms, upside/downside capture, and tail-return comparisons.

### AE-ALPHA-009 Thesis Interpretation Report

Write the final thesis-facing interpretation: whether CSI outperforms the market benchmark, whether it outperforms low-volatility `Q1`, whether it is mainly a low-volatility/quality/sector/size tilt, and which claims are defensible.

## allowed output root

All generated alpha-validation outputs should be written under:

`03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

Documentation and tickets should be written under:

`05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/`

## must_not_touch

- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not overwrite existing canonical CSI outputs unless a ticket explicitly permits it.
- Do not alter existing CSI index construction logic unless a ticket explicitly permits it.
- Do not commit large generated output files.
- Do not edit thesis or presentation files unless a later ticket explicitly permits it.

## citations

Blitz, David C., and Pim van Vliet. 2007. "The Volatility Effect: Lower Risk without Lower Return." Journal of Portfolio Management 34(1): 102-113.

Baker, Malcolm, Brendan Bradley, and Jeffrey Wurgler. 2011. "Benchmarks as Limits to Arbitrage: Understanding the Low-Volatility Anomaly." Financial Analysts Journal 67(1): 40-54.
