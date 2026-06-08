# Feature Engineering Methodology

This note documents the current implementation in
`01_Code/pipeline/06B_FeatureEngineering.R`, with upstream annual price inputs
from `01_Code/pipeline/06_Merge.R` and monthly return cleaning from
`01_Code/pipeline/02_Prices.R`.

The feature matrix is built at the firm-year level, one row per `(permno, year)`.
The main input is `panel_raw.rds`; monthly CRSP prices are read from
`prices_monthly.rds` for rolling market features. Most accounting features are
computed from Compustat annual variables already merged into the panel.

## Utility Definitions

The script uses three helper definitions:

```text
safe_div(x, y) = x / y if y is non-missing and non-zero, otherwise NA
safe_log(x)    = log(x) if x is non-missing and positive, otherwise NA
compound(r)    = product(1 + r_m) - 1 over non-missing returns
```

All dynamic transformations are grouped by `permno` and ordered by `year`.

## Base Annual Price Inputs

Before `06B_FeatureEngineering.R`, `06_Merge.R` collapses monthly returns to
annual observations:

```text
ann_return_{i,t} = product_{m in year t}(1 + ret_adj_{i,m}) - 1
n_months_ret_{i,t} = count of non-missing ret_adj months in year t
avg_mktcap_{i,t} = mean monthly market capitalization in year t
log_return_{i,t} = log(1 + ann_return_{i,t}) if ann_return_{i,t} > -1
```

`ret_adj` is cleaned in `02_Prices.R`: CRSP sentinel return codes
`-66, -77, -88, -99` are set to missing, and delisting returns replace regular
returns in the delisting month when available.

## Family 1: Point-In-Time Ratios

The point-in-time ratios are computed directly from the current firm-year row.
For firm `i` in year `t`, the implementation creates:

### Profitability

```text
earn_yld        = epspx / prcc_f
ocf_per_share   = oancf / csho
roa             = ni / at
roe             = ni / seq
roic            = oiadp / icapt
ebit_roa        = ebit / at
gross_margin    = gp / sale
ebitda_margin   = ebitda / sale
ocf_margin      = oancf / sale
```

### Leverage

```text
leverage        = (dltt + dlc) / at
net_debt_ebitda = (dltt + dlc - che) / ebitda
std_debt_pct    = dlc / (dltt + dlc)
eff_int_rate    = xint / (dltt + dlc)
interest_cov    = oiadp / xint
dd1_ratio       = dd1 / at
```

### Liquidity

```text
current_ratio   = act / lct
quick_ratio     = (act - invt) / lct
cash_pct_act    = che / act
wcap_ratio      = wcap / at
```

### Valuation And Market

```text
bp_ratio        = seq / mkvalt
ev_to_sales     = (mkvalt + dltt + dlc - che) / sale
div_yield       = dvc / mkvalt
cash_div_cf     = dv / oancf
mkt_to_book     = mkvalt / seq
```

Note: `cash_div_cf` is computed but is not included in the later `ratio_cols`
dynamic-transform list.

### Quality And Efficiency

```text
accruals_ratio  = (ni - oancf) / at
asset_turnover  = sale / at
capex_intensity = capx / at
rd_intensity    = xrd / at
reinvest_rate   = capx / oancf
```

### Size

```text
log_at          = log(at)
log_mkvalt      = log(mkvalt)
log_emp         = log(emp * 1000)
```

### Zombie Precursors

```text
rental_ratio    = xrent / at
assets_per_emp  = at / emp
ni_per_emp      = ni / emp
min_int_tcap    = mib / (seq + mib + dltt)
compr_inc_ratio = citotal / at
```

Note: `min_int_tcap` and `compr_inc_ratio` are computed but are not included in
the later `ratio_cols` dynamic-transform list.

### Altman Z-Score

```text
altman_z1 = wcap / at
altman_z2 = re / at
altman_z3 = ebit / at
altman_z4 = mkvalt / lt
altman_z5 = sale / at

altman_z = 1.2 * altman_z1
         + 1.4 * altman_z2
         + 3.3 * altman_z3
         + 0.6 * altman_z4
         + 1.0 * altman_z5
```

The script also creates:

```text
invest_st_ratio = ivst / at
```

## Ratio Columns Used For Dynamic Accounting Transforms

The following ratio columns are used by the year-over-year, acceleration,
expanding, and selected rolling transformations:

```text
earn_yld, ocf_per_share, roa, roe, roic, ebit_roa,
gross_margin, ebitda_margin, ocf_margin,
leverage, net_debt_ebitda, std_debt_pct, eff_int_rate,
interest_cov, dd1_ratio,
current_ratio, quick_ratio, cash_pct_act, wcap_ratio,
bp_ratio, ev_to_sales, div_yield, mkt_to_book,
accruals_ratio, asset_turnover, capex_intensity,
rd_intensity, reinvest_rate,
log_at, log_mkvalt, log_emp,
rental_ratio, assets_per_emp, ni_per_emp,
altman_z1, altman_z2, altman_z3, altman_z4, altman_z5,
altman_z, invest_st_ratio
```

If already present on `panel_raw.rds`, these price-derived columns are appended:

```text
log_return, ann_return, max_dd_12m, vol_12m, mom_6m
```

In the current ordering, `max_dd_12m`, `vol_12m`, and `mom_6m` are created later
inside `06B_FeatureEngineering.R`, so they are not part of the annual
accounting dynamic transforms unless they already existed in the input panel.
`log_return` and `ann_return` do exist in `panel_raw.rds`.

## Family 2: Year-Over-Year Changes

For every variable `x` in `ratio_cols`:

```text
yoy_x_{i,t} = x_{i,t} - x_{i,t-1}
```

The first available observation for each firm has `NA` because no lag exists.

## Family 3: Acceleration

For every variable `x` in `ratio_cols`, acceleration is the first difference of
the year-over-year change:

```text
accel_x_{i,t} = yoy_x_{i,t} - yoy_x_{i,t-1}
              = x_{i,t} - 2*x_{i,t-1} + x_{i,t-2}
```

## Family 4: Expanding Mean And Volatility

For every variable `x` in `ratio_cols`, the expanding mean is lagged so the
feature at year `t` uses only prior years:

```text
expmean_x_{i,t} = mean(x_{i,1}, ..., x_{i,t-1})
```

The expanding volatility is also lagged:

```text
expvol_x_{i,t} = sd(x_{i,1}, ..., x_{i,t-1})
```

The implementation computes the cumulative variance as:

```text
var_t = [sum_{s<=t}(x_s^2) - n_t * mean_t^2] / max(n_t - 1, 1)
expvol_x_t = lag(sqrt(max(var_t, 0)))
```

Rows with fewer than three firm observations are set to `NA`.

## Family 5: Peak Deterioration And Trough Rise

### Peak Deterioration

Peak deterioration is computed for these "higher is better" ratios:

```text
earn_yld, ocf_per_share, roa, roe, roic, ebit_roa,
gross_margin, ebitda_margin, ocf_margin,
current_ratio, quick_ratio, cash_pct_act, wcap_ratio,
interest_cov, asset_turnover, bp_ratio,
log_mkvalt, log_emp
```

For each ratio `x`, the output is:

```text
peak_drop_x_{i,t} = x_{i,t} - reference_peak_{i,t}
```

where:

```text
reference_peak_{i,t} = max(x over years t-5 through t-1) once enough history
                       exists for the shifted 5-year rolling peak
```

For the first four observations, the reference peak falls back to a lagged
expanding peak:

```text
reference_peak_{i,t} = max(x_{i,1}, ..., x_{i,t-1})
```

Because the reference is lagged, the effective comparison at `t` is against
previously observed peaks, not the current value.

### Trough Rise

Trough rise is computed for these "higher is worse" ratios:

```text
leverage, net_debt_ebitda, std_debt_pct,
eff_int_rate, dd1_ratio, rental_ratio, accruals_ratio
```

For each ratio `x`:

```text
trough_rise_x_{i,t} = x_{i,t} - min(x_{i,1}, ..., x_{i,t-1})
```

This measures deterioration relative to the firm's prior all-time low for that
ratio.

## Family 6: Consecutive Decline Counters

Consecutive decline counters are computed for:

```text
earn_yld, ocf_per_share, roa, roic,
gross_margin, interest_cov, log_mkvalt, log_emp,
current_ratio, wcap_ratio
```

For each ratio `x`, the output `consec_decline_x` follows:

