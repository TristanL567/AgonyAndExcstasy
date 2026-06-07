#==============================================================================#
#==== ae_sens_prepare_raw_inputs.R ============================================#
#==== AE-SENS single-run labels, raw features, and splits ======================#
#==============================================================================#

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L || all(is.na(a))) b else a

fn_env <- function(name) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) stop(sprintf("%s is required", name), call. = FALSE)
  value
}

fn_bool_env <- function(name, default = TRUE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "1" else "0")
  tolower(trimws(value)) %in% c("1", "true", "t", "yes", "y", "on")
}

fn_is_abs <- function(path) grepl("^/", path)

MT_ROOT <- fn_env("MT_ROOT")
AE_SENS_OUTPUT_ROOT <- fn_env("AE_SENS_OUTPUT_ROOT")
AE_SENS_RUN_ID <- fn_env("AE_SENS_RUN_ID")
AE_SENS_C <- as.numeric(fn_env("AE_SENS_C"))
AE_SENS_M <- as.numeric(fn_env("AE_SENS_M"))
AE_SENS_T <- as.integer(fn_env("AE_SENS_T"))
MODEL <- fn_env("MODEL")
RESPONSE_TRACK <- fn_env("RESPONSE_TRACK")

if (!identical(MODEL, "raw")) stop("AE-SENS runner only permits MODEL=raw", call. = FALSE)
if (!identical(RESPONSE_TRACK, "dynamic_csi")) {
  stop("AE-SENS runner only permits RESPONSE_TRACK=dynamic_csi", call. = FALSE)
}
if (!fn_is_abs(AE_SENS_OUTPUT_ROOT)) {
  stop("AE_SENS_OUTPUT_ROOT must be absolute", call. = FALSE)
}
if (!grepl("/03_Data_Output/3_Modelling_Results/Necessary/sensitivity$", AE_SENS_OUTPUT_ROOT)) {
  stop("AE_SENS_OUTPUT_ROOT must end with 03_Data_Output/3_Modelling_Results/Necessary/sensitivity",
       call. = FALSE)
}

fn_param_token <- function(prefix, value, digits = 2L) {
  paste0(prefix, gsub("\\.", "", formatC(abs(value), format = "f", digits = digits)))
}
expected_run_id <- sprintf(
  "%s_%s_T%s",
  fn_param_token("C", AE_SENS_C),
  fn_param_token("M", AE_SENS_M),
  formatC(AE_SENS_T, width = 3L, flag = "0")
)
if (!grepl("^C(060|080|090)_M(000|020|030)_T(012|018|028)$", AE_SENS_RUN_ID)) {
  stop("AE_SENS_RUN_ID does not match the approved C/M/T run-id pattern", call. = FALSE)
}
if (!identical(AE_SENS_RUN_ID, expected_run_id)) {
  stop(sprintf("AE_SENS_RUN_ID=%s does not match C/M/T values; expected %s",
               AE_SENS_RUN_ID, expected_run_id), call. = FALSE)
}

RUN_DIRS <- list(
  logs = file.path(AE_SENS_OUTPUT_ROOT, "logs", AE_SENS_RUN_ID),
  labels = file.path(AE_SENS_OUTPUT_ROOT, "labels", AE_SENS_RUN_ID),
  raw_features = file.path(AE_SENS_OUTPUT_ROOT, "raw_features", "by_config", AE_SENS_RUN_ID),
  raw_models = file.path(AE_SENS_OUTPUT_ROOT, "raw_models", AE_SENS_RUN_ID),
  raw_predictions = file.path(AE_SENS_OUTPUT_ROOT, "raw_predictions", AE_SENS_RUN_ID),
  evaluation = file.path(AE_SENS_OUTPUT_ROOT, "evaluation", AE_SENS_RUN_ID),
  index_construction = file.path(AE_SENS_OUTPUT_ROOT, "index_construction", AE_SENS_RUN_ID)
)

fn_non_empty <- function(path) dir.exists(path) && length(list.files(path, all.files = TRUE, no.. = TRUE)) > 0L
output_dirs <- setdiff(names(RUN_DIRS), "logs")
non_empty <- output_dirs[vapply(RUN_DIRS[output_dirs], fn_non_empty, logical(1))]
if (length(non_empty) > 0L) {
  stop(sprintf(
    "AE-SENS fail-closed: non-empty destination directories for %s: %s",
    AE_SENS_RUN_ID,
    paste(sprintf("%s=%s", non_empty, unlist(RUN_DIRS[non_empty])), collapse = "; ")
  ), call. = FALSE)
}
invisible(lapply(RUN_DIRS, dir.create, recursive = TRUE, showWarnings = FALSE))

