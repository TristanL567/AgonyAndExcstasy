# AE-ALPHA Risk-Return and Overlap Summary

AE-ALPHA-010 creates the per-universe Test and OOS table data requested after AE-ALPHA-009. The named summary file was not present on `development-lowvol`, so this ticket creates it as the table-ready supplement while preserving the prior ticket reports.

Interpretation guardrail: the tables compare realized risk-return and low-volatility quintile overlap. They do not claim that CSI exclusions causally generate alpha, and they do not rerun modelling, low-volatility construction, or CSI index construction.

## Generated Table Data

- Risk-return table data: `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_risk_return_table_data.csv` (64 rows).
- Overlap table data: `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_overlap_table_data.csv` (80 rows).
- Validation checks: `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_validation_checks.csv`.
- Source traceability: `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_source_traceability.csv`.

## Coverage

- Periods: Test and OOS.
- Universes: Total, Large, Mid, Small.
- Risk-return rows: benchmark at 0 bps, low-volatility Q1-Q5 at 20 bps, headline temporary CSI at 20 bps, headline permanent CSI at 20 bps.
- Overlap rows: headline temporary and permanent CSI at 20 bps by low-volatility quintile Q1-Q5.

## How to Read These Tables

- Benchmark is the zero-cost market-weighted benchmark.
- LowVol quintiles and selected CSI rows are shown at 20 bps.
- The evidence is descriptive composition/performance evidence, not causal proof.

## Full Per-Universe Risk-Return Tables

### Test (2016-01-29 to 2019-12-31)

#### Total

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 13.75% | 12.05% | 0.89 | -14.62% | -8.44% | n/a |
| LowVol Q1 | 20 | 13.90% | 9.86% | 1.08 | -9.34% | -6.61% | 33.07% |
| LowVol Q2 | 20 | 15.21% | 14.71% | 0.84 | -18.79% | -9.70% | 88.23% |
| LowVol Q3 | 20 | 11.04% | 17.74% | 0.51 | -24.28% | -12.41% | 127.77% |
| LowVol Q4 | 20 | 11.82% | 17.65% | 0.56 | -23.93% | -11.66% | 90.36% |
| HighVol Q5 | 20 | 7.57% | 24.82% | 0.30 | -30.61% | -18.28% | 93.06% |
| CSI dynamic | 20 | 14.19% | 11.56% | 0.95 | -13.72% | -8.07% | 9.46% |
| CSI permanent | 20 | 13.85% | 11.87% | 0.91 | -14.37% | -8.32% | 6.94% |

#### Large

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 14.18% | 11.60% | 0.95 | -13.82% | -8.02% | n/a |
| LowVol Q1 | 20 | 13.45% | 9.09% | 1.12 | -7.92% | -6.55% | 64.40% |
| LowVol Q2 | 20 | 12.31% | 10.79% | 0.86 | -11.10% | -6.99% | 144.93% |
| LowVol Q3 | 20 | 17.35% | 13.53% | 1.04 | -13.72% | -8.44% | 167.91% |
| LowVol Q4 | 20 | 15.43% | 15.11% | 0.83 | -20.10% | -9.86% | 135.98% |
| HighVol Q5 | 20 | 10.67% | 18.22% | 0.49 | -25.10% | -13.01% | 95.34% |
| CSI dynamic | 20 | 14.45% | 11.31% | 0.99 | -13.27% | -7.79% | 12.18% |
| CSI permanent | 20 | 14.22% | 11.47% | 0.96 | -13.63% | -7.93% | 10.89% |

#### Mid

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 13.82% | 12.85% | 0.85 | -15.30% | -8.68% | n/a |
| LowVol Q1 | 20 | 14.36% | 8.71% | 1.25 | -7.07% | -5.43% | 120.56% |
| LowVol Q2 | 20 | 15.44% | 11.40% | 1.06 | -9.94% | -6.64% | 195.28% |
| LowVol Q3 | 20 | 13.24% | 14.21% | 0.74 | -17.32% | -9.95% | 198.85% |
| LowVol Q4 | 20 | 11.20% | 16.51% | 0.55 | -20.58% | -10.90% | 181.44% |
| HighVol Q5 | 20 | 12.61% | 19.13% | 0.56 | -22.55% | -13.12% | 173.45% |
| CSI dynamic | 20 | 13.68% | 12.78% | 0.84 | -15.33% | -8.69% | 82.58% |
| CSI permanent | 20 | 13.92% | 12.67% | 0.86 | -14.97% | -8.59% | 82.21% |

