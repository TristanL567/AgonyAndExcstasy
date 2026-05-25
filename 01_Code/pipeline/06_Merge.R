#==============================================================================#
#==== 06_Merge.R ===============================================================#
#==== Annual Modelling Panel: Labels + Fundamentals + Macro + Prices ===========#
#==============================================================================#
#
# PURPOSE:
#   Build panel_raw.rds, the single annual firm-year input used by
#   06B_FeatureEngineering.R.
#
# RESPONSE TRACK:
#   The active response is selected in config.R via RESPONSE_TRACK:
#
#     dynamic_csi   : temporary/Tewari-style CSI target
#     permanent_csi : permanent-capital-loss CSI target
#
#   For both supported tracks, this script builds the active model-ready annual
#   label directly from the corresponding event table:
#     dynamic_csi   -> PATH_CSI_EVENTS_BASE
#     permanent_csi -> PATH_PCL_EVENTS_BASE
#
# ANNUAL TIMING:
#   No accounting release lag is applied here. A Compustat row with fyear = t is
#   merged to annual label row t. Monthly trigger events in calendar year t + 1
#   are aligned to annual row t through LABEL_EVENT_YEAR_LAG.
#
# OUTPUT:
#   PATH_PANEL_RAW : one row per labelled (permno, year), with active-track y.
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

cat("\n[06_Merge.R] START:", format(Sys.time()), "\n")
cat(sprintf("  RESPONSE_TRACK: %s\n", RESPONSE_TRACK))

fn_label_scaffold <- function() {
  if (!file.exists(PATH_PRICES_MONTHLY)) {
    stop("[06_Merge.R] Cannot build annual label scaffold: missing ",
         PATH_PRICES_MONTHLY)
  }
  prices_for_permno <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
  all_permno <- sort(unique(prices_for_permno$permno))
  years <- seq(year(START_DATE), year(END_DATE))
  CJ(permno = all_permno, year = years)
}

fn_prepare_dynamic_model_ready <- function() {
  if (RESPONSE_TRACK != "dynamic_csi") {
    return(invisible(FALSE))
  }
  if (!file.exists(PATH_CSI_EVENTS_BASE)) {
    stop("[06_Merge.R] Cannot build dynamic labels: missing ", PATH_CSI_EVENTS_BASE)
  }

  cat("[06_Merge.R] Building dynamic model-ready labels from 05A base events...\n")

  events <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE))
  events[, trigger_date := as.Date(trigger_date)]
  if (!"trigger_year" %in% names(events)) {
    events[, trigger_year := year(trigger_date)]
  }

  labels_dyn <- fn_label_scaffold()
  labels_dyn[, `:=`(
    y_dynamic_csi = 0L,
    dynamic_label_censored = FALSE,
    dynamic_event_date = as.Date(NA),
    dynamic_confirmation_date = as.Date(NA),
    dynamic_event_year = NA_integer_,
    dynamic_label_year = NA_integer_
  )]

  pos <- events[event_status %in% CSI_POSITIVE_EVENT_STATUSES, .(
    permno,
    label_year = trigger_year - LABEL_EVENT_YEAR_LAG,
    trigger_date,
    confirmation_date,
    event_year = trigger_year
  )]
  setorder(pos, permno, label_year, trigger_date)
  pos <- pos[, .SD[1L], by = .(permno, label_year)]

  labels_dyn[pos, y_dynamic_csi := 1L, on = .(permno, year = label_year)]
  labels_dyn[pos, dynamic_event_date := i.trigger_date,
             on = .(permno, year = label_year)]
  labels_dyn[pos, dynamic_confirmation_date := i.confirmation_date,
             on = .(permno, year = label_year)]
  labels_dyn[pos, dynamic_event_year := i.event_year,
             on = .(permno, year = label_year)]
  labels_dyn[pos, dynamic_label_year := i.label_year,
             on = .(permno, year = label_year)]

  cens <- unique(events[event_status == "censored", .(
    permno,
    label_year = trigger_year - LABEL_EVENT_YEAR_LAG
  )])
  labels_dyn[cens, dynamic_label_censored := TRUE,
             on = .(permno, year = label_year)]
  labels_dyn[dynamic_label_censored == TRUE & y_dynamic_csi != 1L,
             y_dynamic_csi := NA_integer_]

  max_label_year <- year(END_DATE) - LABEL_EVENT_YEAR_LAG
  labels_dyn[year > max_label_year, `:=`(
    y_dynamic_csi = NA_integer_,
    dynamic_label_censored = TRUE
  )]

  labels_dyn[, `:=`(
    y = y_dynamic_csi,
    censored = dynamic_label_censored,
    param_id = "DYNAMIC_CSI_EVENT_YEAR_MINUS_1",
    response_track = "dynamic_csi",
    label_type = "dynamic_csi",
    label_alignment = "event_year_minus_1"
  )]

  out <- labels_dyn[, .(
    permno, year,
    y_dynamic_csi, y, censored,
    dynamic_label_censored,
    dynamic_event_date, dynamic_confirmation_date,
    dynamic_event_year, dynamic_label_year,
    param_id, response_track, label_type, label_alignment
  )]

  dir.create(dirname(PATH_LABELS_DYNAMIC), recursive = TRUE, showWarnings = FALSE)
  dir.create(dirname(PATH_LABELS_MODEL_READY), recursive = TRUE, showWarnings = FALSE)
  saveRDS(out, PATH_LABELS_DYNAMIC)
  saveRDS(out, PATH_LABELS_MODEL_READY)

  labels_base_compat <- out[, .(
    permno, year,
    y, y_dynamic_csi, censored,
    event_date = dynamic_event_date,
    confirmation_date = dynamic_confirmation_date,
    event_year = dynamic_event_year,
    label_year = dynamic_label_year,
    param_id, response_track
  )]
  saveRDS(labels_base_compat, PATH_LABELS_BASE)

  cat(sprintf("  Dynamic model-ready labels saved: %s\n", PATH_LABELS_MODEL_READY))
  cat(sprintf("  Positives: %d | labelled: %d | prevalence: %.3f%%\n",
              sum(out$y == 1L, na.rm = TRUE),
              sum(!is.na(out$y)),
              100 * mean(out$y == 1L, na.rm = TRUE)))

  invisible(TRUE)
}

