# AE-ALPHA Risk-Return and CSI/Volatility-Overlap Summary

## Scope and Periods

This note summarizes the current AE-ALPHA outputs for manual validation. It compares:

- the market-weighted benchmark;
- volatility-sorted portfolios `Q1` to `Q5`, where `Q1` is lowest volatility and `Q5` is highest volatility;
- selected CSI strategies from the existing headline/best strategy rows.

The risk-return tables below use:

- benchmark at `0 bps` transaction costs;
- low-volatility quintile portfolios at `20 bps` transaction costs;
- selected CSI strategies at `20 bps` transaction costs;
- averages across the four universes: `large_cap`, `mid_cap`, `small_cap`, and `total_market`.

The period definitions follow the AE-ALPHA performance summaries:

| Period | Date Window |
|---|---|
| Test | 2016-01-29 to 2019-12-31 |
| OOS | 2020-01-31 to 2024-12-31 |

## Key Takeaways

1. The volatility buckets behave as expected: `Q1` has the lowest volatility and best downside profile, while `Q5` has the highest volatility and weakest drawdown/tail-risk profile.
2. CSI portfolios are closer to the benchmark than to pure `Q1`. CSI improves some benchmark-relative metrics, but it is not as defensive as `Q1`.
3. CSI exclusions strongly overlap with the high-volatility `Q5` bucket. This is clearest in the excluded-name shares, where most CSI-excluded names are in `Q5`.
4. CSI is not identical to a high-volatility exclusion rule. CSI retained portfolios still hold firms across all volatility buckets and keep meaningful `Q1` exposure.
5. The correct wording is therefore: CSI has substantial high-volatility overlap, especially in its excluded firms, but it should not be described as simply equivalent to a low-volatility or high-volatility sort.

## Test Period Risk-Return

Test period: `2016-01-29` to `2019-12-31`.

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark | 0 | 13.30% | 13.01% | 0.818 | -16.0% | -8.99% | n/a |
| LowVol Q1 | 20 | 13.71% | 9.73% | 1.084 | -9.3% | -6.69% | 79.2% |
| LowVol Q2 | 20 | 14.09% | 12.97% | 0.870 | -14.4% | -8.34% | 147.5% |
| LowVol Q3 | 20 | 13.20% | 15.48% | 0.711 | -19.0% | -10.35% | 165.0% |
| LowVol Q4 | 20 | 12.46% | 16.78% | 0.617 | -21.9% | -11.12% | 139.2% |
| HighVol Q5 | 20 | 9.41% | 21.09% | 0.407 | -26.4% | -14.99% | 122.9% |
| CSI dynamic | 20 | 13.59% | 12.53% | 0.861 | -15.2% | -8.68% | 41.6% |
| CSI permanent | 20 | 13.33% | 12.85% | 0.830 | -15.7% | -8.90% | 39.9% |

### Test Period Reading

- `Q1` is the strongest risk-adjusted portfolio in the test window. It has the lowest volatility, best Sharpe, least severe drawdown, and least severe ES 2.5%.
- `Q5` is clearly the weakest bucket. It has the lowest return, highest volatility, weakest Sharpe, and worst tail-risk profile.
- CSI dynamic and permanent are close to the benchmark in risk level, but with slightly better Sharpe and slightly lower volatility.
- CSI turnover is materially lower than the volatility buckets, especially relative to `Q2` to `Q4`.
- In the test period, CSI does not beat `Q1` on risk-adjusted performance, but it avoids the severe risk profile of `Q5`.

## OOS Period Risk-Return

OOS period: `2020-01-31` to `2024-12-31`.

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark | 0 | 11.22% | 20.51% | 0.491 | -25.9% | -13.10% | n/a |
| LowVol Q1 | 20 | 7.80% | 16.86% | 0.361 | -23.0% | -11.94% | 82.8% |
| LowVol Q2 | 20 | 12.05% | 20.04% | 0.524 | -24.7% | -12.70% | 141.1% |
| LowVol Q3 | 20 | 13.26% | 22.69% | 0.523 | -29.1% | -14.88% | 160.9% |
| LowVol Q4 | 20 | 14.44% | 27.37% | 0.510 | -33.8% | -15.99% | 159.0% |
| HighVol Q5 | 20 | 13.05% | 31.23% | 0.469 | -43.1% | -18.73% | 124.5% |
| CSI dynamic | 20 | 11.53% | 19.90% | 0.515 | -25.4% | -12.87% | 53.7% |
| CSI permanent | 20 | 11.50% | 20.38% | 0.507 | -25.8% | -13.11% | 50.1% |

### OOS Period Reading

