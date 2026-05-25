#==============================================================================#
#==== 05B_Permanent_Capital_Loss.R ============================================#
#==== Hybrid Permanent-Capital-Loss Label from CSI Events =====================#
#==============================================================================#
#
# PURPOSE:
#   Build a stricter, absorbing permanent-capital-loss target on top of the
#   confirmed CSI events produced in 05A. The label is intended to support the
#   index overlay's PERMANENT exclusion rule, where firms flagged PCL = 1 are
#   removed from the investable universe and never re-entered (in contrast to
#   the dynamic CSI label, which only filters firms while their CSI state is
#   active).
#
# REFERENCE: see
#   05_Documentation/01_Methodology/03_Classification/Necessary/
#     CSI_Classification_Permanent_CSI_Methdology.md
#
# HYBRID DEFINITION (per-event):
#
#   Reference date for both tiers : trigger_date (the official CSI flag date,
#                                   e.g. 2011-09-30).
#
#   Tier (i)  Adverse CRSP delisting within PCL_DELISTING_WINDOW_MONTHS of
#             trigger_date. Adverse codes follow Campbell-Hilscher-Szilagyi
#             (2008): 400-490 (liquidations) and 550-585 (dropped for cause).
#             Missing dlret on these codes is imputed -0.55 in 02_Prices.R.
#
#   Tier (ii) NO recovery above the CSI M-ceiling within PCL_FORWARD_MONTHS
#             of trigger_date. The M-ceiling and recovery test are already
#             computed in 05A as `late_recovery` and `months_to_late_recovery`.
#             Tier (ii) is just the bounded version of that test.
#
#   PCL = 1   if Tier (i) hits, OR (full forward window observable AND no
#             recovery within PCL_FORWARD_MONTHS).
#   PCL = 0   if firm recovers within PCL_FORWARD_MONTHS AND no adverse
#             delisting in PCL_DELISTING_WINDOW_MONTHS, AND the tier-1 window
#             is fully observable (so we can confirm the absence of Tier (i)).
#   PCL = NA  otherwise (right-censored — at least one tier window extends
#             beyond the data end without a definitive resolution).
#
# OUTPUTS:
#   PATH_PCL_EVENTS_BASE : event-level base C/M/T PCL labels
#   PATH_PCL_EVENTS_GRID : event-level PCL labels for all C/M/T grid combos
#   PATH_PCL_DIAG        : per-grid PCL summary diagnostics
#   PATH_FIGURE_PCL      : PCL events per year (base case)
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(scales)
  library(lubridate)
})

cat("\n[05B_Permanent_Capital_Loss.R] START:", format(Sys.time()), "\n")

stopifnot(
  "Run 05A first: missing CSI base events" =
    file.exists(PATH_CSI_EVENTS_BASE),
  "Run 02_Prices first: missing delisting reference" =
    file.exists(PATH_DELISTING)
)
if (CSI_RUN_GRID && !file.exists(PATH_CSI_EVENTS_GRID)) {
  stop("[05B] CSI_RUN_GRID=1 but missing CSI grid events: ", PATH_CSI_EVENTS_GRID)
}

#==============================================================================#
# 0. Load inputs
#==============================================================================#

events_base <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE))
events_grid <- NULL

events_base[, trigger_date := as.Date(trigger_date)]
if (CSI_RUN_GRID) {
  events_grid <- as.data.table(readRDS(PATH_CSI_EVENTS_GRID))
  events_grid[, trigger_date := as.Date(trigger_date)]
}

delisting_full <- as.data.table(readRDS(PATH_DELISTING))
delisting_full[, dlstdt := as.Date(dlstdt)]

cat(sprintf("  Base CSI event rows : %d\n", nrow(events_base)))
if (CSI_RUN_GRID) {
  cat(sprintf("  Grid CSI event rows : %d\n", nrow(events_grid)))
} else {
  cat("  Grid CSI event rows : skipped (CSI_RUN_GRID=0)\n")
}
cat(sprintf("  Delisting records   : %d  (raw, all permno)\n",
            nrow(delisting_full)))

