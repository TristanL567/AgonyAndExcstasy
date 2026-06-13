# Final Presentation Text

## Title Slide

Welcome to my thesis presentation on:
The Agony and the Ecstasy. Constructing a 'Crash-Filtered' Equity Index using Machine Learning.

Special thanks go to my thesis supervisor Prof. Hornik for guiding me along this thesis project and
for always giving great remarks and additional ideas!

## Slide 2: The Agony and Ecstasy

Citations:
- Besembinder (2018; p.6 parapgraph 3): "I show in the subsequent sections of this paper that the majority of individual stocks 
underperform one-month Treasury bills over their full lifetimes, and that the bulk of the dollar 
wealth created in the US stock markets can be attributed to a relatively few successful stocks."

- Cembalest (2014; p.4 paragraph 2): "We then defined 
what we believe a concentrated stock holder would see as a catastrophic loss: “a decline of 70% or 
more in the price of a stock from its peak, after which there was little recovery such that the 
eventual loss from the peak is 60% or more.”  How often does this take place?  As shown in the 
table, 40% of all stocks suffered such a permanent decline from their peak value.  Remember, we are 
not talking about temporary declines during the tech boom-bust or during the financial crisis, but large, 
permanent declines that were not subsequently recovered."


Contemporary research, by amongst others Besembinder (2018) has shown that long-run index returns in the US-stock market
are driven by a few high-performing stocks. A considerable amount of constituents underperform
one-month T-Bills and suffer from catastrophic stock declines.

Passive indices are exposed to both extremes. 

The Ecstasy: Extreme winners carry a large share of long-run wealth creation.
Winners, like NVIDIA, can be volatile, expensive or distressed.
Even a small number of winners can hurt performance!

The Agony: Some index constituents experience deep and persistent drawdowns without recovery (Cembalest (2014)).
Passive indices, by construction, may hold these implodings firms for too long.

### Solution

The challenge is not to eliminate highly volatile stocks. It is to distinguish recoverable volatility from persistent
implosion. The empirical question is whether catastrophically declining firms are forecastable (like with using ideas from
credit-risk modelling, but with market-based distress signals).

## Slide 3: Research Question

Citations:
- Tewari et al. (2024): 

### Main Research-Question:
To what extent does a “Crash-Filtered” equity index, constructed via probabilistic
implosion modeling, generate superior risk-adjusted returns compared to the market
benchmark and traditional minimum-volatility strategies?

To ask whether one is able to ex-ante identify these imploding stocks and reliable exclude them
from a filtered-equity index. The probabilistic implosion model follows the Catastrophic Stock Implosion approach
proposed by Tewari et al. (2024). Instead of relying only on formal bankruptcy
declarations, CSI uses market-based price-path signals.

The potential advantage is two fold:
- First, one can increase the number of response-observations than when only relying on bankruptcy indicators.
- Secondly, many firms do not necessarily go into bankruptcy proceedings. A prolonged period of stagnation without recovery
can diminish return-opportunities.

In addition, I have also stated three sub-research questions. Yet, those will not be explicitly tackled in this
presentation due to time constraints. If you are interested, I also prepared some further slights on these topics.

## Slide 4: Dataset

Citations:
- Jiang et al. (2024): Fuwei Jiang, Tian Ma, and Feifei Zhu study whether machine-learning methods can predict stock price crash risk using firm-level fundamental characteristics in the Chinese A-share market.
- Barboza et al. (2017): Flavio Barboza, Herbert Kimura, and Edward Altman study whether machine-learning classifiers improve one-year-ahead bankruptcy prediction relative to traditional discriminant analysis, logistic regression, and neural networks (pp. 405-406). The paper uses North American firm data from Compustat and bankruptcy information from NYU's Salomon Center, with a 1985-2005 training sample containing 449 bankrupt firms and 449 matched non-bankrupt firms, plus a 2006-2013 validation/test sample with 133 bankrupt firms and 13,167 solvent firms (pp. 409-410). The authors compare support vector machines, bagging, boosting, random forest, artificial neural networks, logistic regression, and multivariate discriminant analysis using accuracy, type I error, type II error, and AUC (pp. 410-413). The feature set includes the five original Altman Z-score variables plus operating margin, asset growth, sales growth, employee growth, change in return on equity, and change in price-to-book (p. 410).
- Tewari et al. (2024).

