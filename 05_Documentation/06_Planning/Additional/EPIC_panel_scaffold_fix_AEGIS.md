# EPIC: Panel Scaffold Row-Count and Label-NA Cleanup

## Epic Goal

Clean up the firm-year panel construction so labelled modelling panels exclude phantom firm-years and represent unresolvable forward-label windows as `NA`, without losing valid positive labels or OOS inference rows.

This epic converts the earlier scaffold-fix story into AEGIS-ready tickets. The first ticket is deliberately read-only because the current story contains source-of-truth ambiguities around row counts, dynamic positive totals, and forward-window censoring rules.

## Current Risk

`01_Code/pipeline/06_Merge.R::fn_label_scaffold()` appears to create a rectangular `(permno, year)` scaffold. That can include firm-years where the firm has no observable CRSP price record, which may inflate the `y = 0` denominator.

The existing epic also proposes new `NA` rules for permanent and dynamic labels. Those rules must be validated against the actual label-generation semantics before implementation, because overly broad calendar cutoffs could remove valid negatives or OOS inference rows.

## Global Constraints

- AEGIS-CORE is reference-only. Do not edit it.
- `C:\Users\Tristan Leiter\Documents\MT` is reference-only. Do not edit it.
- One ticket at a time.
- No implementation begins until the active ticket envelope is complete.
- Validators are blocking unless the Master explicitly overrides.
- Do not delete files.
- Do not modify ignored data or documentation outside the active ticket's allowed areas.
- Preserve OOS inference rows needed for scoring.
- Preserve positive-label counts unless the ticket explicitly proves an existing count is stale and the Master accepts the new source of truth.

## Ticket Sequence

1. `AE-PANEL-001` - read-only discovery and source-of-truth validation.
2. `AE-PANEL-002` - implement observable firm-year scaffold filtering, if validated by `AE-PANEL-001`.
3. `AE-PANEL-003` - implement permanent-CSI unresolvable-window `NA` handling, if validated by `AE-PANEL-001`.
4. `AE-PANEL-004` - implement or explicitly decline dynamic-CSI additional `NA` handling, based on `AE-PANEL-001`.
5. `AE-PANEL-005` - rerun `06_Merge`, `06B_FeatureEngineering`, and `08_Split` for both tracks; capture logs.
6. `AE-PANEL-006` - regenerate descriptive-statistics CSVs affected by panel row counts.
7. `AE-PANEL-007` - summarize new counts and slide/documentation updates without editing the deck unless separately authorized.

---

# Ticket Envelope: AE-PANEL-001

## ticket_id

`AE-PANEL-001`

## goal

Validate the current panel scaffold, row counts, label counts, and forward-window censoring rules before any implementation. Determine whether the original scaffold-fix tickets are safe as written or need adjustment.

## dependencies

- Current cleaned repository on `main`.
- Existing epic: `05_Documentation/06_Planning/Additional/EPIC_panel_scaffold_fix.md`.
- Current pipeline code and local data artifacts.

## allowed_areas

Read-only inspection of:

- `01_Code/pipeline/06_Merge.R`
- `01_Code/pipeline/06B_FeatureEngineering.R`
- `01_Code/pipeline/08_Split.R`
- `01_Code/pipeline/config.R`
- Relevant local input/output artifacts needed to count rows and labels:
  - `02_Data_Input/**`
  - `03_Data_Output/**`
  - ignored local `.rds` / `.csv` artifacts already present
- Existing planning and validation docs under:
  - `05_Documentation/06_Planning/**`
  - `05_Documentation/08_Data_Paths/**`
  - `06_Presentations/**`

## must_not_touch

- Do not edit any file.
- Do not write regenerated outputs.
- Do not render slides.
- Do not run model training.
- Do not edit or read-write `C:\Users\Tristan Leiter\Documents\MT`.
- Do not edit or read-write `C:\Users\Tristan Leiter\Documents\aegis-core`.
- Do not commit.

## requirements

