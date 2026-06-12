# Personal Observations for the MT-project

# Methodology

## Temporary-CSI

Temporary-CSI identifies firms that experience a severe market-value collapse and do not recover within a fixed confirmation window. It is a market-based distress label: the firm does not need to formally declare bankruptcy. It is sufficient that the price path shows a large crash and persistent non-recovery.

### Core Idea

A firm is classified as Temporary-CSI if three conditions are met:

1. It suffers a large drawdown from its previous wealth peak.
2. It does not recover sufficiently during the confirmation window.
3. The event can be assigned to a valid annual prediction year before the observed event.

The baseline parameters are:

| Parameter | Meaning | Baseline |
|---|---|---:|
| `C` | Initial crash threshold | `-80%` |
| `M` | Recovery ceiling | `-20%` |
| `T` | Confirmation window | `18 months` |

### Wealth Index

The monthly wealth index accumulates adjusted monthly returns:

$$
W_{i,t} = W_{i,t-1}(1+r_{i,t})
$$

where:

- $W_{i,t}$ is the cumulative wealth index of firm $i$ at month $t$.
- $r_{i,t}$ is the adjusted monthly return.
- The wealth index is normalized to an arbitrary starting value, usually $1$.

### Trailing Peak

The trailing peak is the highest wealth value observed up to month $t$:

$$
P_{i,t} = \max_{\tau \leq t} W_{i,\tau}
$$

where $P_{i,t}$ is firm $i$'s previous peak wealth level.

### Drawdown

The drawdown from the trailing peak is:

$$
D_{i,t} = \frac{W_{i,t}}{P_{i,t}} - 1
$$

A crash trigger occurs if:

$$
D_{i,t} \leq C
$$

With the baseline threshold:

$$
D_{i,t} \leq -80\%
$$

This means the firm has lost at least 80% of its value relative to its previous peak.

### Recovery During the Confirmation Window

After the crash trigger month $t$, the firm is tracked over the next $T$ months. Recovery is measured relative to the same pre-crash peak:

$$
R_{i,t,u} = \frac{W_{i,u}}{P_{i,t}} - 1
$$

for:

$$
u \in [t, t+T]
$$

The maximum recovery during the confirmation window is:

$$
R^{\max}_{i,t,T} = \max_{u \in [t,t+T]} R_{i,t,u}
$$

A firm is classified as Temporary-CSI if it does not recover above the recovery ceiling $M$:

$$
R^{\max}_{i,t,T} \leq M
$$

With the baseline threshold:

$$
R^{\max}_{i,t,T} \leq -20\%
$$

This means the firm remains at least 20% below its previous peak throughout the confirmation window.

### Temporary-CSI Event Indicator

The monthly Temporary-CSI event indicator is:

$$
CSI^{temp}_{i,t} =
\begin{cases}
1, & \text{if } D_{i,t} \leq C \text{ and } R^{\max}_{i,t,T} \leq M \\
0, & \text{otherwise}
\end{cases}
$$

The annual response label is assigned to the prediction year before the event:

$$
y = \text{event year} - 1
$$

Thus:

$$
y^{temp}_{i,y} = 1
$$

if firm $i$ has a confirmed Temporary-CSI event assigned to annual label year $y$.

In contrast to Tewari et al. (2024), an observation is also classified as a CSI event if it enters bankruptcy proceedings,
indicated by the CRSP delisting-codes, DLSTCD \in \{572,573,574\}. Thus, the sample contains firms,
which survive the drawdown and subsequent survival period (T) and ones which delisted within the
survival period. 

### Interpretation

Temporary-CSI captures market-based distress episodes. It is useful for modelling firms that enter persistent market distress, even if the firm later recovers or never formally declares bankruptcy.

The central question is:

> Did the firm crash and fail to recover within the confirmation window?

## Robustness-Checks

### Check Nr.1

### Check Nr.2

## Permanent-CSI

Permanent-CSI identifies firms whose collapse appears economically irreversible. It is stricter than Temporary-CSI because it focuses on terminal or near-terminal capital loss rather than temporary non-recovery.

### Core Idea

A firm is classified as Permanent-CSI if a severe market-value collapse is followed by evidence that the loss is permanent. This can occur through:

1. A severe crash trigger.
2. A terminal or adverse delisting event.
3. A sufficiently long unresolved loss window showing no durable recovery.
4. Valid forward observation windows that allow the label to be resolved.

Permanent-CSI is therefore an absorbing or long-horizon distress concept. Once a firm is classified as permanently impaired, the event is treated as structurally different from temporary volatility.

### Crash Trigger

Permanent-CSI starts from the same crash logic as Temporary-CSI.

The wealth index is:

$$
W_{i,t} = W_{i,t-1}(1+r_{i,t})
$$

The trailing peak is:

$$
P_{i,t} = \max_{\tau \leq t} W_{i,\tau}
$$

The drawdown is:

$$
D_{i,t} = \frac{W_{i,t}}{P_{i,t}} - 1
$$

A crash trigger occurs when:

$$
D_{i,t} \leq C
$$

with the baseline value:

$$
C = -80\%
$$

### Permanent Capital Loss Window

Permanent-CSI uses a longer forward-looking window than Temporary-CSI. The key idea is that a firm must either experience a terminal failure event or fail to recover over a longer horizon.

Let the permanent forward window be:

$$
H = 60 \text{ months}
$$

or five years.

The forward recovery relative to the pre-crash peak is:

$$
R_{i,t,u} = \frac{W_{i,u}}{P_{i,t}} - 1
$$

for:

$$
u \in [t, t+H]
$$

The maximum recovery over the permanent window is:

$$
R^{\max}_{i,t,H} = \max_{u \in [t,t+H]} R_{i,t,u}
$$

A firm shows persistent capital loss if:

$$
R^{\max}_{i,t,H} \leq M
$$

where $M$ is the recovery ceiling.

### Terminal Failure Route

Permanent-CSI can also be triggered or confirmed by adverse delisting outcomes. In the CRSP data, terminal failure is represented by selected delisting codes, especially bankruptcy- or liquidation-related codes:

$$
DLSTCD \in \{572,573,574\}
$$

A terminal failure is treated as evidence that the prior market collapse was not merely temporary.

A simplified terminal-failure rule is:

$$
CSI^{term}_{i,t} =
\begin{cases}
1, & \text{if a crash trigger occurs and adverse delisting follows within the valid event window} \\
0, & \text{otherwise}
\end{cases}
$$

CRSP delisting codes are not used as standalone labels. They confirm or strengthen a market-based CSI event; they do not replace the market-path methodology.

### Permanent-CSI Event Indicator

The permanent event indicator can be written as:

$$
CSI^{perm}_{i,t} =
\begin{cases}
1, & \text{if a crash trigger occurs and terminal failure is observed} \\
1, & \text{if a crash trigger occurs and five-year recovery remains insufficient} \\
0, & \text{if the forward window is complete and no permanent failure is observed} \\
NA, & \text{if the forward outcome cannot be resolved}
\end{cases}
$$

The annual label is assigned to the prediction year before the event:

$$
y = \text{event year} - 1
$$

Thus:

$$
y^{perm}_{i,y} = 1
$$

if firm $i$ has a confirmed Permanent-CSI event assigned to annual label year $y$.

### Unresolved Labels

Permanent-CSI requires enough forward information to determine whether the firm truly failed to recover. If the forward window is incomplete, the label should not be forced to zero.

The unresolved-label rule is:

$$
y^{perm}_{i,y} = NA
$$

when the pipeline cannot determine whether the firm permanently failed or recovered.

This avoids treating unresolved future outcomes as true negatives.

### Interpretation

Permanent-CSI is more conservative than Temporary-CSI. It targets firms whose collapse is likely irreversible, either because they experience terminal failure or because they fail to recover over a long horizon.

This makes Permanent-CSI rarer than Temporary-CSI. The lower prevalence makes prediction harder, but the label is economically stronger because it focuses on structural capital destruction rather than temporary distress.

The central question is:

> Did the firm crash and experience terminal or long-horizon capital destruction?

## Temporary-CSI vs Permanent-CSI

