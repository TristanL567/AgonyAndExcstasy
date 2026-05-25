#==============================================================================#
#==== 14c_RobustnessChecks_PermanentCapitalLoss_Response.R ====================#
#==== Permanent Capital Loss Response Robustness ===============================#
#==============================================================================#
#
# PURPOSE:
#   Audit candidate permanent capital loss response definitions before changing
#   the production 05B label. The script starts from the base Tewari-style CSI
#   event definition and evaluates a grid of permanent-loss definitions:
#
#     V in {36, 48, 60}                 validation horizon in months
#     q in {0.40, 0.50, 0.60}           maximum recovered share of prior peak
#     L in {-0.60, -0.70, -0.80}        wealth loss at validation end vs peak
#     require_no_late_recovery in {TRUE, FALSE}
#
#   The permanent label is defined using information up to m+V. Survival after
#   m+V is then evaluated separately, so the audit is not tautological.
#
# OUTPUTS:
#   robust_pcl_response_grid.rds
#   robust_pcl_response_events.rds
#   robust_pcl_response_yearly.rds
#   robust_pcl_response_survival_heatmap.png
#   robust_pcl_response_event_count_heatmap.png
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(lubridate)
  library(scales)
})

cat("\n[14c] Permanent Capital Loss Response Robustness START:",
    format(Sys.time()), "\n")

OUT_DIR <- file.path(DIR_ROB_NEC, "permanent_csi",
                     "14c_permanent_capital_loss")
FIG_DIR <- OUT_DIR
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

PATH_PCL_GRID_OUT   <- file.path(OUT_DIR, "robust_pcl_response_grid.rds")
PATH_PCL_EVENTS_OUT <- file.path(OUT_DIR, "robust_pcl_response_events.rds")
PATH_PCL_YEARLY_OUT <- file.path(OUT_DIR, "robust_pcl_response_yearly.rds")
PATH_PCL_ALIGN_OUT  <- file.path(OUT_DIR, "robust_pcl_response_feature_alignment.rds")

#==============================================================================#
# 1. Load and prepare monthly price path
#==============================================================================#

prices_monthly <- as.data.table(readRDS(PATH_PRICES_MONTHLY))
universe <- as.data.table(readRDS(PATH_UNIVERSE))

setnames(prices_monthly, "ret_adj", "ret", skip_absent=TRUE)
prices_monthly <- prices_monthly[permno %in% universe$permno]
prices_monthly[, date := as.Date(date)]
prices_monthly[, ret := pmin(pmax(ret, -0.99, na.rm=TRUE), 10, na.rm=TRUE)]
setorder(prices_monthly, permno, date)

prices_monthly[, ret_clean := fifelse(is.na(ret), 0, ret)]
prices_monthly[, wealth_index := cumprod(1 + ret_clean), by=permno]
prices_monthly[, running_peak := cummax(wealth_index), by=permno]
prices_monthly[, drawdown := wealth_index / running_peak - 1]
prices_monthly[, row_in_firm := seq_len(.N), by=permno]

cat(sprintf("  Monthly rows : %d | permnos: %d | %s to %s\n",
            nrow(prices_monthly), uniqueN(prices_monthly$permno),
            min(prices_monthly$date), max(prices_monthly$date)))

#==============================================================================#
# 2. Base Tewari CSI events
#==============================================================================#

fn_months_between <- function(start_date, end_date) {
  12L * (year(end_date) - year(start_date)) + (month(end_date) - month(start_date))
}