```text
consec_decline_x_{i,t} = 0, if t is the first firm observation
consec_decline_x_{i,t} = 0, if yoy_x_{i,t} is missing
consec_decline_x_{i,t} = consec_decline_x_{i,t-1} + 1, if yoy_x_{i,t} < 0
consec_decline_x_{i,t} = 0, otherwise
```

## Family 7: Accounting Momentum

Accounting momentum is computed for this rolling core:

```text
earn_yld, ocf_per_share, roa, roic,
leverage, net_debt_ebitda, interest_cov,
current_ratio, cash_pct_act, accruals_ratio,
asset_turnover, gross_margin, ebitda_margin,
log_mkvalt, log_at
```

For each core variable `x`:

```text
acct_mom_x_{i,t} = mean(x_{i,t-1}, x_{i,t}) - mean(x_{i,1}, ..., x_{i,t-1})
```

The two-year rolling mean is right-aligned and includes the current year. The
expanding baseline is lagged and excludes the current year.

## Families 8 And 9: Rolling Statistics

Rolling statistics are computed over 3-year and 5-year windows for the same
rolling core variables used in accounting momentum.

For each window `w` in `{3, 5}` and core variable `x`, the script creates:

```text
roll_mean_wy_x      = mean(x over trailing w firm-years)
roll_min_wy_x       = min(x over trailing w firm-years)
roll_max_wy_x       = max(x over trailing w firm-years)
roll_sd_wy_x        = sd(x over trailing w firm-years), if at least two values
roll_trend_wy_x     = slope from OLS x_s = a + b*s over valid observations
roll_autocorr_wy_x  = correlation(x_{s-1}, x_s) over valid observations
```

The trend slope is implemented as:

```text
roll_trend = cov(time_index, x) / var(time_index)
```

Trend and autocorrelation require at least three valid observations. The rolling
window uses available observations when the full window is not yet complete.

## Family 10: Price Momentum And Volatility

`06B_FeatureEngineering.R` reloads monthly prices and creates market features
from the full monthly history of each firm.

### Monthly Wealth Index And Drawdown

For monthly return `ret_adj`, missing returns are treated as zero inside the
wealth index:

```text
wealth_index_{i,m} = product_{k<=m}(1 + ret_adj^*_{i,k})
ret_adj^*_{i,k} = ret_adj_{i,k} if non-missing, otherwise 0
```

Monthly drawdown uses a 36-month rolling peak once enough history exists. Before
month 36, it uses the expanding peak:

```text
peak_{i,m} = max(wealth_index over months m-35 through m), if m >= 36
peak_{i,m} = max(wealth_index over months 1 through m), otherwise

drawdown_{i,m} = wealth_index_{i,m} / peak_{i,m} - 1
```

### Within-Year Price Features

For each firm-calendar-year group:

```text
mom_1m_{i,t}     = final monthly ret_adj in year t
mom_3m_{i,t}     = product over final 3 months of year t (1 + ret_adj) - 1
mom_6m_{i,t}     = product over final 6 months of year t (1 + ret_adj) - 1
vol_12m_{i,t}    = sd(monthly ret_adj in year t), if at least 3 valid returns
max_dd_12m_{i,t} = min(monthly drawdown in year t)
```

`mom_3m` and `mom_6m` require at least 3 and 6 monthly rows respectively.

### Multi-Year Price Features

For each firm-year, the script takes all monthly data up to and including that
calendar year and computes:

```text
mom_24m_{i,t}    = product over trailing 24 months (1 + ret_adj) - 1,
                   if at least 24 monthly rows exist

vol_60m_{i,t}    = sd(ret_adj over trailing 60 months),
                   if at least 12 valid monthly returns exist

max_dd_60m_{i,t} = min(drawdown over trailing 60 months),
                   if at least 60 monthly rows exist
```

The drawdown used in `max_dd_12m` and `max_dd_60m` is always based on the
36-month rolling peak logic above, not an all-time cumulative peak.

## Family 11: Macro Interaction Terms

The script creates six firm-by-macro interaction features:

```text
interact_lev_rate  = leverage * fedfunds
interact_cov_rate  = interest_cov * fedfunds
interact_nde_hyspr = net_debt_ebitda * hy_spread
interact_roa_gdp   = roa * gdp_growth
interact_ret_vix   = log_return * vix
interact_acc_hyspr = accruals_ratio * hy_spread
```

## Macro Level Features Included Directly

After engineered features are created, the final feature list explicitly keeps
these macro variables when present:

