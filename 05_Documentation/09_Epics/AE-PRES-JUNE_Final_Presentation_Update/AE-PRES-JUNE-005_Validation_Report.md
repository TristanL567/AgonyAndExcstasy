# AE-PRES-JUNE-005 Validation Report

Result: worker_static_checks_passed

## Worker Checks

| Check | Status | Detail |
|---|---|---|
| branch_is_development | passed | `git status --short --branch` reports `## Development`. |
| scoped_files_only | passed | Worktree changes are limited to the June `.Rnw` plus ignored AE-PRES-JUNE-005 evidence files; known unrelated dirty files remain outside scope. |
| no_old_finalpresentation_touched | passed | The pre-existing deleted old `FinalPresentation/**` file remains unstaged and was not modified by this ticket. |
| no_data_outputs_modified | passed | No `03_Data_Output/**` files were modified. |
| no_model_index_pipeline_sensitivity_scripts_run | passed | Only static file inspection/editing commands were used; no model, index, evaluation, pipeline, or sensitivity scripts were invoked. |
| sensitivity_status_matches_sources | passed | The Rnw states all 27 run IDs represented, 24 complete/reused, and 3 `blocked_partial`, matching local manifest sources. |
| blocked_partial_ids_named | passed | `C080_M000_T012`, `C080_M000_T018`, and `C060_M020_T028` are named in the Rnw and evidence. |
| sensitivity_conclusions_match_sources | passed | Objective winners match local comparison files: `C090_M000_T012`, `C060_M000_T012`, `C090_M020_T018`, and baseline `C080_M020_T018`. |
| permanent_sensitivity_not_completed | passed | Permanent-CSI sensitivity is marked future/not completed. |
| benchmark_extensions_future | passed | Minimum-volatility, quality/risk-scaling, active weighting, and residual diagnostic are marked future/not completed. |
| source_map_exists | passed | `AE-PRES-JUNE-005_Sensitivity_Source_Map.md` created. |
| frame_balance | passed | Static count found 44 `\begin{frame}` and 44 `\end{frame}` occurrences. |
| git_diff_check | passed | `git diff --check` returned no whitespace errors. |

## Notes

Full compile and visual QA are intentionally deferred to AE-PRES-JUNE-007.