| Dimension | Temporary-CSI | Permanent-CSI |
|---|---|---|
| Main concept | Persistent short- or medium-term distress | Long-horizon or terminal capital loss |
| Horizon | `T = 18 months` baseline | `H = 60 months` baseline |
| Recovery logic | No recovery above `M` during confirmation window | No durable recovery over long horizon |
| Bankruptcy/delisting role | Robustness or additive terminal-failure evidence | Stronger evidence of permanent failure |
| Label type | Temporary distress event | Absorbing or structural distress event |
| Prevalence | Higher | Lower |
| Modelling difficulty | Easier | Harder |

In short:

- Temporary-CSI asks whether the firm crashed and failed to recover within the confirmation window.
- Permanent-CSI asks whether the firm crashed and experienced terminal or long-horizon capital destruction.

# Modelling setup

## Dataset

This thesis uses WRDS-data to replicate the methodology outlined by Tewari et al. (2024) and to extend its results
to practical index construction. CRSP and Compustat data was retrieved from WRDS within the period from 1993 to 2024.
The CRSP data is used to define the constituent universe. From this universe, the price data of all US-stock constituents is
retrieved. Consequently, the price data is used to compute the associated stock returns and classification labels.

The Compustat database was queried to construct the feature set of the associated asset universe. This includes balance sheet
data, earnings data and other important firm-specific labels. In addition, the FRED database, provided by the St. Louis FED, was
used to download marco-level features, like interest rates. The goal was to enable the ML-models
to explore feature interactions between firm-level characteristics and marco-level features. 

The feature-dataset is on an annual time-interval whilst the labelling is done on a monthly time-frequency. Following Tewari et al. (2024),
these datasets were merged to be on an annual time-period. 

## ML-modelling methodology

The dataset was split into three distinct, non-overlaping sub-datasets. Firstly, the training-set, which ranges from 1993 to 2014
was setup for model-training and cross-validation. Secondly, the test-set includes the years 2015 to 2019 whilst
the OOS-dataset is comprised of the years from 2020 to 2024. The OOS-dataset serves primarily as the dataset to evaluate the
index-construction parts of this thesis. Model selection will be conducted based on the test-set.

Within the train-dataset, an expanding-window cross-validation approach is employed. The hyperparameters are optimized on 
an initial batch of training years. These are then tested on unseen data from the training set. In the next iteration, the 
hyperparameter optimization set includes the previous batch of test-observations. This time, the hyperparameters are evaluated on a
new batch of unseen future observations. 

## ML-modelling techniques

Two modelling approaches are used: AutoGluon Tabular and XGBoost. Both are tree-based machine-learning approaches suited to tabular financial data, non-linear effects, and interactions between firm-level, market-based, and macroeconomic variables.

### AutoGluon Tabular

AutoGluon is an automated machine-learning framework for tabular prediction tasks. Instead of estimating one manually specified model, AutoGluon trains a portfolio of candidate models, tunes them, and combines strong learners through ensembling.

In this thesis, AutoGluon is useful because the CSI prediction task is high-dimensional and imbalanced. The feature set includes accounting variables, market variables, macro variables, interaction terms, and latent VAE features. The relationship between these predictors and future CSI labels is unlikely to be linear. AutoGluon allows the model to search over flexible model classes without requiring a single hand-crafted specification.

The general prediction problem is:

$$
\hat{p}_{i,y} = \Pr(y_{i,y}=1 \mid X_{i,y})
$$

where:

- $X_{i,y}$ is the feature vector for firm $i$ in year $y$.
- $y_{i,y}$ is the CSI response label.
- $\hat{p}_{i,y}$ is the predicted probability that firm $i$ becomes CSI-relevant in the next labelled period.

AutoGluon trains multiple base learners:

$$
f_1(X), f_2(X), \ldots, f_K(X)
$$

and combines them into an ensemble prediction:

$$
\hat{p}_{i,y}^{AG} = \sum_{k=1}^{K} w_k f_k(X_{i,y})
$$

where:

- $f_k(\cdot)$ is a trained base model.
- $w_k$ is the ensemble weight assigned to model $k$.
- The weights are selected to improve validation performance.

The final AutoGluon output is therefore not only a single classifier, but an ensemble score that ranks firms by predicted CSI risk.

### XGBoost

XGBoost is a gradient-boosted decision tree algorithm. It builds an additive ensemble of trees, where each new tree is trained to correct the errors of the previous trees.

