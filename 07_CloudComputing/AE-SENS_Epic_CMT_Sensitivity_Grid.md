# AE-SENS Epic: Raw-Model C/M/T Sensitivity Grid On Vast.ai

## Epic Envelope

ticket_id: AE-SENS

goal: Plan and execute a cloud-computing sensitivity study for dynamic CSI classification parameters C, M, and T, using only the raw model family and comparing how alternative classification labels affect downstream index construction.

dependencies:
- Cleaned AgonyAndExcstasy repository exists locally.
- MT source repository remains reference-only.
- AEGIS-CORE remains reference-only.
- Vast.ai instance credentials are provided by Master.
- Baseline pipeline paths are already adapted to the AgonyAndExcstasy layout.

allowed_areas:
- `07_CloudComputing/`
- Future ticket-specific edits may touch `01_Code/` only if a ticket explicitly authorizes implementation.
- Future generated outputs may be written under `03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/`.

must_not_touch:
- `C:\Users\Tristan Leiter\Documents\MT`
- `C:\Users\Tristan Leiter\Documents\aegis-core`
- Existing data files except for read-only inspection.
- Non-raw model families unless a later ticket explicitly expands scope.

requirements:
- Use exactly this sensitivity grid:
  - C in `-0.60`, `-0.80`, `-0.90`
  - M in `0.00`, `-0.20`, `-0.30`
  - T in `12`, `18`, `28`
- Full grid size is 27 configurations.
- Baseline configuration is `C=-0.80`, `M=-0.20`, `T=18`.
- Train and evaluate only raw models for the first sensitivity study.
- Keep the cloud run reproducible from a manifest, explicit run IDs, and logged environment details.
- Do not delete files on local or cloud machines.

non_goals:
- No VAE, latent, Autoencoder, or non-raw model retraining.
- No thesis or documentation rewrite.
- No cleanup of unrelated stale comments.
- No changes to MT.
- No productionizing beyond what is needed to run and compare this grid.

acceptance_criteria:
- There is a validated upload manifest for the minimum required files.
- There is a confirmed cloud instance connection and reproducible environment report.
- The baseline configuration and at least one pilot variant complete end to end before the full grid is run.
- The full 27-configuration grid produces raw-model prediction outputs and index-construction outputs.
- A comparison table reports classification counts, model metrics, and index-construction outcomes per configuration.
- Conformance Gate passes before any ticket is reported complete.

manual_verification_required: true

verification_commands:
- `Rscript 01_Code/pipeline/00_Master.R --help`
- `Rscript 01_Code/pipeline/09C_preflight.py --help`
- `Rscript 01_Code/pipeline/13c_Old_CSI_Recovery_Buckets_All_Grid.R --help`
- `find 03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid -maxdepth 4 -type f | sort`

completion_report_required: true

## Sensitivity Grid

Run ID convention:
- `C060` means `C=-0.60`
- `C080` means `C=-0.80`
- `C090` means `C=-0.90`
- `M000` means `M=0.00`
- `M020` means `M=-0.20`
- `M030` means `M=-0.30`
- `T012`, `T018`, and `T028` mean 12, 18, and 28 months.

Baseline run ID: `C080_M020_T018`

| C | M | T | run_id |
|---:|---:|---:|---|
| -0.60 | 0.00 | 12 | `C060_M000_T012` |
| -0.60 | 0.00 | 18 | `C060_M000_T018` |
| -0.60 | 0.00 | 28 | `C060_M000_T028` |
| -0.60 | -0.20 | 12 | `C060_M020_T012` |
| -0.60 | -0.20 | 18 | `C060_M020_T018` |
| -0.60 | -0.20 | 28 | `C060_M020_T028` |
| -0.60 | -0.30 | 12 | `C060_M030_T012` |
| -0.60 | -0.30 | 18 | `C060_M030_T018` |
| -0.60 | -0.30 | 28 | `C060_M030_T028` |
| -0.80 | 0.00 | 12 | `C080_M000_T012` |
| -0.80 | 0.00 | 18 | `C080_M000_T018` |
| -0.80 | 0.00 | 28 | `C080_M000_T028` |
| -0.80 | -0.20 | 12 | `C080_M020_T012` |
| -0.80 | -0.20 | 18 | `C080_M020_T018` |
| -0.80 | -0.20 | 28 | `C080_M020_T028` |
| -0.80 | -0.30 | 12 | `C080_M030_T012` |
| -0.80 | -0.30 | 18 | `C080_M030_T018` |
| -0.80 | -0.30 | 28 | `C080_M030_T028` |
| -0.90 | 0.00 | 12 | `C090_M000_T012` |
| -0.90 | 0.00 | 18 | `C090_M000_T018` |
| -0.90 | 0.00 | 28 | `C090_M000_T028` |
| -0.90 | -0.20 | 12 | `C090_M020_T012` |
| -0.90 | -0.20 | 18 | `C090_M020_T018` |
| -0.90 | -0.20 | 28 | `C090_M020_T028` |
| -0.90 | -0.30 | 12 | `C090_M030_T012` |
| -0.90 | -0.30 | 18 | `C090_M030_T018` |
| -0.90 | -0.30 | 28 | `C090_M030_T028` |

