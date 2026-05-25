#==============================================================================#
#==== 05A_Dynamic_CSI_Label.R =================================================#
#==== Tewari-Style CSI Events as a Dynamic Capital-Impairment State ===========#
#==============================================================================#
#
# PURPOSE:
#   Implement the Tewari et al. CSI methodology using the three parameters
#   already used in the thesis:
#
#     C : drawdown trigger threshold
#     M : recovery threshold from the crash low
#     T : confirmation horizon in months
#
#   This script no longer treats CSI as permanent capital loss. It stores exact
#   monthly trigger dates and constructs an ex-post dynamic distress state.
#   Later scripts can align annual feature rows to these monthly event dates.
#
# KEY CLOCKS:
#   1. Event clock: monthly CRSP returns detect triggers.
#   2. Confirmation clock: T months after trigger validates non-recovery.
#   3. Feature clock: annual features are aligned later in 05C.
#
# EVENT DEFINITION:
#   W_i,m = prod_{s <= m} (1 + r_i,s)
#   P_i,m = max_{s <= m} W_i,s
#   D_i,m = W_i,m / P_i,m - 1
#
#   trigger at month m if D_i,m <= C
#
#   confirmed CSI if:
#     max_{k=1,...,T} W_i,m+k <= W_i,m * (1 + M)
#
#   terminal-failure CSI if:
#     CSI_USE_TERMINAL_FAILURE_INDICATORS is TRUE and a trigger is followed by
#     CRSP bankruptcy-related delisting code 572-574 after trigger_date and
#     on/before trigger_date + T months
#
#   T is the confirmation horizon, not the ML forecast horizon.
#
# OUTPUTS:
#   PATH_CSI_EVENTS_BASE   : event-level base C/M/T table
#   PATH_CSI_EVENTS_GRID   : optional event-level table for all grid combinations
#   PATH_CSI_STATE_MONTHLY : base-case monthly unresolved distress state
#   PATH_CSI_DIAG          : event-level diagnostics by parameter set
#
# COMPATIBILITY OUTPUTS:
#   PATH_LABELS_BASE       : annual same-year label, as in old pipeline
#   PATH_LABELS_GRID       : optional annual grid labels when CSI_RUN_GRID=1
#   PATH_LABELS_DIAG       : annual diagnostic table, as in old pipeline
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(scales)
  library(lubridate)
})

cat("\n[05A_Dynamic_CSI_Label.R] START:", format(Sys.time()), "\n")

FIGS <- fn_setup_figure_dirs()

#==============================================================================#
# 0. Load inputs
#==============================================================================#

prices_monthly <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
universe       <- as.data.table(readRDS(PATH_UNIVERSE))
delisting_raw  <- if (CSI_USE_TERMINAL_FAILURE_INDICATORS) {
  as.data.table(readRDS(PATH_DELISTING))
} else {
  data.table(permno = integer(), dlstdt = as.Date(character()),
             dlstcd = integer(), dlret = numeric())
}

setnames(prices_monthly, "ret_adj", "ret", skip_absent=TRUE)
prices_monthly <- prices_monthly[permno %in% universe$permno]
prices_monthly[, ret := fifelse(is.na(ret), NA_real_, pmin(pmax(ret, -0.99), 10))]
prices_monthly[, date := as.Date(date)]
setorder(prices_monthly, permno, date)

terminal_failures <- if (CSI_USE_TERMINAL_FAILURE_INDICATORS) {
  delisting_raw[
    dlstcd %in% CSI_TERMINAL_FAILURE_CODES & !is.na(dlstdt),
    .(
      permno,
      dlstdt = as.Date(dlstdt),
      dlstcd = as.integer(dlstcd),
      dlret
    )
  ]
} else {
  data.table(permno = integer(), dlstdt = as.Date(character()),
             dlstcd = integer(), dlret = numeric())
}
setorder(terminal_failures, permno, dlstdt)
setkey(terminal_failures, permno)

cat(sprintf("  Monthly prices: %d rows | %d permnos | %s to %s\n",
            nrow(prices_monthly), uniqueN(prices_monthly$permno),
            min(prices_monthly$date), max(prices_monthly$date)))
cat(sprintf("  Terminal CSI failure delistings: %d rows | enabled=%s | codes %s\n",
            nrow(terminal_failures),
            CSI_USE_TERMINAL_FAILURE_INDICATORS,
            paste(CSI_TERMINAL_FAILURE_CODES, collapse=", ")))

