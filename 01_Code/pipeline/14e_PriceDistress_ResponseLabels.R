#==============================================================================#
#==== 14e_PriceDistress_ResponseLabels.R ======================================#
#==== Price-Distress Filtered Permanent-Loss Response Labels ===================#
#==============================================================================#
#
# PURPOSE:
#   Use the empirical insight from 14d that dead firms show strong pre-event
#   price distress. This script constructs candidate response labels by adding
#   ex-ante annual price-distress filters to the strict permanent-loss event
#   definition from 14c, then checks how many labelled firms/events survive.
#
# BASE EVENT:
#   V60_q40_L80_lateY from 14c:
#     V = 60 months
#     q = 0.40
#     L = -0.80
#     require_no_late_recovery = TRUE
#
# PRICE-DISTRESS FILTERS:
#   max_dd_60m <= {-0.70, -0.80, -0.90}
#   max_dd_12m <= {-0.50, -0.60, -0.70}
#   vol_60m    >= { 0.15,  0.20,  0.25}
#
#   Candidate labels are built from single filters, pairwise filters, all three
#   filters, and "at least two of three" filters.
#
# OUTPUTS:
#   price_distress_label_grid.rds/csv
#   price_distress_label_rows.rds
#   price_distress_best_labels.csv
#   price_distress_non_survival_heatmap.png
#   price_distress_label_count_heatmap.png
#
#==============================================================================#

source("config.R")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(lubridate)
  library(scales)
})

cat("\n[14e] Price-Distress Response Labels START:", format(Sys.time()), "\n")

IN_DIR <- file.path(DIR_ROB_NEC, "permanent_csi",
                    "14c_permanent_capital_loss")
OUT_DIR <- file.path(DIR_ROB_NEC, "permanent_csi",
                     "14e_price_distress_response_labels")
FIG_DIR <- OUT_DIR
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

PATH_14C_EVENTS <- file.path(IN_DIR, "robust_pcl_response_events.rds")
stopifnot("Run 14c first: missing robust_pcl_response_events.rds" =
            file.exists(PATH_14C_EVENTS))

BASE_PARAM <- "V60_q40_L80_lateY"

#==============================================================================#
# 1. Load inputs and align base events to annual feature rows
#==============================================================================#

features_raw <- as.data.table(readRDS(PATH_FEATURES_RAW))
event_labels <- as.data.table(readRDS(PATH_14C_EVENTS))

needed_price <- c("max_dd_60m", "max_dd_12m", "vol_60m")
missing_price <- setdiff(needed_price, names(features_raw))
if (length(missing_price) > 0L) {
  stop(sprintf("Missing price-distress features: %s",
               paste(missing_price, collapse=", ")))
}

events_base <- event_labels[
  param_id == BASE_PARAM & y_perm_event == 1L,
  .(permno, trigger_date, validation_date, survived_post_V,
    wealth_V_vs_peak, max_wealth_V_vs_peak, post_V_max_vs_peak,
    drawdown_trigger)
]

events_base <- events_base[!is.na(survived_post_V)]
events_base[, event_outcome := fifelse(survived_post_V == FALSE,
                                       "dead", "survived")]

feature_panel <- features_raw[, .(
  permno, year,
  max_dd_60m, max_dd_12m, vol_60m, vol_12m, mom_24m,
  ann_return, log_return, log_mkvalt, altman_z, roa, interest_cov
)]
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

events_base[, `:=`(start = trigger_date, end = trigger_date)]

setkey(feature_panel, permno, start, end)
setkey(events_base, permno, start, end)
hits <- foverlaps(events_base, feature_panel, type="within", nomatch=0L)

if (nrow(hits) == 0L) {
  stop("No strict PCL events align to annual feature rows.")
}

setorder(hits, row_id, trigger_date)
event_rows <- hits[, .SD[1L], by=row_id]

cat(sprintf("  Base strict PCL event rows aligned: %d\n", nrow(event_rows)))
cat(sprintf("  Dead rows     : %d\n", sum(event_rows$event_outcome == "dead")))
cat(sprintf("  Survived rows : %d\n", sum(event_rows$event_outcome == "survived")))
cat(sprintf("  Row non-survival rate: %.2f%%\n",
            100 * mean(event_rows$event_outcome == "dead")))

#==============================================================================#
# 2. Candidate price-distress filters
#==============================================================================#

DD60_GRID <- c(-0.70, -0.80, -0.90)
DD12_GRID <- c(-0.50, -0.60, -0.70)
VOL60_GRID <- c(0.15, 0.20, 0.25)

threshold_grid <- CJ(
  dd60_cut = DD60_GRID,
  dd12_cut = DD12_GRID,
  vol60_cut = VOL60_GRID
)

