# AE-PRES-JUNE-004 Index And Transaction-Cost Slide Update Report

Result: worker_complete_pending_validator

## Scope

Updated the June final presentation index-result section only:

- index construction results;
- benchmark comparison;
- transaction-cost robustness;
- turnover interpretation;
- threshold-family conclusions.

No sensitivity-result slides were finalized. No model, index, data, pipeline, or sensitivity scripts were run.

## Updated Frames

- `Index Results: Temporary CSI at 20 bps`
- `Index Results: Permanent CSI at 20 bps`
- `Transaction-Cost Robustness`
- `Threshold Families and Turnover`
- `Appendix A14: Final Index Grid Contract`
- `Appendix A15: 20 bps Winners With Benchmarks`
- `Appendix A16: Transaction-Cost Robustness`
- `Appendix A17: Threshold Family and Turnover Summary`
- `Appendix A18: Index Result Source Paths`

## Headline Conclusions Added

At 20 bps:

- Temporary CSI: `fund` wins Total Market, Large Cap, and Mid Cap; `raw_plus_latent` wins Small Cap.
- Permanent CSI: `raw_plus_latent` wins Total Market and Large Cap; `fund` wins Mid Cap; `latent_raw` wins Small Cap.
- Transaction costs do not change the top winner rankings between 0 and 20 bps across the 8 track-index comparisons.
- VAE/non-raw variants beat raw in 5 of 8 track-index cases at 20 bps.

## Grid Coverage Added

The appendix now states the complete AE-INDEX-SUITE grid:

- models: `raw`, `fund`, `latent_raw`, `raw_plus_latent`;
- tracks: temporary CSI and permanent CSI;
- universes: Total Market, Large Cap, Mid Cap, Small Cap;
- thresholds: Youden, FPR1, FPR3, FPR5;
- temporary lockouts: 1, 2, 3, 5 years;
- permanent rule: permanent removal;
- transaction costs: 0, 5, 10, 20 bps;
- turnover outputs: complete.

## Benchmark And Transaction-Cost Handling

Benchmark returns are shown as the unfiltered market-cap-weighted universe return. The benchmark does not receive a strategy transaction-cost overlay. Strategy returns are net of transaction-cost drag where a transaction-cost level is stated.

## Layout Risk

The index tables are dense but intentionally compact. Full compile and visual QA are deferred to AE-PRES-JUNE-007.
