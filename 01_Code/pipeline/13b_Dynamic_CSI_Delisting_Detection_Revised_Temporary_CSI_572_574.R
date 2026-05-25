#==============================================================================#
#==== 13b_Dynamic_CSI_Delisting_Detection_Revised_Temporary_CSI_572_574.R =====#
#==== Delisting Detection Audit for Revised Dynamic CSI Grid ===================#
#==============================================================================#
#
# PURPOSE:
#   For each revised dynamic CSI C/M/T grid combination, measure how many
#   positive CSI firms subsequently delist and how many CRSP delistings were not
#   preceded by a positive CSI classification. Positive statuses follow
#   CSI_POSITIVE_EVENT_STATUSES, including terminal-failure events from CRSP
#   `dlstcd` 572-574 when enabled.
#
# DEFINITIONS:
#   - Headline detection uses classification_date <= dlstdt. For ordinary
#     confirmed CSI this is confirmation_date; for terminal-failure events this
#     is terminal_failure_date.
#   - A diagnostic trigger-date version is also reported because the permanent
#     CSI methodology uses trigger_date for its adverse-delisting tier.
#   - "Adverse delisting" follows the permanent-CSI/CHS code set:
#       PCL_DELISTING_ADVERSE_CODES = 400:490, 550:585.
#
# OUTPUTS:
#   03_Data_Output/2_Robustness_Checks/Necessary/dynamic_csi_revised_temporary_csi_572_574/tables/
#     E_delisting_detection_by_grid.{rds,csv}
#     E_adverse_delisting_detection_firm_detail.{rds,csv}
#     E_adverse_delisting_code_distribution.{rds,csv}
#     F_bankruptcy_detection_by_grid.{rds,csv}
#     F_bankruptcy_detection_firm_detail.{rds,csv}
#     E_delisting_detection_markdown_fragment.md
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[13b_Dynamic_CSI_Delisting_Detection_Revised_Temporary_CSI_572_574.R] START:",
    format(Sys.time()), "\n")

stopifnot(
  "Run 05A first: missing CSI grid events" = file.exists(PATH_CSI_EVENTS_GRID),
  "Run 02_Prices first: missing delisting reference" = file.exists(PATH_DELISTING),
  "Run 02_Prices first: missing monthly prices" = file.exists(PATH_PRICES_MONTHLY)
)

ROBUST_METHOD_SLUG <- Sys.getenv(
  "ROBUST_METHOD_SLUG",
  unset = "dynamic_csi_revised_temporary_csi_572_574"
)
ROB_OUT_DIR   <- file.path(DIR_ROB_NEC, ROBUST_METHOD_SLUG)  ## under 2_Robustness_Checks/Necessary/
ROB_TABLE_DIR <- file.path(ROB_OUT_DIR, "tables")
ROB_DOC_DIR   <- file.path(DIR_ROOT, "05_Documentation", "04_Robustness",
                           "02_Revised_Temporary_CSI_572_574", "Necessary")