The model has the form:

$$
\hat{p}_{i,y}^{XGB} = \sigma \left( \sum_{m=1}^{M} f_m(X_{i,y}) \right)
$$

where:

- $f_m(\cdot)$ is the $m$-th regression tree.
- $M$ is the number of boosting rounds.
- $\sigma(\cdot)$ is the logistic transformation that maps the model score into a probability.

The logistic transformation is:

$$
\sigma(z) = \frac{1}{1+\exp(-z)}
$$

At each boosting step, XGBoost adds a new tree that improves the objective function:

$$
\mathcal{L} = \sum_{i} \ell(y_i, \hat{p}_i) + \sum_{m=1}^{M} \Omega(f_m)
$$

where:

- $\ell(y_i, \hat{p}_i)$ is the classification loss.
- $\Omega(f_m)$ is a regularization penalty that controls tree complexity.

This regularization is important because the feature space is large relative to the number of positive CSI events. Without regularization, a flexible tree model could overfit rare historical collapses.

### Why These Models Fit the CSI Task

The CSI prediction task has three properties that make tree-based machine learning suitable:

1. The response variable is rare.
2. The relevant patterns are likely non-linear.
3. Interactions between firm-level and macro-level variables may matter.

For example, leverage may be more dangerous when interest rates are high, weak profitability may matter more during recessions, and negative return momentum may interact with volatility or market-cap size. Tree-based models can capture such threshold effects and interactions naturally.

The models are evaluated primarily as ranking models. The key output is not only whether a firm is classified as `0` or `1`, but where the firm appears in the risk ranking:

$$
\hat{p}_{i,y}^{high} > \hat{p}_{j,y}^{low}
$$

This means firm $i$ is ranked as more likely to experience CSI than firm $j$.

This ranking interpretation matters because the index-construction step uses predicted risk scores to exclude or downweight high-risk firms. Therefore, the model does not need to perfectly classify every future CSI event. It needs to produce a useful risk ordering.

### Evaluation Metrics

The main metrics are Average Precision, AUC, and recall at fixed false-positive rates.

Average Precision is especially important because CSI positives are rare. A random classifier has expected AP approximately equal to the base prevalence:

$$
AP_{random} \approx \Pr(y=1)
$$

Thus, if the response prevalence is 3% and the model reaches AP of 15%, the model concentrates positives about five times better than random:

$$
\frac{0.15}{0.03} = 5
$$

AUC measures broad ranking quality:

$$
AUC = \Pr(\hat{p}_{positive} > \hat{p}_{negative})
$$

It can remain high even when positives are rare, so it is useful but not sufficient on its own.

Recall at a fixed false-positive rate evaluates how many true CSI cases can be captured while limiting false alarms:

$$
FPR = \frac{FP}{FP + TN}
$$

and:

$$
Recall = \frac{TP}{TP + FN}
$$

For index construction, fixed-FPR recall is economically intuitive: it asks how many future CSI firms can be identified while only excluding a controlled share of healthy firms.

## Feature Engineering

### PIT

In the modelling scripts, PIT mainly means probability integral transform normalisation, not a full accounting point-in-time database. For each numeric model feature, the empirical distribution is learned on the training sample only. Values in train, test, and OOS are then mapped by their training-distribution rank, so the model sees variables on a comparable scale without using test or OOS distribution information. Before this transform, the standard model pipeline winsorises each feature at the training-set 0.1% and 99.9% percentiles and imputes missing values with training-set medians.

The standard AutoGluon pipeline maps the transformed features to a uniform scale, approximately `[0, 1]`. The VAE pipeline uses the same train-fitted quantile idea differently: continuous inputs are mapped to an approximately standard-normal scale and are kept in that standard-normal scale for VAE training. Binary indicators are not transformed in this way and remain in their original `0/1` form. The accounting-data point-in-time treatment is weaker: the pipeline preserves `datadate` and uses valid Compustat-CRSP link windows, but it does not apply filing-date, `rdq`, `as_of`, or positive reporting-lag logic. Therefore, PIT normalisation is robustly implemented; full accounting release-timing PIT is only partial.

### Feature Engineering

