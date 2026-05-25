# AE-SLIDE24-005 - 84 Miss Reason Diagnostic

Date: 2026-05-25

## Decision

Existing artifacts are insufficient to produce a sourced reason breakdown for
all 84 remaining CRSP `572-574` misses without rerunning or implementing a new
diagnostic.

The current source-of-truth overlap artifact is:

- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`

It supports the current aggregate result:

| Scope | Firms in sample | Detected | Missed | Detection rate |
| --- | ---: | ---: | ---: | ---: |
| CRSP `572-574` bankruptcy-related range | 629 | 545 | 84 | 86.65% |
| CRSP `574` bankruptcy / declared insolvent | 548 | 513 | 35 | 93.61% |
| Implied non-`574` portion of `572-574` | 81 | 32 | 49 | 39.51% |

The 49 non-`574` misses are derived by subtracting the `574` row from the
aggregate `572-574` row. No current firm-level revised overlap artifact was
found that assigns reasons to those 49 firms.

## Available Sourced Reason Table

The available reason detail applies only to the narrower `574` subset:

- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_missed_574_reason_summary.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_missed_574_firm_detail.csv`

| Miss reason | Firms | Scope |
| --- | ---: | --- |
| `no_C80_drawdown_before_574` | 33 | Missed CRSP `574` only |
| `C80_trigger_censored_but_574_not_within_T_window` | 1 | Missed CRSP `574` only |
| `C80_trigger_recovered_and_574_after_T_window` | 1 | Missed CRSP `574` only |
| Total classified by existing reason table | 35 | Missed CRSP `574` only |

This table should not be presented as a reason breakdown for all 84 missed
CRSP `572-574` firms.

## Inspected But Not Suitable For The Revised 84

The older grid diagnostic exists here:

- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_firm_detail.csv`

For base grid `C080_M020_T018` and `bankruptcy_572_574`, it contains 629 rows,
but its counts do not match the current revised overlap result:

| Field from old grid detail | Count |
| --- | ---: |
| Rows | 629 |
| Detected after confirmation | 151 |
| Missed after confirmation | 478 |
| Detected after trigger | 485 |
| Missed after trigger | 144 |

Because these counts do not reproduce the current 545 detected / 84 missed
revised result, this file should be treated as historical grid-detail evidence,
not as the reason source for the current revised misses.

## Recommendation

If the deck needs a full reason breakdown for all 84 misses, open a separate
diagnostic implementation ticket to generate a current firm-level revised
`572-574` missed-detail table. That diagnostic should preserve the existing
classification method and classify misses against the retained CSI-trigger
rule, rather than changing labels or treating CRSP `572-574` as an independent
default label.
