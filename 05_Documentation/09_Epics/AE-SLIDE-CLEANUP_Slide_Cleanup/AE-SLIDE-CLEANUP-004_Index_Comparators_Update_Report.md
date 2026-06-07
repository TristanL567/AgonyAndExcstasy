# AE-SLIDE-CLEANUP-004 Index Comparators Update Report

## Ticket

- Epic: AE-SLIDE-CLEANUP
- Ticket: AE-SLIDE-CLEANUP-004
- Branch: development-slides
- Target: Draft deck only

## Implementation Summary

Reworked the Draft slide previously titled `Index Construction II: Four Benchmark Universes` into:

`Index Construction II: Universes and Comparators`

The revised slide keeps the four-universe concept, removes internal implementation terminology, replaces repeated signal-calibration bullets with an audience-facing comparator section, and preserves the single alert block `Same exclusion rule, four universes`.

## Slide Content

- Four universes:
  - Total Market: all eligible firms above USD 100 million market cap.
  - Large Cap: prior-December market-cap rank, top tier.
  - Mid Cap: prior-December market-cap rank, middle tier.
  - Small Cap: prior-December market-cap rank, bottom tier.
- Comparator section:
  - Primary comparator is the unfiltered cap-weighted benchmark in the same universe.
  - Screened portfolios are compared like-for-like against the matching universe benchmark.
  - Min-volatility and quality screens are framed as planned extensions under the main research question.

## Tier Threshold Note

Exact Large/Mid/Small cap tier breakpoint values were not found in the allowed read-only evidence search. The required placeholder was therefore kept:

`Tier breakpoints: <author to insert exact Large/Mid/Small cap thresholds>`

## Verification Summary

- Frame count remains 54 begin / 54 end.
- Target slide contains no `revised 11C track`, build/diagnostic code, internal output-folder name, or `Signal discipline` section.
- Draft compile passed with existing natbib citation warnings only.
- Targeted render of page 20 passed visual QA.
- Tracked Draft PDF/TeX compile byproducts were restored before staging.
- No non-Draft June presentation file was edited or staged.
- No model, index, evaluation, sensitivity, pipeline, or training scripts were run.
