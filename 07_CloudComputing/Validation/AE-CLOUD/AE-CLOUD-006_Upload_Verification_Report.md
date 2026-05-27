# AE-CLOUD-006 Upload Verification Report

## Status

Complete. The required scoped code/control files and exactly the 10 validation manifest data files were uploaded to the Vast.ai project root and verified remotely.

## Local Repository State

- Local branch: `Development`
- Local HEAD: `3ea55fa AE-CLOUD-005: add live connection environment report`
- Local writes made by this ticket: this report only.
- No commit was made.
- No files were staged.

## Remote Project Root

- Remote project root: `/root/AgonyAndExcstasy`
- Remote root confirmation: `cd /root/AgonyAndExcstasy && pwd` returned `/root/AgonyAndExcstasy`.

## Upload Method

- Tooling: explicit OpenSSH binaries:
  - `C:\Windows\System32\OpenSSH\ssh.exe`
  - `C:\Windows\System32\OpenSSH\scp.exe`
- Host-key options used for both SSH and SCP:
  - `-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL`
- Transfer behavior: `scp`/`scp -r`, preserving relative paths under `/root/AgonyAndExcstasy`.
- Delete behavior: no delete or mirror-delete operation was used.
- Dry-run behavior: `scp` has no dry-run mode, so the data preflight was manifest-derived: each source path, resolved destination path, expected byte size, and SHA256 value was checked from `manifest_validate.tsv` before upload.

## Code Scope Uploaded

Required code/control scope uploaded:

- `01_Code/**`
- `.gitignore`
- `07_CloudComputing/Validation/AE-CLOUD/**`

Scope notes:

- Optional planning context under `05_Documentation/**` was not uploaded.
- Unrelated presentations, full documentation trees, historical outputs, model result archives, caches, and cloud scratch folders were not uploaded.
- Local file counts at verification time:
  - `01_Code/**`: `56` files
  - `07_CloudComputing/Validation/AE-CLOUD/**`: `14` files
- Required remote script checks passed:
  - `01_Code/pipeline/09C_AutoGluon.py`
  - `01_Code/pipeline/10_Evaluation.R`
  - `01_Code/pipeline/11C_IndexConstruction_Revised.R`

## Manifest Validation

Manifest file:

- `07_CloudComputing/Validation/AE-CLOUD/manifest_validate.tsv`

Local validation results:

- Row count: `10`
- Required files missing locally: `0`
- Local size mismatches: `0`
- SHA256 fields blank: `0`
- Total existing-file size: `925,649,900` bytes
- Expected total existing-file size: `925,649,900` bytes

## Data Upload Summary

- Uploaded exactly the 10 files listed in `manifest_validate.tsv`.
- Preserved each relative manifest path beneath `/root/AgonyAndExcstasy`.
- Did not upload full `02_Data_Input/**`, full `03_Data_Output/**`, model output directories, sensitivity output directories, caches, or cloud scratch folders.
- Remote `02_Data_Input` file count after upload: `10`.
- Remote `02_Data_Input` contents matched the 10 manifest paths.

## Remote Data Verification Table

| # | Manifest local path | Expected bytes | Remote bytes | Size status |
|---:|---|---:|---:|---|
| 1 | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw.rds` | 419,892,918 | 419,892,918 | Pass |
| 2 | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/split_labels_oot.parquet` | 302,281 | 302,281 | Pass |
| 3 | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds` | 321,756 | 321,756 | Pass |
| 4 | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_raw.rds` | 420,025,211 | 420,025,211 | Pass |
| 5 | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/split_labels_oot.parquet` | 302,281 | 302,281 | Pass |
| 6 | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Labels/labels_model_ready.rds` | 454,712 | 454,712 | Pass |
| 7 | `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds` | 48,869,889 | 48,869,889 | Pass |
| 8 | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds` | 35,362,592 | 35,362,592 | Pass |
| 9 | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds` | 43,081 | 43,081 | Pass |
| 10 | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_summary_quarterly.csv` | 75,179 | 75,179 | Pass |

## Hash Verification Summary

Manifest SHA256 availability:

- All 10 rows have SHA256 values.

Required remote SHA256 checks passed for:

- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw.rds`
- `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_raw.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds`
- `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Labels/labels_model_ready.rds`
- `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`

Observed remote hashes matched the manifest:

| File | SHA256 status |
|---|---|
| `temporary_csi/Features/features_raw.rds` | Pass |
| `permanent_csi/Features/features_raw.rds` | Pass |
| `temporary_csi/Labels/labels_model_ready.rds` | Pass |
| `permanent_csi/Labels/labels_model_ready.rds` | Pass |
| `01_CRSP/Necessary/prices_monthly.rds` | Pass |
| `04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds` | Pass |

## Script Execution Confirmation

No validation, model training, evaluation, index construction, sensitivity analysis, pipeline regeneration, or project scripts were run locally or remotely.

## Sanitized Commands Run

```powershell
git branch --show-current
git rev-parse --short HEAD
git log -1 --pretty=format:"%h %s"
git status --short
Import-Csv -Delimiter "`t" -LiteralPath "07_CloudComputing\Validation\AE-CLOUD\manifest_validate.tsv" | <local manifest checks>
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "cd /root/AgonyAndExcstasy && pwd"
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "mkdir -p /root/AgonyAndExcstasy/07_CloudComputing/Validation /root/AgonyAndExcstasy/01_Code"
& "C:\Windows\System32\OpenSSH\scp.exe" -P <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -r "01_Code" <USER>@<HOST>:/root/AgonyAndExcstasy/
& "C:\Windows\System32\OpenSSH\scp.exe" -P <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL ".gitignore" <USER>@<HOST>:/root/AgonyAndExcstasy/.gitignore
& "C:\Windows\System32\OpenSSH\scp.exe" -P <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -r "07_CloudComputing\Validation\AE-CLOUD" <USER>@<HOST>:/root/AgonyAndExcstasy/07_CloudComputing/Validation/
Import-Csv -Delimiter "`t" -LiteralPath "07_CloudComputing\Validation\AE-CLOUD\manifest_validate.tsv" | <manifest-derived data preflight>
Import-Csv -Delimiter "`t" -LiteralPath "07_CloudComputing\Validation\AE-CLOUD\manifest_validate.tsv" | ForEach-Object {
  & "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "mkdir -p '<REMOTE_PARENT>'"
  & "C:\Windows\System32\OpenSSH\scp.exe" -P <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "<LOCAL_MANIFEST_FILE>" <USER>@<HOST>:"<REMOTE_MANIFEST_FILE>"
}
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "find /root/AgonyAndExcstasy/02_Data_Input -type f"
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "stat -c '%s %n' <REMOTE_MANIFEST_FILES>"
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "sha256sum <REQUIRED_HASH_CHECK_FILES>"
& "C:\Windows\System32\OpenSSH\ssh.exe" -p <PORT> -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "test -f <REQUIRED_SCRIPT_PATHS>"
```

## Blockers

None.

## Readiness For AE-VALIDATE-001/002

Ready. The remote project root now has the required scoped code/control files and exactly the 10 validation manifest data files. File sizes match the manifest, and the required remote SHA256 checks passed.

