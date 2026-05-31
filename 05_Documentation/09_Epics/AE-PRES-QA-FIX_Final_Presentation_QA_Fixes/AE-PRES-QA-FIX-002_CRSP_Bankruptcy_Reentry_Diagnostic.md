# AE-PRES-QA-FIX-002 CRSP Bankruptcy Reentry Diagnostic

## Scope

This ticket investigates whether firms categorized as bankrupt or insolvent by CRSP delisting indicators later reentered the CRSP-like index universe. It is diagnostic only: no label, methodology, input, output, pipeline, model, index, or presentation files were modified.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `a6e9a56 AE-PRES-QA-FIX-001: explain oos unresolved labels`

## CRSP Code Basis

The repository's accepted temporary-CSI terminal-failure path uses CRSP delisting codes `572:574`:

- `01_Code/pipeline/config.R` defines `CSI_TERMINAL_FAILURE_CODES <- 572:574`.
- `01_Code/pipeline/05A_Dynamic_CSI_Label.R` uses those codes as bankruptcy-related terminal failures before confirmation.
- `01_Code/pipeline/13b_Dynamic_CSI_Delisting_Detection_Revised_Temporary_CSI_572_574.R` labels:
  - `574` as `CRSP 574 bankruptcy / declared insolvent`.
  - `572-574` as `CRSP 572-574 bankruptcy-related range`.

The local code and documentation therefore support using `572:574` as the repository's bankruptcy/insolvency-related range. The local source does not include the official CRSP codebook text for each individual code. If exact official wording for code `573` is required for publication, request the CRSP delisting-code manual or WRDS codebook as a separate human-supplied reference.

## Data Sources Inspected

- `02_Data_Input/01_CRSP/Necessary/delisting_raw.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds`
- `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Labels/labels_model_ready.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/csi_events_base.rds`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_firm_detail.csv`

## Method

1. Select all `delisting_raw.rds` rows with `dlstcd %in% 572:574` and non-missing `dlstdt`.
2. Match each bankrupt/insolvent PERMNO to the CRSP-like index constituent file.
3. Test two reentry definitions:
   - Same-PERMNO reentry: the same PERMNO appears in any CRSP-like index constituent row after the bankruptcy delisting date.
   - Same-PERMCO reentry: the pre-bankruptcy PERMCO associated with the bankrupt PERMNO appears in any CRSP-like index constituent row after the bankruptcy delisting date.
4. Join temporary and permanent CSI labels to determine whether the bankrupt/insolvent firms were classified as CSI in the available label artifacts.

## Results

| Metric | Count |
|---|---:|
| Bankruptcy-related delisting events, CRSP `572:574` | 1,056 |
| Unique bankruptcy-related PERMNOs | 1,056 |
| Code `572` events | 0 |
| Code `573` events | 107 |
| Code `574` events | 949 |
| Same-PERMNO index reentries after bankruptcy date | 0 |
| Same-PERMCO index reentries after bankruptcy date | 0 |
| Any same-PERMNO or same-PERMCO reentry evidence | 0 |
| Temporary-CSI `y=1` among bankruptcy PERMNOs | 537 |
| Temporary-CSI `y=1` before or at bankruptcy year | 537 |
| Temporary terminal-failure event PERMNOs | 429 |
| Permanent-CSI `y=1` among bankruptcy PERMNOs | 479 |

## Interpretation

Within the local CRSP-like index universe and the repository's accepted `572:574` bankruptcy-related rule, there is no evidence that bankrupt/insolvent firms later reentered the CRSP-like index after the bankruptcy delisting date.

The practical implication is that this diagnostic does not currently justify a methodology change or a special exclusion override for recovered bankrupt/insolvent firms. The data show no post-bankruptcy reentry cases under same-PERMNO or same-PERMCO matching.

## Outputs Created

- `AE-PRES-QA-FIX-002_bankruptcy_reentry_summary.csv`
- `AE-PRES-QA-FIX-002_crsp_code_distribution.csv`
- `AE-PRES-QA-FIX-002_bankruptcy_reentry_firm_detail.csv`
- `AE-PRES-QA-FIX-002_validation_checks.csv`

## Human Review Point

No blocker is raised for the presentation QA epic. The only optional human follow-up is whether publication requires official CRSP codebook text for code `573`. The repository already treats `572:574` as the bankruptcy-related range and explicitly labels `574` as bankruptcy / declared insolvent.

## Scope Confirmation

No `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, `06_Presentations/**`, or `07_CloudComputing/**` files were modified. No pipeline, model, index, sensitivity, SSH, or Vast.ai commands were run.