#### Small

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 11.44% | 15.55% | 0.59 | -20.07% | -10.80% | n/a |
| LowVol Q1 | 20 | 13.13% | 11.25% | 0.89 | -12.81% | -8.18% | 98.75% |
| LowVol Q2 | 20 | 13.38% | 14.98% | 0.72 | -17.58% | -10.02% | 161.61% |
| LowVol Q3 | 20 | 11.16% | 16.44% | 0.55 | -20.54% | -10.59% | 165.43% |
| LowVol Q4 | 20 | 11.40% | 17.86% | 0.53 | -23.00% | -12.05% | 149.02% |
| HighVol Q5 | 20 | 6.79% | 22.18% | 0.27 | -27.36% | -15.56% | 129.87% |
| CSI dynamic | 20 | 12.04% | 14.48% | 0.66 | -18.38% | -10.17% | 61.99% |
| CSI permanent | 20 | 11.32% | 15.38% | 0.58 | -19.98% | -10.75% | 59.41% |

### OOS (2020-01-31 to 2024-12-31)

#### Total

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 13.29% | 19.03% | 0.60 | -25.03% | -11.62% | n/a |
| LowVol Q1 | 20 | 10.79% | 16.40% | 0.53 | -21.59% | -10.28% | 34.53% |
| LowVol Q2 | 20 | 15.64% | 21.46% | 0.65 | -25.25% | -12.65% | 83.85% |
| LowVol Q3 | 20 | 22.02% | 25.90% | 0.79 | -31.70% | -16.61% | 78.79% |
| LowVol Q4 | 20 | 22.76% | 36.64% | 0.66 | -47.18% | -16.97% | 89.02% |
| HighVol Q5 | 20 | 5.77% | 37.38% | 0.25 | -59.70% | -21.92% | 91.98% |
| CSI dynamic | 20 | 13.70% | 18.28% | 0.63 | -23.79% | -11.22% | 10.37% |
| CSI permanent | 20 | 13.54% | 18.82% | 0.61 | -24.73% | -11.45% | 6.80% |

#### Large

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 14.28% | 18.49% | 0.66 | -24.79% | -10.84% | n/a |
| LowVol Q1 | 20 | 8.81% | 15.52% | 0.43 | -19.01% | -10.00% | 62.97% |
| LowVol Q2 | 20 | 11.69% | 17.26% | 0.56 | -21.59% | -10.53% | 136.56% |
| LowVol Q3 | 20 | 11.74% | 18.77% | 0.53 | -28.17% | -11.48% | 179.56% |
| LowVol Q4 | 20 | 15.05% | 22.25% | 0.61 | -26.41% | -13.04% | 158.63% |
| HighVol Q5 | 20 | 28.21% | 28.12% | 0.92 | -36.48% | -15.42% | 66.00% |
| CSI dynamic | 20 | 14.40% | 17.98% | 0.68 | -23.90% | -10.65% | 13.04% |
| CSI permanent | 20 | 14.48% | 18.38% | 0.67 | -24.52% | -10.74% | 11.51% |

#### Mid

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 9.65% | 20.72% | 0.41 | -24.58% | -13.83% | n/a |
| LowVol Q1 | 20 | 5.52% | 16.43% | 0.23 | -22.14% | -11.90% | 113.94% |
| LowVol Q2 | 20 | 10.85% | 19.06% | 0.48 | -22.43% | -11.86% | 181.89% |
| LowVol Q3 | 20 | 8.98% | 21.16% | 0.37 | -25.84% | -14.23% | 226.70% |
| LowVol Q4 | 20 | 10.23% | 23.77% | 0.40 | -28.72% | -16.83% | 222.06% |
| HighVol Q5 | 20 | 12.34% | 27.30% | 0.45 | -32.20% | -17.27% | 186.12% |
| CSI dynamic | 20 | 9.93% | 20.69% | 0.42 | -24.46% | -13.85% | 105.86% |
| CSI permanent | 20 | 10.16% | 20.57% | 0.43 | -24.52% | -13.90% | 106.24% |

#### Small

| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Naive benchmark |  0 | 7.65% | 23.80% | 0.31 | -29.05% | -16.12% | n/a |
| LowVol Q1 | 20 | 6.09% | 19.11% | 0.25 | -29.11% | -15.58% | 119.64% |
| LowVol Q2 | 20 | 10.04% | 22.37% | 0.41 | -29.42% | -15.76% | 161.97% |
| LowVol Q3 | 20 | 10.29% | 24.93% | 0.40 | -30.68% | -17.21% | 158.72% |
| LowVol Q4 | 20 | 9.74% | 26.82% | 0.37 | -32.94% | -17.10% | 166.44% |
| HighVol Q5 | 20 | 5.89% | 32.10% | 0.24 | -43.88% | -20.32% | 153.98% |
| CSI dynamic | 20 | 8.11% | 22.64% | 0.33 | -29.33% | -15.77% | 85.49% |
| CSI permanent | 20 | 7.82% | 23.77% | 0.31 | -29.26% | -16.35% | 75.73% |


