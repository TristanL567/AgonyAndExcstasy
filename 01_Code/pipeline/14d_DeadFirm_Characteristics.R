#==============================================================================#
#==== 14d_DeadFirm_Characteristics.R =========================================#
#==== Characteristics of Permanent Non-Survivor Firms =========================#
#==============================================================================#
#
# PURPOSE:
#   Take the strict permanent-capital-loss candidates from 14c and study which
#   pre-event annual characteristics they share. The analysis aligns event
#   outcomes back to the annual feature rows that would have predicted them.
#
# BASELINE "DEAD" DEFINITION:
#   param_id = V60_q40_L80_lateY
#   y_perm_event == 1
#   survived_post_V == FALSE
#
# COMPARISON GROUPS:
#   dead_pcl      : strict permanent-loss event, no post-validation survival
#   survived_pcl  : strict permanent-loss event, but later recovered/survived
#   control       : usable annual feature rows without a strict PCL event in the
#                   next 12 months
#
# OUTPUTS:
#   dead_firm_feature_ranking_raw.rds/csv
#   dead_firm_feature_ranking_fund.rds/csv
#   dead_firm_core_characteristics.rds/csv
#   dead_firm_group_counts.rds/csv
#   dead_firm_top_features.png
#   dead_firm_core_characteristics.png
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(lubridate)
  library(scales)
})

cat("\n[14d] Dead Firm Characteristics START:", format(Sys.time()), "\n")

IN_DIR <- file.path(DIR_ROB_NEC, "permanent_csi",
                    "14c_permanent_capital_loss")
OUT_DIR <- file.path(DIR_ROB_NEC, "permanent_csi",
                     "14d_dead_firm_characteristics")
FIG_DIR <- OUT_DIR
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

PATH_14C_EVENTS <- file.path(IN_DIR, "robust_pcl_response_events.rds")
stopifnot("Run 14c first: missing robust_pcl_response_events.rds" =
            file.exists(PATH_14C_EVENTS))

BASE_PARAM <- "V60_q40_L80_lateY"

#==============================================================================#
# 1. Load inputs
#==============================================================================#

features_raw <- as.data.table(readRDS(PATH_FEATURES_RAW))
features_fund <- as.data.table(readRDS(PATH_FEATURES_FUND))
event_labels <- as.data.table(readRDS(PATH_14C_EVENTS))

cat(sprintf("  Features raw : %d rows | %d cols\n",
            nrow(features_raw), ncol(features_raw)))
cat(sprintf("  Features fund: %d rows | %d cols\n",
            nrow(features_fund), ncol(features_fund)))
cat(sprintf("  Event labels : %d rows\n", nrow(event_labels)))

events_base <- event_labels[param_id == BASE_PARAM]
stopifnot("No events found for BASE_PARAM" = nrow(events_base) > 0L)

events_base[, event_group := fcase(
  y_perm_event == 1L & survived_post_V == FALSE, "dead_pcl",
  y_perm_event == 1L & survived_post_V == TRUE,  "survived_pcl",
  y_perm_event == 1L & is.na(survived_post_V),   "pcl_unknown_postV",
  default = "not_pcl"
)]

cat(sprintf("  Base param   : %s\n", BASE_PARAM))
print(events_base[, .N, by=event_group][order(event_group)])

#==============================================================================#
# 2. Align events to annual feature rows
#==============================================================================#

feature_panel <- unique(features_raw[, .(permno, year)])
feature_panel[, row_id := .I]
feature_panel[, `:=`(
  prediction_date = make_date(year + 1L, PREDICTION_MONTH, PREDICTION_DAY),
  label_end_date = make_date(year + 1L, PREDICTION_MONTH, PREDICTION_DAY) %m+%
    months(LABEL_FWD_MONTHS)
)]
feature_panel[, label_censored := label_end_date > END_DATE]
feature_panel[, `:=`(
  start = prediction_date + days(1L),
  end = label_end_date
)]

event_points <- events_base[
  event_group %in% c("dead_pcl", "survived_pcl"),
  .(permno, trigger_date, validation_date, event_group,
    wealth_V_vs_peak, max_wealth_V_vs_peak, post_V_max_vs_peak,
    drawdown_trigger)
]
event_points[, `:=`(start = trigger_date, end = trigger_date)]

setkey(feature_panel, permno, start, end)
setkey(event_points, permno, start, end)

hits <- foverlaps(event_points, feature_panel, type="within", nomatch=0L)

if (nrow(hits) > 0L) {
  hits[, group_priority := fifelse(event_group == "dead_pcl", 1L, 2L)]
  setorder(hits, row_id, group_priority, trigger_date)
  row_events <- hits[, .SD[1L], by=row_id]
} else {
  row_events <- data.table(row_id=integer())
}