The feature-engineering methodology converts the annual firm panel into a backward-looking firm-year prediction dataset. It starts with interpretable accounting, valuation, size, market, and macro variables, then adds firm-specific deterioration and persistence signals. The important scope point is that the dynamic transforms are not applied to every column indiscriminately. Most first-difference, acceleration, expanding-baseline, peak/trough, decline-counter, accounting-momentum, and rolling-window features are applied only to explicitly defined base-feature subsets. This prevents, for example, every macro variable, label field, identifier, or later-generated feature from recursively creating new engineered columns.

| Group Name | Applied To | Concise Description | Formula |
|---|---|---|---|
| Base profitability ratios | Accounting point-in-time fields: `earn_yld`, `ocf_per_share`, `roa`, `roe`, `roic`, `ebit_roa`, `gross_margin`, `ebitda_margin`, `ocf_margin` | Measures earnings, margins, and cash-flow generation. | `earn_yld = epspx / prcc_f`; `roa = ni / at`; `roe = ni / seq`; `roic = oiadp / icapt` |
| Base leverage and debt ratios | `leverage`, `net_debt_ebitda`, `std_debt_pct`, `eff_int_rate`, `interest_cov`, `dd1_ratio` | Captures debt burden, short-term debt pressure, and interest coverage. | `leverage = (dltt + dlc) / at`; `net_debt_ebitda = (dltt + dlc - che) / ebitda`; `interest_cov = oiadp / xint` |
| Base liquidity ratios | `current_ratio`, `quick_ratio`, `cash_pct_act`, `wcap_ratio` | Measures near-term balance-sheet flexibility. | `current_ratio = act / lct`; `quick_ratio = (act - invt) / lct`; `cash_pct_act = che / act`; `wcap_ratio = wcap / at` |
| Base valuation, quality, and size ratios | `bp_ratio`, `ev_to_sales`, `div_yield`, `mkt_to_book`, `accruals_ratio`, `asset_turnover`, `capex_intensity`, `rd_intensity`, `reinvest_rate`, `log_at`, `log_mkvalt`, `log_emp`, `rental_ratio`, `assets_per_emp`, `ni_per_emp`, `invest_st_ratio` | Captures valuation, accounting quality, efficiency, investment intensity, firm size, and zombie precursors. | `bp_ratio = seq / mkvalt`; `accruals_ratio = (ni - oancf) / at`; `asset_turnover = sale / at`; `log_mkvalt = log(mkvalt)` |
| Altman Z components | `altman_z1` to `altman_z5`, plus `altman_z` | Adds a traditional accounting distress score. | `altman_z = 1.2*wcap/at + 1.4*re/at + 3.3*ebit/at + 0.6*mkvalt/lt + sale/at` |
| Other retained point-in-time ratios | `cash_div_cf`, `min_int_tcap`, `compr_inc_ratio` | These are retained as static point-in-time features, but they are not part of the main dynamic-transform base set. | `cash_div_cf = dv / oancf`; `min_int_tcap = mib / (seq + mib + dltt)`; `compr_inc_ratio = citotal / at` |
| Year-on-year changes | The `ratio_cols` set: selected profitability, leverage, liquidity, valuation, quality, size, zombie, Altman, and `invest_st_ratio` ratios, plus annual price fields already present at this stage when available (`log_return`, `ann_return`, `max_dd_12m`, `vol_12m`, `mom_6m`). It excludes retained-only fields such as `cash_div_cf`, `min_int_tcap`, and `compr_inc_ratio`. | Measures first-order firm-specific deterioration or improvement. | `yoy_x,t = x_t - x_{t-1}` |
| Acceleration | The same `ratio_cols` set as year-on-year changes. It does **not** apply to all engineered features, macro variables, identifiers, or later-created monthly price features such as `mom_24m` or `vol_60m`. | Measures whether deterioration itself is speeding up or slowing down. | `accel_x,t = yoy_x,t - yoy_x,t-1` |
| Expanding baseline | The same `ratio_cols` set. | Compares current variables to the firm's own prior history. | `expmean_x,t = mean(x_1,...,x_{t-1})`; `expvol_x,t = sd(x_1,...,x_{t-1})` |
| Peak deterioration | Subset of healthier-is-higher variables: profitability, margins, liquidity, coverage, turnover, book-to-price, size proxies such as `log_mkvalt` and `log_emp`. | Measures decline from a recent firm-specific high point. | `peak_drop_x,t = x_t - max(x_{t-5},...,x_{t-1})` |
| Trough rise | Riskier-is-higher variables: `leverage`, `net_debt_ebitda`, `std_debt_pct`, `eff_int_rate`, `dd1_ratio`, `rental_ratio`, `accruals_ratio`. | Measures worsening from a prior low-risk baseline. | `trough_rise_x,t = x_t - min(x_1,...,x_{t-1})` |
| Consecutive declines | Selected health variables: `earn_yld`, `ocf_per_share`, `roa`, `roic`, `gross_margin`, `interest_cov`, `log_mkvalt`, `log_emp`, `current_ratio`, `wcap_ratio`. | Counts persistent negative changes in key health indicators. | `counter_t = counter_{t-1} + 1` if `yoy_x,t < 0`, otherwise `0` |
| Accounting momentum | Core accounting set: profitability, leverage, coverage, liquidity, accruals, turnover, margins, and size proxies (`log_mkvalt`, `log_at`). | Compares the recent two-year level with the firm's prior expanding baseline. | `acct_mom_x,t = mean(x_t, x_{t-1}) - expmean_x,t` |
| Rolling statistics | Same core accounting set as accounting momentum. | Measures short- and medium-run levels, dispersion, trends, and persistence over 3-year and 5-year windows. | `roll_mean_w(x)`, `roll_min_w(x)`, `roll_max_w(x)`, `roll_sd_w(x)`, `roll_trend_w(x)`, `roll_autocorr_w(x)` for `w in {3,5}` |
| Price momentum and volatility | Monthly CRSP returns by firm. | Captures recent market performance, realised volatility, and drawdown. | `wealth_t = cumprod(1 + ret_adj_t)`; `mom_km = prod(1+r_m)-1`; `vol_12m = sd(r_m)` within year; `vol_60m = sd(r_m)` over trailing 60 months |
| Drawdown | Monthly wealth index relative to a rolling peak. | Measures downside market stress from a recent rolling high, not from an all-time high. | `drawdown_t = wealth_t / rolling_peak_t - 1`; `max_dd_12m = min(drawdown)` within year; `max_dd_60m = min(drawdown)` over trailing 60 months |
| Macro interactions | Six explicit pairs only: `leverage * fedfunds`, `interest_cov * fedfunds`, `net_debt_ebitda * hy_spread`, `roa * gdp_growth`, `log_return * vix`, `accruals_ratio * hy_spread`. | Allows firm weakness to vary with interest-rate, credit-spread, growth, and volatility regimes. | `interact_lev_rate = leverage * fedfunds`; `interact_ret_vix = log_return * vix` |

