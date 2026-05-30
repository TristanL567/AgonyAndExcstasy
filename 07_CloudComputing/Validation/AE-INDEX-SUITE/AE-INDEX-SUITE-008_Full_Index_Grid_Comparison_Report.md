# AE-INDEX-SUITE-008 Full Index Grid Comparison Report

Result: validator_passed

## Scope

This is a comparison/reporting-only ticket. It compares the completed isolated full index grid across four model families, two CSI tracks, four CRSP-like indices, four threshold methods, temporary lockouts, permanent removal, and transaction-cost levels of 0, 5, 10, and 20 bps.

No 11C, model training, evaluation, sensitivity, or pipeline script was rerun in this ticket.

## Output Locations

Comparison outputs were written under:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison`

Mirrored compact evidence files were written under:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\07_CloudComputing\Validation\AE-INDEX-SUITE`

## Grid Validation

| check                          | status   | detail                                                                                                                        |
|:-------------------------------|:---------|:------------------------------------------------------------------------------------------------------------------------------|
| all_required_files_exist       | True     | 8/8 model-track pairs complete                                                                                                |
| threshold_grid_complete        | True     | All model-track threshold and lockout/permanent grids complete                                                                |
| transaction_cost_grid_complete | True     | All model-track performance files contain 0,5,10,20 bps                                                                       |
| turnover_outputs_complete      | True     | All model-track turnover summaries populated                                                                                  |
| indices_complete               | True     | All model-track outputs include total_market, large_cap, mid_cap, small_cap                                                   |
| comparison_reporting_only      | True     | No 11C/model/evaluation/sensitivity/pipeline script was invoked by this comparison ticket                                     |
| comparison_output_root         | True     | C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\comparison |

## Headline Winners At 20 bps

Temporary CSI: large_cap: fund / youden / 3yr lockout (net alpha 0.15%); mid_cap: fund / fpr5 / 5yr lockout (net alpha 0.51%); small_cap: raw_plus_latent / youden / 3yr lockout (net alpha 0.62%); total_market: fund / youden / 3yr lockout (net alpha 0.42%)

Permanent CSI: large_cap: raw_plus_latent / fpr5 / Permanent removal (net alpha 0.23%); mid_cap: fund / fpr5 / Permanent removal (net alpha 0.74%); small_cap: latent_raw / fpr3 / Permanent removal (net alpha 0.32%); total_market: raw_plus_latent / fpr5 / Permanent removal (net alpha 0.27%)

## Best Model/Strategy By Track, Index, And Cost