analysis_keys <- copy(feature_panel)
analysis_keys[, outcome_group := "control"]
analysis_keys[row_events[event_group == "survived_pcl"],
              outcome_group := "survived_pcl", on=.(row_id)]
analysis_keys[row_events[event_group == "dead_pcl"],
              outcome_group := "dead_pcl", on=.(row_id)]
analysis_keys[label_censored == TRUE, outcome_group := "censored"]

analysis_keys <- analysis_keys[outcome_group != "censored"]

group_counts <- analysis_keys[, .(
  n_rows = .N,
  n_firms = uniqueN(permno)
), by=outcome_group][order(factor(outcome_group,
                                  levels=c("dead_pcl", "survived_pcl",
                                           "control")))]

saveRDS(group_counts, file.path(OUT_DIR, "dead_firm_group_counts.rds"))
fwrite(group_counts, file.path(OUT_DIR, "dead_firm_group_counts.csv"))

cat("\n  Annual feature-row groups:\n")
print(group_counts)

analysis_raw <- merge(
  features_raw,
  analysis_keys[, .(permno, year, row_id, outcome_group,
                    prediction_date, label_end_date)],
  by=c("permno", "year"),
  all=FALSE
)

analysis_fund <- merge(
  features_fund,
  analysis_keys[, .(permno, year, row_id, outcome_group,
                    prediction_date, label_end_date)],
  by=c("permno", "year"),
  all=FALSE
)

#==============================================================================#
# 3. Feature-ranking helpers
#==============================================================================#

ID_COLS <- c(
  "permno", "year", "row_id", "outcome_group",
  "prediction_date", "label_end_date",
  "y", "censored", "param_id", "gvkey", "datadate",
  "lifetime_years", "fiscal_year_end_month"
)

