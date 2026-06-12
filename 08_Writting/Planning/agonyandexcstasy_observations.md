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

### Probability-Integral Transformation (PIT)

In general, PIT normalisation in the modelling pipeline is a train-fitted quantile transformation: for each feature, the empirical distribution is 
learned only from the training data, and every observation is mapped according to its rank within that training 
distribution. This makes features comparable across scales and reduces the influence of skewness and extreme values 
without using information from the test or OOS samples. In the standard model pipeline, the transformed values are 
mapped to a uniform [0, 1] scale; in the VAE pipeline, continuous features are instead mapped to an approximately 
standard-normal scale, while binary variables remain unchanged.

For the VAE, the continuous input features are first cleaned using training-set information only: missing values 
are imputed and the empirical distribution of each feature is estimated on the training sample. Each continuous 
feature is then transformed through a probability-integral/quantile mapping into an approximately standard normal 
distribution, so the VAE receives inputs centered around zero with comparable scale across variables. Binary 
indicators are not transformed this way and remain in their original 0/1 form. The VAE is trained on these 
normalized continuous features to learn compressed latent representations and reconstruction errors, which are 
later added back to the modelling dataset as additional features rather than replacing the original raw feature set.

### Feature Engineering

The feature-engineering methodology converts the annual firm panel into a backward-looking prediction dataset where each row is a firm-year observation. The goal is to describe a firm’s current financial condition, recent deterioration, longer-run trajectory, market stress, and macro sensitivity without using future information. The pipeline therefore starts from point-in-time accounting, valuation, market, and macro variables, derives interpretable financial ratios, then augments them with lagged dynamics, rolling statistics, momentum, drawdown, volatility, and macro-interaction terms.
Group Name	Concise Description	Formula
Profitability	Measures earnings and cash-flow generation relative to assets, equity, sales, or market price.	ROA = NI / AT; ROE = NI / SEQ; ROIC = OIADP / ICAPT; Earnings yield = EPSPX / PRCC_F
Leverage	Captures balance-sheet debt burden and interest pressure.	Leverage = (DLTT + DLC) / AT; Net debt / EBITDA = (DLTT + DLC - CHE) / EBITDA; Interest coverage = OIADP / XINT
Liquidity	Measures short-term financial flexibility.	Current ratio = ACT / LCT; Quick ratio = (ACT - INVT) / LCT; Cash ratio = CHE / ACT; Working capital ratio = WCAP / AT
Valuation	Captures market valuation relative to accounting fundamentals.	Book-to-price = SEQ / MKVALT; Market-to-book = MKVALT / SEQ; EV / Sales = (MKVALT + DLTT + DLC - CHE) / SALE
Quality	Measures accruals, efficiency, reinvestment, and operating quality.	Accruals = (NI - OANCF) / AT; Asset turnover = SALE / AT; Capex intensity = CAPX / AT; R&D intensity = XRD / AT
Altman Z	Combines liquidity, retained earnings, profitability, leverage, and turnover into a distress score.	Z = 1.2 WCAP/AT + 1.4 RE/AT + 3.3 EBIT/AT + 0.6 MKVALT/LT + SALE/AT
Year-on-Year Change	Measures first-order deterioration or improvement in ratios.	YoY_x,t = x_t - x_{t-1}
Acceleration	Measures whether deterioration itself is speeding up.	Accel_x,t = YoY_x,t - YoY_x,t-1
Expanding Baseline	Compares current values to the firm’s own historical level, using only prior years.	ExpMean_x,t = mean(x_1,...,x_{t-1}); ExpVol_x,t = sd(x_1,...,x_{t-1})
Peak Deterioration	Measures decline from a recent firm-specific high point.	PeakDrop_x,t = x_t - max(x_{t-5},...,x_{t-1})
Trough Rise	Measures increase from a prior firm-specific low, mainly for risk variables such as leverage.	TroughRise_x,t = x_t - min(x_1,...,x_{t-1})
Consecutive Declines	Counts persistent negative changes in key health variables.	Counter_t = Counter_{t-1} + 1 if YoY_x,t < 0; else 0
Accounting Momentum	Compares recent two-year accounting performance to the firm’s prior long-run baseline.	AcctMom_x,t = mean(x_t, x_{t-1}) - ExpMean_x,t
Rolling Statistics	Captures short- and medium-term dynamics over 3-year and 5-year windows.	RollMean_w(x), RollMin_w(x), RollMax_w(x), RollSD_w(x), RollTrend_w(x), RollAutocorr_w(x)
Price Momentum	Measures recent stock-price performance over monthly horizons.	Mom_km,t = product(1 + r_m) - 1 over the last k months
Price Volatility	Measures recent realized return dispersion.	Vol_12m = sd(r_m) over current-year monthly returns; Vol_60m = sd(r_m) over trailing 60 months
Drawdown	Measures downside market stress from a rolling wealth-index peak.	Wealth_t = cumprod(1 + r_t); Drawdown_t = Wealth_t / RollingPeak_t - 1; MaxDD = min(Drawdown)
Macro Interactions	Captures whether firm weakness becomes more severe in adverse macro regimes.	Leverage × FedFunds; InterestCoverage × FedFunds; NetDebt/EBITDA × HYSpread; ROA × GDPGrowth; Return × VIX

