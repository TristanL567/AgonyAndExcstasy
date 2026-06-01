# AE-FP-FEATURE-DEEPDIVE-004R Presentation-Ready Summary

## Temporary CSI

- False positives are moderately, not cleanly, separable from true positives in CV feature space.
- Strict raw-model FPR slices shift from liquidity/accounting distress-lookalike at `fpr1` (`roll_min_5y_cash_pct_act`) to macro-credit stress at `fpr3`/`fpr5` (`hy_spread`).
- Broader `youden` slices are drawdown-led, with `max_dd_12m` the strongest temporary CSI separator.
- Raw-plus-latent temporary CSI is less clean at `fpr3`; the top matched separator is below abs SMD `0.20` and retains high distributional overlap.
- Main read: temporary CSI FPs look distress-like across liquidity, credit-stress, and drawdown channels, but not as one cleanly separable FP class.

## Permanent CSI

- Permanent CSI shows the most repeatable strict-threshold signal in macro-credit stress, with `hy_spread` leading or near-leading raw and raw-plus-latent `fpr3`/`fpr5` slices.
- Volatility and drawdown matter: `vol_12m` leads permanent raw `fpr1`, and `max_dd_12m` leads permanent raw-plus-latent `youden`.
- Firm-age/scale and market-value histories matter more in permanent CSI than in temporary CSI, especially `lifetime_years` and rolling `log_mkvalt` features.
- Broader `youden` slices show the strongest tail separation, but median matched-feature effects remain small.
- Main read: permanent CSI FPs look like ambiguous distress-adjacent cases shaped by credit spreads, drawdowns, volatility, and firm lifecycle/scale.

## Caveat

These are CV-only associations from 002R/003R feature contrasts. They do not use test or OOS rows, do not claim test/OOS performance, and do not establish causal mechanisms. The safest conclusion is that false positives are moderately separable but not cleanly separable; they look partly distress-like because their feature distributions overlap strongly with true positives.