1. Inspect `06_Merge.R` and summarize how `fn_label_scaffold()` currently creates rows.
2. Identify the exact monthly prices artifact used by the scaffold and verify its schema.
3. Compute the rectangular scaffold row count and the observable firm-year row count using the actual monthly prices table.
4. Define observable firm-year using the available columns. Prefer at least one valid monthly `ret_adj` or `mktcap` if those columns exist; otherwise report the actual substitute columns.
5. For both `permanent_csi` and `dynamic_csi`, report current row counts for available `panel_raw.rds`, `features_raw.rds`, labels, and split artifacts.
6. For both tracks, report current `y=1`, `y=0`, and `y=NA` counts from the relevant label/panel artifacts.
7. Resolve the dynamic-track source-of-truth conflict between `8,341`, `8,440`, and `8,647` positive counts by identifying which artifact each number comes from.
8. Validate whether permanent-CSI `NA` logic should use calendar-year cutoff, firm-level observed-window cutoff, event-window completeness, or a combination.
9. Validate whether dynamic-CSI needs additional `NA` logic beyond current censored-trigger handling, and identify any risk of incorrectly removing valid negatives.
10. Identify the exact script(s) that regenerate the descriptive-statistics CSVs named in the original epic.
11. Recommend the next ticket envelope and state whether the original Tickets 2 and 3 require rewriting.

## non_goals

- No code edits.
- No data edits.
- No output regeneration.
- No slide edits.
- No model retraining.
- No cloud-computing setup.

## acceptance_criteria

- A concise validation report exists in the completion response.
- The report includes current row-count and label-count tables for both tracks where artifacts are available.
- The report states whether phantom firm-years are present and estimates their count.
- The report states the correct source of truth for dynamic positives.
- The report gives a safe implementation rule for permanent unresolvable `NA` rows.
- The report gives a safe implementation rule or no-change recommendation for dynamic unresolvable `NA` rows.
- The report identifies exact downstream descriptive-stat scripts or states that a follow-up discovery sub-step is required.
- No files are modified.

## manual_verification_required

Yes. The Master must review the validation report before authorizing any implementation ticket, because row-count and positive-label guardrails control all later work.

## verification_commands

Suggested commands. The worker may add read-only commands as needed.

```powershell
git status --short --branch
Select-String -LiteralPath "01_Code/pipeline/06_Merge.R" -Pattern "fn_label_scaffold|max_label_year|dynamic_label_censored|permanent_label_censored|tier2|window" -Context 3,5
Select-String -LiteralPath "01_Code/pipeline/config.R" -Pattern "PATH_PRICES_MONTHLY|PATH_LABELS|PATH_PANEL|PATH_FEATURES|RESPONSE_TRACK|T_MONTHS|START_DATE|END_DATE" -Context 2,3
Get-ChildItem -Recurse -File "03_Data_Output" -Include "*.rds","*.csv" | Select-Object FullName,Length,LastWriteTime
```

R read-only counting commands may be used, but must not write outputs.

## completion_report_required

Yes. Include:

- Status.
- Files inspected.
- Commands run.
- Current branch and dirty worktree entries.
- Row-count table by artifact and track.
- Label-count table by artifact and track.
- Dynamic positive source-of-truth conclusion.
- Permanent `NA` rule recommendation.
- Dynamic `NA` rule recommendation.
- Whether original Tickets 2 and 3 are safe as written.
- Recommended next ticket.

---

# Ticket Envelope: AE-PANEL-002

## ticket_id

`AE-PANEL-002`

## goal

Implement validated observable firm-year filtering in `06_Merge.R::fn_label_scaffold()` so phantom firm-years do not enter labelled panels.

## dependencies

- `AE-PANEL-001` completed and validated by the Master.
- Exact observable firm-year definition accepted by the Master.

## allowed_areas

- `01_Code/pipeline/06_Merge.R`
- Minimal adjacent code in `01_Code/pipeline/config.R` only if `AE-PANEL-001` proves it is required.

## must_not_touch

- `02_Data_Input/**`
- `03_Data_Output/**`
- `06_Presentations/**`
- `C:\Users\Tristan Leiter\Documents\MT`
- `C:\Users\Tristan Leiter\Documents\aegis-core`
- Model training scripts unless explicitly required by `AE-PANEL-001`.

## requirements

1. Modify scaffold construction using the Master-approved observable firm-year rule.
2. Keep the function track-agnostic.
3. Add concise diagnostics for rectangular rows, observable rows, and kept share.
4. Do not apply market-cap universe filters at scaffold stage unless `AE-PANEL-001` explicitly requires it.
5. Preserve all observable OOS rows needed for inference.

