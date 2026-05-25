#==============================================================================#
#==== 13c_Old_CSI_Recovery_Buckets_All_Grid.R =================================#
#==============================================================================#
#
# PURPOSE:
#   For the old temporary-CSI methodology, recompute five-year post-confirmation
#   recovery buckets for all 27 C/M/T grid combinations.
#
#   This deliberately uses only:
#     event_status == "confirmed_csi"
#
#   Therefore it excludes the revised 572-574 terminal-failure additions and
#   matches the original 8,369-event base calculation for C080_M020_T018.
#
# RECOVERY CLOCK:
#   For each confirmed CSI event, start at confirmation_date and inspect the
#   next 60 months. Recovery is measured by maximum wealth over that horizon
#   relative to wealth at the original trigger date.
#
# BUCKETS:
#   1. stayed_below_M              : max return <= M
#   2. recovered_M_to_0            : M < max return <= 0
#   3. recovered_0_to_absC         : 0 < max return <= |C|
#   4. recovered_more_than_absC    : max return > |C|
#   5. no_followup                 : no usable 5-year follow-up observation
#
# OUTPUTS:
#   03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/
#     G_old_csi_recovery_buckets_all_grid_firm_summary.csv
#     G_old_csi_recovery_buckets_all_grid_event_summary.csv
#     G_old_csi_recovery_buckets_all_grid_detail.csv
#
#   05_Documentation/04_Robustness/01_Dynamic_CSI/Necessary/
#     old_csi_recovery_buckets_all_grid.md
#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(parallel)
})

if (!nzchar(Sys.getenv("MT_ROOT"))) {
  Sys.setenv(MT_ROOT = "/workspace/AgonyAndExcstasy")
}

# Force old methodology semantics for this diagnostic. We still read the current
# grid event file, but only old confirmed_csi rows are used downstream.
Sys.setenv(CSI_USE_TERMINAL_FAILURE_INDICATORS = "0")

setwd(file.path(Sys.getenv("MT_ROOT"), "01_Code", "pipeline"))
source("config.R")

cat("\n[13c_Old_CSI_Recovery_Buckets_All_Grid.R] START:",
    format(Sys.time()), "\n")

out_dir <- DIR_ROB_GRID_TRACK  ## 03_Data_Output/2_Robustness_Checks/Necessary/{track_folder}/csi_parameter_grid_results/
doc_dir <- file.path(DIR_ROOT, "05_Documentation", "04_Robustness",
                     "01_Dynamic_CSI", "Necessary")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(doc_dir, recursive = TRUE, showWarnings = FALSE)

bucket_levels <- c(
  "stayed_below_M",
  "recovered_M_to_0",
  "recovered_0_to_absC",
  "recovered_more_than_absC",
  "no_followup"
)

fmt_int <- function(x) format(as.integer(x), big.mark = ",", trim = TRUE)
fmt_pct <- function(x) sprintf("%.1f%%", x)

#==============================================================================#
# 1. Load old confirmed CSI events and monthly wealth path
#==============================================================================#

events <- as.data.table(readRDS(PATH_CSI_EVENTS_GRID))
events <- events[event_status == "confirmed_csi"]
events[, old_event_row_id := .I]

if (nrow(events) == 0L) {
  stop("No confirmed_csi events found in PATH_CSI_EVENTS_GRID: ",
       PATH_CSI_EVENTS_GRID)
}

cat(sprintf("  Confirmed CSI event rows: %s | param grids: %d\n",
            fmt_int(nrow(events)), uniqueN(events$param_id)))

prices <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
universe <- as.data.table(readRDS(PATH_UNIVERSE))
setnames(prices, "ret_adj", "ret", skip_absent = TRUE)

prices <- prices[permno %in% universe$permno]
prices[, `:=`(
  date = as.Date(date),
  ret = fifelse(is.na(ret), NA_real_, pmin(pmax(ret, -0.99), 10))
)]
setorder(prices, permno, date)
prices[, ret_clean := fifelse(is.na(ret), 0, ret)]
prices[, wealth_index := cumprod(1 + ret_clean), by = permno]

prices_points <- prices[
  ,
  .(
    permno,
    date_start = date,
    date_end = date,
    wealth_index
  )
]
setkey(prices_points, permno, date_start, date_end)

#==============================================================================#
# 2. Parallel per-grid computation
#==============================================================================#

requested_workers <- as.integer(Sys.getenv("CSI_RECOVERY_WORKERS", unset = "0"))
available_cores <- max(1L, detectCores(logical = TRUE) - 2L)
param_ids <- sort(unique(events$param_id))
workers <- if (is.na(requested_workers) || requested_workers <= 0L) {
  min(length(param_ids), available_cores)
} else {
  min(length(param_ids), requested_workers)
}

cat(sprintf("  Parallel workers: %d\n", workers))

