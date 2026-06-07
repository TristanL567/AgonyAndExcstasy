# AE-TC-RECHECK-002 Validation Report

status: approved

ticket_id: AE-TC-RECHECK-002

validator_role: ds-validator / code-validator scope gate

## Validation Summary

- Required evidence files exist.
- All 24 requested active-alpha values were recomputed against the zero-cost benchmark definition.
- Corrected values use `benchmark_gross_annualized_geometric_return` as the zero-cost market-cap benchmark and `net_annualized_geometric_return` as the strategy return after transaction costs.
- All eight fixed selected strategies are weakly declining from 5 to 10 to 20 bps under the corrected definition.
- Selected OOS winners remain unchanged because subtracting a zero-cost benchmark return, which is constant within each track/universe/cost slice, preserves the net-return ranking.
- No presentation file was edited for this ticket.
- No `03_Data_Output/**` file was edited for this ticket.
- No model, index construction, evaluation, sensitivity, or pipeline script was run.

## Evidence Reviewed

- `AE-TC-RECHECK-002_Zero_Cost_Benchmark_Recompute_Report.md`
- `AE-TC-RECHECK-002_corrected_slide_values.csv`
- `AE-TC-RECHECK-002_monotonicity_checks.csv`
- `AE-TC-RECHECK-002_worker_completion_report.md`
- `epics/AE-TC-RECHECK/tickets/AE-TC-RECHECK-002.yaml`

## Mechanical Checks

- Artifact existence: pass.
- Corrected-value row count: 24.
- Cost levels represented: 5, 10, 20 bps.
- Track/universe coverage: Temporary CSI and Permanent CSI, each with Total, Large, Mid, and Small.
- Monotonicity rows: 8.
- All monotonicity flags: pass.
- All winner-unchanged flags: pass.
- Scope validation: pass with `validate_ticket_scope.py` using a temporary markdown frontmatter envelope equivalent to the ticket YAML.
- Staged file count: 8.
- Staged protected paths under `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, `04_Research/**`, `06_Presentations/**`, and `07_CloudComputing/**`: none.
- `git diff --cached --check`: pass.

Compatibility note: `validate_ticket_scope.py` accepts markdown frontmatter tickets and exact or directory-prefix patterns. The required ticket artifact is YAML and uses `/**` glob notation, so the validator command was run with an equivalent temporary markdown envelope using trailing-slash directory prefixes.

## Validator Decision

approved

The ticket is ready for scoped commit with message:

`AE-TC-RECHECK AE-TC-RECHECK-002 docs: recompute alpha against zero-cost benchmark`
