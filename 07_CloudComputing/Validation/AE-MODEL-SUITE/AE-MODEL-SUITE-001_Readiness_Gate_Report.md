# AE-MODEL-SUITE-001 Readiness Gate Report

## Status

Decision: `BLOCKED`

AE-MODEL-SUITE should not proceed to upload or train non-raw models until VAE-derived features are regenerated or otherwise proven fresh for the revised labelled panel.

## Branch And Base

- Active branch: `validation-model-suite`
- Branch base: `origin/main`
- HEAD: `6aaf136 AE-SENS-009: validate and download sensitivity results`
- Known unrelated untracked files preserved:
  - `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005R_Model_Evaluation_Rerun_Report.md`
  - `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`

## AEGIS Reference Check

Read-only AEGIS references were found and applied:

- `AEGIS.md`
- `contracts/swarm-contract.md`
- `contracts/ticket-contract.md`
- `skills/roles/master/SKILL.md`
- `execution/runbooks/shared-orchestration-loop.md`
- `execution/runbooks/apply-to-project.md`
- `execution/prompts/validate-ticket.md`

No AEGIS files were edited.

## Scope

Models in scope:

- `fund`
- `latent_raw`
- `raw_plus_latent`

Tracks in scope:

- `RESPONSE_TRACK=dynamic_csi` / `temporary_csi`
- `RESPONSE_TRACK=permanent_csi` / `permanent_csi`

Raw model training is out of scope for this epic and should use AE-VALIDATE raw results as comparator.

## Local Feature Readiness

The revised labels, splits, and fundamental features are ready for both tracks:

| Track | Artifact | Rows | Key status | Decision |
|---|---|---:|---|---|
| temporary_csi | labels_model_ready.rds | 188,460 | revised key panel | present_current |
| temporary_csi | split_labels_oot.parquet | 188,460 | matches labels | present_current |
| temporary_csi | features_fund.rds | 188,460 | matches labels | present_current |
| permanent_csi | labels_model_ready.rds | 188,460 | revised key panel | present_current |
| permanent_csi | split_labels_oot.parquet | 188,460 | matches labels | present_current |
| permanent_csi | features_fund.rds | 188,460 | matches labels | present_current |

VAE-derived feature readiness is blocked:

| Track | Artifact | Rows | Key issue | Decision |
|---|---|---:|---|---|
| temporary_csi | features_latent_raw.parquet | 626,080 | 437,620 extra keys vs revised labels | stale_or_misaligned |
| temporary_csi | features_raw_plus_latent.parquet | 127,649 | 60,811 missing keys vs revised labels | stale_or_misaligned |
| permanent_csi | features_latent_raw.parquet | 626,080 | 437,620 extra keys vs revised labels | stale_or_misaligned |
| permanent_csi | features_raw_plus_latent.parquet | 626,080 | 437,620 extra keys vs revised labels | stale_or_misaligned |

The VAE-derived files are also timestamped May 13/17, before the revised May 25 label/split/fundamental artifacts. Freshness cannot be proven; key checks prove misalignment.

## Revised Dataset Counts Confirmed

Temporary CSI labels:

- `y=0`: 171,269
- `y=1`: 8,517
- `y=NA`: 8,674
- split rows: train 143,173; test 18,111; oos 27,176

Permanent CSI labels:

- `y=0`: 181,368
- `y=1`: 6,258
- `y=NA`: 834
- split rows: train 143,173; test 18,111; oos 27,176

## Code Support

`09C_AutoGluon.py` supports the three requested model keys:

- `fund`
- `latent_raw`
- `raw_plus_latent`

It also supports:

- `MT_ROOT`
- absolute `MT_OUTPUT_DIR`
- `RESPONSE_TRACK`
- dynamic-to-temporary track-folder mapping

`10_Evaluation.R` supports `fund` and `latent_raw` through the existing model registry. It does not include `raw_plus_latent` in the `MODELS` registry or CSI `TRACK_KEYS`, so `raw_plus_latent` evaluation/reporting remains a compatibility blocker until a narrow evaluator update or compact metric extractor is scoped.

## Remote Readiness

Remote smoke test result: `PASS`

Sanitized endpoint: `[authorized endpoint]`

Remote findings:

- `/root/AgonyAndExcstasy` exists.
- `01_Code/pipeline/09C_AutoGluon.py` exists.
- `01_Code/pipeline/10_Evaluation.R` exists.
- `01_Code/pipeline/config.R` exists.
- Remote root is not currently a git repository.

No upload or remote execution beyond the smoke/status check occurred.

## Blockers

1. VAE latent raw features are stale/misaligned for both tracks.
2. Raw-plus-latent features are stale/misaligned for both tracks.
3. `raw_plus_latent` evaluation compatibility is not established in `10_Evaluation.R`.

## Recommended Next Ticket

Create a scoped AE-MODEL-SUITE-002A blocker-resolution ticket before upload/training:

- Regenerate or reconstruct `features_latent_raw.parquet` for both tracks from the revised raw feature panel.
- Regenerate `features_raw_plus_latent.parquet` for both tracks from revised raw features plus the fresh latent features.
- Validate rows and unique `(permno, year)` keys against the 188,460-row revised labels/splits.
- Keep outputs isolated and do not run model training in the regeneration ticket unless explicitly scoped.
- Separately scope evaluator compatibility for `raw_plus_latent` before AE-MODEL-SUITE-006.

## Safety Confirmation

- No model training ran.
- No evaluation ran.
- No index construction ran.
- No VAE regeneration ran.
- No pipeline regeneration ran.
- No sensitivity scripts ran.
- No canonical `03_Data_Output/**` files were modified.
- No `02_Data_Input/**` files were modified.
- No secrets or SSH endpoint details were written to this report.
