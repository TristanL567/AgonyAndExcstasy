# AE-MODEL-SUITE-008 Download And Local Structure Report

## Status

Decision: PASS - compact AE-MODEL-SUITE results were downloaded, structured locally, and checksum-validated.

Branch: validation-model-suite  
Base HEAD: c651d71 AE-MODEL-SUITE-007: compare model suite results  
Remote endpoint: [authorized endpoint]  
SSH authentication: [authorized SSH key path]  
Local destination: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, cloud execution, and branch-hygiene guidance was available and followed.

## Local Structure

Downloaded and mirrored files are saved under the ignored local output folder:

```text
03_Data_Output/6_ModelSuite/
  README.md
  manifest/
    download_manifest.csv
    checksum_manifest.csv
    validation_summary.csv
  raw/
    temporary_csi/
    permanent_csi/
  fund/
    temporary_csi/
    permanent_csi/
    compact_evidence/
  latent_raw/
    temporary_csi/
    permanent_csi/
    compact_evidence/
  raw_plus_latent/
    temporary_csi/
    permanent_csi/
    compact_evidence/
  comparison/
```

`raw/` is intentionally separated from the non-raw model suites because it comes from the AE-VALIDATE optional-library raw rerun. The non-raw folders contain the AE-MODEL-SUITE `fund`, `latent_raw`, and `raw_plus_latent` artifacts.

## Download Scope

Downloaded feature sets:

| Feature set | Files | Scope |
|---|---:|---|
| raw | 12 | Compact AE-VALIDATE raw comparator evidence only. |
| fund | 27 | Prediction parquet, metrics, leaderboard, compact metadata, warnings, status, row counts. |
| latent_raw | 28 | Prediction parquet, metrics, leaderboard, compact metadata, warnings, status, row counts. |
| raw_plus_latent | 27 | Prediction parquet, metrics, leaderboard, compact metadata, warnings, status, row counts. |

Total remote-manifested files: 94  
Total remote-manifested bytes: 8,991,574  
Checksum pass count: 94  
Checksum fail count: 0  
Missing downloaded files: 0

The `comparison/` folder mirrors AE-MODEL-SUITE-007 comparison outputs for local analysis. These mirrored comparison files are local copies and are listed in the local checksum manifest as local-only rows.

## Exclusions

The download intentionally excluded:

- full AutoGluon predictor directories;
- CV fold model directories;
- model binary files;
- cache directories;
- canonical output files unrelated to the isolated validation/model-suite outputs;
- endpoint metadata, notebook metadata, or secret material.

Validation found zero heavy AutoGluon predictor/model/cache artifacts under `03_Data_Output/6_ModelSuite`.

## Missing Or Skipped Compact Artifacts

No file selected into the remote manifest failed download or checksum validation.

One optional raw compact filename, `status_summary.csv`, was not present in the remote AE-VALIDATE raw compact folder and was therefore not selected into the remote manifest. Raw status/provenance remains covered by the downloaded `summary.json`, raw metric snapshot, row counts, leaderboards, log tails, and the committed AE-VALIDATE evidence referenced by AE-MODEL-SUITE-007.

## Git Hygiene

`03_Data_Output/6_ModelSuite/**` is ignored by `.gitignore` through the existing `03_Data_Output/**` rule. The generated local output files were not staged and should not be committed.

Committed evidence for this ticket is limited to:

- `AE-MODEL-SUITE-008_Download_And_Local_Structure_Report.md`
- `AE-MODEL-SUITE-008_remote_download_manifest.csv`
- `AE-MODEL-SUITE-008_local_checksum_manifest.csv`
- `AE-MODEL-SUITE-008_validation_summary.csv`

The pre-existing unrelated AE-VALIDATE blocker reports remain untracked and unstaged.

## Verification

Validation checks retained in `AE-MODEL-SUITE-008_validation_summary.csv` confirm:

- local destination exists;
- all remote-manifested files were downloaded;
- all remote/local sizes match;
- all remote/local SHA256 values match;
- no heavy AutoGluon artifacts were downloaded;
- all four feature sets are represented;
- local output files are ignored and not part of the committed source tree.

No model training, evaluation, index construction, pipeline regeneration, or sensitivity scripts were run.