Extensive research has been conducted in bankruptcy and market-based distress prediction using machine learning.
Jiang et al. (2024) have researched a similar topic using fundamental firm information. 
Barboza et al. (2017) used Compustat data for fundamental information, the original Altman-Z-score and other firm metrics.
Tewari et al. (2024) used balance-sheet data, earnings-data and additional firm-level information.

Thus, the main idea was to combine balance-sheet data with further earnings- and firm-related information and to intersect it
using US-macro data. For this reason, three different databases are accessed to conduct the research. CRSP and Compustat are offered by WRDS
and FRED by the St. Louis FED. All three databases are queried via R-API calls. All US stocks with a market
capitalization greater than USD 100 Mio. constitute the constituent universe.

The sample period covers 32 years between 1993 to 2024. The whole dataset was split into three non-overlapping parts:
a cross-validation (training) set, a test-set to evaluate the models and hyperparameters and a OOS-set primarily
designated for index-construction and performance-evaluation.

## Slide 5: Methodology I: Response variable classification

Exactly as on the slide.

Example: A firm crosses C in November 2011 (2011-11-15). It must now stay consistently
below the M-threshold for the next T-periods (18 Months). Thus, it must decline another 20%
until March 2013 (2013-03-15). Consequently, it is classified as a CSI in the whole year of 2012.

## Slide 6: Robustness I: Do CSI-firms go bankrupt?

By applying the paper methodology to the CRSP dataset, one finds 8,217 observations within the specified period.
Yet, as outlined by my thesis supervisor, one should raise the question whether this, at first glance arbitrary, parameter
combination actually leads to the detection of CSI-firms?

Interestingly, the parameter combination used by the paper only catches 24% of firms matching the CRSP-delisting codes 572 to 574.
The low-detection rate causes methodological issues. If one sticks
strictly to the paper, then the CSI methodology should catch firms that never
recover. Yet, the data show a different result.

## Slide 7: Methodology II: “Temporary-CSI”

To deal with this issue, I propose a revision to the classification methodology.

Within the revised framework, I explicitly add all firms which match
the CRSP codes 572, 573, and 574, to the dataset after observing a valid drawdown trigger. This classification
methodology will henceforth be referred to as “Temporary-CSI”.

Using this framework, one is able to detect 86.65% of the delisting firms. 
The remaining 84 firms bankrupt before observing the breach in the initial C-threshold. As such they
are excluded from the label-classification.

## Slide 8: Applying the revised temporary classification

After applying the revised temporary-CSI rule, which augments the paper classification
with terminal-failure delisting codes, one finds 8,517 response observations for the
selected CRSP dataset within the 1993 to 2024 time period. The prevalence of the
response variable is similar across the train and test datasets. Overall, the dataset has
188,460 observations, with roughly 75% clustered in the train set.

### Further robustness checks

Even though the paper outlines that a combination of classification grid values was tested,
the selected combination still appears arbitrary. For this reason, further robustness checks
will be conducted to evaluate the chosen grid values. It will be asked how different the prevalence rate of the response variable is when testing different grid combinations.

## Slide 9: Robustness II: Do CSI-classified firms recover again?

In addition to bankruptcy checks, robustness checks were also conducted to
determine whether CSI-classified firms are in persistent decline.
A grid-search for the three classification parameters was conducted to track the five-year recovery of firms
after classification. Subsequently, each firm is sorted into one of five buckets depending on its five-year
performance after classification

