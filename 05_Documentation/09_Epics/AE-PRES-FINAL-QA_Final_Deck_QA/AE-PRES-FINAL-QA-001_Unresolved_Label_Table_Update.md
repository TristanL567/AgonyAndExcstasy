# AE-PRES-FINAL-QA-001 Unresolved Label Table Update

## Scope

This ticket updates the June final presentation count tables so the displayed
sample is the labelled sample used for prevalence, supervised training, and
label-based evaluation. No source data, model output, index output, code, or
pipeline artifact was modified.

## Change Summary

- Removed the `y=NA` column from the main temporary-CSI count table.
- Removed the `y=NA` column from the main permanent-CSI count table.
- Removed the `y=NA` column from Appendix A3's cleaned-label count table.
- Preserved concise notes explaining that unresolved labels remain in canonical
  artifacts for scaffold consistency, but are excluded from the displayed
  labelled count tables, supervised training, and label-based evaluation.
- Updated `SLIDE_DATA_SOURCES.md` rows for slides 6, 7, and 32.

## Count Interpretation

The labelled denominator is unchanged:

- `labelled rows = y=0 + y=1`
- `prevalence = y=1 / labelled rows`

The table update changes only presentation display. It does not alter any
canonical counts or computed outputs.

## Validation Notes

The presentation still mentions unresolved labels where methodologically needed,
but they are no longer shown as a core table column in the displayed cleaned-label
count tables.
