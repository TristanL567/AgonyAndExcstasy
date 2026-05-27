# AE-CLOUD-002 Minimal Data Manifest By Epic

## Scope

This local-readiness ticket defines minimal local data bundles for future cloud upload planning. No data was copied, moved, uploaded, or modified.

## Repository State

- Branch: `Development`
- HEAD: `b55198b AE-CLOUD-001: add cloud connection playbook`
- Pre-ticket status: clean working tree on `Development`
- Ticket status: local manifest files created under `07_CloudComputing/Validation/AE-CLOUD/`; no files staged and no commit made.

## Manifest Row Counts

| bundle | required_status | rows |
| --- | ---: | ---: |
| validate | required | 10 |
| sensitivity | required | 8 |
| sensitivity | optional_fallback | 3 |
| minor | required | 7 |
| minor | produced_by_AE_VALIDATE | 6 |

## Existing-File Upload Size

| bundle | currently existing rows counted | total size_bytes |
| --- | ---: | ---: |
| validate | 10 | 925649900 |
| sensitivity | 11 | 571279143 |
| minor | 7 | 70683742 |

The sensitivity bundle includes all specified optional fallback paths because they are currently present locally. The produced_by_AE_VALIDATE rows in the minor bundle are future placeholders and are not counted in the current upload size.

## Missing Files

No specified required local input files were missing during manifest generation. All specified optional fallback files were present and included with `required_status = optional_fallback`.

The six future AE-VALIDATE transaction-cost placeholder rows in `manifest_minor.tsv` intentionally use `size_bytes = NA` and `sha256 = NA`.

## Explicitly Excluded Areas

- `03_Data_Output/**` except the listed future validation placeholders in `manifest_minor.tsv`
- `04_Research/**`
- `05_Documentation/**`
- `06_Presentations/**`
- Existing AutoGluon model artifacts
- Figures, logs, PDFs, DOCX, PPTX, and archives

## Handoff Notes For AE-CLOUD-003

- Use the three TSV manifests as upload planning inputs only; replace `<REMOTE_PROJECT>/` with the final project root after the remote layout is approved.
- Verify that AE-CLOUD-003 preserves the manifest row order and `required_status` semantics when building upload commands.
- Before any upload, re-run hash and size checks against the current local files because upstream validation or sensitivity work may regenerate inputs.
- Treat `produced_by_AE_VALIDATE` rows as expected downstream outputs, not upload inputs, until an AE-VALIDATE run materializes a concrete `<RUN_ID>`.