START_DATE <- as.Date("1993-01-01")
END_DATE <- as.Date("2024-12-31")
LABEL_EVENT_YEAR_LAG <- 1L
CSI_TERMINAL_FAILURE_CODES <- 572:574
CSI_USE_TERMINAL_FAILURE_INDICATORS <- fn_bool_env("CSI_USE_TERMINAL_FAILURE_INDICATORS", TRUE)
CSI_POSITIVE_EVENT_STATUSES <- c("confirmed_csi")
if (CSI_USE_TERMINAL_FAILURE_INDICATORS) {
  CSI_POSITIVE_EVENT_STATUSES <- c(CSI_POSITIVE_EVENT_STATUSES,
                                   "terminal_failure_before_confirmation")
}

DIR_DATA_INPUT <- file.path(MT_ROOT, "02_Data_Input")
DIR_CRSP_NEC <- file.path(DIR_DATA_INPUT, "01_CRSP", "Necessary")
DIR_FEATURES_CANON <- file.path(
  DIR_DATA_INPUT, "05_PipelineResults", "Necessary", "temporary_csi", "Features"
)
PATH_PRICES_MONTHLY <- file.path(DIR_CRSP_NEC, "prices_monthly.rds")
PATH_DELISTING <- file.path(DIR_CRSP_NEC, "delisting_raw.rds")
PATH_UNIVERSE <- file.path(DIR_CRSP_NEC, "universe.rds")
PATH_FEATURES_RAW_CANON <- file.path(DIR_FEATURES_CANON, "features_raw.rds")
PATH_SPLIT_LABELS_CANON <- file.path(DIR_FEATURES_CANON, "split_labels_oot.parquet")

required <- c(PATH_PRICES_MONTHLY, PATH_DELISTING, PATH_UNIVERSE,
              PATH_FEATURES_RAW_CANON, PATH_SPLIT_LABELS_CANON)
missing <- required[!file.exists(required)]
if (length(missing) > 0L) stop("Missing required input(s):\n", paste(missing, collapse = "\n"),
                               call. = FALSE)

fn_months_between <- function(start_date, end_date) {
  12L * (year(end_date) - year(start_date)) + (month(end_date) - month(start_date))
}

fn_prepare_price_path <- function(dt) {
  out <- copy(dt)
  out[, ret_clean := fifelse(is.na(ret), 0, ret)]
  out[, wealth_index := cumprod(1 + ret_clean), by = permno]
  out[, running_peak := cummax(wealth_index), by = permno]
  out[, drawdown := wealth_index / running_peak - 1]
  out[]
}

fn_terminal_failure_hit <- function(failure_dates, failure_codes, failure_dlrets,
                                    trigger_date, confirm_date) {
  if (length(failure_dates) == 0L) return(NULL)
  hit_idx <- which(failure_dates > trigger_date & failure_dates <= confirm_date)
  if (length(hit_idx) == 0L) return(NULL)
  first_idx <- hit_idx[which.min(failure_dates[hit_idx])]
  list(
    dlstdt = failure_dates[first_idx],
    dlstcd = failure_codes[first_idx],
    dlret = failure_dlrets[first_idx]
  )
}

