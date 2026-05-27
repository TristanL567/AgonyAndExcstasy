# AE-CLOUD Upload Templates

These files are inert templates for future cloud upload and preflight work. They contain placeholders and must not be executed until a future operator replaces every placeholder and reviews the resolved command.

Required placeholders:

- `<SSH_KEY_PATH>`
- `<PORT>`
- `<USER>`
- `<HOST>`
- `<REMOTE_PROJECT>`

## Templates

- `rsync_data_dry_run.sh`: builds a temporary file list from one AE-CLOUD-002 manifest and runs `rsync --dry-run`. It skips the header, skips `produced_by_AE_VALIDATE` rows, requires concrete local paths, and includes only paths that exist locally.
- `rsync_data_upload.sh`: same manifest filtering as the dry run, but performs the upload. Run the dry-run template first with the same manifest and review the output before using this.
- `rsync_code_sync.sh`: syncs code/config/planning files separately from data. It excludes data inputs, outputs, research, documentation, presentations, archives, caches, and model artifacts.
- `remote_preflight.sh`: runs read-only remote environment checks through SSH. It does not install packages and does not run project scripts.

These templates were created for local readiness only and were not executed by AE-CLOUD-003.

