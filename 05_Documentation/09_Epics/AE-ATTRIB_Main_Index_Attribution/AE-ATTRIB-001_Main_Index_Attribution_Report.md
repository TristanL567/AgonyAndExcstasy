# AE-ATTRIB-001 Main Index Attribution Report

## Scope

This ticket computes a realized active attribution for the existing main index-construction outputs. It does not edit slides, code, model outputs, index outputs, or any data under `03_Data_Output/**`.

- Branch: `Development`
- Input root: `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`
- Output folder: `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/`
- Models: `raw`, `fund`, `latent_raw`, `raw_plus_latent`
- Tracks: temporary CSI and permanent CSI
- Periods represented: full, insample, oos, test
- Transaction costs represented: 0, 5, 10, 20 bps

## Accounting Definition

The realized attribution uses the ticket's economic interpretation:

`realized alpha = strategy net geometric return - benchmark gross geometric return`

and reconciles each row as:

`TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha`

where:

- `TP exclusion gain` is the realized benefit from excluding predicted CSI firms that later had the adverse label.
- `FP exclusion cost` is the realized opportunity cost from excluding predicted CSI firms that did not have the adverse label.
- `retained-stock reweighting effect` is the active return effect on retained names after portfolio renormalization. This is where retained FN/TN names can affect realized alpha.
- `transaction-cost effect` is the strategy's own net-minus-gross return effect at the selected bps level, so it is non-positive.
- `compounding/geometric adjustment` is the explicit residual required because source category diagnostics are independently annualized while alpha is full-portfolio geometric return minus benchmark geometric return.

## Why The Previous Four-Column FP/FN/TP/TN View Was Misleading

The prior four-category decomposition was useful diagnostically, but it implied a direct additive attribution from FP, FN, TP, and TN labels to geometric alpha. That is not what the retained source files measure. The source `error_cost_decomposition_by_crsp_universe.csv` files annualize category-level monthly return differences independently. A full strategy alpha is instead the difference between two full-portfolio annualized geometric returns. Independent category compounding is not additive to full-portfolio geometric alpha.

FN and TN rows are therefore not forced into direct realized alpha as classification buckets. They are reported separately as diagnostics. Their economic effect enters realized alpha only through the retained-stock reweighting term, because retained names receive active weights after exclusions and portfolio renormalization.

## Exactness And Limitations

The attribution reconciles exactly row by row by construction through the named compounding/geometric adjustment. The TP and FP terms are sourced directly from existing category diagnostics. The retained-stock reweighting term is reconstructed as the sum of retained FN and TN category active return effects, which is the best available retained-stock active-weight measure in the compact source files.

This is a defensible reconstructed attribution, not a full Shapley or log-return attribution. The available compact files do not retain all monthly category paths needed to allocate the geometric interaction back into TP/FP/retained effects without changing methodology.

## Coverage

- Configuration-level attribution rows: 5120
- FN/TN diagnostic rows: 1280
- Reconciliation rows passing: 5120 / 5120
- Missing main configuration files: 0

No missing main configurations were found for the four model folders under `nonraw_index_suite/raw`, `fund`, `latent_raw`, and `raw_plus_latent`.

## Headline Temporary CSI Findings

At 10 bps, the best OOS realized alpha by universe is:

- large_cap: Base Dataset youden_3yr alpha 0.14pp; largest absolute component FP exclusion cost
- mid_cap: Base Dataset fpr5_5yr alpha 0.39pp; largest absolute component retained-stock reweighting
- small_cap: Exp. Dataset + VAE youden_3yr alpha 0.55pp; largest absolute component FP exclusion cost
- total_market: Base Dataset youden_3yr alpha 0.42pp; largest absolute component FP exclusion cost

Temporary CSI outperformance is generally driven by a mix of retained-stock reweighting and the geometric adjustment, with FP exclusion costs often offsetting TP exclusion gains. This supports the interpretation that economic outperformance is not simply a count of correctly excluded bad firms; it also depends on which retained stocks absorb the active weight.

## Headline Permanent CSI Findings

At 10 bps, the best OOS realized alpha by universe is:

- large_cap: Exp. Dataset + VAE fpr5_permanent alpha 0.22pp; largest absolute component retained-stock reweighting
- mid_cap: Base Dataset fpr5_permanent alpha 0.62pp; largest absolute component retained-stock reweighting
- small_cap: Latent Dataset (VAE) fpr3_permanent alpha 0.24pp; largest absolute component retained-stock reweighting
- total_market: Exp. Dataset + VAE fpr5_permanent alpha 0.26pp; largest absolute component retained-stock reweighting

Permanent CSI has smaller direct TP gains because adverse permanent events are rare. The strongest realized alpha rows are mostly explained by retained-stock reweighting plus geometric adjustment, with fixed-FPR rules limiting false-positive exclusion costs.

## Transaction-Cost Interpretation

Transaction costs are represented at 0, 5, 10, and 20 bps. The transaction-cost effect is always the strategy net return minus strategy gross return, so it is zero or negative. Across the main configurations, costs reduce realized alpha mechanically but do not change the conceptual attribution: exclusion and retained-stock effects still explain the gross active return, while the transaction-cost effect isolates implementation drag.

## Files Created

- `AE-ATTRIB-001_config_level_attribution.csv`
- `AE-ATTRIB-001_realized_attribution_summary.csv`
- `AE-ATTRIB-001_fn_tn_diagnostics.csv`
- `AE-ATTRIB-001_reconciliation_checks.csv`
- `AE-ATTRIB-001_validation_report.md`

## Protected Path Statement

No files under `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, `06_Presentations/**`, or `07_CloudComputing/**` were modified. No model, index, sensitivity, evaluation, or pipeline scripts were run.