filter_types <- c(
  "dd60",
  "dd12",
  "vol60",
  "dd60_dd12",
  "dd60_vol60",
  "dd12_vol60",
  "all_three",
  "at_least_two"
)

candidate_grid <- CJ(
  filter_type = filter_types,
  threshold_id = seq_len(nrow(threshold_grid))
)
candidate_grid <- merge(
  candidate_grid,
  threshold_grid[, threshold_id := .I],
  by="threshold_id",
  all.x=TRUE
)
candidate_grid[, label_id := sprintf(
  "%s_dd60%s_dd12%s_vol60%s",
  filter_type,
  gsub("-", "m", sprintf("%.2f", dd60_cut)),
  gsub("-", "m", sprintf("%.2f", dd12_cut)),
  sprintf("%.2f", vol60_cut)
)]

fn_apply_filter <- function(dt, filter_type, dd60_cut, dd12_cut, vol60_cut) {
  cond_dd60 <- is.finite(dt$max_dd_60m) & dt$max_dd_60m <= dd60_cut
  cond_dd12 <- is.finite(dt$max_dd_12m) & dt$max_dd_12m <= dd12_cut
  cond_vol60 <- is.finite(dt$vol_60m) & dt$vol_60m >= vol60_cut
  n_met <- as.integer(cond_dd60) + as.integer(cond_dd12) + as.integer(cond_vol60)

  switch(
    filter_type,
    dd60 = cond_dd60,
    dd12 = cond_dd12,
    vol60 = cond_vol60,
    dd60_dd12 = cond_dd60 & cond_dd12,
    dd60_vol60 = cond_dd60 & cond_vol60,
    dd12_vol60 = cond_dd12 & cond_vol60,
    all_three = cond_dd60 & cond_dd12 & cond_vol60,
    at_least_two = n_met >= 2L,
    stop(sprintf("Unknown filter_type: %s", filter_type))
  )
}

#==============================================================================#
# 3. Evaluate candidate labels
#==============================================================================#

grid_results <- vector("list", nrow(candidate_grid))
label_rows <- vector("list", nrow(candidate_grid))

for (g in seq_len(nrow(candidate_grid))) {
  cg <- candidate_grid[g]
  keep <- fn_apply_filter(
    event_rows,
    filter_type = cg$filter_type,
    dd60_cut = cg$dd60_cut,
    dd12_cut = cg$dd12_cut,
    vol60_cut = cg$vol60_cut
  )

  pos <- copy(event_rows[keep == TRUE])
  pos[, label_id := cg$label_id]
  pos[, filter_type := cg$filter_type]
  pos[, `:=`(
    dd60_cut = cg$dd60_cut,
    dd12_cut = cg$dd12_cut,
    vol60_cut = cg$vol60_cut
  )]
  label_rows[[g]] <- pos

  n_pos <- nrow(pos)
  n_dead <- sum(pos$event_outcome == "dead")
  n_surv <- sum(pos$event_outcome == "survived")

  grid_results[[g]] <- data.table(
    label_id = cg$label_id,
    filter_type = cg$filter_type,
    dd60_cut = cg$dd60_cut,
    dd12_cut = cg$dd12_cut,
    vol60_cut = cg$vol60_cut,
    n_positive_rows = n_pos,
    n_positive_firms = uniqueN(pos$permno),
    n_dead_rows = n_dead,
    n_survived_rows = n_surv,
    n_dead_firms = uniqueN(pos[event_outcome == "dead"]$permno),
    n_survived_firms = uniqueN(pos[event_outcome == "survived"]$permno),
    row_non_survival_rate = n_dead / max(n_pos, 1L),
    row_survival_rate = n_surv / max(n_pos, 1L),
    median_max_dd_60m = median(pos$max_dd_60m, na.rm=TRUE),
    median_max_dd_12m = median(pos$max_dd_12m, na.rm=TRUE),
    median_vol_60m = median(pos$vol_60m, na.rm=TRUE),
    median_altman_z = median(pos$altman_z, na.rm=TRUE),
    median_roa = median(pos$roa, na.rm=TRUE),
    median_log_mkvalt = median(pos$log_mkvalt, na.rm=TRUE)
  )
}

grid_results <- rbindlist(grid_results, fill=TRUE)
label_rows <- rbindlist(label_rows, fill=TRUE)

setorder(grid_results, -row_non_survival_rate, -n_positive_rows)

saveRDS(grid_results, file.path(OUT_DIR, "price_distress_label_grid.rds"))
saveRDS(label_rows, file.path(OUT_DIR, "price_distress_label_rows.rds"))
fwrite(grid_results, file.path(OUT_DIR, "price_distress_label_grid.csv"))

best_labels <- grid_results[n_positive_rows >= 100][
  order(-row_non_survival_rate, -n_positive_rows)
][1:30]
fwrite(best_labels, file.path(OUT_DIR, "price_distress_best_labels.csv"))

