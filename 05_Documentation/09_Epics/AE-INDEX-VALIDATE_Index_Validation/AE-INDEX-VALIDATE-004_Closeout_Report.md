# AE-INDEX-VALIDATE-004 Closeout Report

## Scope

This closeout synthesizes validator-approved evidence from `AE-INDEX-VALIDATE-001`, `AE-INDEX-VALIDATE-002`, and `AE-INDEX-VALIDATE-003`. It does not create new model, index, evaluation, sensitivity, or pipeline evidence.

Evidence reviewed:

- `AE-INDEX-VALIDATE-001_Attribution_State_Audit.md`
- `AE-INDEX-VALIDATE-001_validation_report.md`
- `AE-INDEX-VALIDATE-002_Excluded_Firm_Return_Diagnostic.md`
- `AE-INDEX-VALIDATE-002_validation_report.md`
- `AE-INDEX-VALIDATE-003_Random_Placebo_Report.md`
- `AE-INDEX-VALIDATE-003_validation_report.md`
- `epics/AE-INDEX-VALIDATE/ledger.md`

## Ticket 001 Synthesis: Attribution State Audit

`AE-INDEX-VALIDATE-001` established that the selected OOS attribution rows reconcile to the existing AE-ATTRIB source outputs. For all eight selected rows, realized alpha is accounted for by:

`TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment`

The important interpretation is narrower than a direct event-avoidance story. In the selected permanent CSI rows, alpha is mostly located in retained-stock reweighting plus the geometric adjustment, not in direct true-positive event avoidance. The direct TP gain is zero or near zero in the permanent CSI rows, and small in most temporary CSI rows.

Therefore, near-zero TP gain does not invalidate the selected index results, because realized portfolio alpha is the full strategy-minus-benchmark return after transaction costs. It does weaken a pure claim that selected alpha mainly comes from avoiding realized CSI or permanent-loss events.

## Ticket 002 Synthesis: False-Positive Return Diagnostic

`AE-INDEX-VALIDATE-002` tested whether excluded false positives underperform retained non-event firms.

The selected-row diagnostic found:

- False positives underperform retained true negatives in 6 of 8 selected rows.
- False positives underperform the retained strategy portfolio in only 1 of 8 selected rows.
- The pattern is strongest in permanent CSI, where false positives underperform retained true negatives in all four selected rows.

This supports a broader distress, quality, or risk-screen interpretation: model-excluded non-event firms often lag retained non-event firms, especially under permanent CSI. However, false positives are not uniformly weak relative to the retained strategy portfolio, and several false-positive groups still have positive realized return proxies. The evidence therefore supports a quality-screen-compatible interpretation, not a pure event-avoidance story and not a causal claim.

## Ticket 003 Synthesis: Existing-Output Placebo Diagnostic

`AE-INDEX-VALIDATE-003` determined that an exact random-name exclusion placebo could not be reconstructed from allowed saved outputs, because constituent-level monthly return paths were not available. The validator approved a bounded existing-output placebo approximation.

Under that approved approximation:

- Six of eight selected CSI rows exceed the matched existing-output placebo p95 and maximum.
- Temporary mid cap and permanent mid cap remain positive but do not exceed the approximation p95 or maximum.
- The result supports useful selected-row signal beyond nearby saved exclusion/reweighting configurations for six rows.

This remains an approximation, not an exact random-name exclusion null. It does not establish causality and does not prove that selected CSI alpha would beat every random, sector-matched, size-matched, or quality-matched exclusion process.

## Final Validation Conclusion

The index results are not invalidated. The selected OOS CSI strategies still show positive index-level alpha in the audited rows, the attribution reconciles to existing outputs, and six of eight selected rows compare favorably against the approved existing-output placebo approximation.

The narrow claim that alpha comes mainly from avoiding realized CSI events is not supported. Ticket 001 shows that direct TP gains are near zero in most selected rows, especially permanent CSI. Ticket 002 shows that false positives often underperform retained true negatives, but not usually the retained strategy portfolio. Ticket 003 shows that selected rows often beat nearby saved placebo configurations, but not through an exact causal event-avoidance test.

The defensible claim is:

The CSI model acts as a broader distress, quality, or risk screen that produces useful retained-stock reweighting effects in several universes. This is an economically relevant index-construction result, but the directly supported mechanism is broader screening and portfolio reweighting rather than direct avoidance of realized CSI events.

Further exact causal validation would require constituent-level monthly returns and exact random-name placebo reconstruction. With those inputs, the next validation layer should rebuild exact random-name, size-matched, sector-matched, size-sector matched, and quality/distress matched placebo portfolios at the rebalance level and compare their full monthly return paths against the selected CSI strategies.

## Closure Boundary

This worker does not mark the epic closed and does not create a validation report. Validator approval and master closure remain separate AEGIS steps.
