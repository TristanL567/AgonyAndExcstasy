# AE-SENS-PRES-004 Sensitivity Slide Update Report

## Scope

Updated the June final presentation sensitivity-analysis section using local-only presentation-ready summaries from:

`03_Data_Output/5_SensitivityAnalysis/presentation_ready/`

No model training, index construction, sensitivity scripts, Vast.ai, SSH, or code changes were used.

## Required Git Scope Repair

The previous local AE-SENS-PRES-003 commit `1594606` contained derived files under `03_Data_Output/**`. Before slide edits, those files were removed from the git index with `git rm --cached`, kept on disk, and the unpushed commit was amended.

Repaired AE-SENS-PRES-003 commit:

`cced316 AE-SENS-PRES-003: build sensitivity presentation summaries`

That repaired commit contains only AE-SENS-PRES documentation/evidence files. The local `presentation_ready` CSVs remain on disk and are ignored by git.

## Slide Updates

Updated these sensitivity-related frames:

- `Robustness I: Temporary CSI Sensitivity Grid`
- `Robustness II: Sensitivity Results and Limits`
- `Appendix A1: Temporary CSI Sensitivity Detail`

The slides now state:

- all 27 temporary-CSI C/M/T run IDs are represented;
- 24 runs are complete or safely reused;
- 3 runs are `blocked_partial`;
- `C090_M000_T012` is the strongest overall composite configuration;
- `C060_M000_T012` is the AP winner;
- `C090_M020_T018` is the strongest total-market 11C benchmark-relative configuration;
- `C080_M020_T018` is a defensible continuity baseline but not top-ranked;
- transaction costs in the accepted-label temporary index grid are applied to gross buy+sell turnover;
- 0/5/10/20 bps overlays do not change the accepted-label temporary winner set;
- permanent-CSI sensitivity remains future work.

## Source Handling

`SLIDE_DATA_SOURCES.md` was updated for every changed frame. The source map points to the local presentation-ready summaries and AE-SENS-PRES-003 evidence. The derived `03_Data_Output/**` summaries were not staged or committed for this ticket.

## Blocked Configurations Disclosed

- `C080_M000_T012`
- `C080_M000_T018`
- `C060_M020_T028`

These are represented in manifests and disclosed as `blocked_partial`, but are not treated as completed evidence.

## Validation Summary

- Local presentation-ready summaries exist on disk.
- No `03_Data_Output/**` files are staged.
- No code files changed.
- No sensitivity/model/index scripts were run.
- Presentation changes are limited to the June `.Rnw` and source map.
- Evidence changes are limited to the AE-SENS-PRES documentation folder.
