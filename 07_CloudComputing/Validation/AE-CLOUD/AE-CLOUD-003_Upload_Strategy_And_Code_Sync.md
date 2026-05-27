# AE-CLOUD-003 Upload Strategy And Code Sync

## Scope

This local-readiness ticket defines an efficient future upload and code-sync procedure for Vast.ai or other cloud execution. It uses the AE-CLOUD-002 manifests as planning inputs only.

No SSH connection was attempted. No files were uploaded. No upload template was executed.

## Repository State

- Branch: `Development`
- HEAD: `7112eca AE-CLOUD-002: add minimal data manifests`
- Status at start: clean working tree on `Development`
- Ticket status: inert planning and template files created under `07_CloudComputing/Validation/AE-CLOUD/`; no files staged and no commit made.

## Remote Placeholders

All future commands must replace these placeholders before use:

- `<SSH_KEY_PATH>`: local private key path for the Vast.ai/cloud instance
- `<PORT>`: SSH port exposed by the instance
- `<USER>`: remote login user
- `<HOST>`: remote host name or IP address
- `<REMOTE_PROJECT>`: project root on the remote instance

Do not commit real credentials, host addresses, ports, or private key paths into these templates.

## Recommended Remote Layout

Use a single project root and preserve repository-relative paths under it:

```text
<REMOTE_PROJECT>/01_Code
<REMOTE_PROJECT>/02_Data_Input
<REMOTE_PROJECT>/03_Data_Output
<REMOTE_PROJECT>/07_CloudComputing/Validation
```

This layout keeps code, uploaded inputs, generated outputs, and validation planning material separate while preserving local relative paths for future pipeline commands.

## Manifest Bundle Summary

AE-CLOUD-002 produced three TSV manifests. They are the source of truth for future data upload planning.

| manifest | bundle | rows | use |
| --- | --- | ---: | --- |
| `manifest_validate.tsv` | validation bundle | 10 required | Minimal existing input files for the Epic 1 raw AutoGluon validation rerun. |
| `manifest_sensitivity.tsv` | sensitivity bundle | 8 required, 3 optional fallback | Minimal existing input files for C/M/T sensitivity label generation and raw-model sensitivity work. |
| `manifest_minor.tsv` | minor diagnostics bundle | 7 required, 6 produced_by_AE_VALIDATE | Existing inputs for recovered bankruptcy or insolvency diagnostics plus future AE-VALIDATE output placeholders. |

The `produced_by_AE_VALIDATE` rows in `manifest_minor.tsv` are not upload inputs yet. They remain placeholders until a concrete AE-VALIDATE `<RUN_ID>` has produced real local paths.

## Code Sync Policy

Sync code separately from data.

Default code sync includes:

- `01_Code/**`
- `.gitignore`
- minimal repository metadata only if needed for provenance or future git status checks
- selected validation planning files under `07_CloudComputing/Validation/**` when needed for cloud execution planning

Default code sync excludes:

- `02_Data_Input/**`
- `03_Data_Output/**`
- `04_Research/**`
- `05_Documentation/**`
- `06_Presentations/**`
- archives and compressed bundles
- caches and temporary files
- model artifacts and AutoGluon output directories

The code-sync template does not use `--delete` by default. If deletion is later enabled, review the include/exclude rules first and apply deletion only to the code-sync surface, never to data or output directories.

## Data Upload Policy

Use the AE-CLOUD-002 manifest TSVs as the source of truth.

Future data upload commands should:

- accept exactly one manifest path at a time
- skip the TSV header row
- upload only rows whose `local_path` is a concrete repository-relative path
- upload only rows whose `local_path` currently exists locally
- skip `required_status = produced_by_AE_VALIDATE` rows until concrete `<RUN_ID>` paths exist
- preserve relative paths under `<REMOTE_PROJECT>`
- avoid uploading unlisted data files, model artifacts, logs, figures, PDFs, DOCX, PPTX, archives, or presentation material

The generated `--files-from` list should contain repository-relative paths such as `02_Data_Input/...`. Running `rsync` from the repository root with source `./` and destination `<USER>@<HOST>:<REMOTE_PROJECT>/` preserves those paths.

## Dry-Run First Policy

Always run the data dry-run template before any real upload:

```bash
bash 07_CloudComputing/Validation/AE-CLOUD/upload_templates/rsync_data_dry_run.sh 07_CloudComputing/Validation/AE-CLOUD/manifest_validate.tsv
```

Review the dry-run output for file count, destination paths, total transfer size, and any skipped missing files. Only after review should the real upload template be used with the same manifest.

## Resume And Retry Policy

Use `rsync -av` so future transfers can resume efficiently after an interrupted upload. If a transfer fails:

- rerun the dry run to confirm the pending file list
- rerun the upload with the same manifest from the repository root
- keep the same `<REMOTE_PROJECT>` so partial remote files can be reused by rsync
- inspect any missing-file warnings instead of broadening the upload scope
- do not switch to recursive whole-directory data uploads as a shortcut

For very large files, a future operator may add reviewed rsync options such as `--partial` or `--append-verify`, but only after confirming compatibility with the remote filesystem and data integrity policy.

## Post-Upload Verification Policy

After future uploads, verify the remote state before running project scripts:

- file count: compare the count of uploadable manifest rows with the count of matching remote files
- size check: compare manifest `size_bytes` against remote file sizes for all uploaded rows where `size_bytes` is concrete
- selected SHA256 check: compute hashes on a selected subset of large and critical files and compare them with manifest `sha256`

For small bundles or final validation readiness, prefer checking all files with concrete `sha256` values.

## Remote Preflight Checklist

Before future cloud execution, run only read-only remote checks:

- `pwd`
- `uname -a`
- `df -h`
- `free -h`
- `nvidia-smi` if available
- `Rscript --version`
- `python --version`
- package import checks for `data.table`, `arrow`, `pyreadr`, `pandas`, and `autogluon`
- `git status --short --branch`

The `remote_preflight.sh` template contains these checks. It does not install packages and does not run project scripts.

## Template Execution Statement

The templates created in `upload_templates/` are inert future-use templates. They were not executed in AE-CLOUD-003.