fn_detect_events_one_firm <- function(dt, C, M, T, end_date, failures_dt, confirm_col) {
  n <- nrow(dt)
  if (n == 0L) return(data.table())

  dates <- dt$date
  wealth_index <- dt$wealth_index
  running_peak <- dt$running_peak
  drawdown <- dt$drawdown
  confirm_dates <- dt[[confirm_col]]
  date_years <- dt$calendar_year
  date_months <- dt$calendar_month
  terminal_wealth_last <- wealth_index[n]
  terminal_date_last <- dates[n]
  failure_dates <- failures_dt$dlstdt
  failure_codes <- failures_dt$dlstcd
  failure_dlrets <- failures_dt$dlret

  rows <- list()
  i <- 1L
  event_n <- 0L

  record_event <- function(status, window_max, postT_max,
                           exit_date = as.Date(NA),
                           months_to_late_recovery = NA_integer_,
                           terminal_failure_date = as.Date(NA),
                           terminal_failure_code = NA_integer_,
                           terminal_failure_dlret = NA_real_) {
    event_n <<- event_n + 1L
    rows[[event_n]] <<- data.table(
      event_seq = event_n,
      trigger_date = trigger_date,
      confirmation_date = confirm_date,
      trigger_year = date_years[i],
      trigger_month = date_months[i],
      event_status = status,
      wealth_trigger = wealth_trigger,
      peak_at_trigger = peak_at_trigger,
      drawdown_trigger = drawdown[i],
      recovery_ceiling = recovery_ceiling,
      window_max = window_max,
      postT_max = postT_max,
      terminal_wealth = terminal_wealth_last,
      terminal_date = terminal_date_last,
      exit_date = exit_date,
      months_to_late_recovery = months_to_late_recovery,
      terminal_failure_date = terminal_failure_date,
      terminal_failure_code = terminal_failure_code,
      terminal_failure_dlret = terminal_failure_dlret
    )
  }

  while (i <= n) {
    if (!is.na(drawdown[i]) && drawdown[i] <= C) {
      trigger_date <- dates[i]
      confirm_date <- confirm_dates[i]
      wealth_trigger <- wealth_index[i]
      peak_at_trigger <- running_peak[i]
      recovery_ceiling <- wealth_trigger * (1 + M)
      terminal_hit <- fn_terminal_failure_hit(
        failure_dates, failure_codes, failure_dlrets, trigger_date, confirm_date
      )

      if (confirm_date > end_date) {
        if (!is.null(terminal_hit)) {
          record_event(
            "terminal_failure_before_confirmation", NA_real_, NA_real_,
            terminal_failure_date = terminal_hit$dlstdt,
            terminal_failure_code = terminal_hit$dlstcd,
            terminal_failure_dlret = terminal_hit$dlret
          )
        } else {
          record_event("censored", NA_real_, NA_real_)
        }
        i <- i + 1L
        next
      }

      end_idx <- min(i + T, n)
      forward_idx <- seq(i + 1L, end_idx)
      if (length(forward_idx) == 0L) {
        i <- i + 1L
        next
      }
      forward_max <- max(wealth_index[forward_idx], na.rm = TRUE)

      if (forward_max <= recovery_ceiling) {
        post_idx <- if (end_idx < n) seq(end_idx + 1L, n) else integer()
        post_vals <- if (length(post_idx) > 0L) wealth_index[post_idx] else numeric()
        post_dates <- if (length(post_idx) > 0L) dates[post_idx] else as.Date(character())
        late_hit <- which(post_vals > recovery_ceiling)
        exit_date <- if (length(late_hit) > 0L) post_dates[late_hit[1L]] else as.Date(NA)
        months_to_late <- if (!is.na(exit_date)) {
          as.integer(fn_months_between(trigger_date, exit_date))
        } else {
          NA_integer_
        }
        record_event(
          "confirmed_csi",
          forward_max,
          if (length(post_vals) > 0L) max(post_vals, na.rm = TRUE) else NA_real_,
          exit_date = exit_date,
          months_to_late_recovery = months_to_late
        )
        i <- end_idx + 1L
      } else {
        if (!is.null(terminal_hit)) {
          record_event(
            "terminal_failure_before_confirmation", forward_max, NA_real_,
            terminal_failure_date = terminal_hit$dlstdt,
            terminal_failure_code = terminal_hit$dlstcd,
            terminal_failure_dlret = terminal_hit$dlret
          )
        } else {
          record_event("recovered_within_T", forward_max, NA_real_)
        }
        i <- i + 1L
      }
    } else {
      i <- i + 1L
    }
  }

  rbindlist(rows, use.names = TRUE, fill = TRUE)
}

fn_detect_events <- function(price_path, C, M, T, param_id, terminal_failures) {
  confirm_col <- sprintf("confirm_date_T%03d", as.integer(T))
  events <- price_path[
    ,
    fn_detect_events_one_firm(
      .SD,
      C = C,
      M = M,
      T = T,
      end_date = END_DATE,
      failures_dt = terminal_failures[.(.BY$permno), nomatch = 0L],
      confirm_col = confirm_col
    ),
    by = permno,
    .SDcols = c(
      "date", "ret", "wealth_index", "running_peak", "drawdown",
      "calendar_year", "calendar_month", confirm_col
    )
  ]
  if (nrow(events) == 0L) return(events)
  events[, `:=`(
    param_id = param_id,
    C = C,
    M = M,
    T = T,
    late_recovery = event_status == "confirmed_csi" & !is.na(exit_date),
    terminal_vs_trigger = terminal_wealth / wealth_trigger - 1,
    terminal_vs_peak = terminal_wealth / peak_at_trigger - 1,
    postT_max_vs_trigger = postT_max / wealth_trigger - 1
  )]
  setcolorder(events, c("param_id", "C", "M", "T", "permno", "event_seq"))
  events[]
}