dir.create(ROB_TABLE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(ROB_DOC_DIR, recursive = TRUE, showWarnings = FALSE)

PATH_SUMMARY_RDS <- file.path(ROB_TABLE_DIR, "E_delisting_detection_by_grid.rds")
PATH_SUMMARY_CSV <- file.path(ROB_TABLE_DIR, "E_delisting_detection_by_grid.csv")
PATH_DETAIL_RDS  <- file.path(
  ROB_TABLE_DIR, "E_adverse_delisting_detection_firm_detail.rds"
)
PATH_DETAIL_CSV  <- file.path(
  ROB_TABLE_DIR, "E_adverse_delisting_detection_firm_detail.csv"
)
PATH_CODE_RDS    <- file.path(
  ROB_TABLE_DIR, "E_adverse_delisting_code_distribution.rds"
)
PATH_CODE_CSV    <- file.path(
  ROB_TABLE_DIR, "E_adverse_delisting_code_distribution.csv"
)
PATH_BANKRUPTCY_RDS <- file.path(
  ROB_TABLE_DIR, "F_bankruptcy_detection_by_grid.rds"
)
PATH_BANKRUPTCY_CSV <- file.path(
  ROB_TABLE_DIR, "F_bankruptcy_detection_by_grid.csv"
)
PATH_BANKRUPTCY_DETAIL_RDS <- file.path(
  ROB_TABLE_DIR, "F_bankruptcy_detection_firm_detail.rds"
)
PATH_BANKRUPTCY_DETAIL_CSV <- file.path(
  ROB_TABLE_DIR, "F_bankruptcy_detection_firm_detail.csv"
)
PATH_MD_FRAGMENT <- file.path(
  ROB_DOC_DIR, "E_delisting_detection_markdown_fragment.md"
)

fn_pct <- function(num, den) {
  fifelse(is.na(den) | den == 0, NA_real_, 100 * num / den)
}

fn_fmt_int <- function(x) {
  format(as.integer(x), big.mark = ",", scientific = FALSE, trim = TRUE)
}

fn_fmt_pct <- function(x) {
  ifelse(is.na(x), "NA", sprintf("%.1f%%", x))
}

fn_positive_statuses <- function() {
  if (exists("CSI_POSITIVE_EVENT_STATUSES", inherits = TRUE)) {
    return(get("CSI_POSITIVE_EVENT_STATUSES", inherits = TRUE))
  }
  "confirmed_csi"
}

#==============================================================================#
# 1. Load inputs
#==============================================================================#

events_grid <- as.data.table(readRDS(PATH_CSI_EVENTS_GRID))
prices_m <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
delisting <- as.data.table(readRDS(PATH_DELISTING))

events_grid[, `:=`(
  trigger_date = as.Date(trigger_date),
  confirmation_date = as.Date(confirmation_date)
)]
if ("terminal_failure_date" %in% names(events_grid)) {
  events_grid[, terminal_failure_date := as.Date(terminal_failure_date)]
}
positive_statuses <- fn_positive_statuses()
events_grid[, classification_date := confirmation_date]
if ("terminal_failure_date" %in% names(events_grid)) {
  events_grid[
    event_status == "terminal_failure_before_confirmation" &
      !is.na(terminal_failure_date),
    classification_date := terminal_failure_date
  ]
}
prices_m[, date := as.Date(date)]
delisting[, dlstdt := as.Date(dlstdt)]

params <- unique(events_grid[, .(param_id, C, M, T)])
setorder(params, C, M, T)

sample_start <- min(prices_m$date, na.rm = TRUE)
sample_end <- max(prices_m$date, na.rm = TRUE)

firm_range <- prices_m[
  ,
  .(
    first_price_date = min(date, na.rm = TRUE),
    last_price_date = max(date, na.rm = TRUE)
  ),
  by = permno
]

delisting[, `:=`(
  is_any_delisting = !is.na(dlstcd) & dlstcd != 100L,
  is_adverse_delisting = dlstcd %in% PCL_DELISTING_ADVERSE_CODES,
  dlret_imputed = dlstcd %in% PCL_DLRET_IMPUTE_TRIGGER_CODES & is.na(dlret)
)]
delisting[, dlret_effective := fifelse(
  dlret_imputed, PCL_DLRET_IMPUTE_VALUE, dlret
)]

delisting_sample <- merge(
  delisting[
    !is.na(dlstdt) & is_any_delisting == TRUE,
    .(
      permno, dlstdt, dlstcd, dlret_raw = dlret, dlret_effective,
      dlret_imputed, is_adverse_delisting
    )
  ],
  firm_range,
  by = "permno",
  all.x = FALSE,
  all.y = FALSE
)

delisting_sample <- delisting_sample[
  dlstdt >= first_price_date & dlstdt <= sample_end
]
setorder(delisting_sample, permno, dlstdt)

cat(sprintf("  Sample window             : %s to %s\n",
            sample_start, sample_end))
cat(sprintf("  Positive CSI event rows   : %d  (statuses: %s)\n",
            nrow(events_grid[event_status %in% positive_statuses]),
            paste(positive_statuses, collapse = ", ")))
cat(sprintf("  Sample delisting firms    : %d\n",
            uniqueN(delisting_sample$permno)))
cat(sprintf("  Sample adverse delistings : %d\n",
            uniqueN(delisting_sample[is_adverse_delisting == TRUE]$permno)))

#==============================================================================#
# 2. Positive CSI events and event-level follow-up
#==============================================================================#

confirmed <- events_grid[
  event_status %in% positive_statuses,
  .(
    param_id, C, M, T, permno, event_seq, trigger_date, confirmation_date,
    trigger_year, trigger_month, event_status, classification_date
  )
]
confirmed[, event_id := .I]

event_hits_confirmation <- merge(
  confirmed,
  delisting_sample[
    ,
    .(
      permno, dlstdt, dlstcd, dlret_effective, dlret_imputed,
      is_adverse_delisting
    )
  ],
  by = "permno",
  allow.cartesian = TRUE
)[dlstdt >= classification_date]

event_hits_confirmation <- event_hits_confirmation[
  order(dlstdt),
  .SD[1L],
  by = .(param_id, event_id)
]

event_followup <- merge(
  confirmed[, .(param_id, event_id, permno)],
  event_hits_confirmation[
    ,
    .(
      param_id, event_id,
      event_followed_by_any_delisting = TRUE,
      event_followed_by_adverse_delisting = is_adverse_delisting,
      months_confirmation_to_delisting =
        12L * (year(dlstdt) - year(classification_date)) +
        (month(dlstdt) - month(classification_date))
    )
  ],
  by = c("param_id", "event_id"),
  all.x = TRUE
)
event_followup[is.na(event_followed_by_any_delisting),
               event_followed_by_any_delisting := FALSE]
event_followup[is.na(event_followed_by_adverse_delisting),
               event_followed_by_adverse_delisting := FALSE]

event_counts <- event_followup[
  ,
  .(
    confirmed_csi_event_rows = .N,
    confirmed_csi_event_rows_followed_by_any_delist =
      sum(event_followed_by_any_delisting),
    confirmed_csi_event_rows_followed_by_adverse_delist =
      sum(event_followed_by_adverse_delisting),
    median_months_confirmation_to_any_delist =
      as.numeric(median(months_confirmation_to_delisting[
        event_followed_by_any_delisting == TRUE
      ], na.rm = TRUE))
  ),
  by = param_id
]
event_counts[is.nan(median_months_confirmation_to_any_delist),
             median_months_confirmation_to_any_delist := NA_real_]

confirmed_firms <- confirmed[
  ,
  .(confirmed_csi_firms = uniqueN(permno)),
  by = param_id
]

#==============================================================================#
# 3. Firm-level detected and missed delistings
#==============================================================================#

firm_hits_confirmation <- merge(
  confirmed,
  delisting_sample[
    ,
    .(
      permno, dlstdt, dlstcd, dlret_effective, dlret_imputed,
      is_adverse_delisting
    )
  ],
  by = "permno",
  allow.cartesian = TRUE
)[classification_date <= dlstdt]

firm_hits_confirmation <- firm_hits_confirmation[
  order(confirmation_date),
  .SD[1L],
  by = .(param_id, permno, dlstdt, dlstcd)
]

firm_hits_trigger <- merge(
  confirmed,
  delisting_sample[
    ,
    .(
      permno, dlstdt, dlstcd, dlret_effective, dlret_imputed,
      is_adverse_delisting
    )
  ],
  by = "permno",
  allow.cartesian = TRUE
)[trigger_date <= dlstdt]

firm_hits_trigger <- firm_hits_trigger[
  order(trigger_date),
  .SD[1L],
  by = .(param_id, permno, dlstdt, dlstcd)
]

delist_grid <- merge(
  params[, .(param_id, C, M, T, join_key = 1L)],
  delisting_sample[, join_key := 1L],
  by = "join_key",
  allow.cartesian = TRUE
)[, join_key := NULL]

firm_detail <- merge(
  delist_grid,
  firm_hits_confirmation[
    ,
    .(
      param_id, permno, dlstdt, dlstcd,
      detected_after_confirmation = TRUE,
      first_detecting_event_seq = event_seq,
      first_detecting_trigger_date = trigger_date,
      first_detecting_confirmation_date = classification_date
    )
  ],
  by = c("param_id", "permno", "dlstdt", "dlstcd"),
  all.x = TRUE
)

firm_detail <- merge(
  firm_detail,
  firm_hits_trigger[
    ,
    .(
      param_id, permno, dlstdt, dlstcd,
      detected_after_trigger = TRUE,
      first_trigger_event_seq = event_seq,
      first_trigger_date = trigger_date
    )
  ],
  by = c("param_id", "permno", "dlstdt", "dlstcd"),
  all.x = TRUE
)

firm_detail[is.na(detected_after_confirmation),
            detected_after_confirmation := FALSE]
firm_detail[is.na(detected_after_trigger),
            detected_after_trigger := FALSE]

firm_detail[, months_confirmation_to_delisting :=
  12L * (year(dlstdt) - year(first_detecting_confirmation_date)) +
  (month(dlstdt) - month(first_detecting_confirmation_date))]
firm_detail[, months_trigger_to_delisting :=
  12L * (year(dlstdt) - year(first_trigger_date)) +
  (month(dlstdt) - month(first_trigger_date))]

firm_counts <- firm_detail[
  ,
  .(
    any_delisting_firms_in_sample = uniqueN(permno),
    any_delisting_firms_detected_after_confirmation =
      uniqueN(permno[detected_after_confirmation == TRUE]),
    any_delisting_firms_missed_after_confirmation =
      uniqueN(permno[detected_after_confirmation == FALSE]),
    any_delisting_firms_detected_after_trigger =
      uniqueN(permno[detected_after_trigger == TRUE]),
    adverse_delisting_firms_in_sample =
      uniqueN(permno[is_adverse_delisting == TRUE]),
    adverse_delisting_firms_detected_after_confirmation =
      uniqueN(permno[
        is_adverse_delisting == TRUE & detected_after_confirmation == TRUE
      ]),
    adverse_delisting_firms_missed_after_confirmation =
      uniqueN(permno[
        is_adverse_delisting == TRUE & detected_after_confirmation == FALSE
      ]),
    adverse_delisting_firms_detected_after_trigger =
      uniqueN(permno[
        is_adverse_delisting == TRUE & detected_after_trigger == TRUE
      ]),
    median_months_confirmation_to_adverse_delist =
      as.numeric(median(months_confirmation_to_delisting[
        is_adverse_delisting == TRUE & detected_after_confirmation == TRUE
      ], na.rm = TRUE))
  ),
  by = .(param_id, C, M, T)
]
firm_counts[is.nan(median_months_confirmation_to_adverse_delist),
            median_months_confirmation_to_adverse_delist := NA_real_]

summary_grid <- merge(params, event_counts, by = "param_id", all.x = TRUE)
summary_grid <- merge(summary_grid, confirmed_firms, by = "param_id",
                      all.x = TRUE)
summary_grid <- merge(summary_grid, firm_counts,
                      by = c("param_id", "C", "M", "T"), all.x = TRUE)

summary_grid[, `:=`(
  any_delisting_detection_rate_pct = fn_pct(
    any_delisting_firms_detected_after_confirmation,
    any_delisting_firms_in_sample
  ),
  adverse_delisting_detection_rate_pct = fn_pct(
    adverse_delisting_firms_detected_after_confirmation,
    adverse_delisting_firms_in_sample
  ),
  adverse_delisting_trigger_detection_rate_pct = fn_pct(
    adverse_delisting_firms_detected_after_trigger,
    adverse_delisting_firms_in_sample
  ),
  confirmed_csi_firm_any_delisting_followup_rate_pct = fn_pct(
    any_delisting_firms_detected_after_confirmation,
    confirmed_csi_firms
  ),
  confirmed_csi_firm_adverse_delisting_followup_rate_pct = fn_pct(
    adverse_delisting_firms_detected_after_confirmation,
    confirmed_csi_firms
  ),
  confirmed_csi_event_any_delisting_followup_rate_pct = fn_pct(
    confirmed_csi_event_rows_followed_by_any_delist,
    confirmed_csi_event_rows
  ),
  confirmed_csi_event_adverse_delisting_followup_rate_pct = fn_pct(
    confirmed_csi_event_rows_followed_by_adverse_delist,
    confirmed_csi_event_rows
  )
)]

setcolorder(summary_grid, c(
  "param_id", "C", "M", "T",
  "confirmed_csi_event_rows", "confirmed_csi_firms",
  "any_delisting_firms_in_sample",
  "any_delisting_firms_detected_after_confirmation",
  "any_delisting_firms_missed_after_confirmation",
  "any_delisting_detection_rate_pct",
  "adverse_delisting_firms_in_sample",
  "adverse_delisting_firms_detected_after_confirmation",
  "adverse_delisting_firms_missed_after_confirmation",
  "adverse_delisting_detection_rate_pct",
  "adverse_delisting_firms_detected_after_trigger",
  "adverse_delisting_trigger_detection_rate_pct",
  "any_delisting_firms_detected_after_trigger",
  "confirmed_csi_firm_any_delisting_followup_rate_pct",
  "confirmed_csi_firm_adverse_delisting_followup_rate_pct",
  "confirmed_csi_event_rows_followed_by_any_delist",
  "confirmed_csi_event_any_delisting_followup_rate_pct",
  "confirmed_csi_event_rows_followed_by_adverse_delist",
  "confirmed_csi_event_adverse_delisting_followup_rate_pct",
  "median_months_confirmation_to_any_delist",
  "median_months_confirmation_to_adverse_delist"
))

setorder(summary_grid, C, M, T)

code_distribution <- firm_detail[
  is_adverse_delisting == TRUE,
  .(
    adverse_delisting_firms = uniqueN(permno),
    detected_after_confirmation = uniqueN(
      permno[detected_after_confirmation == TRUE]
    ),
    missed_after_confirmation = uniqueN(
      permno[detected_after_confirmation == FALSE]
    )
  ),
  by = .(param_id, C, M, T, dlstcd)
]
code_distribution[, detection_rate_pct := fn_pct(
  detected_after_confirmation, adverse_delisting_firms
)]
setorder(code_distribution, param_id, dlstcd)

adverse_detail <- firm_detail[is_adverse_delisting == TRUE]
setorder(adverse_detail, param_id, permno, dlstdt)

#==============================================================================#
# 4. Bankruptcy-specific detection audit
#==============================================================================#

bankruptcy_groups <- rbindlist(list(
  data.table(
    bankruptcy_group = "bankruptcy_574",
    bankruptcy_group_label = "CRSP 574 bankruptcy / declared insolvent",
    dlstcd = 574L
  ),
  data.table(
    bankruptcy_group = "bankruptcy_572_574",
    bankruptcy_group_label = "CRSP 572-574 bankruptcy-related range",
    dlstcd = 572:574
  )
))

bankruptcy_delist <- merge(
  delisting_sample,
  bankruptcy_groups,
  by = "dlstcd",
  allow.cartesian = TRUE
)

bankruptcy_grid <- merge(
  params[, .(param_id, C, M, T, join_key = 1L)],
  bankruptcy_delist[, join_key := 1L],
  by = "join_key",
  allow.cartesian = TRUE
)[, join_key := NULL]

bankruptcy_hits_confirmation <- merge(
  confirmed,
  bankruptcy_delist[
    ,
    .(
      bankruptcy_group, bankruptcy_group_label, permno,
      bankruptcy_date = dlstdt, dlstcd, dlret_effective, dlret_imputed
    )
  ],
  by = "permno",
  allow.cartesian = TRUE
)[classification_date <= bankruptcy_date]

bankruptcy_hits_confirmation <- bankruptcy_hits_confirmation[
  order(confirmation_date),
  .SD[1L],
  by = .(bankruptcy_group, param_id, permno, bankruptcy_date, dlstcd)
]

bankruptcy_hits_trigger <- merge(
  confirmed,
  bankruptcy_delist[
    ,
    .(
      bankruptcy_group, bankruptcy_group_label, permno,
      bankruptcy_date = dlstdt, dlstcd
    )
  ],
  by = "permno",
  allow.cartesian = TRUE
)[trigger_date <= bankruptcy_date]

bankruptcy_hits_trigger <- bankruptcy_hits_trigger[
  order(trigger_date),
  .SD[1L],
  by = .(bankruptcy_group, param_id, permno, bankruptcy_date, dlstcd)
]

bankruptcy_detail <- merge(
  bankruptcy_grid,
  bankruptcy_hits_confirmation[
    ,
    .(
      bankruptcy_group, param_id, permno,
      dlstdt = bankruptcy_date, dlstcd,
      detected_after_confirmation = TRUE,
      first_detecting_event_seq = event_seq,
      first_detecting_trigger_date = trigger_date,
      first_detecting_confirmation_date = classification_date
    )
  ],
  by = c("bankruptcy_group", "param_id", "permno", "dlstdt", "dlstcd"),
  all.x = TRUE
)

bankruptcy_detail <- merge(
  bankruptcy_detail,
  bankruptcy_hits_trigger[
    ,
    .(
      bankruptcy_group, param_id, permno,
      dlstdt = bankruptcy_date, dlstcd,
      detected_after_trigger = TRUE,
      first_trigger_event_seq = event_seq,
      first_trigger_date = trigger_date
    )
  ],
  by = c("bankruptcy_group", "param_id", "permno", "dlstdt", "dlstcd"),
  all.x = TRUE
)

bankruptcy_detail[is.na(detected_after_confirmation),
                  detected_after_confirmation := FALSE]
bankruptcy_detail[is.na(detected_after_trigger),
                  detected_after_trigger := FALSE]
bankruptcy_detail[, months_confirmation_to_bankruptcy :=
  12L * (year(dlstdt) - year(first_detecting_confirmation_date)) +
  (month(dlstdt) - month(first_detecting_confirmation_date))]
bankruptcy_detail[, months_trigger_to_bankruptcy :=
  12L * (year(dlstdt) - year(first_trigger_date)) +
  (month(dlstdt) - month(first_trigger_date))]

bankruptcy_detection <- bankruptcy_detail[
  ,
  .(
    bankruptcy_firms_in_sample = uniqueN(permno),
    bankruptcy_firms_detected_after_confirmation =
      uniqueN(permno[detected_after_confirmation == TRUE]),
    bankruptcy_firms_missed_after_confirmation =
      uniqueN(permno[detected_after_confirmation == FALSE]),
    bankruptcy_firms_detected_after_trigger =
      uniqueN(permno[detected_after_trigger == TRUE]),
    median_months_confirmation_to_bankruptcy =
      as.numeric(median(months_confirmation_to_bankruptcy[
        detected_after_confirmation == TRUE
      ], na.rm = TRUE))
  ),
  by = .(bankruptcy_group, bankruptcy_group_label, param_id, C, M, T)
]

bankruptcy_detection[is.nan(median_months_confirmation_to_bankruptcy),
                     median_months_confirmation_to_bankruptcy := NA_real_]
bankruptcy_detection[, `:=`(
  bankruptcy_detection_rate_pct = fn_pct(
    bankruptcy_firms_detected_after_confirmation,
    bankruptcy_firms_in_sample
  ),
  bankruptcy_trigger_detection_rate_pct = fn_pct(
    bankruptcy_firms_detected_after_trigger,
    bankruptcy_firms_in_sample
  )
)]

bankruptcy_followup_events <- merge(
  confirmed,
  bankruptcy_delist[
    ,
    .(bankruptcy_group, permno, bankruptcy_date = dlstdt)
  ],
  by = "permno",
  allow.cartesian = TRUE
)[classification_date <= bankruptcy_date]

bankruptcy_followup_events <- bankruptcy_followup_events[
  order(bankruptcy_date),
  .SD[1L],
  by = .(bankruptcy_group, param_id, event_id)
]

bankruptcy_followup_counts <- bankruptcy_followup_events[
  ,
  .(
    confirmed_csi_event_rows_followed_by_bankruptcy = .N,
    confirmed_csi_firms_followed_by_bankruptcy = uniqueN(permno)
  ),
  by = .(bankruptcy_group, param_id)
]

bankruptcy_detection <- merge(
  bankruptcy_detection,
  event_counts[, .(param_id, confirmed_csi_event_rows)],
  by = "param_id",
  all.x = TRUE
)
bankruptcy_detection <- merge(
  bankruptcy_detection,
  confirmed_firms,
  by = "param_id",
  all.x = TRUE
)
bankruptcy_detection <- merge(
  bankruptcy_detection,
  bankruptcy_followup_counts,
  by = c("bankruptcy_group", "param_id"),
  all.x = TRUE
)

bankruptcy_detection[
  is.na(confirmed_csi_event_rows_followed_by_bankruptcy),
  confirmed_csi_event_rows_followed_by_bankruptcy := 0L
]
bankruptcy_detection[
  is.na(confirmed_csi_firms_followed_by_bankruptcy),
  confirmed_csi_firms_followed_by_bankruptcy := 0L
]
bankruptcy_detection[, `:=`(
  confirmed_csi_event_bankruptcy_followup_rate_pct = fn_pct(
    confirmed_csi_event_rows_followed_by_bankruptcy,
    confirmed_csi_event_rows
  ),
  confirmed_csi_firm_bankruptcy_followup_rate_pct = fn_pct(
    confirmed_csi_firms_followed_by_bankruptcy,
    confirmed_csi_firms
  )
)]

setcolorder(bankruptcy_detection, c(
  "bankruptcy_group", "bankruptcy_group_label",
  "param_id", "C", "M", "T",
  "bankruptcy_firms_in_sample",
  "bankruptcy_firms_detected_after_confirmation",
  "bankruptcy_firms_missed_after_confirmation",
  "bankruptcy_detection_rate_pct",
  "bankruptcy_firms_detected_after_trigger",
  "bankruptcy_trigger_detection_rate_pct",
  "confirmed_csi_event_rows",
  "confirmed_csi_event_rows_followed_by_bankruptcy",
  "confirmed_csi_event_bankruptcy_followup_rate_pct",
  "confirmed_csi_firms",
  "confirmed_csi_firms_followed_by_bankruptcy",
  "confirmed_csi_firm_bankruptcy_followup_rate_pct",
  "median_months_confirmation_to_bankruptcy"
))

setorder(bankruptcy_detection, bankruptcy_group, C, M, T)
setorder(bankruptcy_detail, bankruptcy_group, param_id, permno, dlstdt)

#==============================================================================#
# 5. Persist outputs
#==============================================================================#

saveRDS(summary_grid, PATH_SUMMARY_RDS)
fwrite(summary_grid, PATH_SUMMARY_CSV)

saveRDS(adverse_detail, PATH_DETAIL_RDS)
fwrite(adverse_detail, PATH_DETAIL_CSV)

saveRDS(code_distribution, PATH_CODE_RDS)
fwrite(code_distribution, PATH_CODE_CSV)

saveRDS(bankruptcy_detection, PATH_BANKRUPTCY_RDS)
fwrite(bankruptcy_detection, PATH_BANKRUPTCY_CSV)

saveRDS(bankruptcy_detail, PATH_BANKRUPTCY_DETAIL_RDS)
fwrite(bankruptcy_detail, PATH_BANKRUPTCY_DETAIL_CSV)

base_row <- summary_grid[param_id == "C080_M020_T018"]
best_detection <- summary_grid[order(-adverse_delisting_detection_rate_pct)][1L]
weakest_detection <- summary_grid[order(adverse_delisting_detection_rate_pct)][1L]

base_bankruptcy_574 <- bankruptcy_detection[
  bankruptcy_group == "bankruptcy_574" &
    param_id == "C080_M020_T018"
]
base_bankruptcy_572_574 <- bankruptcy_detection[
  bankruptcy_group == "bankruptcy_572_574" &
    param_id == "C080_M020_T018"
]

md_lines <- c(
  "## E. Delisting Detection After Dynamic CSI Classification",
  "",
  paste0("Generated: ", format(Sys.time())),
  "",
  "This audit asks whether confirmed dynamic CSI events precede later CRSP ",
  "delistings. The headline rule counts a delisting as detected only when the ",
  "firm has a positive CSI classification before or on the delisting date. ",
  "For ordinary confirmed CSI this uses `confirmation_date <= dlstdt`; for ",
  "terminal-failure CSI this uses `terminal_failure_date <= dlstdt`. This is ",
  "stricter than the permanent-CSI ",
  "tier-i rule, which uses `trigger_date`.",
  "",
  paste0("- Sample window: ", sample_start, " to ", sample_end, "."),
  paste0("- Delisting source: `", PATH_DELISTING, "` (`crsp_a_stock.msedelist`)."),
  paste0("- Dynamic CSI source: `", PATH_CSI_EVENTS_GRID, "`."),
  "- Adverse delisting codes: `400-490` and `550-585`, as stored in ",
  "`PCL_DELISTING_ADVERSE_CODES`.",
  "",
  "### Base Grid: `C080_M020_T018`",
  "",
  paste0("- Positive CSI event rows: ",
         fn_fmt_int(base_row$confirmed_csi_event_rows), "."),
  paste0("- Positive CSI firms: ",
         fn_fmt_int(base_row$confirmed_csi_firms), "."),
  paste0("- Sample adverse-delisting firms: ",
         fn_fmt_int(base_row$adverse_delisting_firms_in_sample), "."),
  paste0("- Adverse-delisting firms detected after confirmation: ",
         fn_fmt_int(base_row$adverse_delisting_firms_detected_after_confirmation),
         " (",
         fn_fmt_pct(base_row$adverse_delisting_detection_rate_pct), ")."),
  paste0("- Adverse-delisting firms missed after confirmation: ",
         fn_fmt_int(base_row$adverse_delisting_firms_missed_after_confirmation),
         "."),
  paste0("- Positive CSI firms that later had an adverse delisting: ",
         fn_fmt_pct(
           base_row$confirmed_csi_firm_adverse_delisting_followup_rate_pct
         ),
         "."),
  paste0("- Positive CSI event rows followed by adverse delisting: ",
         fn_fmt_int(
           base_row$confirmed_csi_event_rows_followed_by_adverse_delist
         ),
         " (",
         fn_fmt_pct(
           base_row$confirmed_csi_event_adverse_delisting_followup_rate_pct
         ),
         ")."),
  paste0("- Trigger-date diagnostic detection rate for adverse delistings: ",
         fn_fmt_pct(base_row$adverse_delisting_trigger_detection_rate_pct),
         "."),
  "",
  "### Bankruptcy-Code Detection",
  "",
  "The bankruptcy-code audit repeats the same firm-level test for strict ",
  "CRSP code `574` and for the broader `572-574` range. A hit requires at ",
  "least one confirmed CSI classification before or on the bankruptcy ",
  "delisting date.",
  "",
  paste0("- Base `574` bankruptcy firms in sample: ",
         fn_fmt_int(base_bankruptcy_574$bankruptcy_firms_in_sample), "."),
  paste0("- Base `574` detected after confirmation: ",
         fn_fmt_int(
           base_bankruptcy_574$bankruptcy_firms_detected_after_confirmation
         ),
         " (",
         fn_fmt_pct(base_bankruptcy_574$bankruptcy_detection_rate_pct),
         "); missed: ",
         fn_fmt_int(
           base_bankruptcy_574$bankruptcy_firms_missed_after_confirmation
         ),
         "."),
  paste0("- Base `574` trigger-date diagnostic detection: ",
         fn_fmt_int(
           base_bankruptcy_574$bankruptcy_firms_detected_after_trigger
         ),
         " (",
         fn_fmt_pct(
           base_bankruptcy_574$bankruptcy_trigger_detection_rate_pct
         ),
         ")."),
  paste0("- Base `572-574` bankruptcy-range firms in sample: ",
         fn_fmt_int(base_bankruptcy_572_574$bankruptcy_firms_in_sample), "."),
  paste0("- Base `572-574` detected after confirmation: ",
         fn_fmt_int(
           base_bankruptcy_572_574$
             bankruptcy_firms_detected_after_confirmation
         ),
         " (",
         fn_fmt_pct(
           base_bankruptcy_572_574$bankruptcy_detection_rate_pct
         ),
         "); missed: ",
         fn_fmt_int(
           base_bankruptcy_572_574$
             bankruptcy_firms_missed_after_confirmation
         ),
         "."),
  paste0("- Base `572-574` trigger-date diagnostic detection: ",
         fn_fmt_int(
           base_bankruptcy_572_574$bankruptcy_firms_detected_after_trigger
         ),
         " (",
         fn_fmt_pct(
           base_bankruptcy_572_574$
             bankruptcy_trigger_detection_rate_pct
         ),
         ")."),
  "",
  "### Grid Range",
  "",
  paste0("- Highest adverse-delisting detection rate: `",
         best_detection$param_id, "` at ",
         fn_fmt_pct(best_detection$adverse_delisting_detection_rate_pct),
         " (",
         fn_fmt_int(
           best_detection$adverse_delisting_firms_detected_after_confirmation
         ),
         " detected, ",
         fn_fmt_int(
           best_detection$adverse_delisting_firms_missed_after_confirmation
         ),
         " missed)."),
  paste0("- Lowest adverse-delisting detection rate: `",
         weakest_detection$param_id, "` at ",
         fn_fmt_pct(weakest_detection$adverse_delisting_detection_rate_pct),
         " (",
         fn_fmt_int(
           weakest_detection$adverse_delisting_firms_detected_after_confirmation
         ),
         " detected, ",
         fn_fmt_int(
           weakest_detection$adverse_delisting_firms_missed_after_confirmation
         ),
         " missed)."),
  "",
  "### Output Files",
  "",
  paste0("- Summary table: `", PATH_SUMMARY_CSV, "`."),
  paste0("- Adverse delisting firm detail: `", PATH_DETAIL_CSV, "`."),
  paste0("- Adverse delisting code distribution: `", PATH_CODE_CSV, "`."),
  paste0("- Bankruptcy detection summary: `", PATH_BANKRUPTCY_CSV, "`."),
  paste0("- Bankruptcy firm detail: `", PATH_BANKRUPTCY_DETAIL_CSV, "`.")
)

writeLines(md_lines, PATH_MD_FRAGMENT, useBytes = TRUE)

cat(sprintf("  Wrote summary     : %s\n", PATH_SUMMARY_CSV))
cat(sprintf("  Wrote firm detail : %s\n", PATH_DETAIL_CSV))
cat(sprintf("  Wrote code dist.  : %s\n", PATH_CODE_CSV))
cat(sprintf("  Wrote bankruptcy  : %s\n", PATH_BANKRUPTCY_CSV))
cat(sprintf("  Wrote bk. detail  : %s\n", PATH_BANKRUPTCY_DETAIL_CSV))
cat(sprintf("  Wrote markdown    : %s\n", PATH_MD_FRAGMENT))

cat("\n[13b_Dynamic_CSI_Delisting_Detection.R] Base row:\n")
print(base_row)

cat("\n[13b_Dynamic_CSI_Delisting_Detection.R] DONE:",
    format(Sys.time()), "\n")