## non_goals

- No `NA` label logic changes.
- No pipeline reruns.
- No descriptive-stat regeneration.
- No slide edits.

## acceptance_criteria

- `06_Merge.R` implements observable firm-year scaffold filtering.
- Diagnostics are emitted when the scaffold is built.
- Positive labels are not intentionally filtered except by impossible non-observable rows identified in `AE-PANEL-001`.
- No output files are regenerated.

## manual_verification_required

Yes.

## verification_commands

```powershell
git diff -- 01_Code/pipeline/06_Merge.R
Select-String -LiteralPath "01_Code/pipeline/06_Merge.R" -Pattern "fn_label_scaffold|observable|scaffold"
```

## completion_report_required

Yes. Include changed lines, rationale, and any expected row-count impact from `AE-PANEL-001`.

---

# Ticket Envelope: AE-PANEL-003

## ticket_id

`AE-PANEL-003`

## goal

Implement validated permanent-CSI `NA` handling for firm-years whose forward outcome cannot be resolved.

## dependencies

- `AE-PANEL-001` completed and validated by the Master.
- `AE-PANEL-002` merged if scaffold filtering is a prerequisite.

## allowed_areas

- `01_Code/pipeline/06_Merge.R`

## must_not_touch

- Dynamic-CSI logic unless shared helper changes are explicitly approved.
- Data/output artifacts.
- MT and AEGIS-CORE.

## requirements

1. Apply only the permanent-CSI `NA` rule validated in `AE-PANEL-001`.
2. Preserve `y=1` count unless `AE-PANEL-001` proves the old count was stale.
3. Add or update diagnostics showing permanent `y=1`, `y=0`, `y=NA`, and prevalence against labelled rows.
4. Avoid broad calendar cutoffs if `AE-PANEL-001` identifies a more precise firm-level or event-window rule.

## non_goals

- No dynamic-track changes.
- No reruns beyond syntax or dry-run checks.
- No descriptive-stat regeneration.

## acceptance_criteria

- Permanent unresolvable rows become `NA` according to the accepted rule.
- Existing positives are preserved according to accepted guardrails.
- Code remains track-specific where appropriate.

## manual_verification_required

Yes.

## verification_commands

```powershell
git diff -- 01_Code/pipeline/06_Merge.R
Select-String -LiteralPath "01_Code/pipeline/06_Merge.R" -Pattern "permanent|censored|y_permanent_csi|prevalence" -Context 2,4
```

## completion_report_required

Yes.

---

# Ticket Envelope: AE-PANEL-004

## ticket_id

`AE-PANEL-004`

## goal

Apply the validated dynamic-CSI `NA` decision: either implement a narrowly justified fix or document that no code change is warranted.

## dependencies

- `AE-PANEL-001` completed and validated by the Master.
- `AE-PANEL-002` merged if scaffold filtering is a prerequisite.

## allowed_areas

- `01_Code/pipeline/06_Merge.R`
- Optional short planning note under `05_Documentation/06_Planning/Additional/` if the validated outcome is no code change.

## must_not_touch

- Permanent-CSI logic unless shared helper changes are explicitly approved.
- Data/output artifacts.
- MT and AEGIS-CORE.

## requirements

1. Follow the `AE-PANEL-001` dynamic-track recommendation exactly.
2. If code changes are needed, preserve accepted positive-count guardrails.
3. If no code changes are needed, document the reason and do not edit code.

## non_goals

- No pipeline reruns.
- No descriptive-stat regeneration.
- No model training.

## acceptance_criteria

- Dynamic-track censoring behavior is either fixed or explicitly validated as already correct.
- Any changed code is limited and justified by `AE-PANEL-001`.

## manual_verification_required

Yes.

## verification_commands

```powershell
git diff -- 01_Code/pipeline/06_Merge.R
Select-String -LiteralPath "01_Code/pipeline/06_Merge.R" -Pattern "dynamic|censored|y_dynamic_csi|T_MONTHS" -Context 2,4
```

## completion_report_required

Yes.

---

# Ticket Envelope: AE-PANEL-005

## ticket_id

`AE-PANEL-005`

