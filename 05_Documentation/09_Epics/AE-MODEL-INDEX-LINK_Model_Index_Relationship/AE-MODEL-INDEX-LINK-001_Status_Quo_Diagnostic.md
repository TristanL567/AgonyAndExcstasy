# AE-MODEL-INDEX-LINK-001 Status Quo Diagnostic

## Scope

This ticket inventories existing evidence for linking model-performance metrics to index-construction outcomes. It is a status-quo diagnostic only. No model metrics, index results, sensitivity outputs, presentation files, code, or data inputs were modified or regenerated.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `179147d`
- Ticket: `AE-MODEL-INDEX-LINK-001`

## AEGIS Context Inspected

Read-only AEGIS references inspected:

- `C:/Users/Tristan Leiter/Documents/aegis-core/execution/runbooks/multi-master-dispatch.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/execution/runbooks/shared-orchestration-loop.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/epic-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/swarm-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/ticket-contract.md`

The epic envelope and ticket envelope were also read:

- `epics/AE-MODEL-INDEX-LINK/envelope.yaml`
- `epics/AE-MODEL-INDEX-LINK/tickets/AE-MODEL-INDEX-LINK-001.yaml`

## Source Locations Inspected

Read-only inspection covered:

- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/`
- `03_Data_Output/5_SensitivityAnalysis/04_index_construction/`
- `03_Data_Output/6_ModelSuite/`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

The detailed inventory is recorded in `AE-MODEL-INDEX-LINK-001_available_sources.csv`.

## Model-Performance Evidence Inventory

The strongest model-performance sources are:

1. `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_model_summary.csv`
   - 81 rows.
   - CMT sensitivity runs keyed by `run_id`, `C`, `M`, `T`, `run_status`, and `split`.
   - Metrics include `auc`, `ap`, `recall_fpr_1pct`, `recall_fpr_3pct`, `recall_fpr_5pct`, and `brier`.

2. `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/sensitivity_index_stability_table.csv`
   - 24 rows.
   - Completed/reused temporary-CSI sensitivity runs.
   - Links `oos_ap`, `oos_auc`, and `oos_r_fpr3` to total-market alpha in one table.

3. `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_suite_metrics_long.csv`
   - 16 rows.
   - Model family comparison for `raw`, `fund`, `latent_raw`, and `raw_plus_latent` across temporary and permanent CSI.

4. `03_Data_Output/6_ModelSuite/derived_metrics/complete_threshold_metrics_long.csv`
   - 24 rows.
   - Detailed AP/AUC/Brier and recall at FPR 1/3/5 by feature set, track, and split.

## Index-Performance Evidence Inventory

The strongest index-performance sources are:

1. `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_index_summary.csv`
   - 27 rows.
   - One CMT row per sensitivity run, including blocked partial status where relevant.
   - Contains best-any and total-market benchmark-relative alpha fields.

2. `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/universe_stability_summary.csv`
   - 4 rows.
   - Distribution of benchmark-relative alpha across the 24 completed/reused sensitivity runs by universe.

3. `03_Data_Output/5_SensitivityAnalysis/presentation_ready/temporary_index_threshold_lockout_cost_summary.csv`
   - 1,024 rows.
   - Full temporary-CSI threshold/lockout/transaction-cost summary from existing outputs.
   - Useful for presentation robustness, but not a native CMT run-level AP-to-alpha linkage table.

4. `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
   - 32 rows.
   - Best model-family index results by track, universe, and transaction cost.

5. `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/model_family_comparison.csv`
   - 128 rows.
   - Full model-family grid for raw, fund, latent_raw, and raw_plus_latent across tracks, universes, and costs.

## Linkage Key Inventory

The cleanest available linkage is for temporary-CSI CMT sensitivity:

- model source: `sensitivity_cmt_model_summary.csv`
- index source: `sensitivity_cmt_index_summary.csv`
- diagnostic source: `sensitivity_index_stability_table.csv`
- keys: `run_id`, `C`, `M`, `T`

This linkage directly supports the question: does OOS AP/AUC/R@FPR3 across CMT sensitivity runs map to total-market index alpha?

The second useful linkage is model-suite family analysis:

- model sources: `AE-MODEL-SUITE-007_model_suite_metrics_long.csv`, `complete_threshold_metrics_long.csv`
- index sources: `best_by_track_index_cost.csv`, `model_family_comparison.csv`
- keys: `track`, `feature_set`/`model_key`, and, where relevant, `split`

This linkage is clean by model family and track, but it answers a different question: how raw, fund, latent_raw, and raw_plus_latent model families relate to index outcomes.

The full temporary-CSI threshold/lockout/cost grid is useful for robustness presentation, but it is not the same as a per-CMT AP-to-alpha linkage. It links strategy rule choices, not model metric changes by CMT run.

## Clean-Linkage Assessment

| Linkage | Cleanliness | Best Use |
|---|---|---|
| CMT `run_id` to total-market alpha | Clean | Ticket 002 correlation analysis |
| CMT `run_id` to universe alpha distribution | Mostly clean | Explaining whether the main run is an outlier |
| Model family and track | Clean by family | Explaining raw/fund/latent/raw_plus_latent differences |
| Threshold/lockout/cost grid | Partial for AP-alpha linkage | Strategy robustness, not model metric linkage |
| Permanent-CSI CMT sensitivity | Not available | Future work |

## Brief Result Summary

AP does not map cleanly to index alpha in the current evidence. The clearest status-quo evidence is the AE-SENS-CHART linked table: the AP winner is `C060_M000_T012`, while the strongest total-market index-alpha configuration is `C090_M020_T018`. The strongest composite sensitivity configuration is `C090_M000_T012`, and the main run `C080_M020_T018` is a defensible continuity baseline but not the top-ranked CMT setting.

The strongest initial linkage is the temporary-CSI CMT run-level link by `run_id`, because it connects OOS AP, OOS AUC, and OOS R@FPR3 to total-market alpha for the 24 completed/reused sensitivity runs. Model-suite linkage is also usable, but it operates at model-family level rather than CMT run level.

Model and index objectives differ because AP, AUC, and R@FPR are label-ranking metrics, while portfolio alpha is return-, timing-, threshold-, universe-, and market-cap-weighted. A model can rank future CSI events better without excluding the right firms at the right time, or without affecting enough portfolio weight to move index returns.

The main run is not an outlier. Existing AE-SENS-CHART evidence records that it sits inside the 24-run distribution: below median for Total Market and Large Cap, and above median for Mid Cap and Small Cap.

## Gaps And Limitations For Ticket 002

- Ticket 002 should use `sensitivity_index_stability_table.csv` as the first linked source for AP/AUC/R@FPR3 versus total-market alpha.
- If a universe-level AP-to-alpha table is required, it may need an aggregation from existing source files; this ticket did not compute new metrics.
- The full threshold/lockout/transaction-cost grid should be treated as strategy robustness, not as native CMT model metric linkage.
- Permanent-CSI CMT sensitivity is not available and remains future work.

## Scope Hygiene

No files under these must-not-touch areas were modified:

- `03_Data_Output/**`
- `06_Presentations/**`
- `01_Code/**`
- `02_Data_Input/**`
- `07_CloudComputing/**`

No model training, model evaluation, index construction, sensitivity scripts, Vast.ai access, or SSH commands were used.