fn_detect_base_events_one_firm <- function(dt, C, M, T, end_date) {
  n <- nrow(dt)
  if (n == 0L) return(data.table())

  out <- vector("list", 0L)
  i <- 1L
  event_n <- 0L

  while (i <= n) {
    if (!is.na(dt$drawdown[i]) && dt$drawdown[i] <= C) {
      trigger_date <- dt$date[i]
      confirm_date <- trigger_date %m+% months(T)
      wealth_trigger <- dt$wealth_index[i]
      peak_at_trigger <- dt$running_peak[i]
      recovery_ceiling <- wealth_trigger * (1 + abs(M))
      event_n <- event_n + 1L

      if (confirm_date > end_date || i + T > n) {
        out[[length(out) + 1L]] <- data.table(
          event_seq = event_n,
          trigger_idx = i,
          trigger_date = trigger_date,
          confirmation_date = confirm_date,
          event_status = "censored",
          wealth_trigger = wealth_trigger,
          peak_at_trigger = peak_at_trigger,
          drawdown_trigger = dt$drawdown[i],
          recovery_ceiling = recovery_ceiling,
          window_max = NA_real_
        )
        i <- i + 1L
        next
      }

      forward_idx <- seq(i + 1L, i + T)
      forward_max <- max(dt$wealth_index[forward_idx], na.rm=TRUE)

      if (forward_max <= recovery_ceiling) {
        out[[length(out) + 1L]] <- data.table(
          event_seq = event_n,
          trigger_idx = i,
          trigger_date = trigger_date,
          confirmation_date = confirm_date,
          event_status = "confirmed_csi",
          wealth_trigger = wealth_trigger,
          peak_at_trigger = peak_at_trigger,
          drawdown_trigger = dt$drawdown[i],
          recovery_ceiling = recovery_ceiling,
          window_max = forward_max
        )

        # Move beyond the confirmation window to avoid repeated triggers inside
        # the same unresolved impairment episode.
        i <- i + T + 1L
      } else {
        out[[length(out) + 1L]] <- data.table(
          event_seq = event_n,
          trigger_idx = i,
          trigger_date = trigger_date,
          confirmation_date = confirm_date,
          event_status = "recovered_within_T",
          wealth_trigger = wealth_trigger,
          peak_at_trigger = peak_at_trigger,
          drawdown_trigger = dt$drawdown[i],
          recovery_ceiling = recovery_ceiling,
          window_max = forward_max
        )
        i <- i + 1L
      }
    } else {
      i <- i + 1L
    }
  }

  if (length(out) == 0L) return(data.table())
  rbindlist(out)
}

C_BASE <- CSI_BASE$C
M_BASE <- CSI_BASE$M
T_BASE <- CSI_BASE$T

cat(sprintf("  Base CSI parameters: C=%.2f | M=%.2f | T=%d\n",
            C_BASE, M_BASE, T_BASE))

base_events <- prices_monthly[
  ,
  fn_detect_base_events_one_firm(.SD, C=C_BASE, M=M_BASE,
                                 T=T_BASE, end_date=END_DATE),
  by=permno,
  .SDcols=c("date", "wealth_index", "running_peak", "drawdown")
]

base_events[, `:=`(
  trigger_year = year(trigger_date),
  trigger_month = month(trigger_date)
)]

confirmed_events <- base_events[event_status == "confirmed_csi"]

cat(sprintf("  Candidate triggers    : %d\n", nrow(base_events)))
cat(sprintf("  Confirmed CSI events  : %d\n", nrow(confirmed_events)))
cat(sprintf("  Confirmed CSI firms   : %d\n", uniqueN(confirmed_events$permno)))

#==============================================================================#
# 3. Event-path diagnostics for V grid
#==============================================================================#

V_GRID <- c(36L, 48L, 60L)
Q_GRID <- c(0.40, 0.50, 0.60)
L_GRID <- c(-0.60, -0.70, -0.80)
REQUIRE_GRID <- c(TRUE, FALSE)