classify_param <- function(pid) {
  ev <- copy(events[param_id == pid])
  setorder(ev, permno, trigger_date, event_seq)

  ev[, `:=`(
    horizon_start = as.Date(confirmation_date),
    horizon_end = as.Date(confirmation_date) %m+% months(60),
    interval_start = as.Date(confirmation_date) + 1L,
    interval_end = as.Date(confirmation_date) %m+% months(60)
  )]

  intervals <- ev[
    ,
    .(
      permno,
      interval_start,
      interval_end,
      old_event_row_id
    )
  ]
  setnames(intervals,
           c("interval_start", "interval_end"),
           c("date_start", "date_end"))
  setkey(intervals, permno, date_start, date_end)

  path_join <- foverlaps(
    prices_points,
    intervals,
    by.x = c("permno", "date_start", "date_end"),
    by.y = c("permno", "date_start", "date_end"),
    type = "within",
    nomatch = 0L
  )

  path_max <- path_join[
    ,
    .(
      n_months_observed_5y = .N,
      max_path_wealth_5y = max(wealth_index, na.rm = TRUE)
    ),
    by = old_event_row_id
  ]

  ev <- merge(ev, path_max, by = "old_event_row_id", all.x = TRUE)
  ev[is.na(n_months_observed_5y), n_months_observed_5y := 0L]
  ev[is.infinite(max_path_wealth_5y), max_path_wealth_5y := NA_real_]

  ev[, terminal_candidate_wealth := fifelse(
    !is.na(terminal_date) & terminal_date <= horizon_end,
    terminal_wealth,
    NA_real_
  )]

  ev[, max_wealth_5y := pmax(
    max_path_wealth_5y,
    terminal_candidate_wealth,
    na.rm = TRUE
  )]
  ev[is.infinite(max_wealth_5y), max_wealth_5y := NA_real_]

  ev[, max_return_5y_vs_trigger := max_wealth_5y / wealth_trigger - 1]
  ev[, recovery_bucket_5y := fifelse(
    is.na(max_return_5y_vs_trigger),
    "no_followup",
    fifelse(
      max_return_5y_vs_trigger <= M,
      "stayed_below_M",
      fifelse(
        max_return_5y_vs_trigger <= 0,
        "recovered_M_to_0",
        fifelse(
          max_return_5y_vs_trigger <= abs(C),
          "recovered_0_to_absC",
          "recovered_more_than_absC"
        )
      )
    )
  )]

  event_summary <- ev[, .N, by = .(param_id, C, M, T, recovery_bucket_5y)]
  event_summary <- merge(
    CJ(param_id = unique(ev$param_id),
       recovery_bucket_5y = bucket_levels,
       unique = TRUE),
    event_summary,
    by = c("param_id", "recovery_bucket_5y"),
    all.x = TRUE
  )
  event_summary[is.na(N), N := 0L]
  event_summary[, `:=`(
    C = unique(ev$C),
    M = unique(ev$M),
    T = unique(ev$T)
  )]
  event_summary[, pct_of_events := 100 * N / sum(N), by = param_id]

  first_event <- ev[order(permno, trigger_date, event_seq), .SD[1], by = permno]
  firm_summary <- first_event[
    ,
    .N,
    by = .(param_id, C, M, T, recovery_bucket_5y)
  ]
  firm_summary <- merge(
    CJ(param_id = unique(ev$param_id),
       recovery_bucket_5y = bucket_levels,
       unique = TRUE),
    firm_summary,
    by = c("param_id", "recovery_bucket_5y"),
    all.x = TRUE
  )
  firm_summary[is.na(N), N := 0L]
  firm_summary[, `:=`(
    C = unique(ev$C),
    M = unique(ev$M),
    T = unique(ev$T)
  )]
  firm_summary[, pct_of_firms := 100 * N / sum(N), by = param_id]

  detail_cols <- c(
    "param_id", "C", "M", "T", "permno", "event_seq",
    "trigger_date", "confirmation_date", "event_status",
    "wealth_trigger", "recovery_ceiling", "window_max",
    "terminal_wealth", "terminal_date", "exit_date",
    "horizon_start", "horizon_end", "n_months_observed_5y",
    "max_wealth_5y", "max_return_5y_vs_trigger", "recovery_bucket_5y"
  )

  list(
    event_summary = event_summary,
    firm_summary = firm_summary,
    detail = ev[, ..detail_cols]
  )
}

results <- if (.Platform$OS.type == "unix" && workers > 1L) {
  mclapply(param_ids, classify_param, mc.cores = workers)
} else {
  lapply(param_ids, classify_param)
}

event_summary <- rbindlist(lapply(results, `[[`, "event_summary"), fill = TRUE)
firm_summary <- rbindlist(lapply(results, `[[`, "firm_summary"), fill = TRUE)
detail <- rbindlist(lapply(results, `[[`, "detail"), fill = TRUE)

setorder(event_summary, C, M, T, recovery_bucket_5y)
setorder(firm_summary, C, M, T, recovery_bucket_5y)
setorder(detail, C, M, T, permno, trigger_date, event_seq)

#==============================================================================#
# 3. Write outputs and documentation
#==============================================================================#