## Core Technical Assumption To Validate

The likely efficient path is to reuse one feature-engineered raw covariate set and attach grid-specific classification labels by firm-date key. This is only valid if the raw predictors, sample universe, key columns, and split logic are invariant across C/M/T values.

The first implementation ticket must therefore validate:
- The feature columns are independent from C, M, and T.
- Label columns can be regenerated separately for each grid configuration.
- Joins by firm-date key are one-to-one or intentionally many-to-one.
- The train/validation/test split logic does not silently change in a way that makes comparisons invalid.

If these checks fail, the fallback is to generate the full model-ready raw dataset separately for every configuration.

## Minimal Cloud Upload

Upload code and only input data needed to regenerate labels, raw features, raw-model predictions, and index-construction outputs.

Required directories:
- `01_Code/`
- `02_Data_Input/01_CRSP/Necessary/`
- `02_Data_Input/02_Compustat/Necessary/`
- `02_Data_Input/03_FRED/Necessary/`
- `02_Data_Input/04_Index_Replication/Necessary/`

Required input files, subject to validation against actual filenames:
- `prices_monthly.rds`
- `delisting_raw.rds`
- `universe.rds`
- `fundamentals.rds`
- `macro_monthly.rds`
- `crsp_like_index_constituents_quarterly.rds`
- `crsp_like_index_returns_monthly.rds`
- `crsp_like_index_summary_quarterly.csv`

Do not upload by default:
- `03_Data_Output/`
- `04_Research/`
- `05_Documentation/`
- `06_Presentations/`
- Existing AutoGluon outputs.
- Existing model artifacts.
- Existing figures, tables, archives, PDFs, DOCX, PPTX, and thesis material.
- Any VAE, latent, or autoencoder-only outputs not needed for raw models.

## Expected Cloud Output Layout

Recommended root:

```text
03_Data_Output/
  2_Robustness_Checks/
    Necessary/
      sensitivity_grid/
        manifest/
        logs/
        labels/
          C080_M020_T018/
        raw_features/
          shared/
          by_config/
        raw_models/
          C080_M020_T018/
        raw_predictions/
          C080_M020_T018/
        index_construction/
          C080_M020_T018/
        comparisons/
```

Use one run ID per configuration. Never overwrite baseline outputs with variant outputs.

## Execution Strategy

1. Establish Vast.ai connection and record environment.
2. Create or switch to cloud branch `Development_CC` before any implementation change.
3. Build and validate upload manifest locally.
4. Upload minimum data and code to the cloud instance.
5. Run preflight checks on cloud paths and required R/Python packages.
6. Implement parameterized label generation for C/M/T.
7. Commit each completed implementation ticket on `Development_CC` with a ticket-scoped commit.
8. Validate whether raw feature covariates can be reused.
9. Run pilot:
   - baseline: `C080_M020_T018`
   - stricter long-window variant: `C090_M020_T028`
10. Compare pilot label counts, model metrics, prediction distributions, and index outputs.
11. If pilot passes, execute full 27-grid raw-model run.
12. Produce final comparison report and transfer only summary artifacts back locally.

## Cloud Git Tracking Requirement

All implementation changes made on the cloud instance must be committed to a dedicated branch named `Development_CC`. This makes the cloud work auditable against the current cleaned repository state.