fn_event_paths_one_firm <- function(dt, ev_dt, V_grid) {
  if (nrow(ev_dt) == 0L) return(data.table())
  out <- vector("list", nrow(ev_dt) * length(V_grid))
  z <- 0L
  n <- nrow(dt)

  for (e in seq_len(nrow(ev_dt))) {
    trig_idx <- ev_dt$trigger_idx[e]
    trigger_date <- ev_dt$trigger_date[e]
    peak_at_trigger <- ev_dt$peak_at_trigger[e]
    wealth_trigger <- ev_dt$wealth_trigger[e]
    recovery_ceiling <- ev_dt$recovery_ceiling[e]
    confirm_idx <- trig_idx + T_BASE

    post_confirm_idx <- if (confirm_idx < n) seq(confirm_idx + 1L, n) else integer()
    late_recovery_full <- if (length(post_confirm_idx) > 0L) {
      any(dt$wealth_index[post_confirm_idx] > recovery_ceiling, na.rm=TRUE)
    } else {
      NA
    }

    for (V in V_grid) {
      val_idx <- trig_idx + V
      validation_date <- trigger_date %m+% months(V)
      observable_V <- validation_date <= END_DATE && val_idx <= n

      if (observable_V) {
        idx_V <- seq(trig_idx + 1L, val_idx)
        wealth_V <- dt$wealth_index[val_idx]
        max_wealth_V <- max(dt$wealth_index[idx_V], na.rm=TRUE)
        recov_ceiling_V <- any(dt$wealth_index[idx_V] > recovery_ceiling,
                               na.rm=TRUE)
        post_V_idx <- if (val_idx < n) seq(val_idx + 1L, n) else integer()
        post_V_max <- if (length(post_V_idx) > 0L) {
          max(dt$wealth_index[post_V_idx], na.rm=TRUE)
        } else {
          NA_real_
        }
        post_V_recov_ceiling <- if (length(post_V_idx) > 0L) {
          any(dt$wealth_index[post_V_idx] > recovery_ceiling, na.rm=TRUE)
        } else {
          NA
        }
      } else {
        wealth_V <- NA_real_
        max_wealth_V <- NA_real_
        recov_ceiling_V <- NA
        post_V_max <- NA_real_
        post_V_recov_ceiling <- NA
      }

      z <- z + 1L
      out[[z]] <- data.table(
        event_seq = ev_dt$event_seq[e],
        trigger_idx = trig_idx,
        trigger_date = trigger_date,
        confirmation_date = ev_dt$confirmation_date[e],
        V = V,
        validation_date = validation_date,
        observable_V = observable_V,
        wealth_trigger = wealth_trigger,
        peak_at_trigger = peak_at_trigger,
        recovery_ceiling = recovery_ceiling,
        drawdown_trigger = ev_dt$drawdown_trigger[e],
        wealth_V = wealth_V,
        wealth_V_vs_peak = wealth_V / peak_at_trigger - 1,
        max_wealth_V = max_wealth_V,
        max_wealth_V_vs_peak = max_wealth_V / peak_at_trigger,
        recovered_above_ceiling_V = recov_ceiling_V,
        late_recovery_full = late_recovery_full,
        post_V_max = post_V_max,
        post_V_max_vs_peak = post_V_max / peak_at_trigger,
        post_V_recovered_above_ceiling = post_V_recov_ceiling
      )
    }
  }

  rbindlist(out[seq_len(z)])
}

cat("  Computing event paths for V grid...\n")

event_paths <- prices_monthly[
  ,
  {
    ev_dt <- confirmed_events[permno == .BY$permno]
    fn_event_paths_one_firm(.SD[order(date)], ev_dt, V_GRID)
  },
  by=permno,
  .SDcols=c("date", "wealth_index")
]

saveRDS(event_paths, PATH_PCL_EVENTS_OUT)

#==============================================================================#
# 4. Permanent-loss grid
#==============================================================================#

grid <- CJ(
  V = V_GRID,
  q = Q_GRID,
  L = L_GRID,
  require_no_late_recovery = REQUIRE_GRID
)
grid[, param_id := sprintf(
  "V%02d_q%02d_L%02d_late%s",
  V, as.integer(round(100 * q)), as.integer(round(abs(100 * L))),
  ifelse(require_no_late_recovery, "Y", "N")
)]

grid_results <- vector("list", nrow(grid))
yearly_results <- vector("list", nrow(grid))
event_label_results <- vector("list", nrow(grid))

