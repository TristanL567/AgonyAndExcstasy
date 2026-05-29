# AE-MODEL-SUITE: Non-Raw CSI Model Rerun

## Purpose

AE-MODEL-SUITE reruns the non-raw CSI model specifications on the revised labelled firm-year panel for both accepted response tracks:

| Track | `RESPONSE_TRACK` | Folder |
|---|---|---|
| temporary CSI | `dynamic_csi` | `temporary_csi` |
| permanent CSI | `permanent_csi` | `permanent_csi` |

Models in scope:

| Model | Repo key | Description |
|---|---|---|
| Fundamental | `fund` | fundamentals-only |
| VAE only | `latent_raw` | VAE latent features from raw input |
| Raw + VAE | `raw_plus_latent` | raw features plus VAE latent features |

The raw model is not rerun in this epic. AE-VALIDATE raw results are the comparator.

## Execution Principles

- Use isolated validation output roots through `MT_OUTPUT_DIR`; never overwrite canonical outputs.
- Verify and sync remote code before remote execution, because remote code can drift.
- Validate VAE feature freshness before any `latent_raw` or `raw_plus_latent` training.
- Confirm `10_Evaluation.R` compatibility before assuming `raw_plus_latent` can be evaluated by the existing suite.
- Keep cloud storage controlled; retain compact metrics, predictions, leaderboards, and reports, not heavy model binaries unless explicitly required.
- Commit only compact documentation and validation evidence. Generated model data stays out of Git.

## Planned Output Root

Remote validation output root convention:

```text
/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/nonraw_rerun_<timestamp>
```

Reports and compact evidence are tracked locally under:

```text
07_CloudComputing/Validation/AE-MODEL-SUITE/
```

## Current Readiness Gate

AE-MODEL-SUITE-001 is the opening readiness gate. It does not run training, evaluation, index construction, VAE regeneration, or pipeline regeneration.

Current gate decision: `BLOCKED`.

Reason: VAE-derived feature files are present but not fresh/aligned to the revised 188,460-row dataset. A scoped VAE-feature regeneration/validation ticket is required before non-raw training.