fn_label_scaffold <- function(prices) {
  p <- copy(prices)
  p[, year := year(date)]
  rectangular <- CJ(permno = sort(unique(p$permno)), year = seq(year(START_DATE), year(END_DATE)))
  observable_cols <- intersect(c("ret_adj", "mktcap"), names(p))
  if (length(observable_cols) > 0L) {
    p[, observable_month := Reduce(`|`, lapply(.SD, function(x) !is.na(x))),
      .SDcols = observable_cols]
    obs <- unique(p[observable_month == TRUE & !is.na(year), .(permno, year)],
                  by = c("permno", "year"))
  } else {
    obs <- unique(p[!is.na(year), .(permno, year)], by = c("permno", "year"))
  }
  rectangular[obs, on = .(permno, year), nomatch = 0L]
}

fn_events_to_labels <- function(events, prices) {
  labels <- fn_label_scaffold(prices)
  labels[, `:=`(
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

  labels[pos, y_dynamic_csi := 1L, on = .(permno, year = label_year)]
  labels[pos, dynamic_event_date := i.trigger_date, on = .(permno, year = label_year)]
  labels[pos, dynamic_confirmation_date := i.confirmation_date, on = .(permno, year = label_year)]
  labels[pos, dynamic_event_year := i.event_year, on = .(permno, year = label_year)]
  labels[pos, dynamic_label_year := i.label_year, on = .(permno, year = label_year)]

  cens <- unique(events[event_status == "censored", .(
    permno,
    label_year = trigger_year - LABEL_EVENT_YEAR_LAG
  )])
  labels[cens, dynamic_label_censored := TRUE, on = .(permno, year = label_year)]
  labels[dynamic_label_censored == TRUE & y_dynamic_csi != 1L, y_dynamic_csi := NA_integer_]
  labels[year > year(END_DATE) - LABEL_EVENT_YEAR_LAG, `:=`(
    y_dynamic_csi = NA_integer_,
    dynamic_label_censored = TRUE
  )]

  labels[, `:=`(
    y = y_dynamic_csi,
    censored = dynamic_label_censored,
    param_id = AE_SENS_RUN_ID,
    response_track = "dynamic_csi",
    label_type = "dynamic_csi",
    label_alignment = "event_year_minus_1"
  )]

  labels[, .(
    permno, year,
    y_dynamic_csi, y, censored,
    dynamic_label_censored,
    event_date = dynamic_event_date,
    confirmation_date = dynamic_confirmation_date,
    event_year = dynamic_event_year,
    label_year = dynamic_label_year,
    dynamic_event_date, dynamic_confirmation_date,
    dynamic_event_year, dynamic_label_year,
    param_id, response_track, label_type, label_alignment
  )]
}

cat(sprintf("[AE-SENS prepare] START %s run=%s C=%.2f M=%.2f T=%d\n",
            format(Sys.time()), AE_SENS_RUN_ID, AE_SENS_C, AE_SENS_M, AE_SENS_T))

prices <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
universe <- as.data.table(readRDS(PATH_UNIVERSE))
delisting_raw <- as.data.table(readRDS(PATH_DELISTING))

setnames(prices, "ret_adj", "ret", skip_absent = TRUE)
prices <- prices[permno %in% universe$permno]
prices[, ret := fifelse(is.na(ret), NA_real_, pmin(pmax(ret, -0.99), 10))]
prices[, date := as.Date(date)]
setorder(prices, permno, date)

terminal_failures <- if (CSI_USE_TERMINAL_FAILURE_INDICATORS) {
  delisting_raw[
    dlstcd %in% CSI_TERMINAL_FAILURE_CODES & !is.na(dlstdt),
    .(permno, dlstdt = as.Date(dlstdt), dlstcd = as.integer(dlstcd), dlret)
  ]
} else {
  data.table(permno = integer(), dlstdt = as.Date(character()),
             dlstcd = integer(), dlret = numeric())
}
setkey(terminal_failures, permno)

price_path <- fn_prepare_price_path(prices)
price_path[, `:=`(calendar_year = year(date), calendar_month = month(date))]
confirm_col <- sprintf("confirm_date_T%03d", AE_SENS_T)
price_path[, (confirm_col) := date %m+% months(AE_SENS_T)]

events <- fn_detect_events(
  price_path = price_path,
  C = AE_SENS_C,
  M = AE_SENS_M,
  T = AE_SENS_T,
  param_id = AE_SENS_RUN_ID,
  terminal_failures = terminal_failures
)
labels <- fn_events_to_labels(events, prices)

features_base <- as.data.table(readRDS(PATH_FEATURES_RAW_CANON))
label_cols <- c(
  "y", "censored", "param_id", "response_track",
  "y_dynamic_csi", "y_permanent_csi", "y_structural",
  "dynamic_label_censored", "permanent_label_censored",
  "event_date", "confirmation_date", "event_year", "label_year",
  "dynamic_event_date", "dynamic_confirmation_date",
  "dynamic_event_year", "dynamic_label_year",
  "permanent_event_date", "permanent_confirmation_date",
  "permanent_event_year", "permanent_label_year",
  "perm_status", "has_adverse_delist", "pcl_delisting_date",
  "pcl_delisting_code", "recovered_within_5y",
  "months_to_late_recovery", "months_observed",
  "tier1_window_complete", "tier2_window_complete",
  "label_type", "label_alignment"
)
base_cov_cols <- setdiff(names(features_base), label_cols)
features_cov <- features_base[, ..base_cov_cols]
features <- merge(labels, features_cov, by = c("permno", "year"), all.x = FALSE)
setorder(features, permno, year)

if (anyDuplicated(features[, .(permno, year)]) > 0L) {
  stop("Duplicate (permno, year) rows in run-specific features", call. = FALSE)
}
if (!all(features$param_id == AE_SENS_RUN_ID)) {
  stop("Run-specific features contain an unexpected param_id", call. = FALSE)
}

saveRDS(events, file.path(RUN_DIRS$labels, "csi_events.rds"))
saveRDS(labels, file.path(RUN_DIRS$labels, "labels_model_ready.rds"))
saveRDS(features, file.path(RUN_DIRS$raw_features, "features_raw.rds"))
file.copy(PATH_SPLIT_LABELS_CANON,
          file.path(RUN_DIRS$raw_features, "split_labels_oot.parquet"),
          overwrite = FALSE)

if (nrow(events) == 0L) {
  event_diag <- data.table(
    param_id = AE_SENS_RUN_ID, C = AE_SENS_C, M = AE_SENS_M, T = AE_SENS_T,
    n_triggers = 0L, n_confirmed = 0L,
    n_terminal_failure_before_confirmation = 0L, n_positive = 0L,
    n_recovered_within_T = 0L, n_censored = 0L
  )
} else {
  event_diag <- events[, .(
    n_triggers = .N,
    n_confirmed = sum(event_status == "confirmed_csi"),
    n_terminal_failure_before_confirmation =
      sum(event_status == "terminal_failure_before_confirmation"),
    n_positive = sum(event_status %in% CSI_POSITIVE_EVENT_STATUSES),
    n_recovered_within_T = sum(event_status == "recovered_within_T"),
    n_censored = sum(event_status == "censored")
  ), by = .(param_id, C, M, T)]
}
label_diag <- labels[, .(
  n_rows = .N,
  n_labelled = sum(!is.na(y)),
  n_csi = sum(y == 1L, na.rm = TRUE),
  n_clean = sum(y == 0L, na.rm = TRUE),
  n_na = sum(is.na(y)),
  prevalence_pct = 100 * mean(y == 1L, na.rm = TRUE)
), by = param_id]

fwrite(event_diag, file.path(RUN_DIRS$labels, "event_diagnostics.csv"))
fwrite(label_diag, file.path(RUN_DIRS$labels, "label_diagnostics.csv"))
fwrite(data.table(
  run_id = AE_SENS_RUN_ID,
  C = AE_SENS_C,
  M = AE_SENS_M,
  T = AE_SENS_T,
  features_rows = nrow(features),
  labels_rows = nrow(labels),
  events_rows = nrow(events),
  started_at = as.character(Sys.time()),
  output_root = AE_SENS_OUTPUT_ROOT
), file.path(RUN_DIRS$logs, "prepare_status.csv"))

cat(sprintf("[AE-SENS prepare] labels=%d features=%d events=%d\n",
            nrow(labels), nrow(features), nrow(events)))
cat("[AE-SENS prepare] DONE\n")
