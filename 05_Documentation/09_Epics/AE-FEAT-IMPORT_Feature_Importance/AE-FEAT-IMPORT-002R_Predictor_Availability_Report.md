# AE-FEAT-IMPORT-002R Predictor Availability Report

## Status

status: complete

role: AEGIS worker only; no self-approval performed.

## Scope

This audit checked fitted AutoGluon predictor availability for:

- `raw`
- `fund`
- `latent_raw`
- `raw_plus_latent`

across:

- `temporary_csi`
- `permanent_csi`

No model training, evaluation, predictor download, feature-importance computation, pipeline regeneration, or protected output mutation was performed.

## Local Availability

Local fitted predictors are absent for all eight required combinations.

The local model-suite tree contains compact artifacts such as prediction parquet files, leaderboards, CV results, evaluation summaries, and compact evidence reports. It does not contain loadable `ag_predictor` directories or AutoGluon model binaries for the eight required combinations.

The local model-suite README states that the local results folder intentionally excludes AutoGluon predictor directories, fold model directories, caches, and model binaries. The local validation summary also reports `heavy_autogluon_artifacts_found,0,PASS`.

## Remote Evidence

Live SSH listing was not performed. The ticket context included a connection note, but it was a port-forward/tunnel template rather than a safe non-interactive read-only listing command for this worker context. Because this worker could not safely convert that note into a bounded read-only listing without risking endpoint, port, key-path, or command-string leakage in ticket artifacts, remote availability is inferred only from existing local evidence. Reports use `[authorized endpoint]` and do not include endpoint details, key paths, credentials, tokens, ports, or raw SSH command strings.

Existing local evidence that was previously downloaded from the authorized validation roots was inspected read-only:

- `03_Data_Output/6_ModelSuite/raw/inventory.csv`
- `03_Data_Output/6_ModelSuite/raw/summary.json`
- `03_Data_Output/6_ModelSuite/manifest/download_manifest.csv`
- nonraw storage-retention CSVs under `03_Data_Output/6_ModelSuite/*/compact_evidence/`

## Classification

| feature_set | temporary_csi | permanent_csi | decision |
|---|---|---|---|
| raw | available remotely, not local | available remotely, not local | recoverable without retraining if a later restore ticket verifies and downloads from `[authorized endpoint]` |
| fund | pruned/unavailable | pruned/unavailable | requires retraining/rebuild |
| latent_raw | pruned/unavailable | pruned/unavailable | requires retraining/rebuild |
| raw_plus_latent | pruned/unavailable | pruned/unavailable | requires retraining/rebuild |

Raw remote evidence lists `ag_raw/ag_predictor` contents, including `predictor.pkl`, `learner.pkl`, `metadata.json`, `version.txt`, and model files for both tracks. Those files are not local, but the evidence supports a later safe restore attempt without retraining.

The nonraw storage-retention evidence records the fitted `ag_predictor` directories as deleted after compact extraction:

- `fund`: `ag_fund/ag_predictor` deleted for both tracks.
- `latent_raw`: `ag_latent_raw/ag_predictor` deleted for both tracks.
- `raw_plus_latent`: `ag_raw_plus_latent/ag_predictor` deleted for both tracks.

## Safe Raw Restore Plan

If a later ticket authorizes restore, use read-only remote listing first against `[authorized endpoint]` and verify each raw predictor directory before transfer. The local staging target should be ignored and isolated:

- `03_Data_Output/10_FeatureImportance/predictors/raw/temporary_csi/ag_predictor/`
- `03_Data_Output/10_FeatureImportance/predictors/raw/permanent_csi/ag_predictor/`

Minimum restore controls:

- dry-run listing before transfer;
- verify `predictor.pkl`, `learner.pkl`, `metadata.json`, `version.txt`, and `models/`;
- copy only the needed `ag_predictor` directory, not full validation outputs or CV fold caches;
- write a file-count, byte-count, and checksum manifest next to the staged predictor;
- load-test with `TabularPredictor.load()` before perturbation;
- do not stage, commit, or overwrite canonical model-suite outputs.

## Minimum Retraining/Rebuild Plan

For `fund`, `latent_raw`, and `raw_plus_latent`, true perturbation requires fresh fitted predictors unless a separate backup outside the audited roots is supplied.

Minimum future rebuild requirements:

- rebuild all six nonraw combinations: three feature sets times two tracks;
- use the original point-in-time feature inputs and labels for each feature set and track;
- preserve track settings: `dynamic_csi` maps to `temporary_csi`, and `permanent_csi` remains `permanent_csi`;
- use a frozen code revision, documented AutoGluon settings, seed policy, and environment manifest;
- write to an isolated future output root, not canonical `03_Data_Output/6_ModelSuite`;
- stage only the final loadable predictor directories under `03_Data_Output/10_FeatureImportance/predictors/`;
- retain compact metrics, manifest, checksums, and load-test evidence;
- do not overwrite canonical outputs.

## AE-FEAT-IMPORT-003R Readiness

AE-FEAT-IMPORT-003R cannot compute true perturbation directly for the full eight-combination scope from the current local workspace.

It may compute true perturbation for raw only after a separate restore ticket safely downloads and validates the two raw predictors. It cannot compute true perturbation for fund, latent_raw, or raw_plus_latent until retraining/rebuild or an out-of-scope backup restore supplies loadable predictors.