Using the paper parameter-combination, roughly 13% of firms either make a partial or full recovery.
This is inherently a methodological issue: we classify firms as a CSI event, which subsequently recover in the next 5 years.
Thus, if we were to exclude them during their recovery, we would inherently create many false-positives.

The more we constrain the sample by implementing "stricter" threshholds, the less-false positives one gets.

## Slide 10: Methodology III: “Permanent-CSI”

Due to the non-negligible portion of recovering
firms, it is proposed to test a secondary classification methodology: “Permanent-CSI”. This methodology is
more forward-looking: if a firm did not recover above the defined M threshold after five years, it is classified as
a CSI event.

Permanent-CSI ensures that no firms recover in the subsequent 5 years. They either get delisted in the next 36 months,
or if they continue to be traded, they do not recover. With this methodology, one can ensure that the firms
classified as a CSI-event represent permanent-impairment events, as outlined by Tewari et al. (2024).

## Slide 11: Applying the classification: permanent CSI

By construction, Permanent-CSI is more restrictive than the initial classification
methodology. The full dataset now records 6,258 responses with y = 1 (compared
to 8,517 originally). The prevalence drops from 4.74 to 3.34%. Overall, the
prevalence rate is similar across the train and test sets, with the test set showing a
slightly smaller prevalence of the response variable.

### Low-prevalence in the OOS-set

The OOS dataset shows a markedly smaller prevalence rate of the response variable. This occurs because the
forward-looking classification methodology is constrained by the available data periods. This is not an issue
because the OOS dataset is mainly used to evaluate index construction performance in the later part of the
thesis.

## Slide 12: Dataset: Descriptive statistics

Both label definitions isolate a small distressed tail. The key contrast is not only prevalence: labeled firms are
much smaller and show worse realized returns and profitability.

Even though the classification methodology seems to separate firms rather well, it also constrains the
expectations for the index construction part of this thesis. CSI-classified firms are considerably smaller
(measured by market cap) than their peers. Thus, their index weight will be smaller, which implies only a
minor contribution to overall index returns. Consequently, a priori one would not expect to observe a drastic
outperformance by avoiding or downweighting CSI-classified firms.

## Slide 13: Modelling I: Setup and feature engineering

The dataset was split into three distinct, non-overlaping sub-datasets. 
Firstly, the training-set, which ranges from 1993 to 2014 was setup for model-training and 
cross-validation. Secondly, the test-set includes the years 2015 to 2019 whilst the OOS-dataset 
is comprised of the years from 2020 to 2024. The OOS-dataset serves primarily as the dataset to 
evaluate the index-construction parts of this thesis. Model selection will be conducted based on the 
test-set.

Within the train-dataset, an expanding-window cross-validation approach is employed. The 
hyperparameters are optimized on an initial batch of training years. These are then tested on 
unseen data from the training set. In the next iteration, the hyperparameter optimization set 
includes the previous batch of test-observations. This time, the hyperparameters are evaluated 
on a new batch of unseen future observations.

### Modelling Algorithm and feature sets

Citations: 
- 

PIT and Feature Engineering. VAE.

Compustat starts with 67 downloaded fields: 5 identifiers/metadata (gvkey, datadate, fyear, fyr, sich) and 62 accounting/business variables. FRED starts with 9 downloaded macro series: GDP, unemployment, Fed funds, 10-year Treasury, high-yield spread, VIX, CPI, industrial production, and recession indicator. These are not used only as raw fields: they are transformed into ratios, changes, rolling histories, deterioration signals, and macro interactions.
The main expansion comes from applying repeat transformations to a core set of 43 dynamic variables. These generate 43 YoY changes, 43 acceleration variables, 43 expanding means, and 43 expanding volatilities. Additional families add 18 peak-deterioration, 7 trough-rise, 10 consecutive-decline, 15 accounting-momentum, 90 rolling 3-year, 90 rolling 5-year, 8 direct price/momentum/risk, and 6 macro-interaction features. Final model counts are: 458 features for the base/fundamental dataset, 477 features for the extended/raw dataset, 25 VAE latent features, and 502 features for extended + VAE