for (g in seq_len(nrow(grid))) {
  V_val <- grid$V[g]
  q <- grid$q[g]
  L <- grid$L[g]
  req_late <- grid$require_no_late_recovery[g]
  pid <- grid$param_id[g]

  dt <- copy(event_paths[V == V_val])
  dt[, y_perm_event := fifelse(
    observable_V == TRUE &
      (!req_late | recovered_above_ceiling_V == FALSE) &
      max_wealth_V_vs_peak <= q &
      wealth_V_vs_peak <= L,
    1L,
    fifelse(observable_V == TRUE, 0L, NA_integer_)
  )]

  dt[, survived_post_V := fifelse(
    y_perm_event == 1L & !is.na(post_V_max_vs_peak),
    post_V_max_vs_peak > q | post_V_recovered_above_ceiling == TRUE,
    NA
  )]

  dt[, survived_by_terminal := fifelse(
    y_perm_event == 1L & !is.na(post_V_max_vs_peak),
    post_V_max_vs_peak > q,
    NA
  )]

  labelled <- dt[!is.na(y_perm_event)]
  positive <- dt[y_perm_event == 1L]

  grid_results[[g]] <- data.table(
    param_id = pid,
    V = V_val,
    q = q,
    L = L,
    require_no_late_recovery = req_late,
    n_confirmed_csi = uniqueN(confirmed_events[, .(permno, event_seq)]),
    n_observable = nrow(labelled),
    n_censored = sum(is.na(dt$y_perm_event)),
    n_perm_events = nrow(positive),
    n_perm_firms = uniqueN(positive$permno),
    perm_event_rate = nrow(positive) / max(nrow(labelled), 1L),
    survived_post_V_n = sum(positive$survived_post_V == TRUE, na.rm=TRUE),
    survived_post_V_rate = mean(positive$survived_post_V == TRUE, na.rm=TRUE),
    non_survival_post_V_rate = mean(positive$survived_post_V == FALSE, na.rm=TRUE),
    survival_audit_available_n = sum(!is.na(positive$survived_post_V)),
    median_wealth_V_vs_peak = median(positive$wealth_V_vs_peak, na.rm=TRUE),
    median_post_V_max_vs_peak = median(positive$post_V_max_vs_peak, na.rm=TRUE),
    median_drawdown_trigger = median(positive$drawdown_trigger, na.rm=TRUE)
  )

  if (nrow(positive) > 0L) {
    yr <- positive[, .(
      n_perm_events = .N,
      n_perm_firms = uniqueN(permno),
      survived_post_V_n = sum(survived_post_V == TRUE, na.rm=TRUE),
      survival_audit_available_n = sum(!is.na(survived_post_V))
    ), by=.(trigger_year=year(trigger_date))]
    yr[, `:=`(
      param_id = pid,
      V = V_val,
      q = q,
      L = L,
      require_no_late_recovery = req_late,
      survived_post_V_rate = survived_post_V_n / pmax(survival_audit_available_n, 1L)
    )]
    yearly_results[[g]] <- yr
  }

  dt[, `:=`(
    param_id = pid,
    q = q,
    L = L,
    require_no_late_recovery = req_late
  )]
  event_label_results[[g]] <- dt
}

grid_results <- rbindlist(grid_results)
yearly_results <- rbindlist(yearly_results, fill=TRUE)
event_label_results <- rbindlist(event_label_results, fill=TRUE)

setorder(grid_results, V, q, L, require_no_late_recovery)
saveRDS(grid_results, PATH_PCL_GRID_OUT)
saveRDS(yearly_results, PATH_PCL_YEARLY_OUT)
saveRDS(event_label_results, PATH_PCL_EVENTS_OUT)

#==============================================================================#
# 4B. Annual feature-row alignment audit
#==============================================================================#

cat("  Auditing alignment to annual feature rows...\n")

features_raw <- as.data.table(readRDS(PATH_FEATURES_RAW))
feature_panel <- unique(features_raw[, .(permno, year)])
feature_panel[, `:=`(
  prediction_date = make_date(year + 1L, PREDICTION_MONTH, PREDICTION_DAY),
  label_end_date = make_date(year + 1L, PREDICTION_MONTH, PREDICTION_DAY) %m+%
    months(LABEL_FWD_MONTHS)
)]
feature_panel[, label_censored := label_end_date > END_DATE]
feature_panel[, row_id := .I]
feature_panel[, `:=`(
  start = prediction_date + days(1L),
  end = label_end_date
)]

setkey(feature_panel, permno, start, end)

alignment_results <- vector("list", nrow(grid))

for (g in seq_len(nrow(grid))) {
  pid <- grid$param_id[g]
  ev <- event_label_results[param_id == pid & y_perm_event == 1L,
                            .(permno, trigger_date)]
  ev <- unique(ev)
  if (nrow(ev) > 0L) {
    ev[, `:=`(start = trigger_date, end = trigger_date)]
    setkey(ev, permno, start, end)
    hits <- foverlaps(ev, feature_panel, type="within", nomatch=0L)
    positive_rows <- unique(hits$row_id)
  } else {
    positive_rows <- integer()
  }

  usable_rows <- feature_panel[label_censored == FALSE]
  alignment_results[[g]] <- data.table(
    param_id = pid,
    V = grid$V[g],
    q = grid$q[g],
    L = grid$L[g],
    require_no_late_recovery = grid$require_no_late_recovery[g],
    n_feature_rows = nrow(feature_panel),
    n_usable_feature_rows = nrow(usable_rows),
    n_censored_feature_rows = sum(feature_panel$label_censored),
    n_positive_feature_rows = sum(feature_panel$row_id %in% positive_rows),
    n_positive_feature_firms = uniqueN(feature_panel[row_id %in% positive_rows]$permno),
    response_prevalence = sum(feature_panel$row_id %in% positive_rows) /
      max(nrow(usable_rows), 1L)
  )
}