fn_auc_rank <- function(x, y) {
  ok <- is.finite(x) & !is.na(y)
  x <- x[ok]
  y <- y[ok]
  n1 <- sum(y == 1L)
  n0 <- sum(y == 0L)
  if (n1 == 0L || n0 == 0L) return(NA_real_)
  r <- rank(x, ties.method="average")
  (sum(r[y == 1L]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

fn_feature_ranking <- function(dt, feature_scope) {
  work <- copy(dt[outcome_group %in% c("dead_pcl", "control")])
  work[, y_dead := as.integer(outcome_group == "dead_pcl")]

  feature_cols <- setdiff(names(work)[vapply(work, is.numeric, logical(1))],
                          c(ID_COLS, "y_dead"))

  out <- rbindlist(lapply(feature_cols, function(v) {
    x <- work[[v]]
    y <- work$y_dead
    x_dead <- x[y == 1L & is.finite(x)]
    x_ctrl <- x[y == 0L & is.finite(x)]

    n_dead <- length(x_dead)
    n_ctrl <- length(x_ctrl)
    if (n_dead < 30L || n_ctrl < 30L) return(NULL)

    mean_dead <- mean(x_dead, na.rm=TRUE)
    mean_ctrl <- mean(x_ctrl, na.rm=TRUE)
    sd_pool <- sqrt((var(x_dead, na.rm=TRUE) + var(x_ctrl, na.rm=TRUE)) / 2)
    smd <- if (is.finite(sd_pool) && sd_pool > 0) {
      (mean_dead - mean_ctrl) / sd_pool
    } else {
      NA_real_
    }

    auc <- fn_auc_rank(x, y)

    data.table(
      feature_scope = feature_scope,
      feature = v,
      n_dead = n_dead,
      n_control = n_ctrl,
      mean_dead = mean_dead,
      mean_control = mean_ctrl,
      median_dead = median(x_dead, na.rm=TRUE),
      median_control = median(x_ctrl, na.rm=TRUE),
      missing_dead = mean(!is.finite(x[y == 1L])),
      missing_control = mean(!is.finite(x[y == 0L])),
      smd = smd,
      abs_smd = abs(smd),
      auc_dead_high = auc,
      auc_directional = pmax(auc, 1 - auc, na.rm=TRUE),
      direction = fifelse(mean_dead > mean_ctrl, "higher_in_dead",
                          "lower_in_dead")
    )
  }), fill=TRUE)

  setorder(out, -abs_smd)
  out[]
}

rank_raw <- fn_feature_ranking(analysis_raw, "raw")
rank_fund <- fn_feature_ranking(analysis_fund, "fund")

saveRDS(rank_raw, file.path(OUT_DIR, "dead_firm_feature_ranking_raw.rds"))
saveRDS(rank_fund, file.path(OUT_DIR, "dead_firm_feature_ranking_fund.rds"))
fwrite(rank_raw, file.path(OUT_DIR, "dead_firm_feature_ranking_raw.csv"))
fwrite(rank_fund, file.path(OUT_DIR, "dead_firm_feature_ranking_fund.csv"))

#==============================================================================#
# 4. Core characteristics table
#==============================================================================#

CORE_FEATURES <- c(
  "altman_z", "roa", "roic", "gross_margin", "ocf_margin",
  "leverage", "net_debt_ebitda", "interest_cov", "current_ratio",
  "cash_pct_act", "wcap_ratio", "accruals_ratio", "bp_ratio",
  "mkt_to_book", "log_mkvalt", "log_at", "ann_return", "log_return",
  "vol_12m", "vol_60m", "max_dd_12m", "max_dd_60m", "mom_6m", "mom_24m"
)
CORE_FEATURES <- intersect(CORE_FEATURES, names(analysis_raw))

core_stats <- rbindlist(lapply(CORE_FEATURES, function(v) {
  analysis_raw[, .(
    feature = v,
    n = sum(is.finite(get(v))),
    mean = mean(get(v), na.rm=TRUE),
    median = median(get(v), na.rm=TRUE),
    p25 = quantile(get(v), 0.25, na.rm=TRUE, names=FALSE),
    p75 = quantile(get(v), 0.75, na.rm=TRUE, names=FALSE),
    missing_rate = mean(!is.finite(get(v)))
  ), by=outcome_group]
}), fill=TRUE)

saveRDS(core_stats, file.path(OUT_DIR, "dead_firm_core_characteristics.rds"))
fwrite(core_stats, file.path(OUT_DIR, "dead_firm_core_characteristics.csv"))

#==============================================================================#
# 5. Figures
#==============================================================================#

top_plot <- rank_fund[1:min(.N, 25)]
top_plot[, feature := factor(feature, levels=rev(feature))]

p_top <- ggplot(top_plot, aes(x=feature, y=smd, fill=direction)) +
  geom_col(width=0.72) +
  coord_flip() +
  scale_fill_manual(values=c(
    higher_in_dead="#b2182b",
    lower_in_dead="#2166ac"
  )) +
  labs(
    title="Characteristics Most Associated with Dead Permanent-Loss Firms",
    subtitle=sprintf("Dead vs control annual rows | baseline %s | fundamentals feature set",
                     BASE_PARAM),
    x=NULL,
    y="Standardized mean difference",
    fill=NULL
  ) +
  theme_minimal(base_size=11)

ggsave(file.path(FIG_DIR, "dead_firm_top_features.png"),
       p_top, width=10, height=8, dpi=300)

core_plot_features <- intersect(
  c("altman_z", "roa", "leverage", "interest_cov", "current_ratio",
    "log_mkvalt", "ann_return", "vol_12m", "max_dd_12m", "mom_24m"),
  CORE_FEATURES
)

core_plot <- core_stats[
  feature %in% core_plot_features &
    outcome_group %in% c("dead_pcl", "survived_pcl", "control")
]
core_plot[, feature := factor(feature, levels=core_plot_features)]

p_core <- ggplot(core_plot, aes(x=outcome_group, y=median, fill=outcome_group)) +
  geom_col(width=0.72) +
  facet_wrap(~ feature, scales="free_y", ncol=3) +
  scale_fill_manual(values=c(
    dead_pcl="#b2182b",
    survived_pcl="#ef8a62",
    control="#67a9cf"
  )) +
  labs(
    title="Median Pre-Event Characteristics by Outcome Group",
    subtitle="Annual feature rows aligned to the 12-month event prediction window",
    x=NULL,
    y="Median",
    fill=NULL
  ) +
  theme_minimal(base_size=11) +
  theme(axis.text.x=element_text(angle=30, hjust=1))

ggsave(file.path(FIG_DIR, "dead_firm_core_characteristics.png"),
       p_core, width=11, height=8, dpi=300)

#==============================================================================#
# 6. Console summary
#==============================================================================#

cat("\n[14d] Top 20 raw features by absolute standardized mean difference:\n")
print(rank_raw[1:20, .(
  feature, direction,
  median_dead = signif(median_dead, 4),
  median_control = signif(median_control, 4),
  smd = round(smd, 3),
  auc_directional = round(auc_directional, 3)
)])

cat("\n[14d] Top 20 fundamentals-only features by absolute standardized mean difference:\n")
print(rank_fund[1:20, .(
  feature, direction,
  median_dead = signif(median_dead, 4),
  median_control = signif(median_control, 4),
  smd = round(smd, 3),
  auc_directional = round(auc_directional, 3)
)])

cat("\n[14d] Core characteristic medians:\n")
print(core_stats[
  outcome_group %in% c("dead_pcl", "survived_pcl", "control") &
    feature %in% core_plot_features,
  .(outcome_group, feature, median=signif(median, 4), n)
][order(feature, outcome_group)])

cat("\n[14d] DONE\n")
cat(sprintf("  Tables : %s\n", OUT_DIR))
cat(sprintf("  Figures: %s\n", FIG_DIR))