Temporary and permanent CSI use the same predictor counts; what changes is the target label, not the feature matrix. The base dataset contains 458 engineered model features, built from fundamentals, macro variables, ratios, lags, rolling windows, deterioration signals, and macro interactions.
The extended dataset adds 19 price/market-based features, mainly return, momentum, volatility, and drawdown information, bringing the count to 477 features. The VAE representation adds 25 latent features: z1 to z24 plus reconstruction error. Therefore the VAE-only dataset has 25 features, and the extended + VAE dataset has 502 features in total: 477 extended features + 25 VAE features.

## Slide 14: Modelling II:AutoGluon

Citations:
- Altman (1968): Altman-Z-Score.
- Alanis et al. (2022): Tree ensemble methods outperform the other model classes in one-year-ahead bankruptcy forecasts, with XG Boost and LightGBM reaching about 0.92 AUC in the full out-of-sample sample (pp. 15-16, 23, 40-41).
Paper directly says: Firm-level market variables, especially annual excess return, idiosyncratic risk, and relative size, are the most important predictors in the overall sample (pp. 16-17, 23, 34)
- Barboza et al. (2017): Machine-learning models generally outperform traditional models in the testing sample, with random forest, boosting, and bagging performing best among the methods studied (pp. 413-415).
Paper directly says: With all eleven predictors, random forest reaches 87.06% testing accuracy, boosting reaches 86.65%, and bagging reaches 85.67%, compared with 76.29% for logistic regression and 52.18% for multivariate discriminant analysis (p. 413).
- Jiang et al. (2024): Machine-learning models outperform OLS in out-of-sample crash-risk prediction; OLS has negative predictive R2, while nonlinear models, especially feed-forward neural networks, perform best (pp. 5-6).
Paper directly says: For NCSKEW prediction, the feed-forward neural network reaches an out-of-sample R2 of 4.56%, while the ensemble model reaches 4.46%; for DUVOL, the feed-forward neural network reaches 3.30% (p. 6).
Paper directly says: Machine learning improves directional crash-risk prediction relative to OLS, especially for nonlinear models such as random forest and feed-forward neural networks (pp. 6-8).

Extensive research has been conducted on bankruptcy prediction. Altman (1968), amongst others, first defined variables 
to predict firm-distress. Contemporary research (Alanis et al. (2022), Barboza et al. (2017), Jiang et al. (2024)) show that machine
learning-models outperform linear-models (like logistic-regression). Decision-Trees, particularly Gradient Boosting methods,
are well suited for bankruptcy prediction. 

Within the Industry Lab Project between the OeNB and the WU-QFIN program, the my colleagues and I showed that
AutoGluon works very well for bankruptcy prediction. For this reason, I decided to once more test it 
within the CSI framework. Early tests have shown that it outperforms single Gradient-Boosting methods, like XGBoost (implemented)
via the standard R-libraries.

AutoGluon is an open-source AutoML library designed to train and
deploy state-of-the-art machine and deep learning models on various types of data.
It optimizes a diverse set of model families (GBMs, Random Forests, Neural Networks) and combines them via multi-layer ensemble-stacking.

Shown on this slide are the second layer stacked-ensemble weights for the temporary- and permanent CSI fundamental
models. Apparently, GBMs are particularly well suited for CSI-prediction.
Neural-Nets also appear to have a considerable weight within the permanent-CSI framework, with RF not being included.

## Slide 15: Modelling II: Results temporary CSI

Citations:
- Tewari et al. (2024, p. 9): " XGBoost proved to
be the most versatile option in implosion detection, predicting 61% of implosions in the test set
with a false positive rate of less than 3%, demonstrating robust ability in signalling Catastrophic
Implosions while also leaving room for improvement."

