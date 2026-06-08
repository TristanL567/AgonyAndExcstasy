# AE-PRES-TC-FIX-001 Slide Update Report

## Ticket

- Epic: AE-PRES-TC-FIX
- Ticket: AE-PRES-TC-FIX-001
- Branch: development-slides
- Updated slide: `Transaction-Cost Robustness`
- Target slide title text: `Impact of transaction costs: the winners are unchanged`

## AEGIS Materials Loaded

- `C:/Users/Tristan Leiter/Documents/aegis-core/AEGIS.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/epic-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/ticket-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/contracts/swarm-contract.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/execution/runbooks/multi-master-dispatch.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/master/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/model-interpreter-worker/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/code-validator/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/roles/ds-validator/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/procedures/ticket-scope-validation/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/procedures/clean-commit/SKILL.md`
- `C:/Users/Tristan Leiter/Documents/aegis-core/skills/discipline/operating-discipline.md`

No dedicated AEGIS presentation/source-map validation role or procedure was found in `aegis-core`; validation used the generic AEGIS scope, clean-commit, and validator rules plus direct Rnw/source-map checks.

## Implementation Summary

The `Transaction-Cost Robustness` slide now uses active-alpha values from:

- `05_Documentation/09_Epics/AE-TC-RECHECK_Transaction_Cost_Slide_Audit/AE-TC-RECHECK-002_corrected_slide_values.csv`
- `05_Documentation/09_Epics/AE-TC-RECHECK_Transaction_Cost_Slide_Audit/AE-TC-RECHECK-002_Zero_Cost_Benchmark_Recompute_Report.md`

Winner labels were kept unchanged. The active-alpha values now measure:

`strategy net annualized geometric return after costs - zero-cost market-cap benchmark annualized geometric return`

The slide note now states:

`Active alpha is measured versus the zero-cost market-cap benchmark; only the strategy pays transaction costs.`

## Corrected Values Applied

| Track | Universe | Winner | 5 bps | 10 bps | 20 bps |
|---|---|---|---:|---:|---:|
| Temporary CSI | Total | AG Base Dataset; Youden 3y | +0.43pp | +0.42pp | +0.41pp |
| Temporary CSI | Large | AG Base Dataset; Youden 3y | +0.15pp | +0.14pp | +0.12pp |
| Temporary CSI | Mid | AG Base Dataset; FPR5 5y | +0.45pp | +0.39pp | +0.28pp |
| Temporary CSI | Small | AG Exp. Dataset + VAE; Youden 3y | +0.59pp | +0.55pp | +0.45pp |
| Permanent CSI | Total | AG Exp. Dataset + VAE; FPR5 | +0.26pp | +0.26pp | +0.25pp |
| Permanent CSI | Large | AG Exp. Dataset + VAE; FPR5 | +0.22pp | +0.22pp | +0.20pp |
| Permanent CSI | Mid | AG Base Dataset; FPR5 | +0.68pp | +0.62pp | +0.51pp |
| Permanent CSI | Small | AG Latent Dataset (VAE); FPR3 | +0.28pp | +0.24pp | +0.16pp |

The same values are recorded in `AE-PRES-TC-FIX-001_corrected_values_applied.csv`.

## Source-Map Update

`SLIDE_DATA_SOURCES.md` row 30 now references the AE-TC-RECHECK-002 corrected value CSV and recomputation report. The source-map row states the zero-cost benchmark definition and notes that AE-TC-RECHECK-002 confirms winner rankings remain unchanged.

## Scope Notes

- No deck compilation was run.
- No generated PDF/TeX refresh was performed.
- No `03_Data_Output/**` file was modified.
- No model, index, evaluation, sensitivity, or pipeline script was run.
- Existing unrelated dirty worktree entries were left untouched.
