# AE-PRES-JUNE-003 Model Performance Update Report

## Scope

Updated model-performance content only in:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

No index-construction result, transaction-cost, turnover, sensitivity, data-output, model-output, or pipeline files were modified.

## Slides Updated

See `AE-PRES-JUNE-003_Changed_Slides.csv`.

Main-deck updates:

- `Modelling II: Results Temporary CSI`
- `Modelling III: Results Permanent-CSI`
- `Modelling IV: What VAE Features Add`

Appendix updates:

- `Appendix A10: Temporary CSI Model Metrics`
- `Appendix A11: Permanent CSI Model Metrics`
- `Appendix A12: Model Family Winners`
- `Appendix A13: Model Metric Caveats`

## Conclusions Added

Temporary CSI:

- Train/CV: `raw_plus_latent` strongest overall with AP 0.2114, AUC 0.8667, and R@FPR1/3/5 = 0.0981 / 0.2478 / 0.3581.
- Test: `raw` strongest with AP 0.1985, AUC 0.8766, and R@FPR1/3/5 = 0.0821 / 0.2002 / 0.2998.
- OOS: `raw_plus_latent` has best AP and fixed-FPR recall: AP 0.3152 and R@FPR1/3/5 = 0.1051 / 0.2632 / 0.4128.
- OOS AUC caveat: `raw` is slightly higher at 0.8961 versus 0.8950 for `raw_plus_latent`.

Permanent CSI:

- Train/CV: `raw_plus_latent` best AP and R@FPR1; `raw` slightly best AUC and R@FPR3/5.
- Test: `raw_plus_latent` best AUC and R@FPR3/5; `raw` narrowly wins AP and R@FPR1.
- OOS: `latent_raw` strongest with AP 0.0482, AUC 0.8337, Brier 0.0166, and R@FPR1/3/5 = 0.0504 / 0.1484 / 0.2226.

Narrative:

- AUC remains high across tracks, but AP and fixed-FPR recall receive emphasis because the class is imbalanced.
- VAE information helps most as `raw_plus_latent` for temporary OOS and as `latent_raw` for permanent OOS robustness.
- `raw` remains a strong benchmark.
- Model metrics alone do not establish index-level superiority; the index section evaluates economic performance.

## Layout Risk

No full deck compile was run. Main slides are compact but readable in source form. The appendix A10/A11 tables are dense by design and should be checked visually during AE-PRES-JUNE-007.
