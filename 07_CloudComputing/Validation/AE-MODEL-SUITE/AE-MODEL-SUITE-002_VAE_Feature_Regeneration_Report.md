# AE-MODEL-SUITE-002 VAE Feature Regeneration Report

## Status

Decision: `PASS`

AE-MODEL-SUITE-001's VAE-feature blocker is resolved on disk for both response tracks. The regenerated VAE-derived feature artifacts now match the revised 188,460-row key universe.

## Branch And Base

- Branch: `validation-model-suite`
- Starting HEAD: `19737b6 AE-MODEL-SUITE-001: open non-raw model rerun epic`
- Required base satisfied: yes, HEAD is `19737b6`
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

## Regeneration Method

Regeneration ran on Vast.ai because local Python was not available on PATH and the VAE script depends on Python/Torch.

Sanitized endpoint: `[authorized endpoint]`

Sanitized authentication: `[authorized SSH key path]`

Code sync was limited to:

- `01_Code/pipeline/08B_Autoencoder.py`
- `01_Code/pipeline/config.R`

Remote environment:

```text
MT_ROOT=/root/AgonyAndExcstasy
MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/vae_feature_regen_20260529_001
VAE_INPUT=raw
```

Runs:

| Track | `RESPONSE_TRACK` | Exit code | Status |
|---|---|---:|---|
| temporary_csi | `dynamic_csi` | 0 | complete |
| permanent_csi | `permanent_csi` | 0 | complete |

The VAE script wrote temporary diagnostic model/figure files only under the isolated AE-MODEL-SUITE validation output root. Canonical `03_Data_Output/**` paths were not used.

## Regenerated Artifacts

Downloaded from the remote into the allowed local feature paths:

| Track | Artifact | Rows | Status |
|---|---|---:|---|
| temporary_csi | `features_latent_raw.parquet` | 188,460 | regenerated |
| temporary_csi | `features_raw_plus_latent.parquet` | 188,460 | regenerated |
| permanent_csi | `features_latent_raw.parquet` | 188,460 | regenerated |
| permanent_csi | `features_raw_plus_latent.parquet` | 188,460 | regenerated |

The first bulk `scp` command timed out while the larger temporary raw-plus-latent file was still transferring. The transfer continued in the background and completed to the expected size. The two permanent files were then downloaded separately with a longer timeout. Final local hashes match the remote hashes for all four files.

## Key Alignment Validation

All four regenerated artifacts pass:

- row count equals 188,460
- unique `(permno, year)` keys equal 188,460
- duplicate key count is zero
- missing keys versus revised raw feature table: zero
- extra keys versus revised raw feature table: zero
- missing keys versus revised labels: zero
- extra keys versus revised labels: zero
- missing keys versus revised split labels: zero
- extra keys versus revised split labels: zero
- `y` mismatch count versus labels: zero
- split counts remain train 143,173; test 18,111; oos 27,176

## Hash Summary

| Track | Artifact | Before size | After size | Remote/local hash match |
|---|---|---:|---:|---|
| temporary_csi | `features_latent_raw.parquet` | 53,511,258 | 29,771,710 | yes |
| temporary_csi | `features_raw_plus_latent.parquet` | 436,643,525 | 577,224,713 | yes |
| permanent_csi | `features_latent_raw.parquet` | 53,493,852 | 29,765,283 | yes |
| permanent_csi | `features_raw_plus_latent.parquet` | 530,170,004 | 577,329,883 | yes |

Full before/after hashes are recorded in `AE-MODEL-SUITE-002_file_hashes_before_after.csv`.

## Git Visibility

The regenerated feature files are under ignored `02_Data_Input/**` paths. They exist on disk and are validated, but they are not tracked and were not force-added.

Only AE-MODEL-SUITE-002 compact report/evidence should be committed unless a future repository policy ticket explicitly decides to publish generated feature artifacts.

## Safety Confirmation

- `09C_AutoGluon.py` did not run.
- `10_Evaluation.R` did not run.
- `11C_IndexConstruction_Revised.R` did not run.
- No AutoGluon model training ran.
- No model evaluation ran.
- No index construction ran.
- No sensitivity scripts ran.
- No non-VAE pipeline regeneration ran.
- No canonical `03_Data_Output/**` files were modified locally.
- The only local generated data changes were the four ticket-allowed VAE-derived feature artifacts under ignored `02_Data_Input/**`.
- No SSH host, port, key path, tokens, credentials, or private key contents are recorded in this report.

## Remaining Work

AE-MODEL-SUITE can proceed to output-isolation/upload/model-run preparation. The known `raw_plus_latent` evaluator compatibility gap from AE-MODEL-SUITE-001 remains unresolved and should be handled before running or validating `MODEL=raw_plus_latent`.