Rules:
- No implementation work starts on the cloud until branch setup is complete.
- Do not commit generated data, model artifacts, figures, logs, presentations, documents, or research files.
- Commit after each completed implementation ticket, not after a batch of unrelated tickets.
- Each commit message starts with the ticket ID, for example `AE-SENS-004: parameterize CMT labels`.
- Before each commit, inspect staged files and confirm they are ticket-scoped.
- If a remote named `origin` exists, push `Development_CC` only after Master authorizes it.
- If no remote exists on the cloud instance, keep the branch local and export `git diff main...Development_CC` or `git diff master...Development_CC` as a review artifact.

Recommended cloud commands:

```bash
git status --short
git branch --show-current
git branch --list Development_CC
git switch -c Development_CC
```

If `Development_CC` already exists:

```bash
git switch Development_CC
```

Before each ticket commit:

```bash
git status --short
git diff --stat
git diff -- 01_Code 07_CloudComputing
git add <ticket-scoped-files>
git diff --cached --stat
git diff --cached --name-only
git commit -m "AE-SENS-00X: concise ticket summary"
```

Optional push, only after Master approval:

```bash
git push -u origin Development_CC
```

Review against the current repo branch:

```bash
git diff --stat main...Development_CC
git diff main...Development_CC -- 01_Code 07_CloudComputing
```

If the default branch is `master` instead of `main`, replace `main` with `master`.

## Ticket AE-SENS-GIT-001: Cloud Branch Setup

ticket_id: AE-SENS-GIT-001

goal: Create or switch to the dedicated cloud development branch `Development_CC` before any cloud implementation work.

dependencies:
- AE-SENS-001 completed.
- Cloud project directory exists.
- Master confirms the cloud path that contains the repository worktree.

allowed_areas:
- Remote project directory git metadata.
- `07_CloudComputing/` for reporting.

must_not_touch:
- MT
- AEGIS-CORE
- Local repository files
- Data and output files

requirements:
- Record current cloud branch.
- Record `git status --short` before branch changes.
- Create `Development_CC` if it does not exist.
- Switch to `Development_CC` if it already exists.
- Confirm the branch after switching.
- Do not commit in this ticket unless branch setup itself creates an explicit tracking artifact approved by Master.

non_goals:
- No code edits.
- No data upload.
- No model execution.
- No package installation.

acceptance_criteria:
- Cloud worktree is on `Development_CC`.
- Pre-branch and post-branch status are reported.
- Any pre-existing dirty files are listed and not overwritten.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git status --short && git branch --show-current"`
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git branch --list Development_CC"`

completion_report_required: true

## Ticket AE-SENS-GIT-002: Ticket-Scoped Cloud Commit Procedure

ticket_id: AE-SENS-GIT-002

goal: Commit one completed cloud implementation ticket to `Development_CC` with only the files changed for that ticket.

dependencies:
- AE-SENS-GIT-001 completed.
- One implementation ticket has passed validator review and Conformance Gate.

allowed_areas:
- Remote project directory git worktree.
- `07_CloudComputing/` for commit report.

must_not_touch:
- MT
- AEGIS-CORE
- Data files
- Generated outputs
- Documentation, research, and presentation folders unless the implementation ticket explicitly allowed them

requirements:
- Confirm branch is `Development_CC`.
- Show unstaged diff stat.
- Stage only ticket-scoped source or planning files.
- Show staged file list before commit.
- Confirm no ignored data or output files are staged.
- Commit with message format `TICKET_ID: concise summary`.
- Record resulting commit SHA.

non_goals:
- No push unless Master explicitly approves.
- No combining multiple implementation tickets in one commit.
- No cleanup of unrelated dirty files.

acceptance_criteria:
- Commit exists on `Development_CC`.
- Commit contains only allowed files for the completed ticket.
- Commit SHA and staged file list are included in the completion report.
- Working tree status after commit is reported.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git branch --show-current"`
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git diff --cached --name-only"`
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git log -1 --oneline"`

completion_report_required: true

## Ticket AE-SENS-GIT-003: Development_CC Review Diff Export

ticket_id: AE-SENS-GIT-003