- The OOS window is different from the test window: `Q1` remains defensive but does not deliver the highest return.
- `Q5` has high raw return in OOS, but this comes with very high volatility, the worst drawdown, and the worst ES 2.5%.
- CSI dynamic and permanent are close to the benchmark on return, volatility, drawdown, and tail risk, with slightly higher Sharpe.
- CSI does not look like pure `Q1` in OOS. Its volatility and drawdown profile are benchmark-like rather than strongly defensive.
- CSI also does not look like `Q5`: it avoids the very high volatility and severe drawdowns of the high-volatility bucket.

## CSI and Volatility-Bucket Overlap

The overlap diagnostics use CSI-selected headline/best rows and existing low-volatility quintile assignments.

Definitions:

- `ExcludedNameShare`: share of CSI-excluded firm names assigned to a given volatility quintile.
- `ExcludedWeightShare`: share of CSI-excluded benchmark weight assigned to a given volatility quintile.
- `RetainedWeightShare`: share of CSI retained portfolio weight assigned to a given volatility quintile.
- `ActiveVsBenchmark`: retained CSI weight share minus benchmark weight share in that quintile.

Important interpretation:

- High `ExcludedNameShare` in `Q5` means CSI exclusions are concentrated in high-volatility firms.
- High `RetainedWeightShare` in `Q1` means the remaining CSI portfolio still holds low-volatility firms.
- Negative `ActiveVsBenchmark` in `Q5` means CSI retained portfolios are underweight high-volatility firms relative to the benchmark.

## Test Period CSI/Volatility Overlap

Test period: `2016-01-29` to `2019-12-31`.

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
|---|---|---:|---:|---:|---:|
| Dynamic CSI | Q1 | 1.0% | 1.2% | 34.9% | +2.6pp |
| Dynamic CSI | Q2 | 2.1% | 6.2% | 24.7% | +1.5pp |
| Dynamic CSI | Q3 | 6.6% | 10.8% | 17.7% | +0.5pp |
| Dynamic CSI | Q4 | 19.9% | 22.0% | 14.7% | -0.9pp |
| Dynamic CSI | Q5 | 70.4% | 59.8% | 8.1% | -3.7pp |
| Permanent CSI | Q1 | 0.9% | 2.9% | 33.2% | +0.9pp |
| Permanent CSI | Q2 | 5.8% | 13.2% | 23.6% | +0.4pp |
| Permanent CSI | Q3 | 8.9% | 15.3% | 17.3% | +0.2pp |
| Permanent CSI | Q4 | 19.1% | 20.3% | 15.5% | -0.1pp |
| Permanent CSI | Q5 | 65.3% | 48.4% | 10.4% | -1.4pp |

### Test Period Overlap Reading

- CSI exclusions are heavily concentrated in `Q5`.
- Dynamic CSI excludes about `70.4%` of names from `Q5`; permanent CSI excludes about `65.3%` of names from `Q5`.
- Q1 exclusions are almost zero: `1.0%` for dynamic CSI and `0.9%` for permanent CSI.
- Retained CSI portfolios still hold large `Q1` weights: `34.9%` for dynamic CSI and `33.2%` for permanent CSI.
- CSI retained portfolios are underweight `Q5` relative to the benchmark.

## OOS Period CSI/Volatility Overlap

OOS period: `2020-01-31` to `2024-12-31`.

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
|---|---|---:|---:|---:|---:|
| Dynamic CSI | Q1 | 1.0% | 1.4% | 36.3% | +4.4pp |
| Dynamic CSI | Q2 | 3.6% | 7.8% | 24.6% | +2.1pp |
| Dynamic CSI | Q3 | 9.1% | 12.3% | 18.5% | +0.5pp |
| Dynamic CSI | Q4 | 20.6% | 21.3% | 12.9% | -2.0pp |
| Dynamic CSI | Q5 | 65.7% | 57.2% | 7.7% | -5.0pp |
| Permanent CSI | Q1 | 2.3% | 4.5% | 33.1% | +1.2pp |
| Permanent CSI | Q2 | 6.5% | 10.3% | 23.1% | +0.6pp |
| Permanent CSI | Q3 | 10.6% | 14.2% | 18.2% | +0.2pp |
| Permanent CSI | Q4 | 22.7% | 23.8% | 14.5% | -0.4pp |
| Permanent CSI | Q5 | 58.0% | 47.2% | 11.0% | -1.6pp |

### OOS Period Overlap Reading

- The same pattern holds OOS: CSI exclusions are concentrated in `Q5`, while retained portfolios preserve meaningful exposure to lower-volatility buckets.
- Dynamic CSI excludes about `65.7%` of names from `Q5`; permanent CSI excludes about `58.0%` of names from `Q5`.
- Q1 exclusions remain very low: `1.0%` for dynamic CSI and `2.3%` for permanent CSI.
- Retained CSI portfolios remain strongly weighted to `Q1`: `36.3%` dynamic CSI and `33.1%` permanent CSI.
- CSI retained portfolios are again underweight `Q5` relative to the benchmark.