alignment_results <- rbindlist(alignment_results)
saveRDS(alignment_results, PATH_PCL_ALIGN_OUT)

#==============================================================================#
# 5. Figures
#==============================================================================#

plot_dt <- copy(grid_results)
plot_dt[, late_rule := fifelse(require_no_late_recovery,
                               "No recovery above CSI ceiling required",
                               "Late recovery allowed")]
plot_dt[, L_label := sprintf("L <= %.0f%%", 100 * L)]
plot_dt[, q_label := sprintf("q <= %.0f%%", 100 * q)]

p_surv <- ggplot(
  plot_dt[survival_audit_available_n > 0],
  aes(x=factor(V), y=q_label, fill=non_survival_post_V_rate)
) +
  geom_tile(colour="white", linewidth=0.2) +
  geom_text(aes(label=sprintf("%.1f%%", 100 * non_survival_post_V_rate)),
            size=3.0) +
  facet_grid(L_label ~ late_rule) +
  scale_fill_gradient(low="#d73027", high="#1a9850",
                      labels=percent_format(accuracy=1),
                      limits=c(0, 1), name="Do not survive\nafter V") +
  labs(
    title="Permanent Capital Loss Robustness: Post-Validation Non-Survival",
    subtitle="Among events labelled permanent using information through m+V",
    x="Validation horizon V (months)",
    y="Max wealth during validation as share of prior peak"
  ) +
  theme_minimal(base_size=11) +
  theme(panel.grid=element_blank())

ggsave(file.path(FIG_DIR, "robust_pcl_response_survival_heatmap.png"),
       p_surv, width=12, height=8, dpi=300)

p_count <- ggplot(
  plot_dt,
  aes(x=factor(V), y=q_label, fill=n_perm_events)
) +
  geom_tile(colour="white", linewidth=0.2) +
  geom_text(aes(label=scales::comma(n_perm_events)), size=3.0) +
  facet_grid(L_label ~ late_rule) +
  scale_fill_gradient(low="#f7fbff", high="#08306b",
                      labels=comma, name="Permanent\nevents") +
  labs(
    title="Permanent Capital Loss Robustness: Label Count",
    subtitle="Number of confirmed CSI events satisfying each permanent-loss definition",
    x="Validation horizon V (months)",
    y="Max wealth during validation as share of prior peak"
  ) +
  theme_minimal(base_size=11) +
  theme(panel.grid=element_blank())

ggsave(file.path(FIG_DIR, "robust_pcl_response_event_count_heatmap.png"),
       p_count, width=12, height=8, dpi=300)

#==============================================================================#
# 6. Console summary
#==============================================================================#

cat("\n[14c] Permanent-loss grid summary:\n")
print(grid_results[, .(
  param_id, V, q, L, require_no_late_recovery,
  n_observable, n_perm_events, n_perm_firms,
  perm_event_rate = round(100 * perm_event_rate, 2),
  survived_post_V_n,
  survived_post_V_rate = round(100 * survived_post_V_rate, 2),
  non_survival_post_V_rate = round(100 * non_survival_post_V_rate, 2),
  survival_audit_available_n
)])

best <- grid_results[survival_audit_available_n >= 100][
  order(-non_survival_post_V_rate, -n_perm_events)
][1:10]

cat("\n[14c] Highest post-validation non-survival definitions",
    "(requiring >=100 auditable positives):\n")
print(best[, .(
  param_id, V, q, L, require_no_late_recovery,
  n_perm_events, n_perm_firms,
  survived_post_V_n,
  non_survival_post_V_rate = round(100 * non_survival_post_V_rate, 2)
)])

cat("\n[14c] Annual feature-row response alignment for those definitions:\n")
print(alignment_results[param_id %in% best$param_id][
  match(best$param_id, param_id),
  .(
    param_id,
    n_usable_feature_rows,
    n_positive_feature_rows,
    n_positive_feature_firms,
    response_prevalence = round(100 * response_prevalence, 3)
  )
])

cat("\n[14c] DONE\n")
cat(sprintf("  Grid results   : %s\n", PATH_PCL_GRID_OUT))
cat(sprintf("  Event labels   : %s\n", PATH_PCL_EVENTS_OUT))
cat(sprintf("  Yearly results : %s\n", PATH_PCL_YEARLY_OUT))
cat(sprintf("  Alignment      : %s\n", PATH_PCL_ALIGN_OUT))
cat(sprintf("  Figures        : %s\n", FIG_DIR))