goal: Produce a reviewable diff summary of `Development_CC` against the current base branch so Master can track all cloud changes.

dependencies:
- At least one implementation commit exists on `Development_CC`.

allowed_areas:
- Remote project directory git worktree.
- `07_CloudComputing/` for copied review summaries.

must_not_touch:
- MT
- AEGIS-CORE
- Data files
- Generated outputs

requirements:
- Detect default base branch as `main` or `master`.
- Generate diff stat against `Development_CC`.
- Generate changed-file list against `Development_CC`.
- Generate source-only patch for review, excluding data/output/documentation/research/presentation artifacts.
- If `origin` exists and Master authorizes push, push `Development_CC`.

non_goals:
- No code edits.
- No new model runs.
- No branch merge.

acceptance_criteria:
- Master receives diff stat and changed-file list.
- Patch excludes ignored large-file areas.
- Push status is reported as pushed, skipped, or unavailable.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git diff --stat main...Development_CC || git diff --stat master...Development_CC"`
- `ssh -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git diff --name-only main...Development_CC || git diff --name-only master...Development_CC"`

completion_report_required: true

## Ticket AE-SENS-001: Vast.ai Connection And Environment Discovery

ticket_id: AE-SENS-001

goal: Connect to the Vast.ai instance and record enough environment detail to decide whether the raw-model grid can run there.

dependencies:
- Master provides SSH host, port, user, key path, and intended remote project directory.

allowed_areas:
- `07_CloudComputing/`
- Remote shell read-only inspection commands.

must_not_touch:
- Local `01_Code/`
- Local `02_Data_Input/`
- Local `03_Data_Output/`
- MT
- AEGIS-CORE

requirements:
- Confirm SSH connection.
- Record OS, CPU, RAM, GPU, disk, R version, Python version, and available package managers.
- Check whether `Rscript`, Python, and shell tools needed by the pipeline are available.
- Do not install packages in this ticket unless Master authorizes a follow-up ticket.

non_goals:
- No upload.
- No code edits.
- No pipeline execution.