## Full Per-Universe CSI/Volatility-Overlap Tables

### Test (2016-01-29 to 2019-12-31)

#### Total

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 1.88% | 3.17% | 59.09% | +4.06 pp |
| Dynamic CSI | Q2 | 4.35% | 18.24% | 29.64% | +0.81 pp |
| Dynamic CSI | Q3 | 14.96% | 25.98% | 8.49% | -1.29 pp |
| Dynamic CSI | Q4 | 33.25% | 33.14% | 2.59% | -2.23 pp |
| Dynamic CSI | Q5 | 45.56% | 19.47% | 0.19% | -1.34 pp |
| Permanent CSI | Q1 | 1.18% | 7.26% | 56.31% | +1.28 pp |
| Permanent CSI | Q2 | 3.29% | 31.82% | 28.74% | -0.09 pp |
| Permanent CSI | Q3 | 9.51% | 25.38% | 9.37% | -0.41 pp |
| Permanent CSI | Q4 | 25.30% | 17.98% | 4.47% | -0.35 pp |
| Permanent CSI | Q5 | 60.72% | 17.55% | 1.10% | -0.43 pp |

#### Large

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 0.52% | 0.37% | 30.04% | +1.35 pp |
| Dynamic CSI | Q2 | 1.42% | 1.85% | 22.85% | +0.99 pp |
| Dynamic CSI | Q3 | 3.64% | 6.70% | 19.39% | +0.57 pp |
| Dynamic CSI | Q4 | 15.38% | 21.58% | 19.65% | -0.05 pp |
| Dynamic CSI | Q5 | 79.03% | 69.51% | 8.07% | -2.86 pp |
| Permanent CSI | Q1 | 0.00% | 0.00% | 29.19% | +0.50 pp |
| Permanent CSI | Q2 | 5.08% | 4.97% | 22.16% | +0.30 pp |
| Permanent CSI | Q3 | 13.14% | 21.61% | 18.76% | -0.05 pp |
| Permanent CSI | Q4 | 19.79% | 32.06% | 19.47% | -0.22 pp |
| Permanent CSI | Q5 | 61.99% | 41.37% | 10.41% | -0.52 pp |

#### Mid

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 0.00% | 0.00% | 20.68% | +0.06 pp |
| Dynamic CSI | Q2 | 0.00% | 0.00% | 20.52% | +0.06 pp |
| Dynamic CSI | Q3 | 0.00% | 0.00% | 20.02% | +0.06 pp |
| Dynamic CSI | Q4 | 0.00% | 0.00% | 20.01% | +0.06 pp |
| Dynamic CSI | Q5 | 100.00% | 100.00% | 18.77% | -0.23 pp |
| Permanent CSI | Q1 | 0.39% | 0.38% | 21.40% | +0.78 pp |
| Permanent CSI | Q2 | 8.17% | 8.95% | 20.91% | +0.46 pp |
| Permanent CSI | Q3 | 4.47% | 4.73% | 20.54% | +0.58 pp |
| Permanent CSI | Q4 | 10.04% | 9.88% | 20.35% | +0.40 pp |
| Permanent CSI | Q5 | 76.93% | 76.06% | 16.79% | -2.21 pp |

#### Small

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 1.05% | 0.86% | 29.68% | +5.10 pp |
| Dynamic CSI | Q2 | 2.00% | 2.56% | 25.94% | +4.13 pp |
| Dynamic CSI | Q3 | 5.45% | 6.29% | 22.75% | +2.85 pp |
| Dynamic CSI | Q4 | 23.44% | 24.99% | 16.38% | -1.53 pp |
| Dynamic CSI | Q5 | 68.07% | 65.31% | 5.25% | -10.54 pp |
| Permanent CSI | Q1 | 2.05% | 3.78% | 25.72% | +1.14 pp |
| Permanent CSI | Q2 | 6.47% | 7.11% | 22.61% | +0.80 pp |
| Permanent CSI | Q3 | 8.52% | 9.34% | 20.47% | +0.58 pp |
| Permanent CSI | Q4 | 21.24% | 21.22% | 17.74% | -0.18 pp |
| Permanent CSI | Q5 | 61.73% | 58.56% | 13.45% | -2.34 pp |

### OOS (2020-01-31 to 2024-12-31)

