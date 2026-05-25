# Temporary CSI and CRSP Bankruptcy Delisting Indicators

Generated: 2026-05-16

This note documents the empirical effect of adding CRSP bankruptcy-related
delisting indicators to the temporary/dynamic CSI label construction. The
change is additive. The original temporary CSI methodology remains in place,
and the CRSP delisting rule only adds an additional positive path for firms that
trigger CSI-like distress but fail before the full confirmation window is
observable.

## Methodological setup

Base grid: `C080_M020_T018`

- Crash trigger: `C = -80%`.
- Ordinary temporary CSI confirmation path: after the trigger, the firm must
  fail to recover above the `M = -20%` recovery ceiling over the full
  `T = 18` month confirmation window.
- Additive terminal-failure path: after the same `C = -80%` trigger, a CRSP
  bankruptcy-related delisting code `572`, `573`, or `574` after the trigger
  date and on or before the `T`-month confirmation date is also a positive
  temporary CSI event.
- Positive event statuses are:
  - `confirmed_csi`
  - `terminal_failure_before_confirmation`
- Non-positive statuses remain:
  - `recovered_within_T`
  - `censored`

The additive path does not lower the crash threshold and does not use CRSP
delisting variables as model features. The delisting metadata are stored only
as event diagnostics:

- `terminal_failure_date`
- `terminal_failure_code`
- `terminal_failure_dlret`

Annual alignment is unchanged. The event date remains `trigger_date`,
`event_year = year(trigger_date)`, and `label_year = event_year - 1`.

## Effect versus the old implementation

At the event-row level, the old implementation produced 8,369 positive
temporary CSI events for the base grid. The additive terminal-failure path adds
2,075 positive event rows, increasing positive event rows to 10,444.

| Metric | Count |
| --- | ---: |
| Old `confirmed_csi` event rows | 8,369 |
| Additional `terminal_failure_before_confirmation` event rows | 2,075 |
| New positive event rows | 10,444 |
| Event-row increase | 24.79% |
| Terminal hits already old `confirmed_csi` | 438 |
| Terminal hits from old `recovered_within_T` | 1,913 |
| Terminal hits from old `censored` | 162 |

The 438 terminal hits already classified as `confirmed_csi` are not incremental.
They show that many bankruptcy delistings occur among firms already captured by
the old temporary CSI rule. The 2,075 incremental event rows are the old
non-positive triggers that become positive because bankruptcy-related delisting
occurs before the `T = 18` month confirmation date.

At the annual modeling-label level, the increase is smaller because multiple
events can collapse into the same `(permno, label_year)` cell, and the modeling
panel starts in 1993. In the in-panel annual labels:

| Metric | Count |
| --- | ---: |
| Old positive label cells | 8,341 |
| Additional new positive label cells | 306 |
| New positive label cells | 8,647 |
| Label-cell increase | 3.67% |
| Terminal-failure positive label cells | 602 |

The event-row increase is therefore larger than the annual label-cell increase.
This is expected: the event table records every eligible trigger, while the
annual response label is a unique firm-year object.

## Annual label impact

The table below reports the in-panel annual comparison by `label_year`.