In implementation, the code first computes the base accounting ratios on the merged annual panel, then orders observations by `permno` and `year` before applying firm-level dynamic transforms. Year-on-year changes, acceleration, and expanding baselines are applied to `ratio_cols`, while peak drops, trough rises, consecutive declines, accounting momentum, and rolling statistics use narrower hand-picked subsets chosen for economic meaning. Price features are computed separately from monthly returns: 1/3/6-month momentum, 12-month volatility, and 12-month drawdown use within-year monthly data, while 24-month momentum, 60-month volatility, and 60-month drawdown use the cumulative monthly history available up to each year end. The final `features_raw` file retains all engineered numeric features together with identifiers and label metadata, while `features_fund` removes pure price-derived variables and their derivatives but keeps accounting, macro, size, and non-price interaction features. The modelling step then excludes identifiers, labels, censoring fields, event dates, and diagnostics before training.

# Modelling-results

## Modelling performance: Temporary-CSI


## Modelling performance: Permanent-CSI


# Modelling-considerations

In the first paragraph, we compare the June Presentation results to the one of the Tewari et al. (2024) paper and the ones of the
May Presentation. We find that the results of the previous iteration were inflated due to the creation of scaffoled rows,
which created many noisy-negatives. Consequently, many ML-metrics were inflated.

## Recall at FPR of 3%