#### Total

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 2.18% | 3.79% | 63.21% | +6.79 pp |
| Dynamic CSI | Q2 | 7.95% | 24.43% | 27.18% | +0.34 pp |
| Dynamic CSI | Q3 | 19.92% | 32.25% | 7.95% | -2.67 pp |
| Dynamic CSI | Q4 | 32.78% | 29.05% | 1.54% | -3.26 pp |
| Dynamic CSI | Q5 | 37.16% | 10.48% | 0.11% | -1.19 pp |
| Permanent CSI | Q1 | 1.19% | 8.08% | 58.09% | +1.67 pp |
| Permanent CSI | Q2 | 3.30% | 19.63% | 27.10% | +0.25 pp |
| Permanent CSI | Q3 | 10.94% | 24.91% | 10.11% | -0.51 pp |
| Permanent CSI | Q4 | 30.38% | 26.36% | 4.07% | -0.73 pp |
| Permanent CSI | Q5 | 54.19% | 21.02% | 0.62% | -0.68 pp |

#### Large

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 0.61% | 0.48% | 29.37% | +2.38 pp |
| Dynamic CSI | Q2 | 2.03% | 1.38% | 22.21% | +1.72 pp |
| Dynamic CSI | Q3 | 4.44% | 4.64% | 22.23% | +1.45 pp |
| Dynamic CSI | Q4 | 20.58% | 27.03% | 16.87% | -0.81 pp |
| Dynamic CSI | Q5 | 72.33% | 66.47% | 9.31% | -4.74 pp |
| Permanent CSI | Q1 | 2.09% | 1.91% | 27.49% | +0.49 pp |
| Permanent CSI | Q2 | 8.46% | 6.13% | 20.78% | +0.29 pp |
| Permanent CSI | Q3 | 8.10% | 5.52% | 21.09% | +0.31 pp |
| Permanent CSI | Q4 | 20.78% | 25.89% | 17.51% | -0.16 pp |
| Permanent CSI | Q5 | 60.58% | 60.55% | 13.12% | -0.93 pp |

#### Mid

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 0.00% | 0.00% | 20.80% | +0.36 pp |
| Dynamic CSI | Q2 | 0.00% | 0.00% | 20.66% | +0.36 pp |
| Dynamic CSI | Q3 | 0.00% | 0.00% | 20.60% | +0.36 pp |
| Dynamic CSI | Q4 | 0.00% | 0.00% | 19.97% | +0.35 pp |
| Dynamic CSI | Q5 | 100.00% | 100.00% | 17.98% | -1.43 pp |
| Permanent CSI | Q1 | 3.34% | 4.15% | 21.51% | +1.08 pp |
| Permanent CSI | Q2 | 7.74% | 7.90% | 21.10% | +0.81 pp |
| Permanent CSI | Q3 | 11.79% | 12.59% | 20.74% | +0.50 pp |
| Permanent CSI | Q4 | 14.28% | 14.91% | 19.90% | +0.28 pp |
| Permanent CSI | Q5 | 62.85% | 60.44% | 16.74% | -2.66 pp |

#### Small

| Track | Quintile | Excluded Name Share | Excluded Weight Share | Retained Weight Share | Active vs Benchmark |
| --- | --- | --- | --- | --- | --- |
| Dynamic CSI | Q1 | 1.21% | 1.41% | 32.00% | +8.07 pp |
| Dynamic CSI | Q2 | 4.46% | 5.35% | 28.40% | +6.06 pp |
| Dynamic CSI | Q3 | 12.05% | 12.43% | 23.15% | +2.77 pp |
| Dynamic CSI | Q4 | 28.85% | 29.12% | 13.24% | -4.20 pp |
| Dynamic CSI | Q5 | 53.43% | 51.68% | 3.20% | -12.70 pp |
| Permanent CSI | Q1 | 2.69% | 3.78% | 25.44% | +1.51 pp |
| Permanent CSI | Q2 | 6.34% | 7.65% | 23.45% | +1.10 pp |
| Permanent CSI | Q3 | 11.47% | 13.93% | 20.87% | +0.49 pp |
| Permanent CSI | Q4 | 25.19% | 27.90% | 16.64% | -0.80 pp |
| Permanent CSI | Q5 | 54.32% | 46.74% | 13.60% | -2.30 pp |


## Source Notes

- Benchmark and low-volatility rows come from AE-ALPHA alpha-validation performance summaries.
- CSI rows come from the headline CSI-vs-low-vol comparison artifact and use the ticket-required 20 bps selected strategies.
- Overlap summaries are periodized from dated overlap/exposure detail artifacts using Test 2016-2019 and OOS 2020-2024 windows because the existing overlap summary artifact is full-sample only.
- All generated outputs are table data or documentation. No model, CSI index, low-volatility, sensitivity, or pipeline script was run.