```text
term_spread, hy_spread, unrate, fedfunds, vix,
cpi_inflation, gdp_growth, indpro_growth, recession
```

## Output Matrices

The script writes two feature matrices.

### `features_raw.rds`

`features_raw.rds` keeps identifier and label columns plus all numeric feature
columns after removing a fixed metadata list. It includes accounting ratios,
dynamic accounting features, price features, macro levels, and macro
interactions.

### `features_fund.rds`

`features_fund.rds` starts from `features_raw.rds` and removes pure
price-derived columns:

```text
mom_1m, mom_3m, mom_6m, mom_24m,
vol_12m, vol_60m,
max_dd_12m, max_dd_60m,
ann_return, log_return,
selected yoy_, accel_, expmean_, expvol_ transforms of pure price features,
selected peak/trough/consecutive/accounting-momentum transforms of price features,
selected rolling statistics of log_return,
interact_ret_vix
```

`log_mkvalt` is retained in `features_fund.rds` because the implementation
treats it as a size proxy rather than a price momentum feature. Its dynamic and
rolling transforms are retained for the same reason.

## Training Feature Sets In The Current Model Suite

The current model-suite training flow uses `01_Code/pipeline/09C_AutoGluon.py`,
not the older `09_Train.R` XGBoost-only workflow. The main feature-set keys are:

```text
fund, raw, raw_plus_latent, latent_raw
```

For non-latent matrices, the training feature list is defined as numeric model
input columns after subtracting fixed identifier, label, split, and metadata
columns. For latent-only matrices, the training feature list is:

```text
z1, z2, ..., z24, vae_recon_error
```

Indicative feature-set composition is:

```text
fund             : fundamentals and engineered accounting features, excluding
                   pure price-return/drawdown/volatility features
raw              : full engineered feature set from 06B
raw_plus_latent  : raw engineered features plus VAE latent dimensions and
                   reconstruction error
latent_raw       : VAE latent dimensions and reconstruction error only
```

`raw_plus_latent` is the raw engineered matrix augmented with the 24 VAE latent
coordinates and the VAE reconstruction error:

```text
raw_plus_latent = raw engineered features + z1...z24 + vae_recon_error
```

Exact feature counts should be read from the regenerated local model-suite
artifacts, because the row/column contracts have been updated during the final
validation runs.

## Relationship To Rank, Dispersion, And VAE Groups

The implementation in `06B_FeatureEngineering.R` does not define a separate
"rank" feature family. Rank-like or quantile-style transformations occur later
in model preprocessing and VAE preprocessing, not as named `06B` output
families.

For interpretation, the engineered features can be grouped as follows:

```text
Base / point-in-time fundamentals:
  current accounting, market, size, Altman, leverage, liquidity, valuation,
  profitability, efficiency, and zombie-precursor ratios.

Time-series dynamics:
  yoy_, accel_, expmean_, expvol_, peak_drop_, trough_rise_,
  consec_decline_, acct_mom_.

Rolling / dispersion-style features:
  roll_sd_*, expvol_*, vol_12m, vol_60m, max_dd_12m, max_dd_60m,
  and other volatility/drawdown features. These are dispersion/risk proxies,
  but "dispersion" is an interpretive group rather than a literal script family.

Rolling level / momentum / trend:
  roll_mean_*, roll_min_*, roll_max_*, roll_trend_*, accounting momentum,
  price momentum, and annual return features.

Macro and macro interactions:
  macro level variables such as hy_spread and vix, plus firm-by-macro
  interactions such as leverage times fed funds and return times VIX.

VAE latent features:
  z1...z24 and vae_recon_error are produced later by
  `01_Code/pipeline/08B_Autoencoder.py`; they are not generated by `06B`.
```

## Current Implementation Notes

- The code comments state that all transformations are intended to be strictly
  backward-looking.
- Most dynamic accounting features are backward-looking via lagged expanding
  baselines or prior-year differences.
- The right-aligned rolling statistics and the two-year accounting momentum
  include the current annual row by construction.
- Price momentum and drawdown features are calendar-year market features joined
  to the annual panel.
- Multi-year price features are computed in a firm-level loop so that 24-month
  and 60-month history can cross calendar-year boundaries.
- VAE/PIT preprocessing and AutoGluon quantile/winsorization steps are part of
  later modelling scripts, not the feature-engineering script itself.