#==============================================================================#
# 1. Adverse-delisting reference table
#
#   Reapply the Shumway imputation here so this script is self-contained for
#   diagnostic purposes (the imputed dlret has already been propagated into
#   prices_monthly by 02_Prices.R; we only need the dlstcd / dlstdt for the
#   Tier (i) window check).
#==============================================================================#

adverse_delist <- delisting_full[
  dlstcd %in% PCL_DELISTING_ADVERSE_CODES & !is.na(dlstdt),
  .(permno, dlstdt, dlstcd, dlret_raw = dlret)
]
adverse_delist[, dlret_imputed := dlstcd %in% PCL_DLRET_IMPUTE_TRIGGER_CODES &
                                  is.na(dlret_raw)]
adverse_delist[, dlret := fifelse(dlret_imputed,
                                  PCL_DLRET_IMPUTE_VALUE, dlret_raw)]
setorder(adverse_delist, permno, dlstdt)

cat(sprintf("  Adverse delistings  : %d  (codes %s)\n",
            nrow(adverse_delist),
            paste(range(PCL_DELISTING_ADVERSE_CODES), collapse = "-")))
cat(sprintf("  Imputed dlret       : %d  (NA dlret on adverse codes -> %.2f)\n",
            sum(adverse_delist$dlret_imputed), PCL_DLRET_IMPUTE_VALUE))

#==============================================================================#
# 2. PCL labelling function — applied per (C, M, T) parameter set
#==============================================================================#

fn_label_permanent_loss <- function(events_dt, adverse_dt, end_date) {

  out <- copy(events_dt)
  out[, trigger_date := as.Date(trigger_date)]

  ## Months from trigger to data end. Negative values would indicate trigger
  ## beyond the data window which should not happen — guard with pmax(0).
  out[, months_observed := pmax(
    0L,
    12L * (year(end_date)  - year(trigger_date)) +
      (month(end_date) - month(trigger_date))
  )]

  ## Window observability
  out[, tier1_window_complete := months_observed >= PCL_DELISTING_WINDOW_MONTHS]
  out[, tier2_window_complete := months_observed >= PCL_FORWARD_MONTHS]

  ## Tier (ii) recovery test from existing 05A fields:
  ## recovery happens at month `months_to_late_recovery` after trigger.
  ## We bound this to PCL_FORWARD_MONTHS. NA months_to_late_recovery means
  ## either no late_recovery flag or no observation, both of which count as
  ## "no recovery within 5y" for PCL purposes.
  out[, recovered_within_5y :=
        !is.na(late_recovery) & late_recovery == TRUE &
        !is.na(months_to_late_recovery) &
        months_to_late_recovery <= PCL_FORWARD_MONTHS]

  ## Tier (i) adverse-delisting test
  ##   For each event row, does the firm have an adverse delisting in
  ##   [trigger_date, trigger_date + PCL_DELISTING_WINDOW_MONTHS]?
  ##   If so, record dlstdt and dlstcd of the FIRST such delisting.
  out[, `:=`(
    pcl_delisting_date = as.Date(NA),
    pcl_delisting_code = NA_integer_,
    pcl_delisting_dlret = NA_real_,
    has_adverse_delist = FALSE
  )]

  if (nrow(adverse_dt) > 0L) {
    ev_idx <- out[, .(
      permno,
      ev_row = .I,
      win_start = trigger_date,
      win_end = trigger_date %m+% months(PCL_DELISTING_WINDOW_MONTHS)
    )]

    adverse_int <- adverse_dt[, .(
      permno,
      dl_start = dlstdt,
      dl_end = dlstdt,
      dlstdt,
      dlstcd,
      dlret
    )]

    setkey(ev_idx, permno, win_start, win_end)
    setkey(adverse_int, permno, dl_start, dl_end)
    hits <- foverlaps(
      ev_idx,
      adverse_int,
      by.x = c("permno", "win_start", "win_end"),
      by.y = c("permno", "dl_start", "dl_end"),
      type = "any",
      nomatch = 0L
    )

    if (nrow(hits) > 0L) {
      first_hits <- hits[
        order(ev_row, dlstdt),
        .SD[1L],
        by = ev_row
      ]
      out[first_hits$ev_row, `:=`(
        pcl_delisting_date = first_hits$dlstdt,
        pcl_delisting_code = first_hits$dlstcd,
        pcl_delisting_dlret = first_hits$dlret,
        has_adverse_delist = TRUE
      )]
    }
  }

  ## Tier label decisions are meaningful for positive temporary CSI events:
  ## ordinary T-month confirmations plus terminal bankruptcy failures.
  out[, eligible := event_status %in% CSI_POSITIVE_EVENT_STATUSES]

  out[, y_perm_event := NA_integer_]
  out[eligible == TRUE, y_perm_event := fcase(
    has_adverse_delist == TRUE,                           1L,   ## Tier (i)
    tier1_window_complete == FALSE,                       NA_integer_,
    tier2_window_complete == TRUE & recovered_within_5y == FALSE, 1L,   ## Tier (ii)
    recovered_within_5y == TRUE,                          0L,   ## explicit recovery
    default                                              = NA_integer_
  )]

  ## Human-readable status for diagnostics
  out[, perm_status := fcase(
    eligible == FALSE,                                  "not_confirmed_csi",
    has_adverse_delist == TRUE,                         "permanent_loss_tier1",
    tier1_window_complete == FALSE,                     "censored_tier1",
    tier2_window_complete == TRUE & recovered_within_5y == FALSE,
                                                        "permanent_loss_tier2",
    recovered_within_5y == TRUE,                        "recovered_within_5y",
    default                                           = "censored_tier2"
  )]

  out[]
}

