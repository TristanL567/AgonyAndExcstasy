# AE-PRES-DRAFT-VALIDATE-001 Validation Report

## Validator decision

- Status: completed
- Decision: APPROVED FOR SCOPED COMMIT
- Timestamp: 2026-06-07T16:36:32+02:00

## Required checks

| Check | Result | Evidence |
|---|---|---|
| No presentation files modified by this ticket | PASS | Shared worktree contains unrelated dirty presentation files; they are outside this ticket and must remain unstaged |
| No `03_Data_Output/**` files modified | PASS | Source data read-only inspection only |
| No forbidden scripts run | PASS | No compile/model/index/evaluation/sensitivity/pipeline scripts run |
| Slide 25 deep dive completed | PASS | `AE-PRES-DRAFT-VALIDATE-001_slide25_deep_dive.csv` |
| Checked values include displayed/source/path/status | PASS | `AE-PRES-DRAFT-VALIDATE-001_slide_number_checks.csv` and slide 25 deep dive CSV |
| Slides 20-28 covered | PASS | Report and slide checks cover visible Draft PDF slides 20-28 |
| Presentation/source-map skill availability stated | PASS | Report states no dedicated AEGIS presentation/source-map validation skill was found |

## Findings

Slide 25 passes: displayed active-alpha values match source values under rounding and the unchanged ranking claim is source-backed.

Blocking issues for the audit artifacts: none.

Content findings for planner handoff:

- Slides 21-22 have stale OOS alpha and some stale OOS benchmark/strategy values relative to current source data.
- Slide 28 contains a material source-support mismatch: it says `permanent-CSI iterations`, while the supporting sensitivity data is temporary CSI only.
- Slide 20 mixes claims from multiple later slides and inherits stale OOS alpha values.

## Scope validation

Allowed write areas:

- `05_Documentation/09_Epics/AE-PRES-DRAFT-VALIDATE_Draft_Number_Audit/**`
- `epics/AE-PRES-DRAFT-VALIDATE/**`

The validator approves committing only those paths.

## Dirty worktree note

`git status --short` shows unrelated dirty entries, including presentation files under `06_Presentations/**`. They were not edited for this ticket and are not approved for staging or commit under AE-PRES-DRAFT-VALIDATE-001. Commit scope is limited to the evidence directory and `epics/AE-PRES-DRAFT-VALIDATE/**`.