fn_prepare_permanent_model_ready <- function() {
  if (RESPONSE_TRACK != "permanent_csi") {
    return(invisible(FALSE))
  }
  if (!file.exists(PATH_PCL_EVENTS_BASE)) {
    stop("[06_Merge.R] Cannot build permanent labels: missing ", PATH_PCL_EVENTS_BASE)
  }

  cat("[06_Merge.R] Building permanent model-ready labels from 05B PCL events...\n")

  events <- as.data.table(readRDS(PATH_PCL_EVENTS_BASE))
  events[, trigger_date := as.Date(trigger_date)]
  if ("confirmation_date" %in% names(events)) {
    events[, confirmation_date := as.Date(confirmation_date)]
  } else {
    events[, confirmation_date := as.Date(NA)]
  }
  if (!"trigger_year" %in% names(events)) {
    events[, trigger_year := year(trigger_date)]
  }

  required_cols <- c(
    "event_status", "y_perm_event", "perm_status", "has_adverse_delist",
    "pcl_delisting_date", "pcl_delisting_code", "recovered_within_5y",
    "months_to_late_recovery", "months_observed",
    "tier1_window_complete", "tier2_window_complete"
  )
  missing_cols <- setdiff(required_cols, names(events))
  if (length(missing_cols) > 0L) {
    stop(sprintf(
      "[06_Merge.R] Permanent PCL events missing required column(s): %s",
      paste(missing_cols, collapse = ", ")
    ))
  }

  events[, pcl_delisting_date := as.Date(pcl_delisting_date)]

  labels_perm <- fn_label_scaffold()
  labels_perm[, `:=`(
    y_permanent_csi = 0L,
    y_structural = 0L,
    permanent_label_censored = FALSE,
    permanent_event_date = as.Date(NA),
    permanent_confirmation_date = as.Date(NA),
    permanent_event_year = NA_integer_,
    permanent_label_year = NA_integer_,
    perm_status = NA_character_,
    has_adverse_delist = NA,
    pcl_delisting_date = as.Date(NA),
    pcl_delisting_code = NA_integer_,
    recovered_within_5y = NA,
    months_to_late_recovery = NA_integer_,
    months_observed = NA_integer_,
    tier1_window_complete = NA,
    tier2_window_complete = NA
  )]

  pos <- events[
    event_status %in% CSI_POSITIVE_EVENT_STATUSES &
      !is.na(y_perm_event) & y_perm_event == 1L,
    .(
    permno,
    label_year = trigger_year - LABEL_EVENT_YEAR_LAG,
    trigger_date,
    confirmation_date,
    event_year = trigger_year
  )]
  setorder(pos, permno, label_year, trigger_date)
  pos <- pos[, .SD[1L], by = .(permno, label_year)]

  labels_perm[pos, y_permanent_csi := 1L, on = .(permno, year = label_year)]
  labels_perm[pos, y_structural := 1L, on = .(permno, year = label_year)]
  labels_perm[pos, permanent_event_date := i.trigger_date,
              on = .(permno, year = label_year)]
  labels_perm[pos, permanent_confirmation_date := i.confirmation_date,
              on = .(permno, year = label_year)]
  labels_perm[pos, permanent_event_year := i.event_year,
              on = .(permno, year = label_year)]
  labels_perm[pos, permanent_label_year := i.label_year,
              on = .(permno, year = label_year)]

  cens <- unique(events[
    event_status %in% CSI_POSITIVE_EVENT_STATUSES & is.na(y_perm_event),
    .(permno, label_year = trigger_year - LABEL_EVENT_YEAR_LAG)
  ])
  labels_perm[cens, permanent_label_censored := TRUE,
              on = .(permno, year = label_year)]
  labels_perm[permanent_label_censored == TRUE & y_permanent_csi != 1L, `:=`(
    y_permanent_csi = NA_integer_,
    y_structural = NA_integer_
  )]

  max_label_year <- year(END_DATE) - LABEL_EVENT_YEAR_LAG
  labels_perm[year > max_label_year, `:=`(
    y_permanent_csi = NA_integer_,
    y_structural = NA_integer_,
    permanent_label_censored = TRUE
  )]

  events_diag <- events[event_status %in% CSI_POSITIVE_EVENT_STATUSES, .(
    permno,
    label_year = trigger_year - LABEL_EVENT_YEAR_LAG,
    diag_priority = fcase(
      !is.na(y_perm_event) & y_perm_event == 1L, 1L,
      is.na(y_perm_event), 2L,
      default = 3L
    ),
    trigger_date,
    perm_status,
    has_adverse_delist,
    pcl_delisting_date,
    pcl_delisting_code,
    recovered_within_5y,
    months_to_late_recovery,
    months_observed,
    tier1_window_complete,
    tier2_window_complete
  )]
  setorder(events_diag, permno, label_year, diag_priority,
           pcl_delisting_date, trigger_date, na.last = TRUE)
  events_diag <- events_diag[, .SD[1L], by = .(permno, label_year)]
  events_diag[, diag_priority := NULL]

  labels_perm <- merge(
    labels_perm,
    events_diag,
    by.x = c("permno", "year"),
    by.y = c("permno", "label_year"),
    all.x = TRUE,
    suffixes = c("", "_event")
  )

  diag_cols <- c(
    "perm_status", "has_adverse_delist", "pcl_delisting_date",
    "pcl_delisting_code", "recovered_within_5y",
    "months_to_late_recovery", "months_observed",
    "tier1_window_complete", "tier2_window_complete"
  )
  for (col in diag_cols) {
    event_col <- paste0(col, "_event")
    if (event_col %in% names(labels_perm)) {
      labels_perm[!is.na(get(event_col)), (col) := get(event_col)]
      labels_perm[, (event_col) := NULL]
    }
  }
  if ("trigger_date" %in% names(labels_perm)) {
    labels_perm[, trigger_date := NULL]
  }

  labels_perm[, `:=`(
    y = y_permanent_csi,
    censored = permanent_label_censored,
    param_id = "PERMANENT_CSI_HYBRID_EVENT_YEAR_MINUS_1",
    response_track = "permanent_csi",
    label_type = "permanent_capital_loss",
    label_alignment = "event_year_minus_1"
  )]

  out <- labels_perm[, .(
    permno, year,
    y_permanent_csi, y, y_structural, censored,
    permanent_label_censored,
    permanent_event_date, permanent_confirmation_date,
    permanent_event_year, permanent_label_year,
    perm_status, has_adverse_delist,
    pcl_delisting_date, pcl_delisting_code,
    recovered_within_5y, months_to_late_recovery,
    months_observed, tier1_window_complete, tier2_window_complete,
    param_id, response_track, label_type, label_alignment
  )]

  dir.create(dirname(PATH_LABELS_PERMANENT), recursive = TRUE, showWarnings = FALSE)
  dir.create(dirname(PATH_LABELS_MODEL_READY), recursive = TRUE, showWarnings = FALSE)
  saveRDS(out, PATH_LABELS_PERMANENT)
  saveRDS(out, PATH_LABELS_MODEL_READY)

  cat(sprintf("  Permanent model-ready labels saved: %s\n", PATH_LABELS_MODEL_READY))
  cat(sprintf("  Positives: %d | labelled: %d | prevalence: %.3f%%\n",
              sum(out$y == 1L, na.rm = TRUE),
              sum(!is.na(out$y)),
              100 * mean(out$y == 1L, na.rm = TRUE)))

  invisible(TRUE)
}

