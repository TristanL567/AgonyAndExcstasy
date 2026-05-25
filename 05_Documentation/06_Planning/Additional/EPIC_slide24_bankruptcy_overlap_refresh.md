# EPIC: Refresh Slide 24 Bankruptcy-Overlap Story

## Epic Envelope

ticket_id: AE-SLIDE24

goal: Replace the stale slide 24 story about 87 confirmation-lag firms with the current validated temporary-CSI bankruptcy-overlap result, while keeping methodology claims consistent with the current pipeline.

dependencies:
- Current cleaned AgonyAndExcstasy repository is available.
- Current final-presentation source exists at `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`.
- Current overlap source exists at `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`.
- Current methodology note exists at `05_Documentation/01_Methodology/03_Classification/Necessary/Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md`.

allowed_areas:
- `05_Documentation/06_Planning/Additional/`
- `05_Documentation/08_Data_Paths/`
- `05_Documentation/01_Methodology/03_Classification/Necessary/`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/`

must_not_touch:
- `C:\Users\Tristan Leiter\Documents\MT`
- `C:\Users\Tristan Leiter\Documents\aegis-core`
- `01_Code/`
- `02_Data_Input/`
- `03_Data_Output/`
- Model outputs, index outputs, data files, PDFs, and generated binary artifacts unless a ticket explicitly authorizes read-only verification.

requirements:
- Treat the current source-of-truth result as:
  - CRSP 572-574 firms in sample: `629`
  - Detected by revised temporary CSI: `545`
  - Missed by revised temporary CSI: `84`
  - Detection rate: `86.65%`
  - Positive annual label cells: `8,647`
- Do not describe the revised method as "any bankruptcy equals y=1".
- Preserve the methodological rule: CRSP 572-574 only creates a positive temporary-CSI event after a valid CSI trigger and within the rule's timing window.
- Remove or qualify stale `458 detected / 171 missed / 72.8%` and `87 confirmation-lag cases under review` statements.
- Do not change the classification methodology in this epic.

non_goals:
- No code edits.
- No model reruns.
- No index-construction reruns.
- No panel-scaffold fix.
- No changes to MT or AEGIS-CORE.
- No commit of large documentation, presentation, PDF, or output files.

acceptance_criteria:
- The current 545/84/86.65% result is verified from local source artifacts.
- The final-presentation source no longer tells the stale 87-firm story as current evidence.
- Any remaining mention of the old 458/171/72.8% story is explicitly labelled historical or removed.
- Documentation/source-map references no longer point to 72.8% as the current revised result.
- The final report states that the remaining 84 misses are methodological exclusions unless a later diagnostic proves otherwise.

manual_verification_required: true

verification_commands:
- `Select-String -LiteralPath 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern "458|171|72.8|87|545|86.65|84" -Context 2,2`
- `Get-Content 03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`
- `Select-String -LiteralPath 05_Documentation/08_Data_Paths/Data_Paths.md -Pattern "72.8|86.65|545|458|171"`

completion_report_required: true

## Branch And Commit Protocol

Branch:
- Use development branch `Development_CC` unless Master explicitly chooses another branch.
- No ticket changes are committed on `main`.

Validator workflow:
1. Master routes exactly one ticket to a worker.
2. Worker returns a concise completion summary.
3. Master routes that summary to the validator.
4. Validator either approves, requests changes, or blocks.
5. Only after validator approval, commit the ticket-scoped changes to `Development_CC`.
6. After the commit, provide Master with the next ticket envelope.

Commit rules:
- Commit after each completed ticket, not after a batch of tickets.
- Commit message format: `AE-SLIDE24-00X: concise summary`.
- Because `05_Documentation/**` and `06_Presentations/**` are ignored by `.gitignore`, use `git add -f` only for small text source files explicitly changed by the ticket.
- Never force-add PDFs, generated `.tex` files, rendered binaries, data files, model outputs, or `03_Data_Output/**`.
- Before each commit, show staged files and confirm they are ticket-scoped.

Recommended commit check:

```powershell
git branch --show-current
git status --short
git diff --stat
git add -f <small-ticket-text-files-only>
git diff --cached --name-only
git commit -m "AE-SLIDE24-00X: concise summary"
```

## Ticket AE-SLIDE24-001: Validate Current Bankruptcy-Overlap Source

ticket_id: AE-SLIDE24-001

goal: Confirm the current source of truth for slide 24 and decide whether the old 87-firm story represents a pipeline error or a stale presentation narrative.

dependencies:
- Epic AE-SLIDE24 exists.
- Current overlap CSV is available.
- Current final-presentation `.Rnw` is available.
- Current methodology note is available.

allowed_areas:
- Read-only inspection of `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`
- Read-only inspection of `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`
- Read-only inspection of `05_Documentation/01_Methodology/03_Classification/Necessary/Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md`
- A concise validation summary returned to Master

must_not_touch:
- All files. This ticket is read-only.
- MT
- AEGIS-CORE

requirements:
- Verify the current 572-574 overlap values: `629`, `545`, `84`, `86.65%`.
- Verify where the final presentation still says `458`, `171`, `72.8%`, or `87`.
- Explain whether the 84 current misses are pipeline errors or methodological exclusions.
- State whether a separate diagnostic is needed to produce a full reason breakdown for all 84 misses.
- Do not edit any file.

non_goals:
- No slide edits.
- No documentation edits.
- No code edits.
- No reruns.
- No commits.

acceptance_criteria:
- Master receives a concise summary with source paths and exact numbers.
- Summary explicitly answers: "Are the 84 current misses genuine errors?"
- Summary identifies the next ticket needed to update the stale presentation source.

manual_verification_required: true

verification_commands:
- `Get-Content 03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`
- `Select-String -LiteralPath 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern "458|171|72.8|87|545|86.65|84" -Context 2,2`
- `Select-String -LiteralPath 05_Documentation/01_Methodology/03_Classification/Necessary/Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md -Pattern "545|86.65|remaining|not detected|572-574" -Context 2,2`

completion_report_required: true

## Ticket AE-SLIDE24-002: Update Final Presentation Source

ticket_id: AE-SLIDE24-002

goal: Replace stale slide 24 and related final-presentation statements with the current 545/84/86.65% temporary-CSI bankruptcy-overlap result.

dependencies:
- AE-SLIDE24-001 completed and validator-approved.
- Master authorizes editing the `.Rnw` source.

allowed_areas:
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`

must_not_touch:
- Generated PDF files
- Generated `.tex` files
- `03_Data_Output/`
- `01_Code/`
- MT
- AEGIS-CORE

requirements:
- Update the main Methodology II table if it still shows `458 detected / 171 missed / 72.8%`.
- Update slide 24 / Appendix A3 so it no longer says the 87 confirmation-lag cases are "currently under review" as the current result.
- Use the current revised result:
  - `629` CRSP 572-574 firms
  - `545` detected
  - `84` missed
  - `86.65%` detection
- Explain remaining misses as methodological exclusions under the retained CSI-trigger rule, not as known pipeline errors.
- Preserve the statement that CRSP 572-574 is not an independent default label.

non_goals:
- No PDF render.
- No code edits.
- No output reruns.
- No new diagnostic computation.

acceptance_criteria:
- `FinalPresentation_TristanLeiter_h11815352.Rnw` contains the current 545/84/86.65% story.
- Stale `458/171/72.8%` is absent or clearly historical.
- Stale "87 under review" language is removed or clearly historical.
- No generated files are changed.

manual_verification_required: true

verification_commands:
- `Select-String -LiteralPath 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern "458|171|72.8|87|545|86.65|84" -Context 2,2`
- `git diff -- 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`

completion_report_required: true

## Ticket AE-SLIDE24-003: Render And Verify Slide 24

ticket_id: AE-SLIDE24-003

goal: Render the final presentation and verify that the updated slide 24 text appears correctly in the generated PDF.

dependencies:
- AE-SLIDE24-002 completed and validator-approved.
- Local LaTeX/Rnw rendering toolchain is available, or missing dependencies are reported.

allowed_areas:
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/`
- Temporary render logs

must_not_touch:
- `01_Code/`
- `02_Data_Input/`
- `03_Data_Output/`
- MT
- AEGIS-CORE

requirements:
- Render the `.Rnw` to PDF if the local toolchain permits.
- Extract text from rendered PDF page 24 and confirm updated values.
- If rendering fails due missing local dependencies, report exact blocker and do not improvise edits.
- Do not commit generated PDF unless Master explicitly approves.

non_goals:
- No content edits unless render verification reveals a typo and Master authorizes a follow-up.
- No pipeline reruns.
- No generated binary commit.

acceptance_criteria:
- Render succeeded and page 24 contains updated current values, or render failure is documented with exact missing dependency.
- No unintended presentation files are modified.

manual_verification_required: true

verification_commands:
- `Select-String -LiteralPath 06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw -Pattern "545|86.65|84"`
- PDF text extraction command selected by the worker's available tooling.

completion_report_required: true

## Ticket AE-SLIDE24-004: Update Documentation Source Map

ticket_id: AE-SLIDE24-004

goal: Update documentation references so the current revised bankruptcy-overlap result is consistently documented as 545 detected, 84 missed, and 86.65%.

dependencies:
- AE-SLIDE24-002 completed and validator-approved.

allowed_areas:
- `05_Documentation/08_Data_Paths/Data_Paths.md`
- `05_Documentation/08_Data_Paths/FinalPresentation_Data_Validation_2026-05-25.md`
- `05_Documentation/01_Methodology/03_Classification/Necessary/Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md`

must_not_touch:
- `01_Code/`
- `02_Data_Input/`
- `03_Data_Output/`
- Presentation source unless a separate ticket authorizes it
- MT
- AEGIS-CORE

requirements:
- Replace stale current-result references to `72.8%`, `458`, and `171`.
- Ensure current docs cite the overlap CSV as the source of truth.
- Preserve historical context only if explicitly labelled historical.
- Do not invent a reason breakdown for all 84 misses unless a source table exists.

non_goals:
- No slide edits.
- No generated output edits.
- No code edits.

acceptance_criteria:
- Documentation source map points to the current 545/84/86.65% result.
- Any old 72.8% reference is marked historical or removed.
- No unsupported explanation is added for all 84 misses.

manual_verification_required: true

verification_commands:
- `Select-String -LiteralPath 05_Documentation/08_Data_Paths/Data_Paths.md -Pattern "72.8|86.65|545|458|171" -Context 2,2`
- `Select-String -LiteralPath 05_Documentation/08_Data_Paths/FinalPresentation_Data_Validation_2026-05-25.md -Pattern "72.8|86.65|545|458|171" -Context 2,2`

completion_report_required: true

## Ticket AE-SLIDE24-005: Optional 84-Miss Reason Breakdown

ticket_id: AE-SLIDE24-005

goal: Produce a reason breakdown for the 84 remaining CRSP 572-574 misses if Master decides the deck needs more detail than the current methodology explanation.

dependencies:
- AE-SLIDE24-001 completed and validator-approved.
- Master explicitly authorizes a diagnostic beyond documentation cleanup.

allowed_areas:
- Read-only input inspection from existing robustness/output tables
- A new small markdown summary under `05_Documentation/08_Data_Paths/`

must_not_touch:
- Existing data files
- Existing output files
- `01_Code/` unless Master opens a separate implementation ticket
- MT
- AEGIS-CORE

requirements:
- Determine whether existing firm-level detail tables can classify all 84 misses without rerunning code.
- If possible, summarize miss reasons using existing artifacts only.
- If not possible, recommend a separate diagnostic implementation ticket.
- Do not change the classification method.

non_goals:
- No slide edits.
- No model reruns.
- No code edits unless a later implementation ticket is created.

acceptance_criteria:
- Master receives either a sourced reason table for all 84 misses or a clear explanation of why current artifacts are insufficient.
- No existing outputs are modified.

manual_verification_required: true

verification_commands:
- `Get-ChildItem -Recurse 03_Data_Output/2_Robustness_Checks/Necessary -Filter "*detail*.csv"`
- `Select-String -Path 03_Data_Output/2_Robustness_Checks/Necessary/**/*.csv -Pattern "crsp_572_574|bankruptcy_572_574"`

completion_report_required: true

## Conformance Gate

Before any ticket is reported complete:
- Ticket envelope exists with all required fields.
- Only allowed areas were touched.
- MT was not touched.
- AEGIS-CORE was not touched.
- No generated PDF, data, output, or binary file was committed.
- Verification commands were run or blockers were reported.
- Completion report lists changed files, commands run, and remaining issues.