| Label year | Old positives | Added positives | New positives | Increase | Terminal-failure cells |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1993 | 127 | 4 | 131 | 3.15% | 7 |
| 1994 | 139 | 1 | 140 | 0.72% | 6 |
| 1995 | 194 | 5 | 199 | 2.58% | 6 |
| 1996 | 293 | 6 | 299 | 2.05% | 20 |
| 1997 | 410 | 10 | 420 | 2.44% | 21 |
| 1998 | 222 | 19 | 241 | 8.56% | 35 |
| 1999 | 883 | 34 | 917 | 3.85% | 55 |
| 2000 | 669 | 18 | 687 | 2.69% | 48 |
| 2001 | 456 | 12 | 468 | 2.63% | 35 |
| 2002 | 117 | 16 | 133 | 13.68% | 23 |
| 2003 | 278 | 8 | 286 | 2.88% | 17 |
| 2004 | 137 | 2 | 139 | 1.46% | 5 |
| 2005 | 153 | 3 | 156 | 1.96% | 4 |
| 2006 | 351 | 13 | 364 | 3.70% | 20 |
| 2007 | 543 | 12 | 555 | 2.21% | 45 |
| 2008 | 141 | 16 | 157 | 11.35% | 22 |
| 2009 | 185 | 10 | 195 | 5.41% | 19 |
| 2010 | 237 | 7 | 244 | 2.95% | 16 |
| 2011 | 154 | 9 | 163 | 5.84% | 13 |
| 2012 | 91 | 13 | 104 | 14.29% | 16 |
| 2013 | 215 | 5 | 220 | 2.33% | 16 |
| 2014 | 272 | 3 | 275 | 1.10% | 17 |
| 2015 | 137 | 7 | 144 | 5.11% | 11 |
| 2016 | 186 | 6 | 192 | 3.23% | 11 |
| 2017 | 284 | 10 | 294 | 3.52% | 23 |
| 2018 | 185 | 10 | 195 | 5.41% | 25 |
| 2019 | 117 | 11 | 128 | 9.40% | 23 |
| 2020 | 419 | 1 | 420 | 0.24% | 4 |
| 2021 | 498 | 3 | 501 | 0.60% | 7 |
| 2022 | 248 | 16 | 264 | 6.45% | 16 |
| 2023 | 0 | 16 | 16 | NA | 16 |

The largest absolute annual additions occur in label years 1999, 1998, 2000,
2002, 2008, 2022, and 2023. The 2023 row has no old positives because those
labels come from 2024 triggers for which ordinary `T = 18` confirmation is not
observable in the current sample, while bankruptcy delisting can still validate
the terminal-failure path.

## Match to CRSP delisting indicators

The `14e_PriceDistress_ResponseLabels` diagnostic was then run against the
updated temporary CSI positives. A CRSP default/adverse firm is counted as
detected if it has at least one positive temporary CSI trigger on or before the
CRSP delisting date. Separately, the diagnostics count whether the delisting
falls within the `T = 18` month confirmation window.

Positive temporary CSI totals used for the overlap diagnostic:

- Positive event rows: 10,444
- Positive firms: 5,702
- Positive annual label cells: 8,647

| Indicator group | CRSP firms in sample | CRSP firms detected | Detection rate | Positive event rows followed by indicator | Within T event rows | Positive label cells followed by indicator | Within T label cells |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `572-574` bankruptcy-related range | 629 | 545 | 86.65% | 2,757 | 2,513 | 985 | 741 |
| `574` bankruptcy / declared insolvent | 548 | 513 | 93.61% | 2,502 | 2,289 | 905 | 692 |
| Broader adverse `400-490`, `550-585` | 5,654 | 3,676 | 65.02% | 7,000 | 5,258 | 5,203 | 3,468 |

The current source-of-truth local artifact for the `572-574` overlap result is
`03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`.
The implied `572-574` miss count is 84 firms. Existing reason diagnostics below
cover only the narrower `574` subset, so the full 84 misses should not be
assigned a detailed reason breakdown without a separate source table.

Interpretation:

- The additive method captures most CRSP `574` bankruptcies: 513 of 548 firms,
  or 93.61%.
- The broader adverse delisting group is much larger and more heterogeneous, so
  the detection rate is lower at 65.02%. This is expected because the broader
  group includes many exchange- or performance-related delistings that need not
  pass through an `80%` drawdown state before delisting.
- The within-`T` counts are lower than the "followed by indicator" counts
  because some firms are already positive temporary CSI events and delist later,
  after the confirmation window.

## Why firms are detected

A CRSP bankruptcy or adverse delisting case is detected by temporary CSI when at
least one of these paths occurs before or at the CRSP delisting date:

1. Ordinary confirmation path: the firm hits the `C = -80%` drawdown trigger and
   remains below the recovery ceiling for the full `T = 18` month window. These
   cases were already positive under the old implementation.