fn_prepare_active_model_ready <- function() {
  if (RESPONSE_TRACK == "dynamic_csi") {
    return(fn_prepare_dynamic_model_ready())
  }
  if (RESPONSE_TRACK == "permanent_csi") {
    return(fn_prepare_permanent_model_ready())
  }
  stop(sprintf("[06_Merge.R] Unknown RESPONSE_TRACK: %s", RESPONSE_TRACK))
}

fn_prepare_active_model_ready()

required_inputs <- c(
  PATH_LABELS_MODEL_READY,
  PATH_FUNDAMENTALS,
  PATH_PRICES_MONTHLY,
  PATH_MACRO_MONTHLY,
  PATH_UNIVERSE
)
missing_inputs <- required_inputs[!file.exists(required_inputs)]
if (length(missing_inputs) > 0L) {
  stop(sprintf(
    "[06_Merge.R] Missing required input(s):\n  %s\nRun 05A for dynamic CSI and 05B for permanent CSI before 06_Merge.",
    paste(missing_inputs, collapse = "\n  ")
  ))
}

#==============================================================================#
# 0. Load inputs
#==============================================================================#

labels <- as.data.table(readRDS(PATH_LABELS_MODEL_READY))
fund   <- as.data.table(readRDS(PATH_FUNDAMENTALS))
prices <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
macro  <- as.data.table(readRDS(PATH_MACRO_MONTHLY))
univ   <- as.data.table(readRDS(PATH_UNIVERSE))

