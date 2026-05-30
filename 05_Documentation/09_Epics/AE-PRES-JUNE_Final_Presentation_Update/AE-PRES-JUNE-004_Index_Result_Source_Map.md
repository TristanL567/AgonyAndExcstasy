# AE-PRES-JUNE-004 Index Result Source Map

## Edited June Presentation File

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

## Slide-Level Sources

| Frame | Claim/Table | Source files |
|---|---|---|
| Index Results: Temporary CSI at 20 bps | At 20 bps, `fund` wins Total, Large, and Mid Cap; `raw_plus_latent` wins Small Cap. Benchmark is the unfiltered market-cap-weighted universe. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/headline_winners_20bps.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/presentation_headline_tables.md` |
| Index Results: Permanent CSI at 20 bps | At 20 bps, `raw_plus_latent` wins Total and Large Cap; `fund` wins Mid Cap; `latent_raw` wins Small Cap. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/headline_winners_20bps.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/presentation_headline_tables.md` |
| Transaction-Cost Robustness | Winner rankings are unchanged from 0 to 20 bps for all eight track-index comparisons. Transaction-cost grid is 0, 5, 10, and 20 bps. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/transaction_cost_robustness_summary.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/transaction_cost_impact.csv` |
| Threshold Families and Turnover | Temporary CSI is strongest on average with Youden and longer lockouts; permanent CSI is strongest with FPR3/FPR5; turnover is concentrated in Mid and Small Cap. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/threshold_family_summary_20bps.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/turnover_summary.csv` |
| Appendix A14: Final Index Grid Contract | Complete grid covers 4 models, 2 tracks, 4 indices, Youden/FPR1/FPR3/FPR5, temporary 1/2/3/5-year lockouts, permanent removal, costs 0/5/10/20 bps, and complete turnover outputs. | `07_CloudComputing/Validation/AE-INDEX-SUITE/AE-INDEX-SUITE-009_Closeout_Report.md`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/full_grid_manifest.csv` |
| Appendix A15: 20 bps Winners With Benchmarks | Compact combined winners table; VAE/non-raw variants beat raw in 5 of 8 track-index cases at 20 bps. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/presentation_headline_tables.md`; `07_CloudComputing/Validation/AE-INDEX-SUITE/AE-INDEX-SUITE-009_Closeout_Report.md` |
| Appendix A16: Transaction-Cost Robustness | Full 0 bps versus 20 bps comparison for all track-index winners. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/transaction_cost_robustness_summary.csv` |
| Appendix A17: Threshold Family and Turnover Summary | Mean alpha by threshold family and mean annualized gross turnover for 20 bps winners. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/threshold_family_summary_20bps.csv`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv` |
| Appendix A18: Index Result Source Paths | Local source paths for final index result claims; sensitivity results are excluded from this ticket. | `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/**`; `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/**` |

## Benchmark Note

Benchmark rows refer to the unfiltered market-cap-weighted index for the corresponding universe. The benchmark has no strategy transaction-cost overlay; strategy results are reported net of the stated transaction-cost assumption where applicable.
