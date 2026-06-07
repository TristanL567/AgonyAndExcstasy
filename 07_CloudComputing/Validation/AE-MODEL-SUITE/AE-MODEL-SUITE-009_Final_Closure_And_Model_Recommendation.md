# AE-MODEL-SUITE-009 Final Closure And Model Recommendation

## Epic Status

Decision: COMPLETE - AE-MODEL-SUITE is closed.

Branch: validation-model-suite  
Base HEAD: 574196f AE-MODEL-SUITE-008: download model suite results  
Final local artifact location: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, and branch-hygiene guidance was available and followed.

All four model feature sets are represented:

- `raw`
- `fund`
- `latent_raw`
- `raw_plus_latent`

Both CSI tracks are represented:

- `dynamic_csi` / temporary CSI
- `permanent_csi` / permanent CSI

## Ticket Outcomes

| Ticket | Outcome |
|---|---|
| AE-MODEL-SUITE-001 | Opened the epic and stopped before training because stale VAE-derived features were found. |
| AE-MODEL-SUITE-002 | Regenerated and validated VAE-derived `features_latent_raw` and `features_raw_plus_latent` artifacts for both tracks. Generated feature artifacts are valid on disk and remain ignored where repo policy ignores data files. |
| AE-MODEL-SUITE-003 | Prepared and verified the remote model-suite environment, current code, regenerated feature inputs, packages, and isolated output root. |
| AE-MODEL-SUITE-004 | Ran `MODEL=fund` for both tracks and retained compact metrics, leaderboards, family metadata, prediction row counts, and storage-retention evidence. |
| AE-MODEL-SUITE-005 | Ran `MODEL=latent_raw` for both tracks and retained compact metrics, leaderboards, family metadata, prediction row counts, and storage-retention evidence. |
| AE-MODEL-SUITE-006 | Ran `MODEL=raw_plus_latent` for both tracks and retained compact metrics, leaderboards, family metadata, prediction row counts, and storage-retention evidence. |
| AE-MODEL-SUITE-007 | Compared revised-dataset `raw`, `fund`, `latent_raw`, and `raw_plus_latent` evidence for both tracks. |
| AE-MODEL-SUITE-008 | Downloaded compact model-suite results to `03_Data_Output/6_ModelSuite`, verified checksums, and confirmed heavy AutoGluon artifacts were excluded. |

## Final Model-Training Recommendation

### Temporary CSI

Use `raw_plus_latent` as the main non-raw index-construction candidate.

Keep `raw` as the revised-dataset benchmark comparator. In AE-MODEL-SUITE-007, `raw_plus_latent` produced the strongest temporary CSI OOS AP and modestly improved CV AP, while `raw` remained the strongest benchmark on test AP/AUC and comparable OOS AUC. The correct reporting posture is therefore not to replace raw outright, but to carry `raw_plus_latent` into the next index-construction rerun and compare it directly against the raw benchmark.

### Permanent CSI

Keep `raw` as the reporting baseline.

Use `raw_plus_latent` as the primary non-raw challenger because it is the stronger non-raw CV/test candidate. Retain `latent_raw` as an OOS-robustness sensitivity because it has the strongest permanent CSI OOS AP/AUC/recall despite weaker CV/test performance. No non-raw permanent CSI model cleanly dominates across all objectives.

### Fund

Retain `fund` as the fundamentals-only benchmark and ablation. It should not be the preferred final candidate unless a future reporting objective explicitly prioritizes fundamentals-only interpretability over predictive performance.

## Reporting Guidance

- Report `raw` as the revised benchmark.
- Report `raw_plus_latent` as the main enhanced feature-set challenger.
- Report `latent_raw` where OOS robustness is relevant, especially for permanent CSI.
- Use `fund` to show the fundamentals-only contribution.
- Do not claim index-construction superiority for non-raw models yet. Non-raw index construction has not been rerun in this epic, so index-level claims must wait for a dedicated index-construction rerun using the saved predictions.

## Next Required Epic

The next work should be an index-construction rerun epic using the saved model predictions from:

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\6_ModelSuite`

The next epic should run index construction at minimum for:

- temporary CSI `raw_plus_latent`, compared against the revised `raw` benchmark;
- permanent CSI `raw_plus_latent`, compared against the revised `raw` benchmark;
- permanent CSI `latent_raw` as an OOS-robustness sensitivity if scope allows.

## Caveats

- `10_Evaluation.R` lacked full `raw_plus_latent` registry support during this epic, so model-suite comparison relies on 09C compact metrics and extracted AutoGluon metadata for `raw_plus_latent`.
- Heavy AutoGluon predictor directories, fold model directories, caches, and model binaries were intentionally pruned and not downloaded.
- Downloaded local results are ignored by git under the existing `03_Data_Output/**` rule.
- Raw comparator evidence comes from the AE-VALIDATE optional-library raw rerun, not a raw rerun executed inside AE-MODEL-SUITE.

## Closure Validation

Local artifact validation confirms:

- `03_Data_Output/6_ModelSuite` exists;
- `raw`, `fund`, `latent_raw`, and `raw_plus_latent` folders exist;
- `temporary_csi` and `permanent_csi` track folders exist where expected;
- AE-MODEL-SUITE-008 checksum validation passed with 94 remote-manifested files, 8,991,574 bytes, 94 checksum passes, 0 failures, and 0 missing files;
- no heavy AutoGluon artifacts were found in the local download;
- no model training, evaluation, index construction, pipeline regeneration, sensitivity scripts, upload, or download were run in this closure ticket;
- no `02_Data_Input/**` or canonical output files were modified.

The pre-existing unrelated AE-VALIDATE blocker reports remain untracked and unstaged.