#==============================================================================#
# 1. Helpers
#==============================================================================#

fn_months_between <- function(start_date, end_date) {
  12L * (year(end_date) - year(start_date)) + (month(end_date) - month(start_date))
}

fn_prepare_price_path <- function(dt) {
  out <- copy(dt)
  out[, ret_clean := fifelse(is.na(ret), 0, ret)]
  out[, wealth_index := cumprod(1 + ret_clean), by=permno]
  out[, running_peak := cummax(wealth_index), by=permno]
  out[, drawdown := wealth_index / running_peak - 1]
  out[]
}

fn_terminal_failure_hit <- function(failure_dates,
                                    failure_codes,
                                    failure_dlrets,
                                    trigger_date,
                                    confirm_date) {
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

fn_detect_events_one_firm <- function(dt, C, M, T, end_date,
                                      failures_dt, confirm_col) {
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

  event_seq_v <- integer(n)
  trigger_date_v <- rep(as.Date(NA), n)
  confirmation_date_v <- rep(as.Date(NA), n)
  trigger_year_v <- integer(n)
  trigger_month_v <- integer(n)
  event_status_v <- rep(NA_character_, n)
  wealth_trigger_v <- rep(NA_real_, n)
  peak_at_trigger_v <- rep(NA_real_, n)
  drawdown_trigger_v <- rep(NA_real_, n)
  recovery_ceiling_v <- rep(NA_real_, n)
  window_max_v <- rep(NA_real_, n)
  postT_max_v <- rep(NA_real_, n)
  terminal_wealth_v <- rep(NA_real_, n)
  terminal_date_v <- rep(as.Date(NA), n)
  exit_date_v <- rep(as.Date(NA), n)
  months_to_late_recovery_v <- rep(NA_integer_, n)
  terminal_failure_date_v <- rep(as.Date(NA), n)
  terminal_failure_code_v <- rep(NA_integer_, n)
  terminal_failure_dlret_v <- rep(NA_real_, n)

  record_event <- function(status,
                           window_max,
                           postT_max,
                           exit_date = as.Date(NA),
                           months_to_late_recovery = NA_integer_,
                           terminal_failure_date = as.Date(NA),
                           terminal_failure_code = NA_integer_,
                           terminal_failure_dlret = NA_real_) {
    event_n <<- event_n + 1L
    event_seq_v[event_n] <<- event_n
    trigger_date_v[event_n] <<- trigger_date
    confirmation_date_v[event_n] <<- confirm_date
    trigger_year_v[event_n] <<- date_years[i]
    trigger_month_v[event_n] <<- date_months[i]
    event_status_v[event_n] <<- status
    wealth_trigger_v[event_n] <<- wealth_trigger
    peak_at_trigger_v[event_n] <<- peak_at_trigger
    drawdown_trigger_v[event_n] <<- drawdown[i]
    recovery_ceiling_v[event_n] <<- recovery_ceiling
    window_max_v[event_n] <<- window_max
    postT_max_v[event_n] <<- postT_max
    terminal_wealth_v[event_n] <<- terminal_wealth_last
    terminal_date_v[event_n] <<- terminal_date_last
    exit_date_v[event_n] <<- exit_date
    months_to_late_recovery_v[event_n] <<- months_to_late_recovery
    terminal_failure_date_v[event_n] <<- terminal_failure_date
    terminal_failure_code_v[event_n] <<- terminal_failure_code
    terminal_failure_dlret_v[event_n] <<- terminal_failure_dlret
  }

  i <- 1L
  event_n <- 0L

  while (i <= n) {
    if (!is.na(drawdown[i]) && drawdown[i] <= C) {
      trigger_date     <- dates[i]
      confirm_date     <- confirm_dates[i]
      wealth_trigger   <- wealth_index[i]
      peak_at_trigger  <- running_peak[i]
      recovery_ceiling <- wealth_trigger * (1 + M)
      terminal_hit <- fn_terminal_failure_hit(
        failure_dates,
        failure_codes,
        failure_dlrets,
        trigger_date,
        confirm_date
      )

      if (confirm_date > end_date) {
        if (!is.null(terminal_hit)) {
          record_event(
            status = "terminal_failure_before_confirmation",
            window_max = NA_real_,
            postT_max = NA_real_,
            terminal_failure_date = terminal_hit$dlstdt,
            terminal_failure_code = terminal_hit$dlstcd,
            terminal_failure_dlret = terminal_hit$dlret
          )
        } else {
          record_event(
            status = "censored",
            window_max = NA_real_,
            postT_max = NA_real_
          )
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

      forward_max <- max(wealth_index[forward_idx], na.rm=TRUE)

      if (forward_max <= recovery_ceiling) {
        post_idx <- if (end_idx < n) seq(end_idx + 1L, n) else integer()
        post_vals <- if (length(post_idx) > 0L) wealth_index[post_idx] else numeric()
        post_dates <- if (length(post_idx) > 0L) dates[post_idx] else as.Date(character())
        late_hit <- which(post_vals > recovery_ceiling)
        exit_date <- if (length(late_hit) > 0L) post_dates[late_hit[1L]] else as.Date(NA)
        months_to_late <- if (!is.na(exit_date)) fn_months_between(trigger_date, exit_date) else NA_integer_

        record_event(
          status = "confirmed_csi",
          window_max = forward_max,
          postT_max = if (length(post_vals) > 0L) max(post_vals, na.rm=TRUE) else NA_real_,
          exit_date = exit_date,
          months_to_late_recovery = months_to_late
        )

        # Dynamic state is unresolved through the confirmation window. If the
        # firm later recovers, 05A stores exit_date and 05C can allow re-entry.
        i <- end_idx + 1L
      } else {
        if (!is.null(terminal_hit)) {
          record_event(
            status = "terminal_failure_before_confirmation",
            window_max = forward_max,
            postT_max = NA_real_,
            terminal_failure_date = terminal_hit$dlstdt,
            terminal_failure_code = terminal_hit$dlstcd,
            terminal_failure_dlret = terminal_hit$dlret
          )
        } else {
          record_event(
            status = "recovered_within_T",
            window_max = forward_max,
            postT_max = NA_real_
          )
        }
        i <- i + 1L
      }
    } else {
      i <- i + 1L
    }
  }

  if (event_n == 0L) return(data.table())
  idx <- seq_len(event_n)
  data.table(
    event_seq = event_seq_v[idx],
    trigger_date = trigger_date_v[idx],
    confirmation_date = confirmation_date_v[idx],
    trigger_year = trigger_year_v[idx],
    trigger_month = trigger_month_v[idx],
    event_status = event_status_v[idx],
    wealth_trigger = wealth_trigger_v[idx],
    peak_at_trigger = peak_at_trigger_v[idx],
    drawdown_trigger = drawdown_trigger_v[idx],
    recovery_ceiling = recovery_ceiling_v[idx],
    window_max = window_max_v[idx],
    postT_max = postT_max_v[idx],
    terminal_wealth = terminal_wealth_v[idx],
    terminal_date = terminal_date_v[idx],
    exit_date = exit_date_v[idx],
    months_to_late_recovery = months_to_late_recovery_v[idx],
    terminal_failure_date = terminal_failure_date_v[idx],
    terminal_failure_code = terminal_failure_code_v[idx],
    terminal_failure_dlret = terminal_failure_dlret_v[idx]
  )
}

fn_detect_events <- function(price_path, C, M, T, param_id, terminal_failures) {
  confirm_col <- sprintf("confirm_date_T%03d", as.integer(T))
  events <- price_path[
    ,
    fn_detect_events_one_firm(
      .SD,
      C=C,
      M=M,
      T=T,
      end_date=END_DATE,
      failures_dt=terminal_failures[.(.BY$permno), nomatch=0L],
      confirm_col=confirm_col
    ),
    by=permno,
    .SDcols=c(
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

fn_events_to_annual <- function(events, all_permno, years, param_id) {
  panel <- CJ(permno=all_permno, year=years)
  if (nrow(events) == 0L) {
    panel[, `:=`(y=0L, censored=FALSE, param_id=param_id)]
    return(panel[])
  }

  pos <- unique(events[event_status %in% CSI_POSITIVE_EVENT_STATUSES,
                       .(permno, year=trigger_year - 1L)])
  cens <- unique(events[event_status=="censored",
                        .(permno, year=trigger_year - 1L)])
  panel[, y := 0L]
  panel[pos, y := 1L, on=.(permno, year)]
  panel[, has_censored_trigger := FALSE]
  panel[cens, has_censored_trigger := TRUE, on=.(permno, year)]
  panel[has_censored_trigger == TRUE & y != 1L, y := NA_integer_]
  panel[, censored := is.na(y)]
  panel[, has_censored_trigger := NULL]
  panel[, param_id := param_id]
  panel[]
}

fn_build_monthly_state <- function(events_base, monthly_dates) {
  states <- copy(monthly_dates)
  states[, `:=`(
    csi_state = 0L,
    state_event_seq = NA_integer_,
    state_trigger_date = as.Date(NA),
    state_exit_date = as.Date(NA)
  )]

  positive_events <- events_base[event_status %in% CSI_POSITIVE_EVENT_STATUSES]
  if (nrow(positive_events) == 0L) return(states[])

  for (j in seq_len(nrow(positive_events))) {
    ev <- positive_events[j]
    state_end <- if (
      ev$event_status == "terminal_failure_before_confirmation" &&
        !is.na(ev$terminal_failure_date)
    ) {
      ev$terminal_failure_date
    } else if (!is.na(ev$exit_date)) {
      ev$exit_date
    } else {
      ev$terminal_date
    }
    idx <- states[
      permno == ev$permno &
        date >= ev$trigger_date &
        date <= state_end,
      which=TRUE
    ]
    if (length(idx) == 0L) next
    states[idx, `:=`(
      csi_state = 1L,
      state_event_seq = ev$event_seq,
      state_trigger_date = ev$trigger_date,
      state_exit_date = ev$exit_date
    )]
  }
  states[]
}

#==============================================================================#
# 2. Detect events
#==============================================================================#

price_path <- fn_prepare_price_path(prices_monthly)
price_path[, `:=`(
  calendar_year = year(date),
  calendar_month = month(date)
)]
for (horizon in sort(unique(CSI_GRID$T))) {
  confirm_col <- sprintf("confirm_date_T%03d", as.integer(horizon))
  price_path[, (confirm_col) := date %m+% months(as.integer(horizon))]
}
all_permno <- sort(unique(price_path$permno))
years <- seq(year(START_DATE), year(END_DATE))

base_param_id <- CSI_GRID[
  CSI_GRID$C == CSI_BASE$C &
    CSI_GRID$M == CSI_BASE$M &
    CSI_GRID$T == CSI_BASE$T,
  "param_id"
][[1]]

cat(sprintf("\n[05A] Running base dynamic CSI: %s\n", base_param_id))
events_base <- fn_detect_events(
  price_path,
  C=CSI_BASE$C,
  M=CSI_BASE$M,
  T=CSI_BASE$T,
  param_id=base_param_id,
  terminal_failures=terminal_failures
)
saveRDS(events_base, PATH_CSI_EVENTS_BASE)

cat(sprintf("  Base trigger rows     : %d\n", nrow(events_base)))
cat(sprintf("  Confirmed CSI events  : %d\n",
            nrow(events_base[event_status=="confirmed_csi"])))
cat(sprintf("  Terminal failures     : %d\n",
            nrow(events_base[
              event_status=="terminal_failure_before_confirmation"
            ])))
cat(sprintf("  Positive CSI events   : %d\n",
            nrow(events_base[
              event_status %in% CSI_POSITIVE_EVENT_STATUSES
            ])))
cat(sprintf("  Late recoveries       : %d\n",
            sum(events_base$late_recovery, na.rm=TRUE)))

#==============================================================================#
# 3. Dynamic monthly state and annual compatibility labels
#==============================================================================#

monthly_state <- fn_build_monthly_state(
  events_base,
  price_path[, .(permno, date)]
)
saveRDS(monthly_state, PATH_CSI_STATE_MONTHLY)

labels_base <- fn_events_to_annual(events_base, all_permno, years, base_param_id)
labels_base[, param_id := "BASE"]
saveRDS(labels_base, PATH_LABELS_BASE)

if (CSI_RUN_GRID) {
  cat(sprintf("\n[05A] Running CSI grid (%d combinations)...\n", nrow(CSI_GRID)))
  grid_worker <- function(i) {
    prm <- CSI_GRID[i, ]
    cat(sprintf("  [%02d/%02d] %s\n", i, nrow(CSI_GRID), prm$param_id))
    ev <- fn_detect_events(
      price_path,
      prm$C,
      prm$M,
      prm$T,
      prm$param_id,
      terminal_failures=terminal_failures
    )
    list(
      events = ev,
      annual = fn_events_to_annual(ev, all_permno, years, prm$param_id)
    )
  }

  grid_workers <- min(CSI_GRID_WORKERS, nrow(CSI_GRID))
  if (grid_workers > 1L && .Platform$OS.type == "unix") {
    cat(sprintf("  Parallel grid workers: %d\n", grid_workers))
    grid_results <- parallel::mclapply(
      seq_len(nrow(CSI_GRID)),
      grid_worker,
      mc.cores=grid_workers
    )
  } else {
    if (grid_workers > 1L) {
      cat("  Parallel grid workers requested but unavailable on this OS; using 1.\n")
    }
    grid_results <- lapply(seq_len(nrow(CSI_GRID)), grid_worker)
  }

  grid_events <- lapply(grid_results, function(x) x[["events"]])
  grid_annual <- lapply(grid_results, function(x) x[["annual"]])

  events_grid <- rbindlist(grid_events, fill=TRUE)
  labels_grid <- rbindlist(grid_annual, fill=TRUE)
  saveRDS(events_grid, PATH_CSI_EVENTS_GRID)
  saveRDS(labels_grid, PATH_LABELS_GRID)
} else {
  cat("\n[05A] Skipping CSI grid. Set CSI_RUN_GRID=1 for robustness grid output.\n")
  events_grid <- NULL
  labels_grid <- NULL
}


#==============================================================================#
# 3. Diagnostics and figures
#==============================================================================#

event_diag_source <- if (CSI_RUN_GRID) events_grid else events_base
event_diag <- event_diag_source[, .(
  n_triggers = .N,
  n_confirmed = sum(event_status=="confirmed_csi"),
  n_terminal_failure_before_confirmation =
    sum(event_status=="terminal_failure_before_confirmation"),
  n_positive = sum(event_status %in% CSI_POSITIVE_EVENT_STATUSES),
  n_recovered_within_T = sum(event_status=="recovered_within_T"),
  n_censored = sum(event_status=="censored"),
  late_recovery_rate = mean(late_recovery[event_status=="confirmed_csi"], na.rm=TRUE),
  median_terminal_vs_peak = median(terminal_vs_peak[event_status=="confirmed_csi"], na.rm=TRUE)
), by=.(param_id, C, M, T)]
saveRDS(event_diag, PATH_CSI_DIAG)

annual_diag_source <- if (CSI_RUN_GRID) labels_grid else labels_base
annual_diag <- annual_diag_source[, .(
  n_obs = .N,
  n_csi = sum(y==1L, na.rm=TRUE),
  n_clean = sum(y==0L, na.rm=TRUE),
  n_na = sum(is.na(y)),
  prevalence_pct = 100 * mean(y==1L, na.rm=TRUE),
  above_threshold = mean(y==1L, na.rm=TRUE) > MAX_IMPLOSION_RATE
), by=.(param_id)]
if (CSI_RUN_GRID) {
  annual_diag <- merge(annual_diag, as.data.table(CSI_GRID), by="param_id", all.x=TRUE)
} else {
  annual_diag[, c("C", "M", "T") := .(CSI_BASE$C, CSI_BASE$M, CSI_BASE$T)]
}
saveRDS(annual_diag, PATH_LABELS_DIAG)

events_per_year <- events_base[
  event_status %in% CSI_POSITIVE_EVENT_STATUSES,
  .N,
  by=trigger_year
]
setnames(events_per_year, "trigger_year", "year")

p_events <- ggplot(events_per_year, aes(x=year, y=N)) +
  geom_col(fill="#2c5f8a", width=0.7) +
  labs(
    title="Dynamic CSI Events per Year - Base Case",
    subtitle=sprintf("C=%.2f | M=%.2f | T=%d months",
                     CSI_BASE$C, CSI_BASE$M, CSI_BASE$T),
    x="Trigger year",
    y="Positive dynamic CSI events"
  ) +
  theme_minimal(base_size=12)

ggsave(PATH_FIGURE_CSI, p_events,
       width=PLOT_WIDTH, height=PLOT_HEIGHT, dpi=PLOT_DPI)

cat("\n[05A] DONE\n")
cat(sprintf("  Events base       : %s\n", PATH_CSI_EVENTS_BASE))
if (CSI_RUN_GRID) {
  cat(sprintf("  Events grid       : %s\n", PATH_CSI_EVENTS_GRID))
} else {
  cat("  Events grid       : skipped (CSI_RUN_GRID=0)\n")
}
cat(sprintf("  Monthly state     : %s\n", PATH_CSI_STATE_MONTHLY))
cat(sprintf("  Legacy annual     : %s\n", PATH_LABELS_BASE))