## Per-Universe Risk-Return Tables

These tables expand the aggregate Test and OOS risk-return summaries above without changing the four existing summary table blocks.

### Test - Total

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 13.75% | 12.05% | 0.889 | -14.6% | -8.44% | n/a |
| LowVol Q1 | 20 | 13.90% | 9.86% | 1.076 | -9.3% | -6.61% | 33.1% |
| LowVol Q2 | 20 | 15.21% | 14.71% | 0.840 | -18.8% | -9.70% | 88.2% |
| LowVol Q3 | 20 | 11.04% | 17.74% | 0.515 | -24.3% | -12.41% | 127.8% |
| LowVol Q4 | 20 | 11.82% | 17.65% | 0.556 | -23.9% | -11.66% | 90.4% |
| HighVol Q5 | 20 | 7.57% | 24.82% | 0.300 | -30.6% | -18.28% | 93.1% |
| CSI dynamic | 20 | 14.19% | 11.56% | 0.955 | -13.7% | -8.07% | 9.5% |
| CSI permanent | 20 | 13.85% | 11.87% | 0.908 | -14.4% | -8.32% | 6.9% |

### Test - Large

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 14.18% | 11.60% | 0.952 | -13.8% | -8.02% | n/a |
| LowVol Q1 | 20 | 13.45% | 9.09% | 1.116 | -7.9% | -6.55% | 64.4% |
| LowVol Q2 | 20 | 12.31% | 10.79% | 0.860 | -11.1% | -6.99% | 144.9% |
| LowVol Q3 | 20 | 17.35% | 13.53% | 1.039 | -13.7% | -8.44% | 167.9% |
| LowVol Q4 | 20 | 15.43% | 15.11% | 0.835 | -20.1% | -9.86% | 136.0% |
| HighVol Q5 | 20 | 10.67% | 18.22% | 0.487 | -25.1% | -13.01% | 95.3% |
| CSI dynamic | 20 | 14.45% | 11.31% | 0.994 | -13.3% | -7.79% | 12.2% |
| CSI permanent | 20 | 14.22% | 11.47% | 0.964 | -13.6% | -7.93% | 10.9% |

### Test - Mid

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 13.82% | 12.85% | 0.846 | -15.3% | -8.68% | n/a |
| LowVol Q1 | 20 | 14.36% | 8.71% | 1.252 | -7.1% | -5.43% | 120.6% |
| LowVol Q2 | 20 | 15.44% | 11.40% | 1.063 | -9.9% | -6.64% | 195.3% |
| LowVol Q3 | 20 | 13.24% | 14.21% | 0.741 | -17.3% | -9.95% | 198.8% |
| LowVol Q4 | 20 | 11.20% | 16.51% | 0.549 | -20.6% | -10.90% | 181.4% |
| HighVol Q5 | 20 | 12.61% | 19.13% | 0.564 | -22.5% | -13.12% | 173.5% |
| CSI dynamic | 20 | 13.68% | 12.78% | 0.840 | -15.3% | -8.69% | 82.6% |
| CSI permanent | 20 | 13.92% | 12.67% | 0.863 | -15.0% | -8.59% | 82.2% |

### Test - Small

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 11.44% | 15.55% | 0.586 | -20.1% | -10.80% | n/a |
| LowVol Q1 | 20 | 13.13% | 11.25% | 0.895 | -12.8% | -8.18% | 98.8% |
| LowVol Q2 | 20 | 13.38% | 14.98% | 0.719 | -17.6% | -10.02% | 161.6% |
| LowVol Q3 | 20 | 11.16% | 16.44% | 0.547 | -20.5% | -10.59% | 165.4% |
| LowVol Q4 | 20 | 11.40% | 17.86% | 0.530 | -23.0% | -12.05% | 149.0% |
| HighVol Q5 | 20 | 6.79% | 22.18% | 0.274 | -27.4% | -15.56% | 129.9% |
| CSI dynamic | 20 | 12.04% | 14.48% | 0.656 | -18.4% | -10.17% | 62.0% |
| CSI permanent | 20 | 11.32% | 15.38% | 0.584 | -20.0% | -10.75% | 59.4% |

### OOS - Total

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 13.29% | 19.03% | 0.598 | -25.0% | -11.62% | n/a |
| LowVol Q1 | 20 | 10.79% | 16.40% | 0.528 | -21.6% | -10.28% | 34.5% |
| LowVol Q2 | 20 | 15.64% | 21.46% | 0.649 | -25.3% | -12.65% | 83.9% |
| LowVol Q3 | 20 | 22.02% | 25.90% | 0.789 | -31.7% | -16.61% | 78.8% |
| LowVol Q4 | 20 | 22.76% | 36.64% | 0.656 | -47.2% | -16.97% | 89.0% |
| HighVol Q5 | 20 | 5.77% | 37.38% | 0.254 | -59.7% | -21.92% | 92.0% |
| CSI dynamic | 20 | 13.70% | 18.28% | 0.634 | -23.8% | -11.22% | 10.4% |
| CSI permanent | 20 | 13.54% | 18.82% | 0.614 | -24.7% | -11.45% | 6.8% |

