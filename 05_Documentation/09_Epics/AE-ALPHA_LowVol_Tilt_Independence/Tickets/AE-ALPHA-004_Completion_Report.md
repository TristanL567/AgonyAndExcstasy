# AE-ALPHA-004 Completion Report

## status

completed

## summary

Created `01_Code/pipeline/11F_LowVol_Performance_Comparison.R` to compute common performance metrics for low-volatility quintiles and the CRSP-like benchmark, and to extract existing CSI strategy performance from `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`.

The script reads existing AE-ALPHA-003 low-volatility outputs only. It does not rerun low-volatility construction, CSI index construction, or model training. It writes neutral performance and comparison tables under the approved `alpha_validation` output root.

## changed_files

- `01_Code/pipeline/11F_LowVol_Performance_Comparison.R`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-004_Completion_Report.md`

## generated_outputs

- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/lowvol_performance_summary.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/lowvol_performance_summary.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/benchmark_performance_summary.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/benchmark_performance_summary.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/csi_performance_extract.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/performance/csi_performance_extract.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/benchmark_vs_lowvol_quintiles.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/benchmark_vs_lowvol_quintiles.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/csi_vs_lowvol_headline.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/csi_vs_lowvol_headline.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/lowvol_q1_minus_q5_spread.rds`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/comparisons/lowvol_q1_minus_q5_spread.csv`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/performance_run_status.csv`

## headline_row_counts

- Low-volatility performance rows: 320
- Benchmark performance rows: 16
- CSI performance extract rows: 6,848
- Benchmark versus low-volatility quintiles rows: 320
- CSI versus low-volatility headline rows: 128
- Low-volatility Q1 minus Q5 spread rows: 64
- CSI source performance files read: 11

## available_universes

- `large_cap`
- `mid_cap`
- `small_cap`
- `total_market`

## transaction_cost_settings_present

- Low-volatility: `0|5|10|20` bps
- Benchmark: `0` bps
- CSI extract: `0|5|10|20` bps, preserved from source outputs

## metric_sanity_checks

- Low-volatility performance includes quintiles `Q1|Q2|Q3|Q4|Q5`.
- Low-volatility max drawdown finite rows: 320 of 320.
- Low-volatility ES 2.5 percent finite rows: 320 of 320.
- Benchmark max drawdown finite rows: 16 of 16.
- Benchmark ES 2.5 percent finite rows: 16 of 16.
- CSI max drawdown finite rows: 6,848 of 6,848.
- CSI ES 2.5 percent finite rows: 6,848 of 6,848.

## verification

- `git status --short --branch`
  - Branch: `development-slides`
  - Existing unrelated dirty files were present before this work, including `.gitignore` and presentation files.
  - New ticket files from this work are the script and this completion report.
- `& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11F_LowVol_Performance_Comparison.R')"`
  - Passed.
- `& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11F_LowVol_Performance_Comparison.R`
  - Passed.
  - Console row counts: low-volatility 320, benchmark 16, CSI extract 6,848.
- Required output files under `alpha_validation/performance` and `alpha_validation/comparisons`
  - Present.

## known_caveats

- The requested implementation spec file `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_LowVol_Implementation_Spec.md` was not present at the specified path during this worker run.
- The requested AE-ALPHA-003 completion report was not present at `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-003_Completion_Report.md` during this worker run.
- `01_Code/pipeline/11E_LowVolatility_Quintiles.R` was not present in the working tree, but AE-ALPHA-003 output status references it and the required low-volatility output files were present and used.
- Low-volatility and benchmark metrics are computed directly from monthly returns using 11C-equivalent formulas and `RF_ANNUAL = 0.03`.
- CSI metrics are extracted from existing `index_performance_gross_and_net_by_tc.rds` files and not recomputed.
- The comparison tables are neutral quantitative tables only; no final interpretation prose or charts were created.

## scope_controls

- No files under `02_Data_Input/**` were modified.
- Existing CSI outputs under `03_Data_Output/7_IndexConstructionValidation/**` were not modified.
- No low-volatility construction was rerun.
- No CSI index construction was rerun.
- No model training was run.
- No thesis files were edited.
- No presentation files were edited by this worker.
- No staging, commit, or push was performed.

## validator_result

approved

Blocking validator checks performed:

- `01_Code/pipeline/11F_LowVol_Performance_Comparison.R` parses successfully.
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/performance_run_status.csv` reports `status=completed`.
- Required performance and comparison files exist under `alpha_validation/performance` and `alpha_validation/comparisons`.
- Low-volatility performance contains `Q1|Q2|Q3|Q4|Q5` and transaction-cost levels `0|5|10|20`.
- Benchmark performance contains transaction-cost level `0`.
- CSI extract contains transaction-cost levels `0|5|10|20`, preserving source output levels.
- Low-volatility, benchmark, and CSI outputs all include finite max drawdown and ES 2.5 percent rows for every performance row.
- Universes represented: `large_cap|mid_cap|small_cap|total_market`.
- Periods represented: `full|insample|oos|test`.
- `git diff --cached --name-only` returned empty; no files are staged.
- Generated AE-ALPHA-004 outputs are ignored under `.gitignore` rule `03_Data_Output/**`.
- This completion report is ignored under `.gitignore` rule `05_Documentation/**`.
- Existing unrelated presentation diffs remain visible in the worktree and were not touched by this ticket.

## next_recommended_role

master