2. Additive terminal-failure path: the firm hits the same `C = -80%` trigger,
   would otherwise have been classified as `recovered_within_T` or `censored`,
   but receives CRSP code `572`, `573`, or `574` after the trigger and on or
   before the confirmation date.

This means the CRSP indicator is not a standalone default label. It only turns a
CSI-like trigger into a positive temporary CSI event when the firm fails before
the confirmation clock can complete.

## Why remaining CRSP 574 firms are not detected

The remaining non-detected `574` cases were diagnosed separately because `574`
is the narrow bankruptcy / declared insolvent code. Out of 548 `574` firms in
the sample, 513 are detected and 35 are not detected.

| Miss reason | Firms | Median minimum pre-574 drawdown | Median months from first price to 574 | Median months from first trigger to 574 | Rule interpretation |
| --- | ---: | ---: | ---: | ---: | --- |
| `no_C80_drawdown_before_574` | 33 | -69.44% | 11 | NA | The firm never reaches the `C = -80%` trigger before the CRSP `574` date, so the terminal-failure override is never eligible. |
| `C80_trigger_censored_but_574_not_within_T_window` | 1 | -90.14% | 3 | 0 | The trigger and `574` date occur in the same month/date. The implemented rule requires `dlstdt > trigger_date`, so same-date delisting is not counted as "after trigger". |
| `C80_trigger_recovered_and_574_after_T_window` | 1 | -82.28% | 75 | 22 | The firm triggers `C = -80%`, recovers within the `T = 18` month window, and receives `574` only after the confirmation window. |

The main reason for non-detection is therefore not a failure of the terminal
override. It is the retained `C = -80%` trigger requirement. Most missed `574`
firms simply do not exhibit an observed pre-delisting drawdown of at least
`80%` in the monthly CRSP price path before the delisting date. Their median
pre-`574` drawdown is about `-69.4%`, and their median observed history from
first monthly price to delisting is only 11 months.

The single censored case is a timing convention issue. It would be captured by
a different rule that allowed `dlstdt >= trigger_date`, but the current
definition follows the stated "after trigger_date" rule and therefore excludes
same-date trigger/delisting cases.

The single recovered case is intentionally excluded. It is not a failure before
confirmation: the `574` event arrives 22 months after the first trigger, outside
the `T = 18` month window, after the old temporary CSI rule had classified the
firm as recovered within `T`.

## Implications

The additive CRSP bankruptcy path addresses the main empirical concern: firms
that crash and then delist for bankruptcy before the full confirmation window
is observable are now counted as positive temporary CSI events. The method
preserves the old label where it already worked and adds bankruptcy-confirmed
terminal cases where the old method was too conservative.

The remaining false negatives under CRSP `574` are mostly firms that never
cross the retained `C = -80%` threshold before delisting. Capturing them would
require a different methodology, such as lowering `C`, allowing delisting
returns to form the crash trigger, or treating CRSP `574` as an independent
response label. Those alternatives would no longer be the agreed additive
temporary CSI rule.

## Reproducibility outputs

Main additive comparison tables:

- `03_Output/Robustness/dynamic_csi/tables/terminal_failure_additive_summary_events.csv`
- `03_Output/Robustness/dynamic_csi/tables/terminal_failure_additive_summary_labels.csv`
- `03_Output/Robustness/dynamic_csi/tables/terminal_failure_additive_vs_old_by_event_year.csv`
- `03_Output/Robustness/dynamic_csi/tables/terminal_failure_additive_vs_old_by_label_year.csv`
- `03_Output/Robustness/dynamic_csi/tables/terminal_failure_additive_vs_old_by_label_year_panel.csv`

CRSP overlap diagnostics:

- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_by_label_year.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_by_event_year.csv`

Missed `574` diagnostics:

- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_missed_574_overall.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_missed_574_reason_summary.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_missed_574_firm_detail.csv`