## goal

Regenerate panel, feature, and split artifacts for both tracks after approved scaffold and `NA` logic changes.

## dependencies

- `AE-PANEL-002` completed and validated.
- `AE-PANEL-003` completed and validated.
- `AE-PANEL-004` completed and validated or explicitly skipped.

## allowed_areas

- Runtime outputs under the accepted `03_Data_Output/**` paths.
- Existing pipeline scripts may be executed but not edited.
- Run logs under `03_Data_Output/3_Modelling_Results/Additional/run_logs/`.

## must_not_touch

- `09C_AutoGluon.py` and model training outputs.
- Index construction outputs.
- Robustness grid outputs.
- MT and AEGIS-CORE.

## requirements

1. Run `06_Merge.R`, `06B_FeatureEngineering.R`, and `08_Split.R` for `permanent_csi`.
2. Run the same sequence for `dynamic_csi`.
3. Capture logs with timestamps.
4. Report row counts, split counts, and label counts after each track.
5. Stop and report if positive-count guardrails fail.

## non_goals

- No model retraining.
- No robustness grid.
- No index construction rerun.
- No slide edits.

## acceptance_criteria

- New artifacts are generated for both tracks.
- Logs are saved in the accepted output location.
- Label-count guardrails pass or the ticket stops with a clear failure report.

## manual_verification_required

Yes.

## verification_commands

Commands depend on the local R setup. At minimum:

```powershell
git status --short --branch
Get-ChildItem -Recurse -File "03_Data_Output" -Include "*.rds","*.csv","*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 40 FullName,Length,LastWriteTime
```

## completion_report_required

Yes.

---

# Ticket Envelope: AE-PANEL-006

## ticket_id

`AE-PANEL-006`

## goal

Regenerate descriptive-statistics CSVs affected by the cleaned panel.

## dependencies

- `AE-PANEL-005` completed and validated.
- Exact descriptive-stat generation scripts identified by `AE-PANEL-001`.

## allowed_areas

- Descriptive-stat output paths under `03_Data_Output/1_Descriptive_Statistics/**`.
- Existing descriptive-stat scripts may be executed but not edited unless separately authorized.

## must_not_touch

- Model training outputs.
- Index construction outputs.
- Slide source.
- MT and AEGIS-CORE.

## requirements

1. Regenerate only the accepted descriptive-stat CSVs.
2. Verify new denominators reflect cleaned panels.
3. Verify accepted positive counts are preserved.
4. Record old vs new counts where old artifacts are available.

## non_goals

- No code edits unless separately ticketed.
- No slide edits.
- No model training.

## acceptance_criteria

- Target CSVs are regenerated.
- Counts and prevalence are summarized in the completion report.
- No unrelated output families are touched.

## manual_verification_required

Yes.

## verification_commands

```powershell
Get-ChildItem -Recurse -File "03_Data_Output/1_Descriptive_Statistics" -Include "*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 40 FullName,Length,LastWriteTime
```

## completion_report_required

Yes.

---

# Ticket Envelope: AE-PANEL-007

## ticket_id

`AE-PANEL-007`

## goal

Produce a concise results summary for the Master listing the new row counts, prevalence numbers, and presentation/documentation values that must change.

## dependencies

- `AE-PANEL-006` completed and validated.

## allowed_areas

- New summary under `05_Documentation/08_Data_Paths/` or `05_Documentation/06_Planning/Additional/`.

## must_not_touch

- Do not edit `FinalPresentation_TristanLeiter_h11815352.Rnw`.
- Do not render slides.
- Do not edit data or code.
- MT and AEGIS-CORE.

## requirements

1. Report old vs new total row counts per track.
2. Report old vs new `y=1`, `y=0`, and `y=NA` counts per track and split where available.
3. Report old vs new prevalence.
4. List every known slide or document value that needs manual update.
5. State any unresolved counting ambiguity.

## non_goals

- No slide editing.
- No PDF rendering.
- No code edits.

## acceptance_criteria

- Summary is written and verified.
- Master can directly route a later presentation-update ticket from the summary.

## manual_verification_required

Yes.

## verification_commands

```powershell
Get-Content -LiteralPath "<created-summary-path>"
git status --short --branch
```

## completion_report_required

Yes.