#==============================================================================#
# 3. Apply to base case and grid
#==============================================================================#

cat("\n[05B] Computing base PCL labels...\n")
pcl_base <- fn_label_permanent_loss(events_base, adverse_delist, END_DATE)

saveRDS(pcl_base, PATH_PCL_EVENTS_BASE)

if (CSI_RUN_GRID) {
  cat("[05B] Computing grid PCL labels...\n")
  pcl_grid <- fn_label_permanent_loss(events_grid, adverse_delist, END_DATE)
  saveRDS(pcl_grid, PATH_PCL_EVENTS_GRID)
  diag_events <- pcl_grid
} else {
  cat("[05B] Skipping grid PCL labels (CSI_RUN_GRID=0). Existing grid file, if any, is left untouched.\n")
  diag_events <- pcl_base
}

#==============================================================================#
# 4. Diagnostics
#==============================================================================#

pcl_diag <- diag_events[event_status %in% CSI_POSITIVE_EVENT_STATUSES, .(
  n_confirmed_csi   = .N,
  n_perm_loss       = sum(y_perm_event == 1L,  na.rm = TRUE),
  n_perm_tier1      = sum(perm_status == "permanent_loss_tier1"),
  n_perm_tier2      = sum(perm_status == "permanent_loss_tier2"),
  n_recovered       = sum(y_perm_event == 0L,  na.rm = TRUE),
  n_censored        = sum(is.na(y_perm_event)),
  n_censored_tier1  = sum(perm_status == "censored_tier1"),
  n_censored_tier2  = sum(perm_status == "censored_tier2"),
  permanent_rate    = mean(y_perm_event == 1L, na.rm = TRUE),
  recovery_rate     = mean(y_perm_event == 0L, na.rm = TRUE),
  median_dd_trigger = median(drawdown_trigger, na.rm = TRUE)
), by = .(param_id, C, M, T)]