acceptance_criteria:
- A short environment report exists under `07_CloudComputing/`.
- Missing dependencies are listed with exact install recommendations.
- Remote project path is confirmed or proposed.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "pwd && uname -a && df -h && free -h"`
- `ssh -p <PORT> <USER>@<HOST> "Rscript --version && python --version"`

completion_report_required: true

## Ticket AE-SENS-002: Minimal Upload Manifest

ticket_id: AE-SENS-002

goal: Build a precise manifest of local files required for cloud execution of raw-model C/M/T sensitivity runs.

dependencies:
- AE-SENS-001 completed.
- Local AgonyAndExcstasy file tree available.

allowed_areas:
- `07_CloudComputing/`
- Read-only inspection of `01_Code/` and `02_Data_Input/`

must_not_touch:
- MT
- AEGIS-CORE
- Any local data file contents

requirements:
- Identify every file needed for label generation, feature construction, raw-model training, prediction, and index construction.
- Record file paths, sizes, and hashes.
- Separate required, optional, and excluded files.
- Confirm that excluded files include all documentation and large generated outputs.

non_goals:
- No upload.
- No file movement.
- No code edits.

acceptance_criteria:
- Manifest exists in `07_CloudComputing/`.
- Manifest contains no `04_Research/`, `05_Documentation/`, or `06_Presentations/` files.
- Manifest contains no generated `03_Data_Output/` files unless explicitly justified.
- Manifest identifies whether dynamic CSI missing generated files must be regenerated on cloud.

manual_verification_required: true

verification_commands:
- `Get-ChildItem -Recurse 02_Data_Input | Select-Object FullName,Length`
- `Get-FileHash <manifest-files>`

completion_report_required: true

## Ticket AE-SENS-003: Sensitivity Run Layout And Parameterization Plan

ticket_id: AE-SENS-003

goal: Define the run IDs, output directories, configuration interface, and logging convention for the 27 C/M/T raw-model runs.

dependencies:
- AE-SENS-002 completed.

allowed_areas:
- `07_CloudComputing/`
- Read-only inspection of `01_Code/pipeline/`

must_not_touch:
- MT
- AEGIS-CORE
- Data files

requirements:
- Specify how C, M, and T are passed to scripts.
- Specify output directories per run ID.
- Specify log paths per run ID.
- Specify how baseline and variant outputs are kept separate.
- Include the full 27-run grid exactly as listed in this epic.

non_goals:
- No code edits.
- No model runs.

acceptance_criteria:
- Master can hand the plan to a worker without additional path decisions.
- No output path can overwrite another run ID.
- Baseline `C080_M020_T018` is clearly marked.

manual_verification_required: true

verification_commands:
- `Select-String -Path 01_Code/pipeline/*.R -Pattern "C|M|T|threshold|dynamic_csi|labels"`

completion_report_required: true

## Ticket AE-SENS-004: Raw Feature Reuse Validation

ticket_id: AE-SENS-004

goal: Determine whether one feature-engineered raw covariate dataset can be reused across all C/M/T label definitions.

dependencies:
- AE-SENS-003 completed.

allowed_areas:
- `01_Code/pipeline/`
- `07_CloudComputing/`
- Local or cloud temporary validation output under the ticket-specific output directory.

must_not_touch:
- MT
- AEGIS-CORE
- Non-raw model code unless read-only inspection is required

requirements:
- Trace where labels are generated and where raw features are generated.
- Verify whether C/M/T affects only labels or also sample construction.
- Verify key columns used to join labels to features.
- Propose exact implementation route:
  - shared covariates plus per-grid labels, or
  - full per-grid model-ready dataset generation.

non_goals:
- No full grid run.
- No index comparison.

acceptance_criteria:
- Validation report states whether feature reuse is valid.
- If valid, report specifies join keys and invariant columns.
- If invalid, report specifies why and names the fallback implementation.

manual_verification_required: true

verification_commands:
- `Rscript 01_Code/pipeline/09C_preflight.py --help`
- `Select-String -Path 01_Code/pipeline/*.R -Pattern "labels_model_ready|features_raw|RESPONSE_TRACK|dynamic_csi"`

completion_report_required: true

## Ticket AE-SENS-005: Cloud Upload And Preflight

ticket_id: AE-SENS-005

goal: Upload the minimal manifest to Vast.ai and verify cloud paths before any model run.

dependencies:
- AE-SENS-001 completed.
- AE-SENS-002 completed.
- Master authorizes upload.

allowed_areas:
- Local `07_CloudComputing/`
- Remote project directory

must_not_touch:
- MT
- AEGIS-CORE
- Local data files except read-only upload source

requirements:
- Upload only files listed in the approved manifest.
- Verify remote file count, sizes, and selected hashes.
- Confirm remote `.gitignore`-equivalent behavior if the remote path is a git worktree.
- Run preflight checks without training.

non_goals:
- No model training.
- No full pipeline execution.
- No package installation unless explicitly approved.

acceptance_criteria:
- Remote tree matches manifest.
- Required input files are present.
- Preflight confirms expected input and output directories.

manual_verification_required: true

verification_commands:
- `rsync --dry-run -av --files-from=<manifest> ./ <USER>@<HOST>:<REMOTE_PROJECT>/`
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT> -maxdepth 4 -type f | sort | wc -l"`

completion_report_required: true

## Ticket AE-SENS-006: Pilot Two-Config Raw Model Run

ticket_id: AE-SENS-006

goal: Run the raw-model pipeline for baseline and one stricter long-window sensitivity variant before launching the full grid.

dependencies:
- AE-SENS-004 completed.
- AE-SENS-005 completed.

allowed_areas:
- Remote project directory
- Local `07_CloudComputing/`
- Remote output path `03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/`

must_not_touch:
- MT
- AEGIS-CORE
- Local data files
- Non-raw model outputs

requirements:
- Run `C080_M020_T018`.
- Run `C090_M020_T028`.
- Use raw model only.
- Save labels, raw model artifacts, predictions, index-construction outputs, and logs per run ID.
- Record wall time and peak resource usage where available.

non_goals:
- No full 27-grid run.
- No non-raw model execution.

acceptance_criteria:
- Both pilot configurations complete.
- Outputs are stored in separate run ID directories.
- Logs show parameter values actually used.
- No baseline output is overwritten by the variant.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid -maxdepth 4 -type f | sort"`
- `ssh -p <PORT> <USER>@<HOST> "grep -R \"C080_M020_T018\\|C090_M020_T028\" <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/logs"`

completion_report_required: true

## Ticket AE-SENS-007: Pilot Comparison Report

ticket_id: AE-SENS-007

goal: Compare the two pilot configurations and decide whether the full grid should run.

dependencies:
- AE-SENS-006 completed.

allowed_areas:
- `07_CloudComputing/`
- Remote read-only inspection of pilot outputs
- Local copy of summary artifacts only

must_not_touch:
- MT
- AEGIS-CORE
- Raw cloud data beyond reading and summarizing

requirements:
- Compare classification counts.
- Compare raw-model performance metrics.
- Compare prediction distributions.
- Compare index-construction outputs.
- Identify whether differences are directionally plausible.
- Recommend proceed, fix, or stop.

non_goals:
- No additional model runs.
- No code edits unless a new ticket is opened.

acceptance_criteria:
- Pilot report exists in `07_CloudComputing/`.
- Report includes baseline vs `C090_M020_T028`.
- Report identifies blockers before full-grid launch, if any.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/comparisons -type f | sort"`

completion_report_required: true

## Ticket AE-SENS-008: Full 27-Grid Raw Model Run

ticket_id: AE-SENS-008

goal: Execute all 27 C/M/T configurations for raw models on Vast.ai.

dependencies:
- AE-SENS-007 completed with proceed decision from Master.

allowed_areas:
- Remote project directory
- Remote output path `03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/`
- Local `07_CloudComputing/` for status reports

must_not_touch:
- MT
- AEGIS-CORE
- Local data files
- Non-raw model families

requirements:
- Execute all 27 run IDs in the epic grid.
- Use resumable execution where completed run IDs are skipped only after output validation.
- Save per-run logs.
- Save per-run labels, predictions, metrics, and index-construction results.
- Produce a status table with success, failed, skipped, and rerun states.

non_goals:
- No non-raw model training.
- No thesis edits.
- No manual deletion of failed outputs.

acceptance_criteria:
- All 27 run IDs either complete or have explicit failure reports.
- Completed outputs pass per-run validation.
- Failed runs include actionable error logs.
- Master receives a concise run status report.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/raw_predictions -mindepth 1 -maxdepth 1 -type d | wc -l"`
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/index_construction -mindepth 1 -maxdepth 1 -type d | wc -l"`

completion_report_required: true

## Ticket AE-SENS-009: Full Grid Comparison And Ranking

ticket_id: AE-SENS-009

goal: Summarize how C, M, and T change labels, raw-model predictions, and index-construction outcomes across the full grid.

dependencies:
- AE-SENS-008 completed.

allowed_areas:
- `07_CloudComputing/`
- Remote read-only inspection of full-grid outputs
- Local summary artifacts copied from cloud

must_not_touch:
- MT
- AEGIS-CORE
- Cloud raw outputs except read-only access and summary artifact export

requirements:
- Build a comparison table with one row per run ID.
- Include C, M, T, classification counts, class balance, raw-model metrics, prediction summaries, and index-construction outcomes.
- Compare every configuration against baseline `C080_M020_T018`.
- Highlight parameter choices that materially alter index construction.
- Include a recommendation for thesis/report interpretation.

non_goals:
- No new model training.
- No non-raw model extension.
- No final thesis writing.

acceptance_criteria:
- Full-grid comparison report exists under `07_CloudComputing/`.
- Baseline-relative differences are visible.
- Report clearly separates classification effects from prediction and index-construction effects.
- Conformance Gate passes.

manual_verification_required: true

verification_commands:
- `ssh -p <PORT> <USER>@<HOST> "find <REMOTE_PROJECT>/03_Data_Output/2_Robustness_Checks/Necessary/sensitivity_grid/comparisons -type f | sort"`

completion_report_required: true

## Conformance Gate

Before any ticket is reported complete, verify:
- Ticket envelope exists and includes all required fields.
- Allowed areas were respected.
- MT was not modified.
- AEGIS-CORE was not modified.
- No unrelated files were edited.
- Verification commands were run or explicitly marked unavailable with reason.
- Manual verification needs are stated.
- Completion report includes changed files, outputs created, commands run, and remaining issues.
