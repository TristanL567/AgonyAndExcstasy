# AE-MODEL-SUITE-011 Final Model And Index Results Summary

## Scope

This ticket summarizes temporary CSI and permanent CSI model-suite evidence only. Feature sets covered are raw, fundamental, VAE-only, and raw + latent. Splits covered are train/CV, test, and OOS. Index-construction results are summarized where available. Sensitivity-analysis results are explicitly excluded.

No model training, evaluation script, index construction, pipeline regeneration, sensitivity script, SSH command, or remote mutation was run for this ticket.

## Source Inputs

- Model-suite local root: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite`
- Raw complete threshold metrics: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite\raw\derived_metrics\raw_complete_threshold_metrics.csv`
- Non-raw complete threshold metrics: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite\derived_metrics\complete_threshold_metrics_long.csv`
- Raw revised 11C benchmark root: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\raw_benchmark\raw_preservation_20260529\raw_11c_index_revised`

## Temporary CSI Model Metrics

|Feature set|Split|AUC|AP|Brier|R@FPR1|R@FPR3|R@FPR5|Labelled|Positives|Negatives|
|---|---|---|---|---|---|---|---|---|---|---|
|raw|train/CV|0.8635|0.2046|0.0371|0.0917|0.2344|0.3415|72223|3119|69104|
|raw|test|0.8766|0.1985|0.0389|0.0821|0.2002|0.2998|18111|804|17307|
|raw|OOS|0.8961|0.3084|0.0498|0.0915|0.2547|0.4000|18502|1170|17332|
|fundamental|train/CV|0.8446|0.1923|0.0374|0.0830|0.2206|0.3229|72223|3119|69104|
|fundamental|test|0.8538|0.1656|0.0392|0.0585|0.1517|0.2413|18111|804|17307|
|fundamental|OOS|0.8686|0.2526|0.0526|0.0598|0.1795|0.3017|18502|1170|17332|
|VAE-only|train/CV|0.8454|0.1659|0.0380|0.0670|0.1706|0.2735|72223|3119|69104|
|VAE-only|test|0.8438|0.1501|0.0394|0.0410|0.1294|0.2264|18111|804|17307|
|VAE-only|OOS|0.8626|0.2813|0.0518|0.1009|0.2274|0.3556|18502|1170|17332|
|raw + latent|train/CV|0.8667|0.2114|0.0368|0.0981|0.2478|0.3581|72223|3119|69104|
|raw + latent|test|0.8741|0.1864|0.0394|0.0634|0.1779|0.2749|18111|804|17307|
|raw + latent|OOS|0.8950|0.3152|0.0494|0.1051|0.2632|0.4128|18502|1170|17332|

## Permanent CSI Model Metrics

|Feature set|Split|AUC|AP|Brier|R@FPR1|R@FPR3|R@FPR5|Labelled|Positives|Negatives|
|---|---|---|---|---|---|---|---|---|---|---|
|raw|train/CV|0.8757|0.1854|0.0297|0.1098|0.2607|0.3697|72223|2459|69764|
|raw|test|0.8810|0.1416|0.0284|0.0664|0.1808|0.3007|18053|542|17511|
|raw|OOS|0.8081|0.0323|0.0211|0.0000|0.0119|0.0623|26400|337|26063|
|fundamental|train/CV|0.8677|0.1785|0.0299|0.1033|0.2379|0.3469|72223|2459|69764|
|fundamental|test|0.8627|0.1289|0.0293|0.0627|0.1697|0.2620|18053|542|17511|
|fundamental|OOS|0.7798|0.0281|0.0232|0.0000|0.0030|0.0297|26400|337|26063|
|VAE-only|train/CV|0.8460|0.1426|0.0308|0.0732|0.1960|0.2908|72223|2459|69764|
|VAE-only|test|0.8496|0.1115|0.0280|0.0424|0.1513|0.2546|18053|542|17511|
|VAE-only|OOS|0.8337|0.0482|0.0166|0.0504|0.1484|0.2226|26400|337|26063|
|raw + latent|train/CV|0.8719|0.1883|0.0297|0.1196|0.2578|0.3680|72223|2459|69764|
|raw + latent|test|0.8838|0.1415|0.0283|0.0609|0.2011|0.3155|18053|542|17511|
|raw + latent|OOS|0.8032|0.0311|0.0207|0.0000|0.0208|0.0653|26400|337|26063|

## Temporary CSI Index-Construction Summary

|Feature set|Index status|Best/available result|Return|Volatility|Sharpe|Max DD|Vs benchmark|Notes|
|---|---|---|---|---|---|---|---|---|
|raw|available|best raw strategy by benchmark-relative return: youden_2yr|12.23%|14.56%|0.6651|-18.65%|0.80%|benchmark return 11.02%, Sharpe 0.5824; weights .rds present=True|
|fundamental|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|
|VAE-only|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|
|raw + latent|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|

