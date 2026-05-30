# AE-PRES-REV-003 Source Map Additions

Added source-map entries:

- `Turnover Effect`: maps to `comparison/turnover_summary.csv`, `final_tables/winner_turnover_summary_20bps.csv`, and `comparison/best_by_track_index_cost.csv`.
- `Error-Cost Decomposition`: maps to `comparison/best_by_track_index_cost.csv` and model-specific `error_cost_decomposition_by_crsp_universe.csv` files under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/{fund,latent_raw,raw_plus_latent}/`.

The error-cost slide uses OOS rows matched on track, universe, model, threshold method, lockout/rule, and strategy id. Required categories were present for every selected best strategy:

- `false_positive`
- `false_negative`
- `true_positive`
- `true_negative`

No data outputs were recomputed or modified.
