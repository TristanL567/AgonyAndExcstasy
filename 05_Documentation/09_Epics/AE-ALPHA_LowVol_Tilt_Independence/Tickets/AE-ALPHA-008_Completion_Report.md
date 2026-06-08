# AE-ALPHA-008 Completion Report

## status

completed

## summary

Created the dedicated distribution diagnostics script and generated table-ready monthly return, distribution, active-return, capture, tail-state, Q-Q, and scatter input datasets. The run read existing benchmark, low-volatility, and CSI outputs only.

## changed_files

- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\01_Code\pipeline\11J_Distributional_Diagnostics.R
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/distribution_diagnostics_report.md
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/distribution_diagnostics_run_status.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-008_Completion_Report.md

## generated_outputs

- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/monthly_return_panel.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/monthly_return_panel.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/distribution_summary_by_strategy.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/distribution_summary_by_strategy.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/active_return_summary.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/active_return_summary.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/upside_downside_capture.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/upside_downside_capture.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/tail_state_summary.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/tail_state_summary.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/qq_plot_data.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/qq_plot_data.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/scatter_plot_data.rds
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/distribution_diagnostics/scatter_plot_data.csv
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/distribution_diagnostics_report.md
- C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/distribution_diagnostics_run_status.csv

## row_counts

                           artifact  rows
                             <char> <int>
1:             monthly_return_panel 65748
2: distribution_summary_by_strategy   400
3:            active_return_summary   400
4:          upside_downside_capture   400
5:               tail_state_summary   800
6:                     qq_plot_data 40800
7:                scatter_plot_data 65748

## period_alignment_rule

Rows are expanded to full, insample, test, and oos periods. The non-full windows use the explicit AE-ALPHA performance-summary dates shared by benchmark and low-vol outputs: insample=1998-01-30 to 2015-12-31; oos=2020-01-31 to 2024-12-31; test=2016-01-29 to 2019-12-31. The full period uses each strategy's available monthly span after matching to the same date and index_id benchmark return.

## selected_strategy_coverage

   selected_strategy_rows                                  indexes
                    <int>                                   <char>
1:                     16 large_cap|mid_cap|small_cap|total_market
             response_tracks transaction_cost_bps return_files
                      <char>               <char>        <int>
1: dynamic_csi|permanent_csi                 0|20            5

## headline_findings_neutral

- The panel separates benchmark, low-volatility quintile, and selected CSI monthly return distributions with matched benchmark returns.
- The capture tables identify benchmark-up and benchmark-down month averages and counts for each strategy-period row.
- The tail-state tables summarize strategy and active returns during each strategy's matched benchmark bottom 2.5% and 5% months.
- Q-Q and scatter outputs are data-only inputs for later chart rendering outside this ticket.

## verification

- Dedicated script exists and was run.
- Required RDS and CSV output families were written.
- Monthly panel includes benchmark, lowvol, and csi strategy groups.
- Low-volatility Q1 and Q5 are present.
- Active returns are matched by date and index_id.
- Upside/downside capture and tail-state rows have nonzero month counts.
- No chart files were created.
- No staging, commit, push, thesis edit, or presentation edit occurred.

## known_caveats

- Full-period sample starts differ by artifact availability after benchmark matching.
- CSI full-period dates are inferred from the selected existing monthly return files because the performance extract stores full-period month counts but not explicit start/end dates.
- Diagnostics are descriptive and table-ready; interpretation is intentionally limited.

## validator_result

approved

## validator_notes

- Script parse validation passed.
- Required distribution diagnostic output families exist under the approved alpha-validation root.
- Run status is `completed`; output row counts are nonzero for monthly return panel, distribution summary, active-return summary, upside/downside capture, tail-state summary, Q-Q data, and scatter data.
- Monthly return panel includes `benchmark`, `lowvol`, and `csi` strategy groups.
- Low-volatility Q1 and Q5 are represented; Q2-Q4 are also present.
- Selected CSI strategy rows are represented across `dynamic_csi` and `permanent_csi`, 0 and 20 bps, and all four universes.
- Active returns are finite for matched non-benchmark strategy months and are matched by date and `index_id`.
- Upside/downside capture has nonzero up and down month counts.
- Tail-state output has nonzero benchmark-tail month counts.
- Q-Q and scatter outputs are data tables only; no chart/image files were created.
- Run-status flags confirm no CSI construction rerun, low-volatility rerun, model training, chart creation, thesis/presentation edit, staging, commit, or push.
- Report wording remains neutral and avoids final causal claims.

## next_recommended_role

master
