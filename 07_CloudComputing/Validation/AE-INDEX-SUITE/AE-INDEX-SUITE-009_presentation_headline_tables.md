# AE-INDEX-SUITE-009 Presentation Headline Tables

## Temporary CSI Winners At 20 bps

| track_label   | index_label   | analysis_model   | threshold_method   | rule_label   |   net_annualized_geometric_return |   benchmark_net_annualized_geometric_return |   net_difference_versus_benchmark |   net_sharpe_ratio |   net_max_drawdown |   annualized_turnover_gross |   total_transaction_cost_return_drag |
|:--------------|:--------------|:-----------------|:-------------------|:-------------|----------------------------------:|--------------------------------------------:|----------------------------------:|-------------------:|-------------------:|----------------------------:|-------------------------------------:|
| Temporary CSI | Large cap     | fund             | youden             | 3yr lockout  |                            0.1440 |                                      0.1425 |                            0.0015 |             0.6765 |            -0.2390 |                      0.1304 |                               0.0013 |
| Temporary CSI | Mid cap       | fund             | fpr5               | 5yr lockout  |                            0.0993 |                                      0.0942 |                            0.0051 |             0.4190 |            -0.2446 |                      1.0586 |                               0.0106 |
| Temporary CSI | Small cap     | raw_plus_latent  | youden             | 3yr lockout  |                            0.0811 |                                      0.0749 |                            0.0062 |             0.3281 |            -0.2933 |                      0.8549 |                               0.0085 |
| Temporary CSI | Total market  | fund             | youden             | 3yr lockout  |                            0.1370 |                                      0.1328 |                            0.0042 |             0.6344 |            -0.2379 |                      0.1037 |                               0.0010 |

## Permanent CSI Winners At 20 bps

| track_label   | index_label   | analysis_model   | threshold_method   | rule_label        |   net_annualized_geometric_return |   benchmark_net_annualized_geometric_return |   net_difference_versus_benchmark |   net_sharpe_ratio |   net_max_drawdown |   annualized_turnover_gross |   total_transaction_cost_return_drag |
|:--------------|:--------------|:-----------------|:-------------------|:------------------|----------------------------------:|--------------------------------------------:|----------------------------------:|-------------------:|-------------------:|----------------------------:|-------------------------------------:|
| Permanent CSI | Large cap     | raw_plus_latent  | fpr5               | Permanent removal |                            0.1448 |                                      0.1425 |                            0.0023 |             0.6695 |            -0.2452 |                      0.1151 |                               0.0012 |
| Permanent CSI | Mid cap       | fund             | fpr5               | Permanent removal |                            0.1016 |                                      0.0942 |                            0.0074 |             0.4307 |            -0.2452 |                      1.0624 |                               0.0106 |
| Permanent CSI | Small cap     | latent_raw       | fpr3               | Permanent removal |                            0.0782 |                                      0.0749 |                            0.0032 |             0.3118 |            -0.2926 |                      0.7573 |                               0.0076 |
| Permanent CSI | Total market  | raw_plus_latent  | fpr5               | Permanent removal |                            0.1354 |                                      0.1328 |                            0.0027 |             0.6140 |            -0.2473 |                      0.0680 |                               0.0007 |

## Transaction-Cost Robustness

| track_label   | index_label   | winner_0bps     | winner_20bps    | winner_changed_0_to_20_bps   |   alpha_0bps |   alpha_20bps |
|:--------------|:--------------|:----------------|:----------------|:-----------------------------|-------------:|--------------:|
| Temporary CSI | Large cap     | fund            | fund            | False                        |       0.0015 |        0.0015 |
| Temporary CSI | Mid cap       | fund            | fund            | False                        |       0.0051 |        0.0051 |
| Temporary CSI | Small cap     | raw_plus_latent | raw_plus_latent | False                        |       0.0064 |        0.0062 |
| Temporary CSI | Total market  | fund            | fund            | False                        |       0.0043 |        0.0042 |
| Permanent CSI | Large cap     | raw_plus_latent | raw_plus_latent | False                        |       0.0023 |        0.0023 |
| Permanent CSI | Mid cap       | fund            | fund            | False                        |       0.0074 |        0.0074 |
| Permanent CSI | Small cap     | latent_raw      | latent_raw      | False                        |       0.0032 |        0.0032 |
| Permanent CSI | Total market  | raw_plus_latent | raw_plus_latent | False                        |       0.0027 |        0.0027 |