The modeling results, especially the FPR3 ratio, is considerably worse compared to the paper. Tewari et al. (2024) claim
"The results achieved indicate a positive response- the XGBoost model
signalled over 60% of Catastrophic Implosions in the test set with a false positive rate of less than
3%, highlighting effectiveness in capturing the majority of implosions while avoiding a wipe-out
of healthy stocks.". An FPR3 ratio of roughly 60% was only replicable using data-year scaffolding, creating "noisy" data-years
(scaffold/broad denominator observations). In the new June run, in which those scaffold observations were removed, a FPR3 rate
of 20-22% was achievable, using arguably stronger ML-models (AutoGluon with weighted model esemblies). 

### Causes for the drop in ML-performance

Recall at an FPR of 3% is constructed via the following formula: FPR = FP / (FP + TN) <= 3%. Consequently, the number of tolerated
false positives is roughly 0.03 * number of actual negatives. Hence, it is conditional on the number of actual negatives.
If this number is inflated, it must also influence the outcome of the metric. 

The old test-dataset showed 77,451 observations, for which the response variable is 0 (y = 0).
At an allowed FPR of 3%, this would correspond to roughly 2,323 observations. The revised dataset only has
17,307 observations, for which the response is 0. Consequently, only 519 false positives would be allowed. Thus,
the number of tolerated false positives was inflated by roughly 4,5 times.
In Summary, more noisy-negatives increases the measured FPR metric for a given metric as more true positives
are allowed to be captured.

### Repercussions for index construction

The cleaned model’s lower recall is not economically fatal: the index-construction results 
are more stable across universes and remain positive after transaction costs. This suggests the cleaned classifier captures fewer 
CSI labels but a more economically useful subset of firms.

### Relation to the Tewari et al. (2024) working paper.


 the paper is not shown to be wrong. The better thesis-safe interpretation is that its 61% claim is not directly comparable and likely reflects a different/easier 
 setup: selected 5-year-history FactSet universe, post-implosion zombie-period exclusion, some tolerance for identifying the 
 right stock even if timing is imperfect, and incomplete disclosure of the exact FPR denominator/threshold mechanics.

For the thesis setting, the current 13%-20% Test R@FPR3 is more credible and conservative because it is computed on the cleaned observable CRSP firm-year panel, 
excludes unresolved y=NA labels from supervised evaluation, uses a time split, and has an explicit ROC-based metric definition.
Recommended wording is included in the report; short version:

The literature benchmark is directionally useful but not directly comparable. On the cleaned observable CRSP firm-year panel, 
our test R@FPR3 of 13%-20% is the more conservative and auditable estimate; the paper's 61% result likely reflects a 
different/easier sample and evaluation denominator rather than a proven error.

# Index-Construction Methodology

# Index-Construction Results

# Index-Construction Considerations

## Story

For index construction, the interesting result is different: even with lower event recall, the strategies are more stable 
and still add modest alpha after transaction costs. It means the model no longer “wins” by separating true events from noisy/easy non-events. 
It now operates on a more economically meaningful universe. 


### Attribution Analysis

But the attribution shows that the alpha is not mainly from direct 
true-positive avoidance. In permanent CSI, the true-positive firms have almost no benchmark weight by the time they can be 
excluded. Most alpha comes from reweighting the portfolio after excluding predicted-risk firms.


The CSI model is not primarily valuable because it catches most future implosion labels. It is valuable, if validated,
because its score acts as a broader distress/quality screen. It removes firms that are economically unattractive even 
when they do not become labelled CSI, and the retained market-cap-weighted portfolio performs better.

# Criticism / Risk

The main criticism is that the index result could be a generic reweighting artifact.
If the model excludes a few low-weight or weak firms and then renormalizes into the rest of the market, 
performance may improve even if the CSI signal is not special. The permanent-CSI result is especially vulnerable to 
this criticism because:

TP gain is almost zero.
FP exclusions are labelled false positives and are a direct cost in the attribution.
retained-stock reweighting explains most of the gain.
permanent CSI events are rare and low-weight.
the model may simply proxy for size, quality, volatility, or distress factors.
This does not invalidate the result yet. But it means the thesis should not claim pure event-avoidance 
alpha until we validate against placebo and alternative screens.