stopifnot(
  "labels_model_ready must contain permno" = "permno" %in% names(labels),
  "labels_model_ready must contain year"   = "year"   %in% names(labels),
  "labels_model_ready must contain y"      = "y"      %in% names(labels)
)

cat(sprintf("  Labels       : %d rows | y prevalence %.3f%%\n",
            nrow(labels), 100 * mean(labels$y == 1L, na.rm = TRUE)))
cat(sprintf("  Fundamentals : %d rows\n", nrow(fund)))
cat(sprintf("  Monthly px   : %d rows\n", nrow(prices)))
cat(sprintf("  Macro monthly: %d rows\n", nrow(macro)))

#==============================================================================#
# 1. Prepare annual labels
#==============================================================================#

labels[, year := as.integer(year)]
setorder(labels, permno, year)
if (anyDuplicated(labels[, .(permno, year)]) > 0L) {
  stop("[06_Merge.R] Duplicate (permno, year) rows in labels_model_ready.")
}

#==============================================================================#
# 2. Prepare annual fundamentals
#==============================================================================#

fund[, datadate := as.Date(datadate)]
fund[, year := as.integer(fyear)]
fund[, fiscal_year_end_month := as.integer(fyr)]

## In rare duplicate permno-year cases, keep the latest fiscal-period row.
setorder(fund, permno, year, datadate)
fund <- fund[, .SD[.N], by = .(permno, year)]

if (anyDuplicated(fund[, .(permno, year)]) > 0L) {
  stop("[06_Merge.R] Duplicate (permno, year) rows after fundamentals dedupe.")
}

cat(sprintf("  Fundamentals annual: %d rows | years %d-%d\n",
            nrow(fund), min(fund$year, na.rm = TRUE), max(fund$year, na.rm = TRUE)))

#==============================================================================#
# 3. Collapse monthly macro to annual
#==============================================================================#

macro[, date := as.Date(date)]
macro[, year := year(date)]