## Permanent CSI Index-Construction Summary

|Feature set|Index status|Best/available result|Return|Volatility|Sharpe|Max DD|Vs benchmark|Notes|
|---|---|---|---|---|---|---|---|---|
|raw|available|best raw strategy by benchmark-relative return: youden_permanent|12.09%|14.18%|0.6702|-18.27%|0.65%|benchmark return 11.02%, Sharpe 0.5824; weights .rds present=True|
|fundamental|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|
|VAE-only|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|
|raw + latent|not yet rerun|not available||||||Predictions exist and are ready for a later 11C rerun; no index results fabricated.|

## Interpretation

For temporary CSI, raw + latent is the strongest feature set by AP on train/CV, test, and OOS. Raw remains very close on AUC, and raw + latent has the best OOS recall at FPR 1%, 3%, and 5%. VAE-only adds standalone signal, especially OOS, but it does not dominate raw + latent. Fundamental-only is useful as a clean benchmark and is weaker than raw + latent across the main temporary CSI metrics.

For permanent CSI, raw + latent is strongest on train/CV and test AP/AUC, while VAE-only is strongest OOS by AP, AUC, Brier, and recall at FPR 1%, 3%, and 5%. Raw remains the reporting baseline, but raw + latent is the main non-raw challenger and VAE-only should be retained as an OOS-robustness sensitivity. Fundamental-only remains useful as a fundamentals benchmark but is not the preferred final candidate unless the reporting objective is specifically fundamentals-only interpretability.

Raw + latent improves over raw for temporary CSI AP and OOS FPR recall, and improves permanent CSI train/CV and test AP/AUC. It does not beat VAE-only on permanent CSI OOS robustness. VAE-only clearly adds standalone signal, most notably in permanent CSI OOS metrics.

The raw revised 11C index benchmark is available for both tracks. Non-raw index construction has not yet been rerun for fund, latent_raw, or raw_plus_latent, so no index-level superiority should be claimed for those feature sets yet. Their predictions exist and are ready for a later index-construction rerun.

## Metric Winners

- temporary CSI train/CV ap: raw + latent (0.2114).
- temporary CSI test ap: raw (0.1985).
- temporary CSI OOS ap: raw + latent (0.3152).
- temporary CSI train/CV auc: raw + latent (0.8667).
- temporary CSI test auc: raw (0.8766).
- temporary CSI OOS auc: raw (0.8961).
- temporary CSI train/CV recall_fpr1: raw + latent (0.0981).
- temporary CSI test recall_fpr1: raw (0.0821).
- temporary CSI OOS recall_fpr1: raw + latent (0.1051).
- temporary CSI train/CV recall_fpr3: raw + latent (0.2478).
- temporary CSI test recall_fpr3: raw (0.2002).
- temporary CSI OOS recall_fpr3: raw + latent (0.2632).
- temporary CSI train/CV recall_fpr5: raw + latent (0.3581).
- temporary CSI test recall_fpr5: raw (0.2998).
- temporary CSI OOS recall_fpr5: raw + latent (0.4128).
- permanent CSI train/CV ap: raw + latent (0.1883).
- permanent CSI test ap: raw (0.1416).
- permanent CSI OOS ap: VAE-only (0.0482).
- permanent CSI train/CV auc: raw (0.8757).
- permanent CSI test auc: raw + latent (0.8838).
- permanent CSI OOS auc: VAE-only (0.8337).
- permanent CSI train/CV recall_fpr1: raw + latent (0.1196).
- permanent CSI test recall_fpr1: raw (0.0664).
- permanent CSI OOS recall_fpr1: VAE-only (0.0504).
- permanent CSI train/CV recall_fpr3: raw (0.2607).
- permanent CSI test recall_fpr3: raw + latent (0.2011).
- permanent CSI OOS recall_fpr3: VAE-only (0.1484).
- permanent CSI train/CV recall_fpr5: raw (0.3697).
- permanent CSI test recall_fpr5: raw + latent (0.3155).
- permanent CSI OOS recall_fpr5: VAE-only (0.2226).

## Next Step

Run a separate index-construction rerun epic for the non-raw model predictions saved under `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite` before claiming index-level superiority for fund, latent_raw, or raw_plus_latent.

## Validation

- All four feature sets are represented for both tracks and all three splits in the model metric tables.
- Raw metrics include recall at FPR 1%, 3%, and 5% from the downloaded raw threshold metrics.
- Non-raw metrics include recall at FPR 1%, 3%, and 5% from local complete threshold metrics.
- Raw revised 11C index outputs are summarized from local raw benchmark files.
- Non-raw index results are explicitly marked not yet rerun; no index results were fabricated.
- No files under `03_Data_Output/**` were written or staged by this ticket.
