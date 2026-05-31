# AE-MODEL-INDEX-LINK-005 Closeout Report

## Scope

This is the closeout ticket for AE-MODEL-INDEX-LINK. It validates artifact completeness, source traceability, checkpoint readiness, and merge-gate readiness. It does not merge the branch and does not modify data outputs, code, presentation files, input data, or cloud-computing files.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `9facd8d`
- Ticket: `AE-MODEL-INDEX-LINK-005`
- Merge performed: no

## Ticket Completion Summary

| Ticket | Status | Commit | Main artifact |
|---|---|---|---|
| AE-MODEL-INDEX-LINK-001 | Complete | `ecc4b55` | Status quo diagnostic and source/linkage inventories |
| AE-MODEL-INDEX-LINK-002 | Complete | `3dc1bf5` | Metric-alpha correlations and joined diagnostic dataset |
| AE-MODEL-INDEX-LINK-003 | Complete | `1056e2f` | Mechanism diagnostic and alignment/divergence examples |
| AE-MODEL-INDEX-LINK-004 | Complete | `9facd8d` | Reporting recommendation, claim boundaries, checkpoint summary |
| AE-MODEL-INDEX-LINK-005 | Complete pending this commit | pending | Closeout, source traceability, merge-gate readiness |

## Final Evidence Set

The epic produced:

- source inventory;
- linkage inventory;
- compact joined metric-index dataset;
- metric-alpha correlation table;
- missingness summary;
- mechanism diagnostic;
- alignment/divergence examples;
- mechanism source map;
- reporting recommendation;
- claim-boundary table;
- checkpoint summaries for tickets 004 and 005;
- final closeout and source traceability.

## Final Findings

The central conclusion is stable across the ticket chain:

> Model metrics are predictive-quality diagnostics; index alpha is the realized portfolio consequence after thresholding, market-cap weighting, timing, universe choice, turnover, and costs.

Key result points:

- AP does not map cleanly to total-market alpha across the 24 completed/reused temporary-CSI CMT runs.
- OOS AP versus total-market alpha: Pearson `-0.042425`, Spearman `-0.100870`.
- OOS R@FPR3 is more aligned but still incomplete: Pearson `0.336036`, Spearman `0.320870`.
- The AP winner `C060_M000_T012` is not the total-market alpha winner.
- The total-market alpha winner is `C090_M020_T018`.
- The main run `C080_M020_T018` is not an outlier.
- Permanent-CSI CMT sensitivity remains future work.

## Source Traceability

Source traceability is recorded in `AE-MODEL-INDEX-LINK-005_source_traceability.csv`.

Every final claim links back to one or more of:

- local sensitivity summary files;
- AE-SENS-CHART stability tables;
- AE-MODEL-SUITE model metrics;
- AE-INDEX-SUITE index comparison outputs;
- earlier AE-MODEL-INDEX-LINK diagnostic artifacts.

## Claim Boundaries

The accepted claim boundary is:

- supported: model metrics and alpha are distinct but related layers;
- supported: the main CMT run is not an outlier;
- not supported: higher AP mechanically implies higher alpha;
- not supported: model metrics alone select the final index rule;
- not supported: temporary-CSI sensitivity conclusions generalize to permanent-CSI sensitivity.

## Merge-Gate Readiness

The epic is ready for the separate merge gate, subject to the envelope policy:

- target base: `main`;
- strategy: `no_ff`;
- requires epic validator: yes;
- requires human approval: yes.

This ticket did not merge the branch.

## Scope Hygiene

No files under these must-not-touch areas were modified by this ticket:

- `03_Data_Output/**`
- `06_Presentations/**`
- `01_Code/**`
- `02_Data_Input/**`
- `07_CloudComputing/**`

No model training, model evaluation, index construction, sensitivity scripts, Vast.ai access, or SSH commands were used.

Known unrelated dirty files remain unstaged:

- deleted old `06_Presentations/.../FinalPresentation/...Rnw`;
- untracked `07_CloudComputing/Validation/AE-VALIDATE/`.

## Closeout Status

AE-MODEL-INDEX-LINK ticket execution is closed. Merge remains a separate master-planner/human step.
