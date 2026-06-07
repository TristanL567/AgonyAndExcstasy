# AE-MODEL-SUITE-003 Remote Model-Suite Readiness Report

## Status

Decision: `PROCEED`

The remote Vast.ai environment is ready for the next non-raw model training ticket. Current code is synced, the 10 required model-suite input files are present remotely with matching local SHA256 hashes, required Python/R packages import successfully, and the isolated AE-MODEL-SUITE output root is writable.

The known `raw_plus_latent` compatibility risk in `10_Evaluation.R` remains. It does not block raw AutoGluon training, but later evaluation/reporting should rely first on 09C compact metrics or use a scoped evaluator-compatibility ticket.

## Branch And Base

- Branch: `validation-model-suite`
- Starting HEAD: `bb7c4b8 AE-MODEL-SUITE-002: regenerate VAE-derived features`
- Required base satisfied: yes
- Known unrelated untracked files preserved:
  - `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005R_Model_Evaluation_Rerun_Report.md`
  - `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`

## AEGIS Reference Check

Read-only AEGIS references were loaded and applied:

- `AEGIS.md`
- `contracts/swarm-contract.md`
- `contracts/ticket-contract.md`
- `skills/roles/master/SKILL.md`
- `execution/runbooks/shared-orchestration-loop.md`
- `execution/runbooks/apply-to-project.md`

No AEGIS files were edited.

## Remote Access

Sanitized endpoint: `[authorized endpoint]`

Sanitized authentication: `[authorized SSH key path]`

SSH smoke test returned:

- `CONNECTION_OK`
- remote root: `/root/AgonyAndExcstasy`
- remote user: `root`

No `-L` tunnel and no bare `ssh` were used.

## Code Sync

Synced scope:

- `01_Code/**`
- `.gitignore`

Remote key-file hashes match the local branch for:

- `01_Code/pipeline/config.R`
- `01_Code/pipeline/09C_AutoGluon.py`
- `01_Code/pipeline/10_Evaluation.R`
- `01_Code/pipeline/08B_Autoencoder.py`
- `.gitignore`

Full hash evidence is recorded in `AE-MODEL-SUITE-003_code_sync_report.txt`.

## Manifest And Upload

Manifest file:

- `AE-MODEL-SUITE-003_model_suite_manifest.tsv`

Required manifest rows: 10

Rows by track:

- temporary_csi: 5
- permanent_csi: 5

Required artifacts per track:

- `Features/features_fund.rds`
- `Features/features_latent_raw.parquet`
- `Features/features_raw_plus_latent.parquet`
- `Features/split_labels_oot.parquet`
- `Labels/labels_model_ready.rds`

Remote pre-check showed that 8 rows were already present and hash-matched, including all regenerated VAE-derived files. The two missing `features_fund.rds` files were uploaded. Final verification shows all 10 remote files match local size and SHA256.

## Remote Verification Summary

| Track | Rows | Size matches | Hash matches | Status |
|---|---:|---:|---:|---|
| temporary_csi | 5 | 5 | 5 | pass |
| permanent_csi | 5 | 5 | 5 | pass |

Full row-level verification is recorded in `AE-MODEL-SUITE-003_remote_verification.csv`.

## Package Checks

Python package imports passed:

- `autogluon.tabular`
- `pandas`
- `pyarrow`
- `pyreadr`
- `sklearn`
- `lightgbm`
- `catboost`
- `xgboost`
- `fastai`

R package checks passed:

- `data.table`
- `arrow`
- `jsonlite`
- `pROC`
- `PRROC`
- `ggplot2`
- `dplyr`
- `tidyr`

Full package evidence is recorded in `AE-MODEL-SUITE-003_package_checks.csv`.

## Model-Key And Output Support

Remote `09C_AutoGluon.py` supports:

- `MODEL=fund`
- `MODEL=latent_raw`
- `MODEL=raw_plus_latent`
- `MT_ROOT`
- absolute `MT_OUTPUT_DIR`
- `RESPONSE_TRACK`

Remote `10_Evaluation.R` still lacks `raw_plus_latent` in its model registry and CSI track key list. Recommendation:

- AE-MODEL-SUITE-004 and AE-MODEL-SUITE-005 can run `fund` and `latent_raw` normally.
- AE-MODEL-SUITE-006 can train `raw_plus_latent` through 09C, but evaluation/reporting should initially rely on 09C compact metrics.
- Add a scoped 10_Evaluation compatibility ticket before final full-suite reporting if the full evaluator is required for `raw_plus_latent`.

## Output Root

Planned isolated output root:

```text
/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/nonraw_rerun_20260529_ready
```

Writable check: pass.

## Safety Confirmation

- `09C_AutoGluon.py` did not run.
- `10_Evaluation.R` did not run.
- `11C_IndexConstruction_Revised.R` did not run.
- No model training ran.
- No index construction ran.
- No sensitivity scripts ran.
- No pipeline regeneration ran.
- No canonical local `03_Data_Output/**` files were modified.
- No generated `02_Data_Input/**` files were staged or committed.
- No SSH host, port, key path, tokens, credentials, or private key contents are recorded in this report.

## Readiness For Next Ticket

Ready for AE-MODEL-SUITE-004: run `MODEL=fund` for both tracks under the isolated AE-MODEL-SUITE output root, retaining compact model outputs and predictions only.