#==============================================================================#
# 4. Figures
#==============================================================================#

plot_dt <- grid_results[filter_type %in% c(
  "dd60", "dd12", "vol60", "dd60_vol60", "all_three", "at_least_two"
)]
plot_dt <- plot_dt[n_positive_rows >= 50]
plot_dt[, filter_type := factor(
  filter_type,
  levels=c("dd60", "dd12", "vol60", "dd60_vol60", "all_three", "at_least_two")
)]
plot_dt[, panel_label := sprintf("dd12<=%.0f%% | vol60>=%.0f%%",
                                 100 * dd12_cut, 100 * vol60_cut)]

p_surv <- ggplot(
  plot_dt,
  aes(x=factor(dd60_cut), y=filter_type, fill=row_non_survival_rate)
) +
  geom_tile(colour="white", linewidth=0.2) +
  geom_text(aes(label=sprintf("%.1f%%\n(n=%s)",
                              100 * row_non_survival_rate,
                              comma(n_positive_rows))),
            size=2.8) +
  facet_wrap(~ panel_label, ncol=3) +
  scale_fill_gradient(low="#d73027", high="#1a9850",
                      labels=percent_format(accuracy=1),
                      limits=c(0.5, 1),
                      name="Do not survive") +
  labs(
    title="Price-Distress Filtered Permanent-Loss Labels",
    subtitle=sprintf("Base event: %s | annual feature rows predicting event in next %d months",
                     BASE_PARAM, LABEL_FWD_MONTHS),
    x="max_dd_60m cutoff",
    y="Filter type"
  ) +
  theme_minimal(base_size=10) +
  theme(panel.grid=element_blank())

ggsave(file.path(FIG_DIR, "price_distress_non_survival_heatmap.png"),
       p_surv, width=13, height=9, dpi=300)

p_count <- ggplot(
  plot_dt,
  aes(x=factor(dd60_cut), y=filter_type, fill=n_positive_rows)
) +
  geom_tile(colour="white", linewidth=0.2) +
  geom_text(aes(label=comma(n_positive_rows)), size=2.8) +
  facet_wrap(~ panel_label, ncol=3) +
  scale_fill_gradient(low="#f7fbff", high="#08306b",
                      labels=comma,
                      name="Positive rows") +
  labs(
    title="Price-Distress Filtered Label Counts",
    subtitle="Number of annual feature rows retained by each price-distress label",
    x="max_dd_60m cutoff",
    y="Filter type"
  ) +
  theme_minimal(base_size=10) +
  theme(panel.grid=element_blank())

ggsave(file.path(FIG_DIR, "price_distress_label_count_heatmap.png"),
       p_count, width=13, height=9, dpi=300)

#==============================================================================#
# 5. Console summary
#==============================================================================#

baseline <- data.table(
  label_id = "baseline_strict_pcl_no_price_filter",
  n_positive_rows = nrow(event_rows),
  n_positive_firms = uniqueN(event_rows$permno),
  n_dead_rows = sum(event_rows$event_outcome == "dead"),
  n_survived_rows = sum(event_rows$event_outcome == "survived"),
  row_non_survival_rate = mean(event_rows$event_outcome == "dead"),
  row_survival_rate = mean(event_rows$event_outcome == "survived")
)

cat("\n[14e] Baseline strict PCL label before price filtering:\n")
print(baseline[, .(
  label_id, n_positive_rows, n_positive_firms,
  n_dead_rows, n_survived_rows,
  non_survival = round(100 * row_non_survival_rate, 2),
  survival = round(100 * row_survival_rate, 2)
)])

cat("\n[14e] Best price-distress labels with at least 100 annual positive rows:\n")
print(best_labels[1:20, .(
  label_id, filter_type,
  dd60_cut, dd12_cut, vol60_cut,
  n_positive_rows, n_positive_firms,
  n_dead_rows, n_survived_rows,
  non_survival = round(100 * row_non_survival_rate, 2),
  survival = round(100 * row_survival_rate, 2),
  median_max_dd_60m = round(median_max_dd_60m, 3),
  median_max_dd_12m = round(median_max_dd_12m, 3),
  median_vol_60m = round(median_vol_60m, 3)
)])

cat("\n[14e] Best labels with at least 500 annual positive rows:\n")
print(grid_results[n_positive_rows >= 500][
  order(-row_non_survival_rate, -n_positive_rows)
][1:15, .(
  label_id, filter_type,
  n_positive_rows, n_positive_firms,
  n_dead_rows, n_survived_rows,
  non_survival = round(100 * row_non_survival_rate, 2),
  survival = round(100 * row_survival_rate, 2)
)])

cat("\n[14e] DONE\n")
cat(sprintf("  Tables : %s\n", OUT_DIR))
cat(sprintf("  Figures: %s\n", FIG_DIR))
