#==============================================================================#
#==== 05C_Label_Preparation.R =================================================#
#==== Annual Labels from Monthly Dynamic and Permanent CSI Events =============#
#==============================================================================#
#
# PURPOSE:
#   Prepare model-ready annual labels from event-level outputs of 05A and 05B.
#   Both target tracks are kept separate:
#
#     1. y_dynamic_csi   : paper-style Tewari CSI event-entry target
#     2. y_permanent_csi : permanent-capital-loss CSI target
#
# METHODOLOGY:
#   Events are detected at monthly frequency, then aligned to annual firm-year
#   observations exactly as in the paper-style setup:
#
#     confirmed trigger in calendar year t+1  ->  y_{i,t} = 1
#
#   Equivalently:
#
#     event_year = year(trigger_date)
#     label_year = event_year - 1
#
#   The trigger year is used, not the later confirmation or validation year.
#
# IMPORTANT:
#   Event dates, confirmation dates, validation dates, and label-year metadata
#   are kept only for diagnostics and interpretation. They must not be passed
#   into model feature matrices.
#
# OUTPUTS:
#   PATH_LABELS_DYNAMIC     : annual dynamic CSI target
#   PATH_LABELS_PERMANENT   : annual permanent CSI target
#   PATH_LABELS_MODEL_READY : merged annual label file with both targets
#
# COMPATIBILITY OUTPUTS:
#   PATH_LABELS_BASE        : dynamic CSI target with generic y column
#   PATH_LABELS_STRUCTURAL  : permanent CSI target with y_structural alias
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[05C_Label_Preparation.R] START:", format(Sys.time()), "\n")

stopifnot("Run 05A first: missing CSI base events" = file.exists(PATH_CSI_EVENTS_BASE))
stopifnot("Run 05B first: missing permanent-loss events" = file.exists(PATH_PCL_EVENTS_BASE))

events_dyn  <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE))
events_perm <- as.data.table(readRDS(PATH_PCL_EVENTS_BASE))
prices      <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
universe    <- as.data.table(readRDS(PATH_UNIVERSE))

prices[, date := as.Date(date)]
prices <- prices[permno %in% universe$permno]
prices[, year := year(date)]

events_dyn[, trigger_date := as.Date(trigger_date)]
events_dyn[, confirmation_date := as.Date(confirmation_date)]
events_perm[, trigger_date := as.Date(trigger_date)]
events_perm[, confirmation_date := as.Date(confirmation_date)]
if ("validation_end_date" %in% names(events_perm)) {
  events_perm[, validation_end_date := as.Date(validation_end_date)]
}

cat(sprintf("  Dynamic event rows   : %d\n", nrow(events_dyn)))
cat(sprintf("  Permanent event rows : %d\n", nrow(events_perm)))

#==============================================================================#
# 1. Annual firm-year panel
#==============================================================================#

years <- seq(year(START_DATE), year(END_DATE))
annual_panel <- CJ(
  permno = sort(unique(prices$permno)),
  year = years
)

firm_years <- unique(prices[, .(permno, year)])
annual_panel <- annual_panel[firm_years, on=.(permno, year), nomatch=0]

## Under the paper-style alignment, row year t predicts whether an event
## triggers in calendar year t + 1. The final observed calendar year has no
## observable t + 1 event year and is therefore right-censored.
max_label_year <- year(END_DATE) - LABEL_EVENT_YEAR_LAG

cat(sprintf("  Annual rows          : %d | years %d-%d\n",
            nrow(annual_panel), min(annual_panel$year), max(annual_panel$year)))

#==============================================================================#
# 2. Annual event-year alignment helper
#==============================================================================#

