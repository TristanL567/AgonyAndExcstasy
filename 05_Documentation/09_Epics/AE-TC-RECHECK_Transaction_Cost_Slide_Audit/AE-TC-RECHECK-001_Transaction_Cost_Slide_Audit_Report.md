# AE-TC-RECHECK-001 Transaction Cost Slide Audit Report

## Scope

Epic: AE-TC-RECHECK
Ticket: AE-TC-RECHECK-001
Branch: development-slides

This audit independently rechecked the Draft slide:

`Impact of transaction costs: the winners are unchanged`

No presentation, model, index, evaluation, sensitivity, pipeline, or data-output files were edited or regenerated. The only write target was the AE-TC-RECHECK evidence and ticket metadata area.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\multi-master-dispatch.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\code-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\backtest-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\clean-commit\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\discipline\operating-discipline.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\quant-backtesting\sections\transaction-costs-and-execution.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\quant-backtesting\sections\benchmark-and-statistical-evidence.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\quant-backtesting\sections\backtest-design.md`

## Exact Slide Source

The slide values are hardcoded in:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/Draft/FinalPresentation_TristanLeiter_h11815352_Draft.Rnw`

The source selection file used for the slide row identities is:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`

The unchanged-winner claim is also supported by:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/transaction_cost_robustness_summary.csv`

The values were recomputed from the underlying model-specific OOS performance files, not from the slide text:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/index_performance_gross_and_net_by_tc.csv`

Related turnover and transaction-cost audit evidence inspected:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/turnover_summary.csv`
- `05_Documentation/09_Epics/AE-TC-AUDIT_Transaction_Cost_Audit/AE-TC-AUDIT-001_Transaction_Cost_Audit_Report.md`
- `05_Documentation/09_Epics/AE-TC-AUDIT_Transaction_Cost_Audit/AE-TC-AUDIT-001_best_strategy_cost_drag_summary.csv`
- `05_Documentation/09_Epics/AE-TC-AUDIT_Transaction_Cost_Audit/AE-TC-AUDIT-001_transaction_cost_math_check.csv`

## Recompute Method

For each slide row and each transaction-cost level 5, 10, and 20 bps:

1. Read the OOS strategy row from the model-specific `index_performance_gross_and_net_by_tc.csv`.
2. Read the OOS market-weight benchmark row for the same universe and cost level.
3. Compute active alpha in percentage points as:

`active alpha pp = 100 * (strategy net annualized geometric return - benchmark net annualized geometric return)`

4. Compare the recomputed value rounded to two decimals against the displayed slide value.
5. Compute expected annual cost drag approximation as:

`annualized gross turnover * transaction_cost_bps / 10000 * 100`

This is an annual percentage-point approximation. The source column `total_transaction_cost_return_drag` is a period-level accumulated return-drag quantity and is not the same as annualized drag.

## Recomputed Values

All 24 displayed values pass under normal two-decimal rounding.

| Track | Universe | Strategy | Recomputed active alpha pp at 5/10/20 bps | Displayed | Status |
|---|---|---|---:|---:|---|
| Temporary CSI | Total | AG Base Dataset; Youden 3y | 0.429253 / 0.427190 / 0.423064 | 0.43 / 0.43 / 0.42 | PASS |
| Temporary CSI | Large | AG Base Dataset; Youden 3y | 0.152658 / 0.152220 / 0.151344 | 0.15 / 0.15 / 0.15 | PASS |
| Temporary CSI | Mid | AG Base Dataset; FPR5 5y | 0.507162 / 0.507501 / 0.508178 | 0.51 / 0.51 / 0.51 | PASS |
| Temporary CSI | Small | AG Exp. Dataset + VAE; Youden 3y | 0.630789 / 0.625631 / 0.615321 | 0.63 / 0.63 / 0.62 | PASS |
| Permanent CSI | Total | AG Exp. Dataset + VAE; FPR5 | 0.265975 / 0.265926 / 0.265828 | 0.27 / 0.27 / 0.27 | PASS |
| Permanent CSI | Large | AG Exp. Dataset + VAE; FPR5 | 0.228675 / 0.229087 / 0.229912 | 0.23 / 0.23 / 0.23 | PASS |
| Permanent CSI | Mid | AG Base Dataset; FPR5 | 0.738614 / 0.738673 / 0.738791 | 0.74 / 0.74 / 0.74 | PASS |
| Permanent CSI | Small | AG Latent Dataset (VAE); FPR3 | 0.321162 / 0.321344 / 0.321707 | 0.32 / 0.32 / 0.32 | PASS |

Full row-level evidence is in `AE-TC-RECHECK-001_recomputed_slide_values.csv`.

## Selection Check

The source file `best_by_track_index_cost.csv` contains best rows selected by `transaction_cost_bps`. That means the source selection is independently evaluated at each cost level.

For this slide, the selected strategy is identical at 5, 10, and 20 bps for every track/universe row. Therefore, the slide effectively compares the same selected strategy across the three displayed costs, even though the source selection file is cost-specific.

The unchanged-winner claim is also supported by `transaction_cost_robustness_summary.csv`, where `winner_changed_0_to_20_bps` is `False` for all eight selected track/universe combinations.

## Monotonicity Check

Strategy net returns weakly decline as transaction costs increase for all eight selected rows.

Active alpha is not monotone for four rows:

- Temporary CSI / Mid
- Permanent CSI / Large
- Permanent CSI / Mid
- Permanent CSI / Small

These are flagged in `AE-TC-RECHECK-001_turnover_drag_checks.csv` as `QUALIFIED_PASS`, not as numeric failures. The reason is that the slide's active alpha is measured against the costed benchmark. When the selected strategy has slightly lower annualized gross turnover than the benchmark, the benchmark net return falls slightly more as costs rise, so benchmark-relative active alpha can increase even while the strategy's own net return declines.

Example: Permanent CSI / Small has annualized gross turnover 0.757282 versus benchmark turnover 0.762737. At 20 bps this implies about 0.151456 pp annual drag for the strategy versus 0.152547 pp for the benchmark, so active alpha rises slightly while strategy net return still declines.

## Why The Changes Are Small

The small 5/10/20 bps changes are plausible and source-supported:

- Transaction costs apply only to traded weight, not to the whole portfolio every month.
- The implementation charges `turnover_gross * transaction_cost_bps / 10000`.
- A 20 bps cost on 100% annualized gross turnover is only about 0.20 pp annual drag.
- Total and large-cap selected strategies have annualized turnover near 0.07-0.13, so expected 20 bps annual drag is only about 0.01-0.03 pp.
- Mid and small-cap rows have higher turnover and larger return drops, but rounding to two decimals still hides much of the movement.
- Active alpha is versus a costed benchmark, so relative turnover determines whether active alpha falls or rises slightly.

## Conclusion

The slide values are correct under two-decimal rounding. No corrected numeric values are required.

The human concern is valid as an interpretability concern: active alpha does not always visibly decline because the benchmark is also net of transaction costs. If this slide is edited in a future presentation ticket, the label should be clarified to something like:

`Active alpha vs net benchmark (5/10/20 bps)`

No presentation edit was made in this ticket.
