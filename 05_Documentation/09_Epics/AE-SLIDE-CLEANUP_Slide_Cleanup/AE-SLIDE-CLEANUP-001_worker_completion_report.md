# AE-SLIDE-CLEANUP-001 Worker Completion Report

## Scope completed

- Reworked Draft slide 16 only.
- Replaced the prior CV-only false-positive diagnostic with the approved modelling-summary payoff slide.
- Added the required process strip, AP-vs-prevalence chart, result/verdict/subquestion text, hand-off block, and Appendix A10-A13 footnote.
- Preserved the VAE-specific detail on the separate VAE slide rather than duplicating it on slide 16.

## Source values used

- Temporary CSI baseline: 4.44%.
- Temporary CSI best Test-AP: 19.85%, AG Expanded Dataset.
- Temporary CSI Test-AUC: 0.8766.
- Temporary CSI recall@FPR3: 0.2002.
- Permanent CSI baseline: 3.00%.
- Permanent CSI best Test-AP: 14.16%, AG Expanded Dataset, rendered as 14.2%.
- Permanent CSI near-tie challenger: AG Exp. Dataset + VAE with Test-AP 14.15%, Test-AUC 0.8838, and recall@FPR3 0.2011.
- Weighted ensembles top the relevant final model runs in the model-family winners file.

## Verification performed

- Confirmed Rnw frame balance: 53 begin frames and 53 end frames.
- Confirmed page 17 contains the revised slide title and required visible content via `pdftotext`.
- Compiled the Draft deck with `knitr::knit2pdf`.
- Rendered PDF page 17 with `pdftoppm` and inspected the image.
- Confirmed no forbidden data/model/index/evaluation/sensitivity/pipeline scripts were run.

## Completion status

Complete and validator-approved for scoped commit.
