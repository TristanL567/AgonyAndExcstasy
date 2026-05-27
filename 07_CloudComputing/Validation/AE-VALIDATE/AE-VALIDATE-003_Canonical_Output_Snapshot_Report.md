# AE-VALIDATE-003 Canonical Output Snapshot Report

Generated: 2026-05-27T22:58:57 local time

## Branch and HEAD
- Branch: `validation`
- HEAD: `50318c8` (`50318c8f08dcbcc354c7828525f550366305916a`)
- Required ancestor `50318c8`: `True`

## Canonical Paths Inspected
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw`
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation`
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw`
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/evaluation`
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised`
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised`
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/mid_cap` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/small_cap` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/total_market` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/temporary_csi/large_cap` (observed 11C-relevant comparison output location)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11d_index_optimal03b_ag_raw_20260517_203745` (observed 11C-relevant comparison output location)
- `01_Code/pipeline/09C_AutoGluon.py` (read-only filename expectation check)
- `01_Code/pipeline/10_Evaluation.R` (read-only filename expectation check)
- `01_Code/pipeline/11C_IndexConstruction_Revised.R` (read-only filename expectation check)

## Inventory Artifacts
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_raw_model_file_inventory.csv` (25 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_raw_model_row_counts.csv` (23 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_raw_model_metric_snapshot.csv` (168 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_11c_file_inventory.csv` (65 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_11c_row_counts.csv` (61 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_11c_metric_snapshot.csv` (16490 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/canonical_missing_expected_files.csv` (30 data rows)
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-003_Canonical_Output_Snapshot_Report.md`

## Raw Model File Presence Summary
- `temporary_csi` ag_raw files: 9
- `temporary_csi` ag_raw expected missing: 1
- `permanent_csi` ag_raw files: 8
- `permanent_csi` ag_raw expected missing: 1

## Evaluation File Presence Summary
- `temporary_csi` evaluation files: 4
- `temporary_csi` evaluation expected missing: 0
- `permanent_csi` evaluation files: 4
- `permanent_csi` evaluation expected missing: 0

## 11C File Presence Summary
- `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` observed 11C-relevant files: 12
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954` observed 11C-relevant files: 2
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap` observed 11C-relevant files: 8
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/mid_cap` observed 11C-relevant files: 8
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/small_cap` observed 11C-relevant files: 8
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/total_market` observed 11C-relevant files: 8
- `shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/temporary_csi/large_cap` observed 11C-relevant files: 7
- `temporary_csi/11d_index_optimal03b_ag_raw_20260517_203745` observed 11C-relevant files: 12
- `temporary_csi` exact `11c_index_revised` expected missing entries: 14
- `permanent_csi` exact `11c_index_revised` expected missing entries: 14

## Key Row-Count Summary
- Raw/evaluation readable tables counted: 23 ok, 0 errors
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_cv_results.parquet`: 273910 rows, 5 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_leaderboard.csv`: 12 rows, 13 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_preds_oos.parquet`: 74847 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_preds_oos_eval.parquet`: 74847 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_preds_test.parquet`: 78260 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_preds_test_eval.parquet`: 78260 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_preds_train_boundary.parquet`: 19565 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/raw_model_comparison_vs_03_Output.csv`: 15 rows, 5 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_by_year_all.rds`: 27 rows, 11 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_performance_all.rds`: 6 rows, 21 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_threshold_all.rds`: 4 rows, 10 columns
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/evaluation/evaluation_results.rds`: 16 rows, 7 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_cv_results.parquet`: 273910 rows, 5 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_leaderboard.csv`: 12 rows, 13 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_preds_oos.parquet`: 77459 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_preds_oos_eval.parquet`: 77459 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_preds_test.parquet`: 78202 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_preds_test_eval.parquet`: 78202 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_preds_train_boundary.parquet`: 19565 rows, 4 columns
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/evaluation/eval_by_year_all.rds`: 24 rows, 11 columns
- Additional raw/evaluation row-count records: 3
- 11C readable tables counted: 61 ok, 0 errors
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/error_cost_decomposition_by_crsp_universe.csv`: 192 rows, 27 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/error_cost_decomposition_by_crsp_universe.rds`: 192 rows, 27 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_exclusion_summary_by_crsp_universe.csv`: 1056 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_exclusion_summary_by_crsp_universe.rds`: 1056 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_performance_by_crsp_universe.csv`: 64 rows, 26 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_performance_by_crsp_universe.rds`: 64 rows, 26 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_returns_by_crsp_universe.csv`: 4224 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_returns_by_crsp_universe.rds`: 4224 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_thresholds_by_crsp_universe.csv`: 3 rows, 12 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_thresholds_by_crsp_universe.rds`: 3 rows, 12 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/index_weights_by_crsp_universe.rds`: 1926660 rows, 24 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745/run_status.csv`: 1 rows, 14 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/eight_bundle_manifest.csv`: 8 rows, 19 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/file_manifest.tsv`: 65 rows, 3 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/error_cost_decomposition.csv`: 48 rows, 27 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/index_exclusion_summary.csv`: 264 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/index_performance.csv`: 16 rows, 26 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/index_returns.csv`: 1056 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/index_thresholds_raw_model.csv`: 3 rows, 12 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/oos_best_strategy_error_cost_summary.csv`: 4 rows, 27 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/large_cap/oos_performance_summary.csv`: 2 rows, 28 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/mid_cap/error_cost_decomposition.csv`: 48 rows, 27 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/mid_cap/index_exclusion_summary.csv`: 264 rows, 22 columns
- `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/11c_index_revised_by_track_index/eight_bundles_20260516_152954/permanent_csi/mid_cap/index_performance.csv`: 16 rows, 26 columns
- Additional 11C row-count records: 37

## Key Metric Snapshot Summary
- Raw model metric snapshot rows: 168
- 11C metric snapshot rows: 16490
- Raw `temporary_csi` `raw` cv cv_ap: 0.2197
- Raw `temporary_csi` `raw` cv cv_auc: 0.9647
- Raw `temporary_csi` `raw` cv cv_r3: 0.6127
- Raw `temporary_csi` `raw` cv cv_n_folds: 3
- Raw `temporary_csi` `raw` test avg_precision: 0.2114
- Raw `temporary_csi` `raw` test auc_roc: 0.9692
- Raw `temporary_csi` `raw` test brier: 0.0089
- Raw `temporary_csi` `raw` test recall_fpr1: 0.3066
- Raw `temporary_csi` `raw` test recall_fpr3: 0.6551
- Raw `temporary_csi` `raw` test recall_fpr5: 0.8183
- Raw `temporary_csi` `raw` test recall_fpr10: 0.9765
- Raw `temporary_csi` `raw` oos avg_precision: 0.2911
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition n_months: 264
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition n_firm_months: 104
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition portfolio_weight_affected: 0.0004606266237
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition filtered_portfolio_weight: 0.0004629629276
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition annualized_geometric_return_contribution: -2.302954073e-06
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition category_benchmark_annualized_contribution: -0.0005621581836
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition category_filtered_annualized_contribution: -0.0005644662486
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition benchmark_annualized_geometric_return: 0.1102200976
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition filtered_annualized_geometric_return: 0.1107947896
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition difference_versus_benchmark: 0.0005746920717
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition n_months: 264
- 11C `permanent_csi/11d_index_optimal03b_ag_raw_20260517_203745` error_cost_decomposition n_firm_months: 2004

## Read-Only Confirmation
- Canonical raw model, evaluation, and 11C files under `03_Data_Output/**` were inspected read-only.
- No canonical output files were edited or generated.
- No files were written outside `07_CloudComputing/Validation/AE-VALIDATE/**`.
- No model training, evaluation, index construction, sensitivity, or pipeline scripts were run.

## Missing Expected Canonical Files
- Missing expected paths recorded in `07_CloudComputing/Validation/AE-VALIDATE/canonical_missing_expected_files.csv`: 30
- `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_feature_importance.csv` (missing_file)
- `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_feature_importance.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised` (missing_directory)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_thresholds_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_thresholds_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_weights_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_weights_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_returns_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_returns_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_performance_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_performance_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_exclusion_summary_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/index_exclusion_summary_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/error_cost_decomposition_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/error_cost_decomposition_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi/11c_index_revised/run_status.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised` (missing_directory)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_thresholds_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_thresholds_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_weights_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_weights_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_returns_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_returns_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_performance_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_performance_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_exclusion_summary_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/index_exclusion_summary_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/error_cost_decomposition_by_crsp_universe.rds` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/error_cost_decomposition_by_crsp_universe.csv` (missing_file)
- `03_Data_Output/4_IndexConstruction_Results/Necessary/permanent_csi/11c_index_revised/run_status.csv` (missing_file)

## Blockers
- None for this local snapshot ticket.

## Readiness Decision for AE-VALIDATE-004
- Ready for AE-VALIDATE-004 from the snapshot perspective. Missing exact canonical `11c_index_revised` paths and other absent expected files are documented rather than generated.
