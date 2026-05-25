# CRSP Four-Index Construction Methodology

Date documented: 2026-05-16

This note documents how to construct model-ready benchmark portfolios for four official CRSP Market Indexes:

| Analysis label | Official CRSP index | Price return code | Total return code | Official size range |
| --- | --- | --- | --- | --- |
| Total market | CRSP US Total Market Index | `CRSPTM1` | `CRSPTMT` | 0-100% of investable US equity market |
| Large cap | CRSP US Large Cap Index | `CRSPLC1` | `CRSPLCT` | 0-85% cumulative market cap |
| Mid cap | CRSP US Mid Cap Index | `CRSPMI1` | `CRSPMIT` | 70-85% cumulative market cap |
| Small cap | CRSP US Small Cap Index | `CRSPSC1` | `CRSPSCT` | 85-98% cumulative market cap |

Important: CRSP Large Cap is a composite of Mega + Mid. It overlaps with the official Mid Cap index. For mutually exclusive size attribution, use Mega, Mid, Small, and Micro instead of Large, Mid, Small.

## Data Availability

There are two materially different constituent sources.

The public CRSP "Daily Index Levels & Quarterly Constituents" page provides a delayed quarterly constituent CSV. CRSP says quarterly constituents are posted with a one-month delay. This file is useful for current-date validation but not for historical model backtests because it has only ticker, company, and weight, and lacks `PERMNO`.

The licensed CRSPMI Historical Database is the correct source for historical index constituents. CRSP documents day-by-day index levels, constituent open files, constituent close files, and pro forma constituent files from 2012 to present. Its constituent files include `Index_Name`, `Index_Code`, `Company`, `PERMNO`, `FIGI`, `CUSIP`, `Ticker`, price, market cap, effective float factor, multipliers, index shares, index market cap, and `Index_Weight`. CRSP notes that `PERMNO` is available beginning 2014-10-30.

Use `00_check_crspmi_access.R` in this folder to test current access from the machine/account and write diagnostics.

## Implemented Local Reconstruction

The local reconstruction is implemented in:

`01_Code/index_construction_crsp/01_construct_crsp_like_four_indices.R`

It reads the existing project CRSP files:

- `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`
- `02_Data_Input/01_CRSP/Necessary/universe.rds`

It writes all generated outputs under:

`02_Data_Input/04_Index_Replication/`

The run completed with:

- 2,100,145 monthly CRSP security rows after filters.
- 19,565 distinct `PERMNO`.
- 128 quarterly rebalance dates.
- Rebalance range from 1993-03-31 through 2024-12-31.
- Monthly return range from 1993-04-30 through 2024-12-31.

The latest generated output files are:

- `crsp_like_company_assignments_quarterly.rds`
- `crsp_like_index_constituents_quarterly.rds`
- `crsp_like_index_constituents_quarterly.csv`
- `crsp_like_index_returns_monthly.rds`
- `crsp_like_index_returns_monthly.csv`
- `crsp_like_index_summary_quarterly.csv`

The latest-quarter constituent counts, at 2024-12-31, are:

| Index | Constituents | Companies | Weight sum |
| --- | ---: | ---: | ---: |
| CRSP-like Total Market | 4,865 | 4,865 | 1.000000 |
| CRSP-like Large Cap | 448 | 448 | 1.000000 |
| CRSP-like Mid Cap | 267 | 267 | 1.000000 |
| CRSP-like Small Cap | 1,217 | 1,217 | 1.000000 |

The reconstructed monthly total-return series, from 1993-04-30 through 2024-12-31, produced:

| Index | Months | Cumulative index | Annualized return |
| --- | ---: | ---: | ---: |
| CRSP-like Total Market | 381 | 21.7060 | 10.18% |
| CRSP-like Large Cap | 381 | 22.0998 | 10.24% |
| CRSP-like Mid Cap | 381 | 23.2193 | 10.41% |
| CRSP-like Small Cap | 381 | 18.2318 | 9.57% |

These figures are diagnostics for the local reconstruction, not official CRSP index levels.

## CRSP Universe

The CRSP US Total Market Index starts from eligible and investable US equity securities. The methodology guide describes screens across:

- eligible exchange/listing venue,
- domicile and headquarters determination,
- organization and share type,
- investability screens,
- total shares outstanding and float shares outstanding,
- total company market capitalization,
- quarterly ranking and reconstitution.

The current guide states that the eligible exchange set includes NYSE, NYSE American, NYSE Arca, Nasdaq, and Cboe BZX. The same eligibility rules feed the market-cap, style, sector, and ESG sub-indexes.

## Size Assignment