### OOS - Large

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 14.28% | 18.49% | 0.657 | -24.8% | -10.84% | n/a |
| LowVol Q1 | 20 | 8.81% | 15.52% | 0.432 | -19.0% | -10.00% | 63.0% |
| LowVol Q2 | 20 | 11.69% | 17.26% | 0.557 | -21.6% | -10.53% | 136.6% |
| LowVol Q3 | 20 | 11.74% | 18.77% | 0.529 | -28.2% | -11.48% | 179.6% |
| LowVol Q4 | 20 | 15.05% | 22.25% | 0.610 | -26.4% | -13.04% | 158.6% |
| HighVol Q5 | 20 | 28.21% | 28.12% | 0.925 | -36.5% | -15.42% | 66.0% |
| CSI dynamic | 20 | 14.40% | 17.98% | 0.676 | -23.9% | -10.65% | 13.0% |
| CSI permanent | 20 | 14.48% | 18.38% | 0.670 | -24.5% | -10.74% | 11.5% |

### OOS - Mid

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 9.65% | 20.72% | 0.406 | -24.6% | -13.83% | n/a |
| LowVol Q1 | 20 | 5.52% | 16.43% | 0.230 | -22.1% | -11.90% | 113.9% |
| LowVol Q2 | 20 | 10.85% | 19.06% | 0.482 | -22.4% | -11.86% | 181.9% |
| LowVol Q3 | 20 | 8.98% | 21.16% | 0.373 | -25.8% | -14.23% | 226.7% |
| LowVol Q4 | 20 | 10.23% | 23.77% | 0.405 | -28.7% | -16.83% | 222.1% |
| HighVol Q5 | 20 | 12.34% | 27.30% | 0.453 | -32.2% | -17.27% | 186.1% |
| CSI dynamic | 20 | 9.93% | 20.69% | 0.419 | -24.5% | -13.85% | 105.9% |
| CSI permanent | 20 | 10.16% | 20.57% | 0.431 | -24.5% | -13.90% | 106.2% |

### OOS - Small

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
|---|---:|---:|---:|---:|---:|---:|---:|
| Benchmark |  0 | 7.65% | 23.80% | 0.305 | -29.0% | -16.12% | n/a |
| LowVol Q1 | 20 | 6.09% | 19.11% | 0.253 | -29.1% | -15.58% | 119.6% |
| LowVol Q2 | 20 | 10.04% | 22.37% | 0.409 | -29.4% | -15.76% | 162.0% |
| LowVol Q3 | 20 | 10.29% | 24.93% | 0.400 | -30.7% | -17.21% | 158.7% |
| LowVol Q4 | 20 | 9.74% | 26.82% | 0.370 | -32.9% | -17.10% | 166.4% |
| HighVol Q5 | 20 | 5.89% | 32.10% | 0.244 | -43.9% | -20.32% | 154.0% |
| CSI dynamic | 20 | 8.11% | 22.64% | 0.328 | -29.3% | -15.77% | 85.5% |
| CSI permanent | 20 | 7.82% | 23.77% | 0.312 | -29.3% | -16.35% | 75.7% |

## How to State the Result

Preferred wording:

> CSI exclusions are strongly concentrated in high-volatility `Q5`, while CSI retained portfolios remain diversified across all volatility buckets and retain substantial low-volatility `Q1` exposure.

Avoid wording:

> CSI is just a low-volatility strategy.

Also avoid:

> CSI is independent of volatility.

The current evidence supports a middle position:

- CSI clearly captures many high-volatility names through its exclusion mechanism.
- CSI is not a pure volatility sort because it does not remove all high-volatility firms, does not only hold `Q1`, and retains exposure across `Q1` to `Q5`.
- The risk-return characteristics of CSI are benchmark-like to moderately defensive, not as defensive as `Q1` and not as risky as `Q5`.

## Manual Validation Checklist

Before using these numbers in thesis text:

1. Confirm that the selected CSI rows are the intended headline/best strategies.
2. Decide whether thesis tables should show `20 bps` costs as the headline case or also include `0 bps` as a robustness view.
3. Treat the OOS period carefully if it is primarily used for index construction rather than model selection.
4. Keep the overlap interpretation separate from causal return attribution.
5. Use the overlap result as composition evidence, not as proof that CSI alpha is or is not a volatility effect.