In the code, the feature builder loads the merged annual panel and monthly CRSP returns, computes the accounting ratios first, then creates dynamic features by grouping observations by permno and ordering them by year. Lagged, expanding, rolling, and deterioration features are therefore firm-specific and backward-looking. Price features are computed separately from monthly returns: short-horizon features use within-year data, while 24-month momentum, 60-month volatility, and 60-month drawdown use the full monthly history available up to each year end. The final features_raw file keeps all engineered numeric features, while features_fund removes pure price-derived variables but retains accounting, macro, size, and interaction features. Model scripts then exclude identifiers, labels, censoring fields, and diagnostic columns before training.


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

# Revised Research Questions and Thesis Interpretation

## Overall finding

The thesis should not claim that CSI filtering has already proven persistent alpha. The stronger and safer interpretation is:

> CSI-based index construction shows promising benchmark-relative improvements in selected configurations, but the evidence points less to pure crash-event avoidance and more to broader distress, quality, volatility, and portfolio-reweighting effects.

This means the thesis should not only ask whether the index outperforms. It should also ask why it outperforms and whether that mechanism is genuinely related to CSI risk.

The central validation problem is:

> Does the CSI model add economically useful information beyond mechanical volatility control, generic quality tilts, and benchmark reweighting?

## Revised main research question

The original main research question was:

> To what extent does a Crash-Filtered equity index, constructed via probabilistic implosion modeling, generate superior risk-adjusted returns compared to the market benchmark and traditional minimum-volatility strategies?

A more thesis-safe revised version is:

> To what extent do probabilistic CSI risk scores improve benchmark-relative equity index construction after transaction costs, and are gains explained by direct CSI avoidance or broader distress, quality, volatility, and reweighting effects?

### Current answer

The current evidence supports a cautious positive answer:

- Some CSI index variants generate positive benchmark-relative performance.
- Several selected strategies compare favorably against approximate placebo checks.
- Index construction remains economically interesting even after the cleaned panel reduced model recall.
- However, attribution does not show that the alpha mainly comes from directly avoiding realized CSI events.
- In particular, permanent-CSI true-positive firms often have very low benchmark weight by the time they can be excluded.
- A large part of the performance improvement appears to come from retained-stock reweighting and broader distress or quality screening.

Therefore, the defensible claim is:

> CSI risk scores can be useful index-construction signals, but the currently supported mechanism is broader distress/risk screening and portfolio reweighting rather than pure event-avoidance alpha.

## Subquestion 1: Autoencoder feature engineering

Original proposal question:

> How does the integration of Autoencoders for feature engineering impact the Average Precision of Ensemble models compared to those trained solely on raw financial data?

Revised question:

> How do Autoencoder-based feature representations affect AP, AUC, and fixed-FPR recall relative to raw financial features?

### Current answer

This question is answerable with the existing modelling results.

The current evidence suggests:

- Autoencoder features do not clearly dominate raw financial data.
- For Temporary-CSI, raw and expanded raw datasets remain highly competitive.
- For Permanent-CSI, latent and raw-plus-latent variants are more useful as robustness signals.
- VAE features appear complementary, not a clean replacement for raw accounting, market, and macro variables.

The thesis-safe interpretation is:

> Autoencoder-based representations can add useful non-linear structure, especially in harder and rarer Permanent-CSI settings, but they do not provide a systematic AP improvement over raw financial features.

This is still a valuable result. It shows that sophisticated representation learning is not automatically superior when the raw feature set already contains economically rich information.

## Subquestion 2: CSI screening beyond naive volatility control

Original proposal question:

> To what extent do Ensemble methods reduce the False Positive Rate, classifying recoverable volatility as CSI, compared to traditional volatility-based exclusion strategies, while maintaining Recall?

This question is too narrow in its original form. It can only be answered directly if a volatility-only classifier is built and evaluated against the same CSI labels.

That would require:

- A volatility-only score, for example `vol_12m`.
- A drawdown-only score, for example `abs(max_dd_12m)`.
- A combined naive score, for example `z(vol_12m) + z(abs(max_dd_12m))`.
- The same response labels as the CSI models.
- AP, AUC, recall, and FPR comparisons at matched thresholds.

The cleanest direct test would be:

> At the same recall, does the ensemble model generate fewer false positives than a volatility-only or drawdown-only rule?

