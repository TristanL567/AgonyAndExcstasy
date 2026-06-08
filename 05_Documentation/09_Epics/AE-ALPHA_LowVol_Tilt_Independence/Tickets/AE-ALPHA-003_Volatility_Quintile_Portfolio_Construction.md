# AE-ALPHA-003 Volatility Quintile Portfolio Construction

## master_agent_initial_instructions

Act as the Master Agent under the AEGIS-style workflow. You coordinate only; do not implement worker tasks yourself. Route this ticket to a worker and then to a blocking validator. The validator is blocking by default. After validation, return a concise completion report to the human user.

One ticket only. Do not expand scope into performance headline interpretation, CSI comparison tables, characteristic diagnostics, overlap diagnostics, thesis edits, or presentation edits.

## ticket_id

`AE-ALPHA-003`

## epic

`AE-ALPHA`

## goal

Implement and run the low-volatility quintile portfolio builder according to `AE-ALPHA_LowVol_Implementation_Spec.md`. Produce volatility signals, quintile memberships, target weights, monthly gross/net returns, turnover, and transaction-cost drag for `Q1` through `Q5`.

This ticket creates the low-volatility portfolio data needed for later performance and CSI comparison tickets. It does not yet interpret performance.

## dependencies

- `AE-ALPHA-001` completed and validator-approved.
- `AE-ALPHA-002` completed and validator-approved.
- Implementation spec exists:
  - `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_LowVol_Implementation_Spec.md`
