# AE-PRES-REV-002 Source Map Additions

Updated `SLIDE_DATA_SOURCES.md` for these revised frames:

- `Index Results: Temporary CSI at 0 bps`
- `Index Results: Temporary CSI at 10 bps`
- `Index Results: Permanent CSI at 0 bps`
- `Index Results: Permanent CSI at 10 bps`

The new source-map rows point to:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- model-specific `index_performance_gross_and_net_by_tc.csv` files under:
  - `fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/`
  - `raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/`
  - `raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/`
  - `fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/`
  - `latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/`

Downstream slide numbers were shifted by two because the prior two 20 bps headline slides were replaced by four track-by-cost benchmark tables.

No source-map entry uses XGB-specific labels because no standalone XGBoost-specific presentation row was confirmed.
