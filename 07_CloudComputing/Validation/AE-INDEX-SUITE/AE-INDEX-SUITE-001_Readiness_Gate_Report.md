# AE-INDEX-SUITE-001 Readiness Gate And Transaction-Cost Design

## Scope And Branch

- Ticket: AE-INDEX-SUITE-001
- Active branch used: `Development`
- Branch-name resolution: lowercase `development` was not present; existing `Development` branch was used.
- Starting HEAD on `Development`: `789645b AE-CLOUD-006: add upload verification report`
- AEGIS reference: loaded from `C:\Users\Tristan Leiter\Documents\aegis-core` read-only.
- Local-only ticket: no remote/Vast.ai access was used.

This ticket created only scoped evidence under `07_CloudComputing/Validation/AE-INDEX-SUITE/`. No code, data, model outputs, index outputs, presentation files, or canonical `03_Data_Output/**` files were edited.

## Prediction Input Readiness

Prediction inputs for `fund`, `latent_raw`, and `raw_plus_latent` were checked for both `temporary_csi` and `permanent_csi` under `03_Data_Output/6_ModelSuite/{model}/{track}/`.

Required compact files checked per model/track:

- `ag_cv_results.parquet`
- `ag_preds_test.parquet`
- `ag_preds_oos.parquet`
- `ag_preds_train_boundary.parquet`
- `ag_eval_summary.json`
- `ag_leaderboard.csv`

Result: complete.

Expected row counts were confirmed for readable prediction parquets:

- temporary CSI: CV/train `72,223`, test `18,111`, OOS `18,502`, train boundary `4,663`
- permanent CSI: CV/train `72,223`, test `18,053`, OOS `26,400`, train boundary `4,663`

Schema checks confirmed required prediction columns `permno`, `year`, `y`, and `p_csi`. CV fold columns are not present, but the current 11C thresholding code does not use fold identifiers; it thresholds directly on CV `y` and `p_csi`.

## Required Index Inputs

Required local index inputs are complete:

- `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_summary_quarterly.csv`
- temporary CSI `labels_model_ready.rds`
- permanent CSI `labels_model_ready.rds`

## 11C Model Routing Assessment

Current `01_Code/pipeline/11C_IndexConstruction_Revised.R` does not yet support model routing for the non-raw model suite. It is hardcoded to:

- `MODEL_KEY <- "raw"`
- `tdir <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_raw")`
- CV threshold input from `DIR_TABLES_AUTOGLUON_TRACK/ag_raw/ag_cv_results.parquet`

`config.R` defines AutoGluon directories for `ag_fund`, `ag_raw`, `ag_latent_raw`, and `ag_raw_plus_latent`, but 11C does not use `MODEL` or `DIR_TABLES_MODEL` to select among them.

AE-INDEX-SUITE-002 should parameterize `MODEL`, `MODEL_KEY`, `MODEL_LABEL`, and the prediction directory, with fail-closed support for:

- `MODEL=raw`
- `MODEL=fund`
- `MODEL=latent_raw`
- `MODEL=raw_plus_latent`

## Transaction-Cost And Turnover Feasibility

The current 11C script computes:

- quarterly target portfolio weights in `weights_all`
- monthly drifted gross portfolio returns in `fn_compute_strategy_returns()` / `returns_all`

It does not currently compute turnover, transaction-cost bps variants, gross/net return pairs, or transaction-cost return drag.

The next implementation is feasible. The preferred insertion point is inside `fn_compute_strategy_returns()`, where monthly active holdings are already carried forward and `w_pre` represents drifted pre-return/pre-rescale weights for the month. Turnover should be based on changed portfolio weights, not full portfolio notional.

Recommended design for AE-INDEX-SUITE-002:

- compute target-vs-drifted turnover at rebalance points if drifted pre-trade weights are available;
- otherwise document target-to-target turnover as a fallback methodology decision;
- add cost variants `0`, `5`, `10`, and `20` bps;
- add monthly fields: `turnover_buy`, `turnover_sell`, `turnover_gross`, `turnover_one_way`, `transaction_cost_bps`, `transaction_cost_return_drag`, `gross_return`, `net_return`;
- compute `transaction_cost_return_drag = turnover_gross * transaction_cost_bps / 10000`;
- preserve existing gross return behavior for `0 bps` comparability.

## Raw Benchmark Availability

Revised raw 11C benchmark outputs exist locally under `03_Data_Output/7_IndexConstructionValidation/raw_benchmark/` for both tracks. Available raw files include thresholds, weights, returns, performance, exclusion summary, error-cost decomposition, and run status.

Raw benchmark files can support later transaction-cost/turnover overlay without rerunning raw model training, because raw index weights and returns are available locally. Index universes observed: `large_cap, mid_cap, small_cap, total_market`.

## Blockers

No missing prediction or required index inputs were found.

Implementation blockers for the next ticket:

- 11C model routing for `fund`, `latent_raw`, and `raw_plus_latent` is missing.
- Transaction-cost and turnover outputs are missing and must be added.

Validator blocker for this ticket:

- The blocking validator found unrelated untracked AE-VALIDATE files outside the AE-INDEX-SUITE scope. Per ticket rules, no commit was made. The unrelated files were not staged or modified by this ticket.

## Readiness Conclusion

NEEDS_11C_MODEL_ROUTING_FIX