| response_track   | index_id     | index_name                | analysis_model   | model_key       | threshold_method   | threshold_label   |   lockout_years | exclusion_rule    | rule_label        | strategy_id    |   transaction_cost_bps |   net_annualized_geometric_return |   benchmark_net_annualized_geometric_return |   net_difference_versus_benchmark |   net_sharpe_ratio |   net_max_drawdown |   annualized_turnover_gross |   total_transaction_cost_return_drag |
|:-----------------|:-------------|:--------------------------|:-----------------|:----------------|:-------------------|:------------------|----------------:|:------------------|:------------------|:---------------|-----------------------:|----------------------------------:|--------------------------------------------:|----------------------------------:|-------------------:|-------------------:|----------------------------:|-------------------------------------:|
| dynamic_csi      | large_cap    | CRSP-like US Large Cap    | fund             | fund            | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                      0 |                            0.1443 |                                      0.1428 |                            0.0015 |             0.6779 |            -0.2389 |                      0.1304 |                               0.0000 |
| dynamic_csi      | large_cap    | CRSP-like US Large Cap    | fund             | fund            | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                     20 |                            0.1440 |                                      0.1425 |                            0.0015 |             0.6765 |            -0.2390 |                      0.1304 |                               0.0013 |
| dynamic_csi      | mid_cap      | CRSP-like US Mid Cap      | fund             | fund            | fpr5               | CV FPR <= 5%      |               5 | lockout_5yr       | 5yr lockout       | fpr5_5yr       |                      0 |                            0.1016 |                                      0.0965 |                            0.0051 |             0.4290 |            -0.2446 |                      1.0586 |                               0.0000 |
| dynamic_csi      | mid_cap      | CRSP-like US Mid Cap      | fund             | fund            | fpr5               | CV FPR <= 5%      |               5 | lockout_5yr       | 5yr lockout       | fpr5_5yr       |                     20 |                            0.0993 |                                      0.0942 |                            0.0051 |             0.4190 |            -0.2446 |                      1.0586 |                               0.0106 |
| dynamic_csi      | small_cap    | CRSP-like US Small Cap    | raw_plus_latent  | raw_plus_latent | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                      0 |                            0.0829 |                                      0.0765 |                            0.0064 |             0.3355 |            -0.2933 |                      0.8549 |                               0.0000 |
| dynamic_csi      | small_cap    | CRSP-like US Small Cap    | raw_plus_latent  | raw_plus_latent | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                     20 |                            0.0811 |                                      0.0749 |                            0.0062 |             0.3281 |            -0.2933 |                      0.8549 |                               0.0085 |
| dynamic_csi      | total_market | CRSP-like US Total Market | fund             | fund            | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                      0 |                            0.1372 |                                      0.1329 |                            0.0043 |             0.6356 |            -0.2378 |                      0.1037 |                               0.0000 |
| dynamic_csi      | total_market | CRSP-like US Total Market | fund             | fund            | youden             | CV Youden J       |               3 | lockout_3yr       | 3yr lockout       | youden_3yr     |                     20 |                            0.1370 |                                      0.1328 |                            0.0042 |             0.6344 |            -0.2379 |                      0.1037 |                               0.0010 |
| permanent_csi    | large_cap    | CRSP-like US Large Cap    | raw_plus_latent  | raw_plus_latent | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                      0 |                            0.1451 |                                      0.1428 |                            0.0023 |             0.6707 |            -0.2451 |                      0.1151 |                               0.0000 |
| permanent_csi    | large_cap    | CRSP-like US Large Cap    | raw_plus_latent  | raw_plus_latent | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                     20 |                            0.1448 |                                      0.1425 |                            0.0023 |             0.6695 |            -0.2452 |                      0.1151 |                               0.0012 |
| permanent_csi    | mid_cap      | CRSP-like US Mid Cap      | fund             | fund            | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                      0 |                            0.1039 |                                      0.0965 |                            0.0074 |             0.4408 |            -0.2452 |                      1.0624 |                               0.0000 |
| permanent_csi    | mid_cap      | CRSP-like US Mid Cap      | fund             | fund            | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                     20 |                            0.1016 |                                      0.0942 |                            0.0074 |             0.4307 |            -0.2452 |                      1.0624 |                               0.0106 |
| permanent_csi    | small_cap    | CRSP-like US Small Cap    | latent_raw       | latent_raw      | fpr3               | CV FPR <= 3%      |               0 | permanent_removal | Permanent removal | fpr3_permanent |                      0 |                            0.0798 |                                      0.0765 |                            0.0032 |             0.3181 |            -0.2926 |                      0.7573 |                               0.0000 |
| permanent_csi    | small_cap    | CRSP-like US Small Cap    | latent_raw       | latent_raw      | fpr3               | CV FPR <= 3%      |               0 | permanent_removal | Permanent removal | fpr3_permanent |                     20 |                            0.0782 |                                      0.0749 |                            0.0032 |             0.3118 |            -0.2926 |                      0.7573 |                               0.0076 |
| permanent_csi    | total_market | CRSP-like US Total Market | raw_plus_latent  | raw_plus_latent | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                      0 |                            0.1356 |                                      0.1329 |                            0.0027 |             0.6147 |            -0.2472 |                      0.0680 |                               0.0000 |
| permanent_csi    | total_market | CRSP-like US Total Market | raw_plus_latent  | raw_plus_latent | fpr5               | CV FPR <= 5%      |               0 | permanent_removal | Permanent removal | fpr5_permanent |                     20 |                            0.1354 |                                      0.1328 |                            0.0027 |             0.6140 |            -0.2473 |                      0.0680 |                               0.0007 |

## Did Transaction Costs Change Rankings?

Ranking changes between 0 bps and 20 bps occurred in 0 of 8 track-index winner comparisons. The full impact table is `AE-INDEX-SUITE-008_transaction_cost_impact.csv`.

Transaction costs are economically smallest for low-turnover strategies and larger for high-turnover threshold/lockout combinations. The transaction-cost impact table reports the 0-to-20 bps return and alpha loss for every OOS strategy.

## Threshold Families

