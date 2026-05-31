# AE-PRES-FINAL-REV2-007 Model Hyperparameters Evidence

## Scope

This evidence note supports the new `Appendix A8: Best-Model Hyperparameters and Choices` slide in:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

Inspection was read-only for local model-suite output paths. No model training, evaluation, index construction, sensitivity run, output regeneration, or `03_Data_Output/**` write was performed.

## Read-Only Evidence Inspected

- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_family_winners.csv`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_suite_best_by_track.csv`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_Model_Suite_Comparison_Report.md`
- `03_Data_Output/6_ModelSuite/raw/model_family_log_excerpt.txt`
- `03_Data_Output/6_ModelSuite/raw/temporary_csi/leaderboard_compact.csv`
- `03_Data_Output/6_ModelSuite/raw/permanent_csi/leaderboard_compact.csv`
- `03_Data_Output/6_ModelSuite/fund/compact_evidence/AE-MODEL-SUITE-004_fund_model_family_hyperparameters.json`
- `03_Data_Output/6_ModelSuite/fund/compact_evidence/AE-MODEL-SUITE-004_fund_weighted_ensemble_weights.json`
- `03_Data_Output/6_ModelSuite/latent_raw/compact_evidence/AE-MODEL-SUITE-005_latent_raw_hyperparameters.json`
- `03_Data_Output/6_ModelSuite/latent_raw/compact_evidence/AE-MODEL-SUITE-005_latent_raw_ensemble_weights.json`
- `03_Data_Output/6_ModelSuite/raw_plus_latent/compact_evidence/AE-MODEL-SUITE-006_raw_plus_latent_hyperparameters.json`
- `03_Data_Output/6_ModelSuite/raw_plus_latent/compact_evidence/AE-MODEL-SUITE-006_raw_plus_latent_ensemble_weights.json`

## Supported Slide Claims

| Slide claim | Support found |
|---|---|
| All final model-suite track-feature-set cells rank `WeightedEnsemble_L2` first. | `AE-MODEL-SUITE-007_model_family_winners.csv` has eight rows, all with `best_leaderboard_model = WeightedEnsemble_L2`, `best_model_family = WeightedEnsemble`, and `score_rank = 1.0`. |
| AutoGluon model selection emphasizes average precision. | `AE-MODEL-SUITE-007_Model_Suite_Comparison_Report.md` and retained hyperparameter JSON model info identify `eval_metric` and `stopping_metric` as `average_precision`; the existing Appendix A6 source also names `EVAL_METRIC = "average_precision"`. |
| Temporary CSI best feature choice is cautiously `raw_plus_latent`, with raw retained as comparator. | `AE-MODEL-SUITE-007_model_suite_best_by_track.csv` recommends `raw_plus_latent` for later temporary index construction, while noting raw retains best test AP/AUC and similar OOS AUC. |
| Permanent CSI has no clean non-raw dominance. | `AE-MODEL-SUITE-007_model_suite_best_by_track.csv` names `raw_plus_latent` as the primary non-raw challenger, `latent_raw` as OOS-robustness sensitivity, and raw as the conservative baseline. |
| `WeightedEnsemble_L2` is a level-2 greedy ensemble with retained ensemble-size and base-model composition metadata where full fitted metadata exists. | Fund and latent compact hyperparameter JSONs show `stack_level = 2` in leaderboards, `WeightedEnsembleModel`, `use_orig_features = false`, `save_bag_folds = true`, `model_random_seed = 0`, child `ensemble_size = 25`, and fitted child ensemble sizes such as 9, 20, 21, or 24 depending on run. |
| Base learner families include LightGBM variants, CatBoost, XGBoost, ExtraTrees/RandomForest, and neural nets. | Leaderboards and `raw/model_family_log_excerpt.txt` list `LightGBMXT`, `LightGBM`, `LightGBMLarge`, `CatBoost`, `XGBoost`, `ExtraTrees*`, `RandomForest*`, `NeuralNetFastAI`, and `NeuralNetTorch`. |
| The configured `LightGBMLarge` variant uses learning rate 0.03, 128 leaves, feature fraction 0.9, and minimum leaf size 3 where fitted hyperparameters are retained. | Fund and latent hyperparameter JSONs and `raw/model_family_log_excerpt.txt` show the `LightGBMLarge` configuration with `learning_rate = 0.03`, `num_leaves = 128`, `feature_fraction = 0.9`, and `min_data_in_leaf = 3`. |
| Full fitted-model hyperparameters are not available for every compact evidence artifact. | `AE-MODEL-SUITE-006_raw_plus_latent_hyperparameters.json` explicitly says full fitted-model hyperparameters are unavailable after storage-pruning policy and only compact leaderboard metadata is retained; raw compact evidence is limited to logs and compact leaderboards. |

## Interpretation Constraint

The slide intentionally avoids claiming a universal "optimal" base learner or complete tuned hyperparameter set. The evidence supports a cautious model-choice story: AutoGluon weighted ensembles dominate the retained validation leaderboards; nonlinear tree/boosted-tree families are consistently strong; neural nets and XGBoost appear as candidate or ensemble components; VAE features add some signal but do not cleanly replace expanded raw features across tracks and splits.
