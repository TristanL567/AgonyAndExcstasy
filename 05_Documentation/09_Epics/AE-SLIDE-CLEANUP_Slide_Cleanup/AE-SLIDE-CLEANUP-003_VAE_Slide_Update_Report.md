# AE-SLIDE-CLEANUP-003 VAE Slide Update Report

## Ticket

- Epic: AE-SLIDE-CLEANUP
- Ticket: AE-SLIDE-CLEANUP-003
- Branch: development-slides
- Target: Draft deck only

## Implementation Summary

Inserted one new Draft frame immediately after the false-positive bridge slide:

`Modelling V: VAE Features --- Benefits and Drawbacks`

The new frame restates the autoencoder/AP subquestion from the Research Question slide, then separates the evidence into benefits, drawbacks, and a verdict block. The slide preserves the AE-SLIDE-CLEANUP-001B modelling-summary frame and the AE-SLIDE-CLEANUP-002 false-positive bridge frame.

No figure was needed for this ticket; the slide uses source-backed text metrics in the existing Beamer style.

## Source-Backed Metrics Used

| Claim area | Metric | Value | Source |
|---|---:|---:|---|
| Temporary CV | AG Exp.+VAE AP | 0.2114 | `complete_threshold_metrics_wide.csv`, `feature_set=raw_plus_latent`, `track=temporary_csi` |
| Permanent CV | AG Exp.+VAE AP | 0.1883 | `complete_threshold_metrics_wide.csv`, `feature_set=raw_plus_latent`, `track=permanent_csi` |
| Temporary OOS | AG Exp.+VAE AP | 0.3152 | `complete_threshold_metrics_wide.csv`, `feature_set=raw_plus_latent`, `track=temporary_csi` |
| Temporary OOS | AG Exp.+VAE R@FPR1/3/5 | 0.1051 / 0.2632 / 0.4128 | same row |
| Permanent test | AG Exp.+VAE AUC | 0.8838 | `complete_threshold_metrics_wide.csv`, `feature_set=raw_plus_latent`, `track=permanent_csi` |
| Permanent test | AG Exp.+VAE R@FPR3/5 | 0.2011 / 0.3155 | same row |
| Permanent OOS | AG Latent Dataset AP/AUC/Brier | 0.0482 / 0.8337 / 0.0166 | `complete_threshold_metrics_wide.csv`, `feature_set=latent_raw`, `track=permanent_csi` |
| Temporary OOS comparator | AG Expanded AUC vs AG Exp.+VAE AUC | 0.8961 vs 0.8950 | `raw/metric_snapshot.csv` and `complete_threshold_metrics_wide.csv` |

## Evidence Caveat

The current model-suite wide metrics show the raw compact permanent CV-AP comparator at 0.1929, above AG Exp.+VAE permanent CV-AP of 0.1883. To avoid overclaiming, the slide scopes the CV-AP lead statement to the VAE/non-raw feature comparison while still showing the required 0.2114 and 0.1883 values.

## Scope Notes

- Edited only the Draft Rnw file.
- Added no Draft-local figure files.
- Did not edit the non-Draft June presentation file.
- Did not edit `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, `04_Research/**`, or `07_CloudComputing/**`.
- Did not run model, index, evaluation, sensitivity, pipeline, or training scripts.