| response_track   | threshold_method   |   transaction_cost_bps |   mean_best_alpha |   median_best_alpha |   mean_best_net_return |   n_index_wins |
|:-----------------|:-------------------|-----------------------:|------------------:|--------------------:|-----------------------:|---------------:|
| dynamic_csi      | youden             |                      0 |            0.0035 |              0.0031 |                 0.1157 |              4 |
| dynamic_csi      | fpr3               |                      0 |            0.0019 |              0.0015 |                 0.1141 |              4 |
| dynamic_csi      | fpr5               |                      0 |            0.0017 |              0.0014 |                 0.1139 |              4 |
| dynamic_csi      | fpr1               |                      0 |            0.0012 |              0.0010 |                 0.1134 |              4 |
| dynamic_csi      | youden             |                      5 |            0.0035 |              0.0031 |                 0.1154 |              4 |
| dynamic_csi      | fpr3               |                      5 |            0.0019 |              0.0015 |                 0.1138 |              4 |
| dynamic_csi      | fpr5               |                      5 |            0.0017 |              0.0014 |                 0.1136 |              4 |
| dynamic_csi      | fpr1               |                      5 |            0.0012 |              0.0011 |                 0.1131 |              4 |
| dynamic_csi      | youden             |                     10 |            0.0035 |              0.0031 |                 0.1152 |              4 |
| dynamic_csi      | fpr3               |                     10 |            0.0019 |              0.0015 |                 0.1136 |              4 |
| dynamic_csi      | fpr5               |                     10 |            0.0017 |              0.0014 |                 0.1134 |              4 |
| dynamic_csi      | fpr1               |                     10 |            0.0012 |              0.0011 |                 0.1128 |              4 |
| dynamic_csi      | youden             |                     20 |            0.0035 |              0.0031 |                 0.1146 |              4 |
| dynamic_csi      | fpr3               |                     20 |            0.0019 |              0.0015 |                 0.1130 |              4 |
| dynamic_csi      | fpr5               |                     20 |            0.0017 |              0.0014 |                 0.1128 |              4 |
| dynamic_csi      | fpr1               |                     20 |            0.0012 |              0.0011 |                 0.1123 |              4 |
| permanent_csi    | fpr3               |                      0 |            0.0035 |              0.0027 |                 0.1157 |              4 |
| permanent_csi    | fpr5               |                      0 |            0.0033 |              0.0025 |                 0.1155 |              4 |
| permanent_csi    | fpr1               |                      0 |            0.0014 |              0.0012 |                 0.1136 |              4 |
| permanent_csi    | youden             |                      0 |           -0.0020 |             -0.0025 |                 0.1102 |              4 |
| permanent_csi    | fpr3               |                      5 |            0.0035 |              0.0027 |                 0.1154 |              4 |
| permanent_csi    | fpr5               |                      5 |            0.0033 |              0.0025 |                 0.1152 |              4 |
| permanent_csi    | fpr1               |                      5 |            0.0014 |              0.0012 |                 0.1133 |              4 |
| permanent_csi    | youden             |                      5 |           -0.0020 |             -0.0025 |                 0.1099 |              4 |

## Do VAE Features Add Index-Level Value?

VAE/non-raw alpha exceeds raw in 5/8 track-index cases at 20 bps.

Use `AE-INDEX-SUITE-008_model_family_comparison.csv` for model-by-model winners and ranks. `raw_plus_latent` and `latent_raw` should be interpreted at the index level only after considering transaction-cost robustness and turnover.

## Temporary Versus Permanent CSI

Temporary CSI has a larger strategy grid because it combines threshold families with 1/2/3/5-year lockouts. Permanent CSI has the simpler permanent-removal rule. The best-strategy tables show which track dominates by index and cost; neither should be generalized without the index-specific net alpha and turnover context.

## Presentation-Ready Tables

`AE-INDEX-SUITE-008_presentation_tables.csv` contains compact tables for:

- temporary CSI headline winners
- permanent CSI headline winners
- benchmark context rows
- threshold-family comparison

These are the recommended inputs for final presentation tables.

## Caveats

- Best-strategy selection is OOS-focused and ranked by net benchmark-relative annualized geometric return, with net return and net Sharpe as tie-break context.
- Benchmark rows are retained for context; model winner tables exclude benchmark rows.
- Comparison outputs are generated under an isolated validation output tree and are not intended to be committed as source data.

## Conclusion

The full FPR5-enabled index grid is represented and internally consistent. AE-INDEX-SUITE closeout can proceed after validator approval.