## Model-Family Comparison Versus Raw

| track_label   | index_label   | top_model_20bps   |   raw_alpha_20bps | best_nonraw_model_20bps   |   best_nonraw_minus_raw_alpha | nonraw_beats_raw   |
|:--------------|:--------------|:------------------|------------------:|:--------------------------|------------------------------:|:-------------------|
| Permanent CSI | Large cap     | raw_plus_latent   |            0.0016 | raw_plus_latent           |                        0.0007 | True               |
| Permanent CSI | Mid cap       | fund              |            0.0046 | fund                      |                        0.0028 | True               |
| Permanent CSI | Small cap     | latent_raw        |            0.0010 | latent_raw                |                        0.0022 | True               |
| Permanent CSI | Total market  | raw_plus_latent   |            0.0021 | raw_plus_latent           |                        0.0006 | True               |
| Temporary CSI | Large cap     | fund              |            0.0015 | fund                      |                        0.0000 | True               |
| Temporary CSI | Mid cap       | fund              |            0.0038 | fund                      |                        0.0013 | True               |
| Temporary CSI | Small cap     | raw_plus_latent   |            0.0057 | raw_plus_latent           |                        0.0005 | True               |
| Temporary CSI | Total market  | fund              |            0.0042 | fund                      |                        0.0000 | True               |

## Threshold-Family Summary At 20 bps

| track_label   | threshold_method   |   mean_best_alpha |   median_best_alpha |   mean_best_net_return |   n_index_wins |
|:--------------|:-------------------|------------------:|--------------------:|-----------------------:|---------------:|
| Temporary CSI | youden             |            0.0035 |              0.0031 |                 0.1146 |              4 |
| Temporary CSI | fpr3               |            0.0019 |              0.0015 |                 0.1130 |              4 |
| Temporary CSI | fpr5               |            0.0017 |              0.0014 |                 0.1128 |              4 |
| Temporary CSI | fpr1               |            0.0012 |              0.0011 |                 0.1123 |              4 |
| Permanent CSI | fpr3               |            0.0035 |              0.0027 |                 0.1146 |              4 |
| Permanent CSI | fpr5               |            0.0033 |              0.0025 |                 0.1144 |              4 |
| Permanent CSI | fpr1               |            0.0014 |              0.0012 |                 0.1125 |              4 |
| Permanent CSI | youden             |           -0.0020 |             -0.0025 |                 0.1091 |              4 |

## Turnover Summary For 20 bps Winners

| track_label   | index_label   | analysis_model   | threshold_method   | exclusion_rule    |   mean_annualized_gross_turnover |   median_annualized_gross_turnover | high_turnover_flag   |
|:--------------|:--------------|:-----------------|:-------------------|:------------------|---------------------------------:|-----------------------------------:|:---------------------|
| Temporary CSI | Large cap     | fund             | youden             | lockout_3yr       |                           0.1878 |                             0.1878 | False                |
| Temporary CSI | Mid cap       | fund             | fpr5               | lockout_5yr       |                           0.9765 |                             0.9765 | False                |
| Temporary CSI | Small cap     | raw_plus_latent  | youden             | lockout_3yr       |                           0.7715 |                             0.7715 | False                |
| Temporary CSI | Total market  | fund             | youden             | lockout_3yr       |                           0.1531 |                             0.1531 | False                |
| Permanent CSI | Large cap     | raw_plus_latent  | fpr5               | permanent_removal |                           0.1720 |                             0.1720 | False                |
| Permanent CSI | Mid cap       | fund             | fpr5               | permanent_removal |                           0.9701 |                             0.9701 | False                |
| Permanent CSI | Small cap     | latent_raw       | fpr3               | permanent_removal |                           0.7240 |                             0.7240 | False                |
| Permanent CSI | Total market  | raw_plus_latent  | fpr5               | permanent_removal |                           0.1220 |                             0.1220 | False                |