CRSP assigns companies to capitalization indexes using total company market capitalization at quarterly ranking. A company's total market capitalization is calculated by summing all capitalization-eligible securities for the company.

Companies are ranked largest to smallest. CRSP computes a cumulative market-cap score using the midpoint of each company's market capitalization in the cumulative distribution. The key breakpoint targets are:

- 70%: Mega / Mid breakpoint,
- 85%: Large-Mid / Small breakpoint,
- 98%: Small / Micro breakpoint.

Official ranges for the four requested indexes:

- Total Market: all eligible securities in the investable universe.
- Large Cap: `0% < X <= 85%`, composite of Mega + Mid.
- Mid Cap: `70% < X <= 85%`.
- Small Cap: `85% < X <= 98%`.

CRSP uses bands around breakpoints and "packeting" to reduce turnover. Constituents near a breakpoint may be partially allocated between adjacent size indexes through the size multiplier. Therefore, official constituents and weights should be taken directly from CRSPMI constituent files rather than recreated from a simple rank rule when official historical membership is available.

The local reconstruction uses hard quarterly breakpoint assignment. A company is fully assigned to Mega, Mid, Small, or Micro at each quarterly rebalance. This captures the core cumulative market-cap rule but does not replicate CRSP's size multiplier or two-step packet migration.

## Official Weight Construction

The preferred construction uses CRSPMI `Index_Weight` directly:

1. Select the relevant `Index_Code`: `CRSPTM1`, `CRSPLC1`, `CRSPMI1`, or `CRSPSC1` for price-return benchmarks, or the matching total-return code when using index-level returns.
2. Select constituent open files for start-of-period portfolio weights, or close files for end-of-day holdings attribution.
3. Keep rows with valid `PERMNO` for model joins.
4. Use `Index_Weight` as the official float-adjusted benchmark weight.
5. Join model predictions by `PERMNO` and signal date, excluding signals not known before the holding period.
6. For model-filtered portfolios, remove flagged constituents and renormalize the remaining official benchmark weights within each index/date.

If rebuilding weights from fields is required, CRSP's documented constituent mechanics are:

```text
Index_Shares =
  Effective_TSO * EFF / 100 *
  Band_Mplier * Style_Mplier * Conc_Mplier * RS_Mplier

Index_Market_Cap =
  Index_Shares * index security price

Index_Weight =
  Index_Market_Cap / sum(Index_Market_Cap within the index)
```

For the four market-cap indexes here, `Style_Mplier` should generally be 1 because style is not part of these indexes. `Band_Mplier` is important because it captures CRSP size packeting.

The local reconstruction uses the available security market cap:

```text
Security_Weight =
  Security_Market_Cap / sum(Security_Market_Cap within reconstructed index)
```

Monthly returns are then drifted between quarterly rebalances with local CRSP `ret_adj`. Securities with no return row in a later month are dropped from the active holdings and the remaining active weights are rescaled. Securities with a delisting-return row are included for that terminal month and then removed from subsequent drifted holdings.

## Backtest Alignment

For the thesis model:

1. Use constituent open files when the portfolio is formed at the beginning of a trading day or holding period.
2. Use `Effective_Date` as the investable date for holdings.
3. Convert daily constituent weights to the monthly/quarterly frequency used by the model by choosing the first investable date after each rebalance or signal date.
4. Use predictions from year `t-1` or the latest fully available signal date for holdings in year `t`.
5. Never use a constituent file dated after the simulated portfolio formation date.
6. Compute benchmark returns using official CRSPMI index returns where possible; compute filtered portfolio returns by applying official constituent weights to CRSP security returns and renormalizing after exclusions.

## Fallback Without CRSPMI Constituents

If licensed historical constituents are unavailable, keep a separate fallback labeled as a custom CRSP stock-file benchmark, not an official CRSP Market Index. The fallback can use local CRSP stock data to create cumulative market-cap buckets with the same breakpoints:

- Total market proxy: all eligible local CRSP common equities after project screens.
- Large proxy: 0-85% cumulative market cap.
- Mid proxy: 70-85% cumulative market cap.
- Small proxy: 85-98% cumulative market cap.

This fallback will not reproduce CRSP's official float adjustment, packeting, investability screens, corporate-action timing, or index weights.

## Sources

- Local guide: `04_Research/01_CRSP/Necessary/CRSP_Market_Indexes_Methodology_Guide.pdf`
- CRSP levels and constituents: https://www.crsp.org/indexes/levels-constituents/
- CRSP market indexes data access: https://www.crsp.org/indexes/data-access/
- CRSPMI Historical Database guide: https://www.crsp.org/research/crspmi-historical-database/