macro_annual <- macro[, .(
  gdp           = mean(gdp,           na.rm = TRUE),
  unrate        = mean(unrate,        na.rm = TRUE),
  fedfunds      = mean(fedfunds,      na.rm = TRUE),
  gs10          = mean(gs10,          na.rm = TRUE),
  term_spread   = mean(term_spread,   na.rm = TRUE),
  hy_spread     = mean(hy_spread,     na.rm = TRUE),
  vix           = mean(vix,           na.rm = TRUE),
  cpi           = mean(cpi,           na.rm = TRUE),
  indpro        = mean(indpro,        na.rm = TRUE),
  gdp_growth    = mean(gdp_growth,    na.rm = TRUE),
  cpi_inflation = mean(cpi_inflation, na.rm = TRUE),
  indpro_growth = mean(indpro_growth, na.rm = TRUE),
  d_unrate      = mean(d_unrate,      na.rm = TRUE),
  d_hy_spread   = mean(d_hy_spread,   na.rm = TRUE),
  d_vix         = mean(d_vix,         na.rm = TRUE),
  recession     = as.integer(max(recession, na.rm = TRUE))
), by = year]

for (col in names(macro_annual)) {
  if (is.numeric(macro_annual[[col]])) {
    set(macro_annual, which(is.nan(macro_annual[[col]])), col, NA_real_)
  }
}

cat(sprintf("  Macro annual: %d rows | years %d-%d\n",
            nrow(macro_annual),
            min(macro_annual$year, na.rm = TRUE),
            max(macro_annual$year, na.rm = TRUE)))

#==============================================================================#
# 4. Collapse monthly prices to annual summaries
#==============================================================================#

prices[, date := as.Date(date)]
prices[, year := year(date)]

fn_compound <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(NA_real_)
  prod(1 + x) - 1
}

price_annual <- prices[, .(
  ann_return   = fn_compound(ret_adj),
  n_months_ret = sum(!is.na(ret_adj)),
  avg_mktcap   = mean(mktcap, na.rm = TRUE)
), by = .(permno, year)]

price_annual[, log_return := fifelse(
  is.na(ann_return) | ann_return <= -1,
  NA_real_,
  log1p(ann_return)
)]

for (col in c("avg_mktcap")) {
  set(price_annual, which(is.nan(price_annual[[col]])), col, NA_real_)
}

cat(sprintf("  Price annual: %d rows | years %d-%d\n",
            nrow(price_annual),
            min(price_annual$year, na.rm = TRUE),
            max(price_annual$year, na.rm = TRUE)))

#==============================================================================#
# 5. Universe metadata
#==============================================================================#

univ_keep <- intersect(
  c("permno", "ticker", "issuernm", "is_active", "listing_date",
    "removal_date", "lifetime_years", "siccd", "naics", "exchange"),
  names(univ)
)
univ_meta <- unique(univ[, ..univ_keep], by = "permno")

#==============================================================================#
# 6. Merge annual panel
#==============================================================================#

panel <- copy(labels)

panel <- merge(panel, fund,          by = c("permno", "year"), all.x = TRUE)
panel <- merge(panel, macro_annual,  by = "year",              all.x = TRUE)
panel <- merge(panel, price_annual,  by = c("permno", "year"), all.x = TRUE)
panel <- merge(panel, univ_meta,     by = "permno",            all.x = TRUE)

setorder(panel, permno, year)

if (anyDuplicated(panel[, .(permno, year)]) > 0L) {
  stop("[06_Merge.R] Duplicate (permno, year) rows in final panel.")
}

if (!"response_track" %in% names(panel)) {
  panel[, response_track := RESPONSE_TRACK]
}

#==============================================================================#
# 7. Diagnostics and save
#==============================================================================#

labelled_rows <- sum(!is.na(panel$y))
positive_rows <- sum(panel$y == 1L, na.rm = TRUE)
fund_rows <- sum(!is.na(panel$datadate))

cat("\n[06_Merge.R] Final panel diagnostics:\n")
cat(sprintf("  Rows            : %d\n", nrow(panel)))
cat(sprintf("  Firms           : %d\n", uniqueN(panel$permno)))
cat(sprintf("  Years           : %d-%d\n",
            min(panel$year, na.rm = TRUE), max(panel$year, na.rm = TRUE)))
cat(sprintf("  Labelled rows   : %d\n", labelled_rows))
cat(sprintf("  Positive y rows : %d (%.3f%% of labelled)\n",
            positive_rows, 100 * positive_rows / max(labelled_rows, 1L)))
cat(sprintf("  Rows with fund. : %d (%.1f%%)\n",
            fund_rows, 100 * fund_rows / max(nrow(panel), 1L)))

saveRDS(panel, PATH_PANEL_RAW)

cat(sprintf("\n[06_Merge.R] Saved: %s\n", PATH_PANEL_RAW))
cat("[06_Merge.R] DONE:", format(Sys.time()), "\n")