csv_firm <- file.path(out_dir, "G_old_csi_recovery_buckets_all_grid_firm_summary.csv")
csv_event <- file.path(out_dir, "G_old_csi_recovery_buckets_all_grid_event_summary.csv")
csv_detail <- file.path(out_dir, "G_old_csi_recovery_buckets_all_grid_detail.csv")
rds_detail <- file.path(out_dir, "G_old_csi_recovery_buckets_all_grid_detail.rds")

fwrite(firm_summary, csv_firm)
fwrite(event_summary, csv_event)
fwrite(detail, csv_detail)
saveRDS(detail, rds_detail)

wide_firm <- dcast(
  firm_summary,
  param_id + C + M + T ~ recovery_bucket_5y,
  value.var = c("N", "pct_of_firms")
)
setorder(wide_firm, C, M, T)

md_table <- c(
  "| param_id | C | M | T | stayed below M | % | M to 0 | % | 0 to abs(C) | % | > abs(C) | % | no follow-up | % |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
)

get_val <- function(dt, col) if (col %in% names(dt)) dt[[col]] else rep(0, nrow(dt))

for (i in seq_len(nrow(wide_firm))) {
  md_table <- c(md_table, sprintf(
    "| `%s` | %.1f | %.1f | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
    wide_firm$param_id[i],
    wide_firm$C[i],
    wide_firm$M[i],
    wide_firm$T[i],
    fmt_int(get_val(wide_firm, "N_stayed_below_M")[i]),
    fmt_pct(get_val(wide_firm, "pct_of_firms_stayed_below_M")[i]),
    fmt_int(get_val(wide_firm, "N_recovered_M_to_0")[i]),
    fmt_pct(get_val(wide_firm, "pct_of_firms_recovered_M_to_0")[i]),
    fmt_int(get_val(wide_firm, "N_recovered_0_to_absC")[i]),
    fmt_pct(get_val(wide_firm, "pct_of_firms_recovered_0_to_absC")[i]),
    fmt_int(get_val(wide_firm, "N_recovered_more_than_absC")[i]),
    fmt_pct(get_val(wide_firm, "pct_of_firms_recovered_more_than_absC")[i]),
    fmt_int(get_val(wide_firm, "N_no_followup")[i]),
    fmt_pct(get_val(wide_firm, "pct_of_firms_no_followup")[i])
  ))
}

base <- wide_firm[param_id == "C080_M020_T018"]

md <- c(
  "# Old Temporary CSI Recovery Buckets: All 27 Grids",
  "",
  paste0("Generated: ", format(Sys.time())),
  "",
  "This diagnostic uses the old temporary-CSI methodology only: `event_status == confirmed_csi`. It excludes the revised CRSP `572-574` terminal-failure additions.",
  "",
  "Recovery is measured over the 60 months after the CSI confirmation date. The recovery metric is the maximum wealth in that window relative to wealth at the original trigger date:",
  "",
  "```text",
  "max_return_5y_vs_trigger = max(wealth within 60 months after confirmation) / wealth_at_trigger - 1",
  "```",
  "",
  "Firm percentages use each firm's first old-methodology CSI event within each grid, so repeat CSI events do not double-count the same firm inside a given C/M/T combination.",
  "",
  "## Base Grid Check",
  "",
  paste0("- Base grid: `C080_M020_T018`."),
  paste0("- Stayed below M firms: ", fmt_int(get_val(base, "N_stayed_below_M")), " (", fmt_pct(get_val(base, "pct_of_firms_stayed_below_M")), ")."),
  paste0("- Recovered from M to 0 firms: ", fmt_int(get_val(base, "N_recovered_M_to_0")), " (", fmt_pct(get_val(base, "pct_of_firms_recovered_M_to_0")), ")."),
  paste0("- Recovered from 0 to |C| firms: ", fmt_int(get_val(base, "N_recovered_0_to_absC")), " (", fmt_pct(get_val(base, "pct_of_firms_recovered_0_to_absC")), ")."),
  paste0("- Recovered more than |C| firms: ", fmt_int(get_val(base, "N_recovered_more_than_absC")), " (", fmt_pct(get_val(base, "pct_of_firms_recovered_more_than_absC")), ")."),
  "",
  "## Firm-Level Recovery Buckets",
  "",
  md_table,
  "",
  "## Output Files",
  "",
  paste0("- Firm summary: `", csv_firm, "`."),
  paste0("- Event-row summary: `", csv_event, "`."),
  paste0("- Event detail CSV: `", csv_detail, "`."),
  paste0("- Event detail RDS: `", rds_detail, "`.")
)

md_path <- file.path(doc_dir, "old_csi_recovery_buckets_all_grid.md")
writeLines(md, md_path, useBytes = TRUE)

cat("Wrote:", csv_firm, "\n")
cat("Wrote:", csv_event, "\n")
cat("Wrote:", csv_detail, "\n")
cat("Wrote:", rds_detail, "\n")
cat("Wrote:", md_path, "\n")
cat("\n[13c_Old_CSI_Recovery_Buckets_All_Grid.R] DONE:",
    format(Sys.time()), "\n")