fn_align_by_event_year <- function(panel_dt,
                                   events_dt,
                                   event_filter,
                                   censored_filter,
                                   target_col,
                                   prefix) {
  event_expr <- substitute(event_filter)
  cens_expr  <- substitute(censored_filter)

  panel <- copy(panel_dt)
  panel[, (target_col) := 0L]
  panel[, paste0(prefix, "_label_censored") := FALSE]
  panel[, paste0(prefix, "_event_date") := as.Date(NA)]
  panel[, paste0(prefix, "_confirmation_date") := as.Date(NA)]
  panel[, paste0(prefix, "_event_year") := NA_integer_]
  panel[, paste0(prefix, "_label_year") := NA_integer_]
  cens_col <- paste0(prefix, "_label_censored")
  panel[year > max_label_year, (target_col) := NA_integer_]
  panel[year > max_label_year, (cens_col) := TRUE]

  if (nrow(events_dt) == 0L) return(panel[])

  pos <- copy(events_dt[eval(event_expr)])
  if (nrow(pos) > 0L) {
    pos[, `:=`(
      event_year = year(trigger_date),
      label_year = year(trigger_date) - 1L
    )]
    setorder(pos, permno, label_year, trigger_date)
    first_pos <- pos[, .SD[1L], by=.(permno, label_year)]

    panel[first_pos, (target_col) := 1L,
          on=.(permno, year=label_year)]
    panel[first_pos, paste0(prefix, "_event_date") := i.trigger_date,
          on=.(permno, year=label_year)]
    panel[first_pos, paste0(prefix, "_confirmation_date") := i.confirmation_date,
          on=.(permno, year=label_year)]
    panel[first_pos, paste0(prefix, "_event_year") := i.event_year,
          on=.(permno, year=label_year)]
    panel[first_pos, paste0(prefix, "_label_year") := i.label_year,
          on=.(permno, year=label_year)]
  }

  cens <- copy(events_dt[eval(cens_expr)])
  if (nrow(cens) > 0L) {
    cens[, label_year := year(trigger_date) - 1L]
    cens_keys <- unique(cens[, .(permno, label_year)])

    panel[cens_keys,
          (cens_col) := get(target_col) != 1L,
          on=.(permno, year=label_year)]
    panel[get(cens_col) == TRUE, (target_col) := NA_integer_]
  }

  panel[]
}

#==============================================================================#
# 3. Dynamic CSI labels
#==============================================================================#

cat("\n[05C] Aligning dynamic CSI labels via event_year - 1...\n")

labels_dynamic <- fn_align_by_event_year(
  annual_panel,
  events_dyn,
  event_filter = event_status %in% CSI_POSITIVE_EVENT_STATUSES,
  censored_filter = event_status == "censored",
  target_col = "y_dynamic_csi",
  prefix = "dynamic"
)

labels_dynamic[, `:=`(
  y = y_dynamic_csi,
  label_type = "dynamic_csi",
  label_alignment = "event_year_minus_1"
)]

cat(sprintf("  Dynamic positives: %d | usable rows: %d | prevalence: %.2f%%\n",
            sum(labels_dynamic$y_dynamic_csi == 1L, na.rm=TRUE),
            sum(!is.na(labels_dynamic$y_dynamic_csi)),
            100 * mean(labels_dynamic$y_dynamic_csi == 1L, na.rm=TRUE)))

saveRDS(labels_dynamic[, .(
  permno, year,
  y_dynamic_csi, y,
  dynamic_label_censored,
  dynamic_event_date,
  dynamic_confirmation_date,
  dynamic_event_year,
  dynamic_label_year,
  label_type,
  label_alignment
)], PATH_LABELS_DYNAMIC)

#==============================================================================#
# 4. Permanent capital-loss labels
#==============================================================================#

cat("\n[05C] Aligning permanent capital-loss labels via event_year - 1...\n")

labels_perm <- fn_align_by_event_year(
  annual_panel,
  events_perm,
  event_filter = y_perm_event == 1L,
  censored_filter = is.na(y_perm_event) & event_status %in% CSI_POSITIVE_EVENT_STATUSES,
  target_col = "y_permanent_csi",
  prefix = "permanent"
)

labels_perm[, `:=`(
  y = y_permanent_csi,
  y_structural = y_permanent_csi,
  label_type = "permanent_capital_loss",
  label_alignment = "event_year_minus_1"
)]

##---------------------------------------------------------------------------##
## Bring through PCL hybrid diagnostic columns (per first event in each
## (permno, label_year) cell). These are passthrough only — they must NOT
## enter the model feature matrix and are excluded by 06B's id_cols list.
##---------------------------------------------------------------------------##

events_perm_diag <- events_perm[
  event_status %in% CSI_POSITIVE_EVENT_STATUSES,
  .(permno, label_year = year(trigger_date) - 1L,
    perm_status, has_adverse_delist,
    pcl_delisting_date, pcl_delisting_code,
    recovered_within_5y, months_to_late_recovery,
    months_observed,
    tier1_window_complete, tier2_window_complete)
]
setorder(events_perm_diag, permno, label_year, pcl_delisting_date,
         na.last = TRUE)
events_perm_diag <- events_perm_diag[, .SD[1L], by = .(permno, label_year)]

labels_perm <- merge(
  labels_perm,
  events_perm_diag,
  by.x = c("permno", "year"),
  by.y = c("permno", "label_year"),
  all.x = TRUE
)

cat(sprintf("  Permanent positives: %d | usable rows: %d | prevalence: %.2f%%\n",
            sum(labels_perm$y_permanent_csi == 1L, na.rm=TRUE),
            sum(!is.na(labels_perm$y_permanent_csi)),
            100 * mean(labels_perm$y_permanent_csi == 1L, na.rm=TRUE)))

