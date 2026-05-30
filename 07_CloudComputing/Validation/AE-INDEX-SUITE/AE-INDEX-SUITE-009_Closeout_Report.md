# AE-INDEX-SUITE-009 Closeout Report

Result: validator_passed

## Status

AE-INDEX-SUITE status: complete.

No remaining index-suite computation is required.

## Completed Grid

The completed full grid covers:

- models: `raw`, `fund`, `latent_raw`, `raw_plus_latent`
- tracks: `dynamic_csi`, `permanent_csi`
- indices: `total_market`, `large_cap`, `mid_cap`, `small_cap`
- threshold methods: `youden`, `fpr1`, `fpr3`, `fpr5`
- temporary lockouts: `1`, `2`, `3`, `5`
- permanent rule: permanent removal
- transaction costs: `0`, `5`, `10`, `20` bps
- turnover outputs: complete

## Final Headline Results

At 20 bps:

- Temporary CSI: `fund` wins total market, large cap, and mid cap; `raw_plus_latent` wins small cap.
- Permanent CSI: `raw_plus_latent` wins total market and large cap; `fund` wins mid cap; `latent_raw` wins small cap.
- Transaction costs did not change top winner rankings between 0 and 20 bps across the 8 track-index comparisons.
- VAE/non-raw variants beat raw in 5 of 8 track-index cases at 20 bps.

## Final Table Folder

`C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\7_IndexConstructionValidation\nonraw_index_suite\final_tables`

## Presentation-Ready Tables

See `AE-INDEX-SUITE-009_presentation_headline_tables.md` for markdown tables covering:

- temporary CSI headline winners at 20 bps
- permanent CSI headline winners at 20 bps
- transaction-cost robustness summary
- model-family comparison versus raw
- threshold-family summary
- turnover summary

## Source Map

See `AE-INDEX-SUITE-009_slide_source_map.md` for a claim-by-claim map to local source files.

## Validation

| check                          | status   | detail                                                                                                                  |
|:-------------------------------|:---------|:------------------------------------------------------------------------------------------------------------------------|
| full_grid_represented          | True     | AE-INDEX-SUITE-008 validation checks all true.                                                                          |
| final_tables_readable          | True     | 7/7 final table/source map artifacts exist.                                                                             |
| no_scripts_run                 | True     | Only local CSV/Markdown summarization was performed; no 11C/model/evaluation/sensitivity/pipeline scripts were invoked. |
| no_canonical_outputs_changed   | True     | Final tables were written only under isolated nonraw_index_suite/final_tables and evidence root.                        |
| no_presentation_files_edited   | True     | No files under 06_Presentations were edited by this ticket.                                                             |
| unrelated_dirty_files_unstaged | True     | Known unrelated dirty files are not part of the 009 evidence set.                                                       |

## Commit Scope

Only AE-INDEX-SUITE-009 evidence under `07_CloudComputing/Validation/AE-INDEX-SUITE/` should be committed. Final table data under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/` is local reporting output and should remain uncommitted unless repository policy changes.