saveRDS(pcl_diag, PATH_PCL_DIAG)

base_positive <- pcl_base[event_status %in% CSI_POSITIVE_EVENT_STATUSES]
cat("\n  Base PCL summary (positive temporary CSI events):\n")
cat(sprintf("    Positive CSI events        : %d\n", nrow(base_positive)))
cat(sprintf("    PCL = 1  (permanent loss)  : %d\n",
            sum(base_positive$y_perm_event == 1L, na.rm = TRUE)))
cat(sprintf("      Tier 1 (delisting)       : %d\n",
            sum(base_positive$perm_status == "permanent_loss_tier1")))
cat(sprintf("      Tier 2 (no recovery 5y)  : %d\n",
            sum(base_positive$perm_status == "permanent_loss_tier2")))
cat(sprintf("    PCL = 0  (recovered <= 5y) : %d\n",
            sum(base_positive$y_perm_event == 0L, na.rm = TRUE)))
cat(sprintf("    PCL = NA (right-censored)  : %d\n",
            sum(is.na(base_positive$y_perm_event))))
cat(sprintf("      Censored tier 1          : %d\n",
            sum(base_positive$perm_status == "censored_tier1")))
cat(sprintf("      Censored tier 2          : %d\n",
            sum(base_positive$perm_status == "censored_tier2")))
cat(sprintf("    Permanent rate among resolved: %.1f%%\n",
            100 * mean(base_positive$y_perm_event == 1L, na.rm = TRUE)))

#==============================================================================#
# 5. Figure: PCL events per year (base case)
#==============================================================================#

events_per_year <- pcl_base[
  event_status %in% CSI_POSITIVE_EVENT_STATUSES,
  .(
    n_perm = sum(y_perm_event == 1L, na.rm = TRUE),
    n_rec  = sum(y_perm_event == 0L, na.rm = TRUE),
    n_cens = sum(is.na(y_perm_event))
  ),
  by = .(year = year(trigger_date))
]
events_long <- melt(
  events_per_year,
  id.vars = "year",
  variable.name = "pcl_outcome",
  value.name = "n"
)
events_long[, pcl_outcome := factor(
  pcl_outcome,
  levels = c("n_perm", "n_rec", "n_cens"),
  labels = c("Permanent loss (PCL=1)",
             "Recovered (PCL=0)",
             "Right-censored (PCL=NA)")
)]

p_pcl <- ggplot(events_long, aes(x = year, y = n, fill = pcl_outcome)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = c(
    "Permanent loss (PCL=1)"     = "#b2182b",
    "Recovered (PCL=0)"          = "#1a9850",
    "Right-censored (PCL=NA)"    = "#bdbdbd"
  )) +
  labs(
    title = "Permanent Capital Loss Outcomes per Trigger Year — Base Case",
    subtitle = sprintf(
      "C=%.2f | M=%.2f | T=%d months  |  forward=%dm | tier1 window=%dm",
      CSI_BASE$C, CSI_BASE$M, CSI_BASE$T,
      PCL_FORWARD_MONTHS, PCL_DELISTING_WINDOW_MONTHS
    ),
    x = "Trigger year",
    y = "Positive temporary CSI events",
    fill = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave(PATH_FIGURE_PCL, p_pcl,
       width = PLOT_WIDTH, height = PLOT_HEIGHT, dpi = PLOT_DPI)

#==============================================================================#
# 6. Done
#==============================================================================#

cat("\n[05B] DONE\n")
cat(sprintf("  Base PCL events  : %s\n", PATH_PCL_EVENTS_BASE))
cat(sprintf("  Grid PCL events  : %s\n", PATH_PCL_EVENTS_GRID))
cat(sprintf("  Diagnostics      : %s\n", PATH_PCL_DIAG))
cat(sprintf("  Figure           : %s\n", PATH_FIGURE_PCL))