However, this should not become the main intellectual comparison. A pure volatility-only rule is intentionally naive. The stronger thesis argument is that mechanical volatility control is backward-looking and treats volatility as bad per se, while CSI modelling tries to distinguish recoverable volatility from structural impairment.

The better revised subquestion is:

> Does probabilistic CSI screening add value beyond naive volatility-based risk control by preserving recoverable volatility while excluding structurally impaired firms?

### Current answer

The current evidence partially supports this, but it still needs validation.

The evidence supports the idea that the CSI model is not only a volatility screen:

- Feature evidence includes volatility and drawdowns, but also macro-credit stress, market-value deterioration, firm age, scale, liquidity, and accounting distress.
- False positives are not arbitrary healthy firms. They often sit in a distress-like feature region.
- However, false positives and true positives are not cleanly separable.
- Therefore, the model appears to capture a broader distress profile, not a pure volatility rule.

The thesis-safe interpretation is:

> CSI screening is best framed as a richer distress and impairment screen, not as a replacement for volatility scaling in the narrow mechanical sense. It may preserve some recoverable volatility, but this must be shown through portfolio and characteristic validation rather than assumed from classification metrics alone.

## Validation checks for Subquestion 2

The following validation checks connect the classification story to the index-construction story.

### 1. Benchmark versus strategy scatter plot

Plot monthly benchmark returns on the x-axis and strategy returns on the y-axis.

Interpretation:

- Points above the 45-degree line in bad benchmark months suggest downside protection.
- Points below the 45-degree line in strong benchmark months suggest sacrificed upside.
- A slope below one suggests lower market exposure.
- A positive intercept is suggestive, but not a causal alpha proof.

This helps answer whether performance improves only because the strategy reduces beta, or whether it selectively improves bad-market outcomes.

### 2. QQ plot

A QQ plot compares the return distribution of the strategy against the benchmark.

Useful interpretations:

- A better left tail supports crash protection.
- A generally compressed distribution suggests volatility reduction.
- A parallel upward shift suggests broad return improvement.
- Worse right-tail behavior indicates foregone upside.

The QQ plot is descriptive, not causal, but it is useful for explaining where the return improvement comes from.

### 3. Upside and downside capture

Upside and downside capture are thesis-friendly because they translate performance into intuitive market states.

Downside capture:

$$
DownsideCapture =
\frac{\mathbb{E}(R^{strategy}_t \mid R^{benchmark}_t < 0)}
{\mathbb{E}(R^{benchmark}_t \mid R^{benchmark}_t < 0)}
$$

Upside capture:

$$
UpsideCapture =
\frac{\mathbb{E}(R^{strategy}_t \mid R^{benchmark}_t > 0)}
{\mathbb{E}(R^{benchmark}_t \mid R^{benchmark}_t > 0)}
$$

The desired CSI pattern is:

$$
DownsideCapture < 100\%
$$

and:

$$
UpsideCapture \approx 100\%
$$

Volatility scaling often reduces both upside and downside. CSI screening is more compelling if it reduces downside more than upside.

### 4. Characteristic tilt comparison

Compare excluded firms, retained firms, and benchmark firms on observable characteristics:

- trailing volatility,
- maximum drawdown,
- market beta,
- size,
- liquidity,
- leverage,
- profitability or quality proxies,
- Altman Z,
- market-value deterioration,
- macro-credit sensitivity.

This answers whether the CSI strategy is simply a low-volatility or quality tilt.

If excluded firms are only high-volatility firms, the model is less interesting. If they are also distressed, deteriorating, illiquid, or weak-quality firms, then the CSI score captures a richer impairment signal.

### 5. Matched placebo portfolios

Matched placebo portfolios are one of the strongest practical validation checks.

The idea is to exclude firms with the same count or weight as the CSI strategy, but match the excluded set on simple characteristics:

- size,
- sector,
- volatility,
- drawdown,
- quality proxy,
- liquidity.

If CSI still performs better than these matched placebo exclusions, the result is more likely to contain information beyond generic tilts.

The important comparison is:

$$
R^{CSI} - R^{matched\ placebo}
$$

not only:

$$
R^{CSI} - R^{benchmark}
$$

### 6. Overlap test

Compare CSI exclusions against simple rule-based exclusions:

$$
Overlap =
\frac{|Excluded^{CSI} \cap Excluded^{HighVol}|}
{|Excluded^{CSI}|}
$$

Also compare against high-drawdown and low-quality exclusions.

Interpretation:

- Very high overlap suggests the CSI score may mostly reproduce a simple volatility or distress rule.
- Partial overlap suggests the CSI score adds distinct information.
- Low overlap combined with better portfolio results would be strong evidence that CSI is not merely a low-volatility screen.

## Subquestion 3: Feature importance and economic interpretation

