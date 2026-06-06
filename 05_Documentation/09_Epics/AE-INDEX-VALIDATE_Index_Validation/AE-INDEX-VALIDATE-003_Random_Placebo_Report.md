# AE-INDEX-VALIDATE-003 Random Placebo Report

## Scope And Evidence

Ticket: `AE-INDEX-VALIDATE-003`

Question: test whether selected CSI strategy alpha exceeds placebo portfolios with matched exclusion intensity.

Evidence used:

- `AE-INDEX-VALIDATE-001_selected_strategy_attribution.csv`, restricted to selected OOS best-strategy rows.
- Existing `index_performance_gross_and_net_by_tc.csv` and `index_exclusion_summary_by_crsp_universe.csv` files referenced by the selected rows.
- `01_Code/pipeline/11C_IndexConstruction_Revised.R` for field semantics only.

No model training, model evaluation, index construction rerun, sensitivity script, pipeline regeneration, or presentation compile was run.

## Feasibility Finding

Exact rebalance-date random-name placebo alpha could not be computed from the allowed existing outputs alone. The saved `index_weights_by_crsp_universe.csv` files identify benchmark and strategy holdings at rebalance dates, and the saved return files provide strategy-level monthly portfolio returns. They do not provide the constituent-level monthly stock returns needed to compute returns for newly sampled random exclusion sets without rerunning or reusing 11C's input return engine.

The completed result is therefore an existing-output approximation, not an exact random-name placebo. It is still useful as a bounded diagnostic for whether the selected row beats nearby exclusion/reweighting strategies already produced by 11C.

## Approximation Used

For each selected OOS row:

- Matched period: `oos`.
- Matched track: selected row response track, temporary or permanent CSI.
- Matched universe: `total_market`, `large_cap`, `mid_cap`, or `small_cap`.
- Matched transaction cost: 10 bps, consistent with selected rows.
- Matched exclusion intensity: average OOS excluded benchmark weight and average excluded-name count from `index_exclusion_summary_by_crsp_universe.csv`.
- Placebo pool: nearest saved 11C strategy configurations in the same selected source output file, excluding the selected configuration itself.
- Draws: 1,000 deterministic bootstrap draws per selected row.
- Seeds: `20260606 + selected_row_id * 1000`.

Because the placebo pool comes from saved strategy configurations rather than newly sampled random names, the diagnostic should be read as an intensity-matched existing-output placebo, not a definitive random-exclusion null.

## Results

| track | universe | selected strategy | CSI alpha | placebo mean | placebo median | placebo p5 | placebo p95 | percentile | exceeds p95? | exceeds all? |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| temporary CSI | large_cap | fund / youden_3yr | 0.138% | -0.142% | -0.001% | -0.680% | 0.085% | 100.0% | yes | yes |
| temporary CSI | mid_cap | fund / fpr5_5yr | 0.392% | 0.191% | 0.179% | -0.003% | 0.455% | 86.9% | no | no |
| temporary CSI | small_cap | raw_plus_latent / youden_3yr | 0.545% | 0.014% | -0.015% | -0.383% | 0.516% | 100.0% | yes | yes |
| temporary CSI | total_market | fund / youden_3yr | 0.420% | -0.037% | 0.011% | -0.372% | 0.293% | 100.0% | yes | yes |
| permanent CSI | large_cap | raw_plus_latent / fpr5_permanent | 0.215% | -0.484% | 0.068% | -1.692% | 0.137% | 100.0% | yes | yes |
| permanent CSI | mid_cap | fund / fpr5_permanent | 0.623% | 0.066% | 0.108% | -0.578% | 0.699% | 66.2% | no | no |
| permanent CSI | small_cap | latent_raw / fpr3_permanent | 0.241% | -0.070% | -0.050% | -0.265% | 0.089% | 100.0% | yes | yes |
| permanent CSI | total_market | raw_plus_latent / fpr5_permanent | 0.258% | -0.361% | 0.103% | -1.293% | 0.158% | 100.0% | yes | yes |

## Interpretation

Temporary CSI:

- Large cap, small cap, and total market exceed the p95 and maximum of the matched existing-output placebo distribution.
- Mid cap is positive and above most placebo draws, but it does not exceed the p95 or maximum.
- Under this approximation, temporary CSI evidence is strongest for large cap, small cap, and total market, and weaker for mid cap.

Permanent CSI:

- Large cap, small cap, and total market exceed the p95 and maximum of the matched existing-output placebo distribution.
- Mid cap is positive but does not exceed the p95 or maximum.
- Under this approximation, permanent CSI evidence is strongest outside mid cap.

Evidence-bound conclusion:

The selected CSI rows generally compare favorably with nearby existing exclusion/reweighting strategies at similar exclusion intensity. Six of eight selected rows exceed the approximation's p95. This supports evidence for model-specific signal beyond a generic saved-strategy exclusion/reweighting benchmark in those six rows. It does not establish causality, and it does not prove superiority against a true random-name exclusion null because that exact null requires constituent-level monthly returns not present in the allowed saved outputs.

## Limitations

- This is not an exact random-name placebo alpha test.
- The saved output files do not contain constituent-level monthly return paths for newly sampled random exclusion portfolios.
- Permanent CSI rows have only three alternative strategy configurations after excluding the selected row, so their placebo distributions are especially coarse.
- Bootstrap draws are deterministic but resample a small existing-output candidate pool; they should not be interpreted as independent market simulations.

## Artifacts

- `AE-INDEX-VALIDATE-003_random_placebo_summary.csv`
- `03_Data_Output/11_IndexValidation/AE-INDEX-VALIDATE-003_random_placebo_draws_existing_output_approx.csv` local-only draw-level output
- `AE-INDEX-VALIDATE-003_worker_completion_report.md`