saveRDS(labels_perm[, .(
  permno, year,
  y_permanent_csi, y, y_structural,
  permanent_label_censored,
  permanent_event_date,
  permanent_confirmation_date,
  permanent_event_year,
  permanent_label_year,
  ## Hybrid PCL diagnostic passthrough (id columns, not features)
  perm_status,
  has_adverse_delist,
  pcl_delisting_date,
  pcl_delisting_code,
  recovered_within_5y,
  months_to_late_recovery,
  months_observed,
  tier1_window_complete,
  tier2_window_complete,
  label_type,
  label_alignment
)], PATH_LABELS_PERMANENT)

#==============================================================================#
# 5. Merged model-ready labels
#==============================================================================#

model_ready <- merge(
  labels_dynamic[, .(
    permno, year,
    y_dynamic_csi,
    dynamic_label_censored,
    dynamic_event_date,
    dynamic_confirmation_date,
    dynamic_event_year,
    dynamic_label_year
  )],
  labels_perm[, .(
    permno, year,
    y_permanent_csi,
    y_structural,
    permanent_label_censored,
    permanent_event_date,
    permanent_confirmation_date,
    permanent_event_year,
    permanent_label_year,
    perm_status,
    has_adverse_delist,
    pcl_delisting_date,
    pcl_delisting_code,
    recovered_within_5y,
    months_to_late_recovery,
    months_observed,
    tier1_window_complete,
    tier2_window_complete
  )],
  by=c("permno", "year"),
  all=TRUE
)

##---------------------------------------------------------------------------##
## "y" alias on the model-ready table follows RESPONSE_TRACK, so downstream
## consumers (06B, 08+) read a single column without knowing which track is
## active. The other track's column is preserved as a separate diagnostic.
##---------------------------------------------------------------------------##

if (RESPONSE_TRACK == "dynamic_csi") {
  model_ready[, `:=`(
    y = y_dynamic_csi,
    censored = dynamic_label_censored,
    param_id = "DYNAMIC_CSI_EVENT_YEAR_MINUS_1",
    response_track = "dynamic_csi"
  )]
} else if (RESPONSE_TRACK == "permanent_csi") {
  model_ready[, `:=`(
    y = y_permanent_csi,
    censored = permanent_label_censored,
    param_id = "PERMANENT_CSI_HYBRID_EVENT_YEAR_MINUS_1",
    response_track = "permanent_csi"
  )]
} else {
  stop(sprintf("[05C] Unknown RESPONSE_TRACK: %s", RESPONSE_TRACK))
}

cat(sprintf("\n[05C] Model-ready 'y' aliased to %s for RESPONSE_TRACK='%s'\n",
            ifelse(RESPONSE_TRACK == "dynamic_csi",
                   "y_dynamic_csi", "y_permanent_csi"),
            RESPONSE_TRACK))
cat(sprintf("  Active y prevalence (over labelled rows): %.4f\n",
            mean(model_ready$y == 1L, na.rm = TRUE)))

saveRDS(model_ready[order(permno, year)], PATH_LABELS_MODEL_READY)

#==============================================================================#
# 6. Compatibility exports
#==============================================================================#

labels_base_compat <- labels_dynamic[, .(
  permno,
  year,
  y = y_dynamic_csi,
  y_dynamic_csi,
  censored = dynamic_label_censored,
  event_date = dynamic_event_date,
  confirmation_date = dynamic_confirmation_date,
  event_year = dynamic_event_year,
  label_year = dynamic_label_year,
  param_id = "DYNAMIC_CSI_EVENT_YEAR_MINUS_1"
)]
saveRDS(labels_base_compat[order(permno, year)], PATH_LABELS_BASE)

labels_struct_compat <- labels_perm[, .(
  permno,
  year,
  y_structural = y_permanent_csi,
  y_permanent_csi,
  censored_bucket = permanent_label_censored,
  permanent_event_date,
  permanent_confirmation_date,
  permanent_event_year,
  permanent_label_year
)]
saveRDS(labels_struct_compat[order(permno, year)], PATH_LABELS_STRUCTURAL)

cat("\n[05C] DONE\n")
cat(sprintf("  Dynamic labels     : %s\n", PATH_LABELS_DYNAMIC))
cat(sprintf("  Permanent labels   : %s\n", PATH_LABELS_PERMANENT))
cat(sprintf("  Model-ready labels : %s\n", PATH_LABELS_MODEL_READY))
cat(sprintf("  Compat dynamic     : %s\n", PATH_LABELS_BASE))
cat(sprintf("  Compat permanent   : %s\n", PATH_LABELS_STRUCTURAL))