Original proposal question:

> Which features are most important for distinguishing between Zombie firms, CSI, and non-zombie firms?

Revised question:

> Which feature families drive CSI risk rankings, and do they indicate crash-specific risk, broad distress, or volatility and market-stress exposure?

### Current answer

This question is answerable with the current feature-importance and false-positive evidence.

The strongest feature families are:

- market deterioration and return histories,
- trailing volatility and drawdowns,
- market-value and firm-size histories,
- macro-credit stress variables such as high-yield spreads, VIX, and term spreads,
- firm age and scale,
- selected liquidity and accounting distress indicators,
- latent VAE components as complementary summary signals.

The current evidence does not support a single simple zombie-firm feature. Instead, the model appears to identify a multi-dimensional distress state.

The thesis-safe interpretation is:

> CSI risk rankings are driven by a combination of market-based deterioration, volatility and drawdown behavior, macro-credit stress, firm scale, and selected accounting distress signals. This supports the view that CSI is a broad structural impairment concept rather than a purely accounting-based zombie label.

## Subquestion 4: Does the index result reflect alpha, risk premia, or inefficiency?

This is not part of the original proposal wording, but it should become part of the thesis discussion.

Suggested question:

> Does index outperformance persist after placebo, attribution, and tilt-based validation, and is the result more consistent with compensated risk premia or market inefficiency?

### Current answer

The current evidence does not yet prove persistent alpha.

What is currently supported:

- Selected CSI strategies improve benchmark-relative performance.
- Some selected rows survive approximate placebo comparison.
- The strategy is economically meaningful after transaction costs in selected cases.
- The attribution suggests that reweighting and broad screening matter more than direct true-positive avoidance.

What is not yet proven:

- that CSI alpha is independent of low-volatility exposure,
- that CSI alpha is independent of quality or distress tilts,
- that direct CSI event avoidance is the main return source,
- that the effect survives exact matched-placebo validation,
- that the effect is a persistent anomaly rather than sample-specific reweighting.

### Risk premium versus inefficiency

If CSI-risk firms underperform after receiving high predicted CSI scores, the result does not look like a standard compensated risk premium. A risk premium usually means investors earn higher expected returns for bearing risk. Here, the risky or impaired firms appear to perform worse, at least in selected index configurations.

Therefore, the result is more consistent with:

- delayed incorporation of distress information,
- mispricing of deteriorating firms,
- limits to arbitrage,
- investor preference for lottery-like distressed stocks,
- structural overvaluation of firms near failure.

However, this should be phrased conditionally:

> The evidence is more consistent with inefficiency or delayed distress recognition than with a compensated risk premium, but this conclusion remains conditional on whether the CSI strategy survives placebo, transaction-cost, and tilt-based validation.

## Final thesis red line

The thesis should follow this logic:

1. Volatility-based risk control is mechanical and backward-looking.
2. CSI modelling attempts a richer distinction between temporary volatility and structural impairment.
3. Prediction quality improves ranking ability, but classification quality does not automatically imply index alpha.
4. Cleaned panel results reduce inflated recall but produce a more credible and economically meaningful evaluation.
5. Selected CSI index configurations still produce promising benchmark-relative results after transaction costs.
6. Attribution shows that these results are not mainly pure crash-event avoidance.
7. The likely mechanism is broader distress, quality, volatility, and retained-stock reweighting.
8. The final thesis contribution is to test whether firm-level CSI probabilities can become investable screening signals, and to diagnose whether their value comes from crash prediction, generic factor tilts, or market inefficiency.

The core thesis statement should therefore be:

> The contribution is not proving that volatility is useless. It is testing whether firm-level CSI probabilities provide a more selective alternative to mechanical volatility control by identifying when volatility reflects structural impairment rather than recoverable risk.

## What the thesis can and cannot claim

### Defensible claims

- The cleaned observable firm-year panel gives a more credible modelling benchmark than the old scaffolded panel.
- Average Precision is the most informative headline classification metric because CSI positives are rare.
- Autoencoder features are complementary but not consistently superior to raw financial features.
- CSI scores can support economically meaningful index construction in selected configurations.
- The index effect is not best described as pure CSI event avoidance.
- The evidence is more consistent with broader distress screening and portfolio reweighting.
- CSI screening may be more selective than naive volatility control, but this requires explicit validation through overlap, capture, characteristic, and placebo tests.

### Claims to avoid unless further validation is completed

- CSI filtering proves persistent alpha.
- CSI alpha is independent of quality, volatility, size, or sector tilts.
- Autoencoders clearly outperform raw features.
- The strategy works because it directly avoids realized CSI events.
- Ensemble models reduce false positives relative to volatility-based strategies unless a volatility-only baseline is explicitly constructed and tested.
- The result proves market inefficiency rather than being consistent with inefficiency.