Temporary CSI is a rare-event classification problem: only 4.74% of labelled firm-years are positives. Because
of this class imbalance, AP and fixed-FPR recall are more decision-relevant than AUC alone. AG Exp. Dataset
and VAE ranks best in CV, while AG Expanded Dataset is strongest on the 2016-2019 test split

Test-AP improves from the 4.44% test prevalence baseline to 19.85%, showing meaningful concentration of
CSI cases near the top of the risk ranking. Test-AUC of 0.8766 confirms strong broad ranking, but AP is the
more useful indicator for practical screening. Overall, the results are in-line with the findings by Alanis et al.
(2022) and Barboza et al. (2017), who showed that (boosted) tree ensembles reach strong
bankruptcy-prediction results.

Overall, Recall-at-FPR3 in the test set gives an interesting insight. Given a maximum FPR of 3%
based on the training set, results in the top model detecting 20% of the CSI-events. 
Tewari et al. (2024) showed a FPR3 of roughly 60%. Thus, the modeling results are markedly
worse than in the reference paper. 

## Slide 16: Modelling III: Results permanent CSI

Permanent CSI is the harder task: positives are rarer than temporary CSI, with only 3.34% positives in the full
labelled sample and 3% in the test split. Despite this, the models still rank risk well. AG Expanded Dataset
remains the reporting baseline, while AG Exp. Dataset + VAE is the strongest non-raw challenger on CV/test.

In comparison to permanent-CSI Test-AP and FPR3 are lower in Permanent-CSI. At the same time, the addition of the
latent representation seems to work better than only the expanded dataset alone, especially in terms of FPR3 in the test set.

## Slide 17: Modelling Summary: the models rank implosion risk well

Overall, as shown by the high-AUC score, model ranking seems to work well.
Average Precision is 4.5x higher than in the naive-classifier benchmark.
Expanded Dataset is the  reporting baseline; Exp. Dataset + VAE
the strongest challenger.

Via the model-predictions we can now use the calibrated risk-scores to form the index-exclusion signal.
The question now expands to: “Does removing flagged firms using the model predictions improve the risk-return metric of risk-filtered indices?”

## Slide 18: Modelling IV: Implications for index construction

Overall, The models rank risk well, but false positives are frequent and unavoidable.
Precision is fairly low: about 4 "healthy" firms are excluded per CSI-labelled firm.
Additionally, there is no clean-cutoff. We cannot seperate false positives and true positives well enough.
Last, but not least the threshold does change considerably. A 8.7% cutoff in the CV-set, becomes a 3%
cutoff in the test-set, which makes proper FPR1, 3 and 5 estimation more difficult.

The prior before starting with index-construction is that it will likely be difficult to outperform
the benchmark due to the low precision and associated high cost of false-positives. 

## Slide 19: Index Construction I: From score to portfolio weight

Citations:
- Campbell et al. (2008): Campbell, Hilscher, and Szilagyi study how corporate failure can be predicted and whether firms with high predicted distress risk earn compensating stock returns (pp. 2900-2903). The sample combines KRIS bankruptcy and failure indicators with Compustat accounting data and CRSP market data, covering bankruptcy filings from 1963-1998 and broader failure events from 1963-2003; the authors report roughly 800 bankruptcies, 1,600 broader failures, and about 1.7 million firm-month observations (pp. 2901, 2903-2906). The core method is a dynamic panel logit model using accounting and market-based predictors, followed by portfolio sorts on estimated failure probability to examine realized returns and factor-adjusted performance (pp. 2900-2902, 2933). The paper is primarily about distress prediction and asset pricing, not machine-learning model selection or index construction directly.

The model produces a probability of a CSI in the next year. A threshold turns this probability into a binary
exclusion flag. The flag is then applied to market-cap weights (similarly to Campbell et al. (2008)). The two
regimes differ only in how long the flag persists after it first emerges