- Required inputs exist:
  - `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
  - `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds`
  - `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds`

## allowed_areas

May create/edit code only under:

- `01_Code/pipeline/**`

May create generated alpha-validation outputs only under:

- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`

May create/update ticket reports only under:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/**`

Read-only inspection allowed under:

- `01_Code/**`
- `02_Data_Input/**`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**`

## must_not_touch

- Do not edit existing CSI index outputs under `03_Data_Output/7_IndexConstructionValidation/**`.
- Do not edit data inputs under `02_Data_Input/**`.
- Do not edit thesis files.
- Do not edit presentation files.
- Do not run model training.
- Do not rerun CSI index construction.
- Do not compute or write final headline performance/comparison interpretation tables; leave those to AE-ALPHA-004/005.
- Do not modify `C:\Users\Tristan Leiter\Documents\MT`.
- Do not modify `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not stage, commit, or push.

## requirements

1. Read and follow:
   - `AE-ALPHA_LowVol_Implementation_Spec.md`
   - `AE-ALPHA_Epic.md`
2. Create a dedicated low-volatility quintile construction script under `01_Code/pipeline/**`.
   - Recommended name: `11E_LowVolatility_Quintiles.R`
   - It may source existing `config.R` and reuse local 11C-style helper logic where appropriate.
   - Do not modify `11C_IndexConstruction_Revised.R` unless unavoidable; prefer a dedicated script.
3. Use quarterly target formation as the headline cadence.
4. Use `ret_adj` from `prices_monthly.rds`.
5. Compute trailing total volatility using:

   ```text
   sigma_i,qdate = sd(ret_adj_i over up to 60 prior monthly observations with date < qdate)
   ```

   Requirements:
   - minimum 24 valid prior monthly returns;
   - no look-ahead;
   - non-finite returns treated as missing for the signal;
   - no annualization needed for sorting.

6. For each `qdate` and `index_id`, assign eligible securities into five equal-count quintiles:
   - `Q1` lowest volatility;
   - `Q5` highest volatility;
   - deterministic tie-breaking by volatility, capitalization, then `permno`;
   - quintiles formed separately within each `qdate` and `index_id`.
7. Build target weights within each quintile using positive capitalization from the quarterly constituent source:

   ```text
   w_i,qdate^Qk = cap_i,qdate / sum_j_in_Qk cap_j,qdate
   ```

8. Compute monthly drifted portfolio returns for each quintile using the same holding-window convention as 11C:
   - `date > qdate`
   - `date <= next_qdate`
   - drift holdings monthly using realized `ret_adj`;
   - recognize delisting-applied returns but do not carry forward delisted holdings if `dlret_applied` indicates that behavior is needed for 11C consistency.
9. Compute turnover at rebalance events against drifted pre-trade holdings:

   ```text
   turnover_buy = sum(max(w_target - w_pre_trade, 0))
   turnover_sell = sum(abs(min(w_target - w_pre_trade, 0)))
   turnover_gross = turnover_buy + turnover_sell
   turnover_one_way = 0.5 * turnover_gross
   ```

10. Compute net returns for transaction-cost settings:
    - `0` bps diagnostic;
    - `5` bps;
    - `10` bps;
    - `20` bps.

    Formula:

    ```text
    transaction_cost_return_drag = turnover_gross * transaction_cost_bps / 10000
    net_return = gross_return - transaction_cost_return_drag
    ```

11. Write generated outputs under:

    `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/`

    Required file families:
    - `inputs_manifest/lowvol_inputs_manifest.csv`
    - `volatility_quintiles/lowvol_signal_quintile_assignments.{rds,csv}`
    - `weights/lowvol_target_weights.{rds,csv}`
    - `returns/lowvol_monthly_returns_gross_and_net_by_tc.{rds,csv}`
    - `turnover_costs/lowvol_turnover_by_month.{rds,csv}`
    - `turnover_costs/lowvol_turnover_summary.{rds,csv}`
    - `reports/lowvol_run_status.csv`

12. Output identifiers must include enough fields for later joins:
    - `index_id`
    - `index_name`
    - `qdate` or `rebalance_date`
    - `date` where monthly
    - `quintile`
    - `portfolio_id`
    - `permno` where security-level
    - `transaction_cost_bps` where return-level
13. Produce a completion report with:
    - files created/edited;
    - output row counts;
    - quintile count checks;
    - target-weight sum checks;
    - return-date coverage;
    - transaction-cost settings present;
    - known caveats.

## non_goals

- No CSI reruns.
- No model training.
- No final performance headline table.
- No CSI-versus-low-vol interpretation.
- No characteristic tilt diagnostics.
- No overlap diagnostics.
- No charts.
- No thesis edits.
- No presentation edits.
- No commits.

## acceptance_criteria

The ticket is complete only if:

- A dedicated low-volatility quintile construction script exists under `01_Code/pipeline/**`.
- The script parses successfully.
- The script runs successfully.
- All required output file families exist under `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/**`.
- Quintile target weights sum to approximately `1` by `qdate`, `index_id`, and `quintile`.
- Quintile membership counts are approximately equal by `qdate` and `index_id` where eligible count permits.
- Monthly return outputs contain `0`, `5`, `10`, and `20` bps transaction-cost settings.
- Turnover values are non-negative.
- No generated outputs are written outside the approved alpha-validation root.
- No existing CSI output files are modified.
- No data inputs are modified.
- Completion report exists and states no staging, commit, push, thesis edit, or presentation edit occurred.

## manual_verification_required

Yes. The Master Agent must route the worker result through a blocking validator.

## verification_commands

Suggested worker commands:

```powershell
git status --short --branch
Rscript -e "parse('01_Code/pipeline/11E_LowVolatility_Quintiles.R')"
Rscript 01_Code/pipeline/11E_LowVolatility_Quintiles.R
```

If `Rscript` is unavailable, use the installed R executable path, for example:

```powershell
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' -e "parse('01_Code/pipeline/11E_LowVolatility_Quintiles.R')"
& 'C:\Program Files\R\R-4.5.2\bin\Rscript.exe' 01_Code/pipeline/11E_LowVolatility_Quintiles.R
```

Suggested validator checks:

```powershell
git status --short --branch
git diff --stat
Test-Path 01_Code/pipeline/11E_LowVolatility_Quintiles.R
Get-ChildItem 03_Data_Output/3_Modelling_Results/Necessary/alpha_validation -Recurse
```

The validator should also run small read-only R checks on generated outputs to confirm:

- target weights sum to approximately `1`;
- required transaction-cost bps are present;
- turnover values are non-negative;
- output identifiers are present.

## completion_report_required

Yes.

## completion_report_format

Return a concise report with:

- `status`
- `summary`
- `changed_files`
- `generated_outputs`
- `verification`
- `known_caveats`
- `validator_result`
- `next_recommended_role`

## next_ticket_preview

If this ticket passes validation, the next ticket should be:

`AE-ALPHA-004 Performance Metrics and Headline Tables`

It should compute the agreed performance metrics for benchmark, CSI, and volatility quintiles, but should still avoid final thesis interpretation until AE-ALPHA-005/009.
