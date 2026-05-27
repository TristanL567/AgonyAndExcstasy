# AE-SENS Epic

## ticket_id

`AE-SENS`

## goal

Conduct a raw-model sensitivity study for temporary CSI C/M/T label parameters and compare how label definitions affect model metrics and 11C index construction.

## dependencies

- `AE-CLOUD` readiness package exists.
- Cloud credentials and upload authorization are available before cloud execution tickets.
- Baseline validation state is known from `AE-VALIDATE` or explicitly accepted by Master.

## allowed_areas

- `05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/**`
- `07_CloudComputing/Validation/AE-SENS/**`
- Ticket-authorized source edits only.
- Remote generated outputs under the approved sensitivity output root.

## must_not_touch

- `C:\Users\Tristan Leiter\Documents\MT`
- `C:\Users\Tristan Leiter\Documents\aegis-core`
- Non-raw model families.
- Canonical local model outputs unless explicitly authorized.

## requirements

Use this grid:

- `C` in `-0.60`, `-0.80`, `-0.90`
- `M` in `0.00`, `-0.20`, `-0.30`
- `T` in `12`, `18`, `28`

Baseline: `C080_M020_T018`.

Compare label counts, prevalence, raw-model metrics, prediction distributions, 11C index outcomes, exclusion effects, and baseline-relative deltas.

## AE-SENS-001 refresh decisions

Refresh date: 2026-05-28.

Current branch context: `development-sensitivity` at local HEAD `5d706ef`, created from the `validation` readiness state. This refresh is documentation-only and does not authorize source edits, data edits, output generation, upload, SSH, or cloud execution.

### Confirmed grid and baseline

The sensitivity grid remains the 27-run C/M/T grid:

- `C` in `-0.60`, `-0.80`, `-0.90`
- `M` in `0.00`, `-0.20`, `-0.30`
- `T` in `12`, `18`, `28`

Run IDs encode absolute parameter magnitudes with three digits:

- `C060`, `C080`, `C090` for `C=-0.60`, `-0.80`, `-0.90`
- `M000`, `M020`, `M030` for `M=0.00`, `-0.20`, `-0.30`
- `T012`, `T018`, `T028` for `T=12`, `18`, `28`

Baseline run ID remains `C080_M020_T018`. No inspected source document superseded this baseline.

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

### Confirmed AE-CLOUD manifest bundle

Use `07_CloudComputing/Validation/AE-CLOUD/manifest_sensitivity.tsv` as the AE-CLOUD manifest bundle for this epic.

Current AE-CLOUD evidence:

- `AE-CLOUD-003_Upload_Strategy_And_Code_Sync.md` identifies `manifest_sensitivity.tsv` as the sensitivity bundle for C/M/T label generation and raw-model sensitivity work.
- `AE-CLOUD-004_Readiness_Gate_Report.md` validates `manifest_sensitivity.tsv` with 11 rows: 8 `required` and 3 `optional_fallback`, all concrete local rows with size and hash values.
- `AE-CLOUD-006_Upload_Verification_Report.md` uploaded and verified the validation manifest only. Sensitivity data upload remains a future AE-SENS upload/preflight task and must use the sensitivity manifest, not the validation manifest.

Sensitivity bundle contents:

| status | path | purpose |
|---|---|---|
| required | `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds` | CRSP prices for C/M/T label generation |
| required | `02_Data_Input/01_CRSP/Necessary/delisting_raw.rds` | CRSP delisting data for labels |
| required | `02_Data_Input/01_CRSP/Necessary/universe.rds` | CRSP universe identifiers and grid alignment |
| required | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw.rds` | raw features for sensitivity modelling |
| required | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/split_labels_oot.parquet` | OOT split alignment for raw modelling |
| required | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds` | 11C benchmark constituents |
| required | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds` | 11C benchmark returns |
| required | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_summary_quarterly.csv` | 11C benchmark summary |
| optional_fallback | `02_Data_Input/02_Compustat/Necessary/fundamentals.rds` | fallback if features or labels must be regenerated |
| optional_fallback | `02_Data_Input/03_FRED/Necessary/macro_monthly.rds` | fallback macro controls for regeneration |
| optional_fallback | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds` | fallback panel for temporary CSI rebuilds |

Do not broaden the upload beyond this manifest without a new ticket and explicit authorization.

### Confirmed output layout

AE-SENS uses the AE-CLOUD project-root convention and preserves repository-relative paths.

Remote project root:

```text
/root/AgonyAndExcstasy
```

Remote sensitivity output root:

```text
/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity
```

Repository-relative local/output layout after cloud results are intentionally transferred or reproduced locally:

```text
03_Data_Output/
  3_Modelling_Results/
    Necessary/
      sensitivity/
        manifest/
        logs/
          <run_id>/
        labels/
          <run_id>/
        raw_features/
          shared/
          by_config/
            <run_id>/
        raw_models/
          <run_id>/
        raw_predictions/
          <run_id>/
        evaluation/
          <run_id>/
        index_construction/
          <run_id>/
        comparisons/
```

Every run ID must write to its own subdirectory. Baseline outputs for `C080_M020_T018` must never be overwritten by pilot or variant outputs. Generated `03_Data_Output/**` artifacts remain ignored and must not be committed.

Scoped AE-SENS validation reports and compact summaries belong under:

```text
07_CloudComputing/Validation/AE-SENS/
```

Reports must not include secrets, real host identifiers, private key paths, tokens, or notebook tokens.

### Refreshed execution plan

1. `AE-SENS-002`: validate raw feature reuse locally by read-only inspection and document whether the grid can reuse `features_raw.rds` plus per-run labels, or must regenerate a model-ready dataset for each run ID.
2. `AE-SENS-003`: define the parameterization interface for C, M, and T, the per-run output/log paths, and the no-overwrite checks. This ticket may authorize source edits only if its envelope explicitly allows them.
3. `AE-SENS-004`: upload/preflight the approved sensitivity bundle using `manifest_sensitivity.tsv`; verify file count, sizes, selected hashes, remote package availability, and expected paths; do not train models.
4. `AE-SENS-005`: run a two-config pilot with baseline `C080_M020_T018` and stricter long-window variant `C090_M020_T028`, raw model only, with outputs isolated under the sensitivity root.
5. `AE-SENS-006`: compare pilot label counts, prevalence, raw-model metrics, prediction distributions, 11C index outcomes, exclusion effects, and baseline-relative deltas; decide proceed, fix, or stop.
6. `AE-SENS-007`: run the full 27-config raw-model grid only after the pilot comparison passes and Master authorizes full execution.
7. `AE-SENS-008`: produce the final comparison and ranking report with one row per run ID, clearly separating classification effects from model, prediction, and index-construction effects.

Before any cloud execution, confirm the remote endpoint and project root are reachable in the current worker session. The previous AE-CLOUD validation upload does not imply the sensitivity manifest has already been uploaded.

## non_goals

- No latent, fund, bucket, structural, VAE, or Autoencoder reruns.
- No thesis rewrite.
- No productionizing beyond reproducible sensitivity execution.

## acceptance_criteria

- Pilot runs complete before full grid.
- Full grid either completes all 27 configurations or records explicit failure reports.
- Final comparison separates classification, model, prediction, and index-construction effects.

## manual_verification_required

Yes.

## completion_report_required

Yes.
