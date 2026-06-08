# AE-FEAT-IMPORT-003R Predictor Workspace Report

## Status

status: blocked

role: AEGIS worker only; no self-approval performed.

## Scope

This ticket prepared and validated fitted AutoGluon predictor workspace evidence for:

- `raw`
- `fund`
- `latent_raw`
- `raw_plus_latent`

across:

- `dynamic_csi`
- `permanent_csi`

No group feature importance, individual feature importance, sensitivity script, evaluation script, index-construction script, pipeline regeneration, presentation compile, staging, commit, or push was performed.

## Workspace

Local ignored predictor workspace used:

`03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`

This root is under the ticket-authorized local-only output area. The repository `.gitignore` ignores `03_Data_Output/**`, so predictor binaries, predictions, and caches remain local workspace artifacts and are not intended for staging.

## Raw Restore Check

Raw predictors were not restored.

Prior AE-FEAT-IMPORT-002R evidence classified raw predictors as remotely recoverable from `[authorized endpoint]`. Live raw restore was not performed because the provided connection note was a tunnel template rather than a bounded non-interactive listing/transfer command for predictor restore, and no authorized raw predictor artifact was already available locally.

Because raw predictors could not be restored and load-tested, the ticket is blocked for full eight-combination readiness.

No endpoint details, ports, key paths, tokens, credentials, private key material, or raw SSH commands are recorded in this report.

## Non-Raw Rebuilds

The six unavailable non-raw predictors were rebuilt with `09C_AutoGluon.py` only, using existing revised input files and an isolated `MT_OUTPUT_DIR` under the ignored feature-importance workspace.

The rebuilds used a bounded GBM-only AutoGluon configuration:

- `AG_FEATURE_IMPORTANCE=0`
- `AG_PRESET=medium_quality`
- `AG_CV_PRESET=medium_quality`
- `AG_TIME_LIMIT=90`
- `AG_CV_TIME_LIMIT=90`
- excluded heavy or slow model families: CatBoost, neural nets, random forests, extra trees, XGBoost, and KNN
- no bagging or stacking override beyond 09C defaults

This produced loadable predictors for:

- `fund/dynamic_csi`
- `fund/permanent_csi`
- `latent_raw/dynamic_csi`
- `latent_raw/permanent_csi`
- `raw_plus_latent/dynamic_csi`
- `raw_plus_latent/permanent_csi`

These are bounded local GBM-only rebuild predictors, not restored full-fidelity model-suite predictors and not restored originals. The validator/master should treat them as loadable workspace artifacts for continuity, while separately deciding whether their bounded model configuration is acceptable for later true perturbation analysis.

## Load Inventory Summary

| feature_set | track | location | loadable | smoke_probability | status | approx_size_mb |
|---|---|---|---|---|---|---:|
| raw | dynamic_csi | local expected missing | no | no | blocker_raw_restore_unavailable | 0.0 |
| raw | permanent_csi | local expected missing | no | no | blocker_raw_restore_unavailable | 0.0 |
| fund | dynamic_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 482.1 |
| fund | permanent_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 481.7 |
| latent_raw | dynamic_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 35.2 |
| latent_raw | permanent_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 33.5 |
| raw_plus_latent | dynamic_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 530.7 |
| raw_plus_latent | permanent_csi | local ignored workspace | yes | yes | rebuilt_bounded_09C_gbm_only | 531.0 |

Detailed row-level inventory is in:

`05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003R_predictor_load_inventory.csv`

## Findings

- Six non-raw predictors are loadable and can produce one-row smoke probabilities through AutoGluon `predict_proba`.
- Two raw predictors remain unavailable locally.
- The blocker is validated: raw restore remains blocked pending a follow-up ticket that supplies or approves a bounded restore command, or authorizes a raw rebuild path.
- Later full true perturbation is not ready for all eight combinations.
- No feature-importance computation was run.

## Next Readiness

Next-ticket readiness is partial.

The non-raw workspace can support later load/predict plumbing checks, subject to validator/master acceptance of bounded GBM-only rebuilds rather than restored full-fidelity model-suite predictors. Full eight-combination true log-odds perturbation remains blocked until raw predictors are restored and load-tested through an approved bounded restore command, or until an explicitly authorized raw rebuild path is provided.
