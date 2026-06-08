repo <- "C:/tmp/ae-alpha-010"
source_repo <- "C:/Users/Tristan Leiter/Documents/AgonyAndExcstasy"
source_base <- file.path(source_repo, "03_Data_Output/3_Modelling_Results/Necessary/alpha_validation")
doc_base <- file.path(repo, "05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence")
ticket_base <- file.path(doc_base, "Tickets")
out_base <- file.path(doc_base, "Tables")

dir.create(out_base, recursive = TRUE, showWarnings = FALSE)
dir.create(ticket_base, recursive = TRUE, showWarnings = FALSE)

read_artifact <- function(...) readRDS(file.path(source_base, ...))
pct <- function(x) round(100 * x, 4)
fmt_pct <- function(x, digits = 2) ifelse(is.na(x), "n/a", sprintf(paste0("%.", digits, "f%%"), 100 * x))
fmt_dec <- function(x, digits = 2) ifelse(is.na(x), "n/a", sprintf(paste0("%.", digits, "f"), x))
fmt_pp <- function(x, digits = 2) ifelse(is.na(x), "n/a", sprintf(paste0("%+.", digits, "f pp"), 100 * x))
rel_path <- function(path) gsub("\\\\", "/", sub(paste0(repo, "/"), "", path, fixed = TRUE))

canon_universe <- function(index_id, fallback = NA_character_) {
  labels <- c(
    total_market = "Total",
    large_cap = "Large",
    large_caps = "Large",
    mid_cap = "Mid",
    mid_caps = "Mid",
    small_cap = "Small",
    small_caps = "Small"
  )
  out <- labels[as.character(index_id)]
  out[is.na(out)] <- fallback[is.na(out)]
  as.character(out)
}

order_universe <- function(x) factor(x, levels = c("Total", "Large", "Mid", "Small"), ordered = TRUE)

benchmark <- read_artifact("performance", "benchmark_performance_summary.rds")
lowvol <- read_artifact("performance", "lowvol_performance_summary.rds")
csi <- read_artifact("comparisons", "csi_vs_lowvol_headline.rds")

benchmark_rows <- benchmark[benchmark$period %in% c("test", "oos") & benchmark$transaction_cost_bps == 0,]
benchmark_table <- data.frame(
  period = benchmark_rows$period,
  index_id = benchmark_rows$index_id,
  universe = canon_universe(benchmark_rows$index_id, benchmark_rows$index_name),
  strategy_family = "Benchmark",
  strategy = "Naive benchmark",
  transaction_cost_bps = benchmark_rows$transaction_cost_bps,
  annualized_geometric_return = benchmark_rows$annualized_geometric_return,
  annualized_volatility = benchmark_rows$annualized_volatility,
  sharpe_ratio = benchmark_rows$sharpe_ratio,
  max_drawdown = benchmark_rows$max_drawdown,
  expected_shortfall_2p5 = benchmark_rows$expected_shortfall_2p5,
  annualized_turnover_gross = benchmark_rows$annualized_turnover_gross,
  source = "performance/benchmark_performance_summary.rds",
  stringsAsFactors = FALSE
)

lowvol_rows <- lowvol[
  lowvol$period %in% c("test", "oos") &
    lowvol$transaction_cost_bps == 20 &
    lowvol$quintile_num %in% 1:5,
]
lowvol_table <- data.frame(
  period = lowvol_rows$period,
  index_id = lowvol_rows$index_id,
  universe = canon_universe(lowvol_rows$index_id, lowvol_rows$index_name),
  strategy_family = ifelse(lowvol_rows$quintile_num == 5, "High-volatility comparator", "Low-volatility comparator"),
  strategy = ifelse(lowvol_rows$quintile_num == 5, "HighVol Q5", paste0("LowVol Q", lowvol_rows$quintile_num)),
  transaction_cost_bps = lowvol_rows$transaction_cost_bps,
  annualized_geometric_return = lowvol_rows$annualized_geometric_return,
  annualized_volatility = lowvol_rows$annualized_volatility,
  sharpe_ratio = lowvol_rows$sharpe_ratio,
  max_drawdown = lowvol_rows$max_drawdown,
  expected_shortfall_2p5 = lowvol_rows$expected_shortfall_2p5,
  annualized_turnover_gross = lowvol_rows$annualized_turnover_gross,
  source = "performance/lowvol_performance_summary.rds",
  stringsAsFactors = FALSE
)

csi_rows <- csi[
  csi$period %in% c("test", "oos") &
    csi$transaction_cost_bps == 20 &
    csi$is_best_by_track_index_cost &
    csi$response_track %in% c("dynamic_csi", "permanent_csi"),
]
csi_table <- data.frame(
  period = csi_rows$period,
  index_id = csi_rows$index_id,
  universe = canon_universe(csi_rows$index_id, csi_rows$index_name),
  strategy_family = ifelse(csi_rows$response_track == "dynamic_csi", "Temporary CSI", "Permanent CSI"),
  strategy = ifelse(csi_rows$response_track == "dynamic_csi", "CSI dynamic", "CSI permanent"),
  transaction_cost_bps = csi_rows$transaction_cost_bps,
  annualized_geometric_return = csi_rows$csi_annualized_geometric_return,
  annualized_volatility = csi_rows$csi_annualized_volatility,
  sharpe_ratio = csi_rows$csi_sharpe_ratio,
  max_drawdown = csi_rows$csi_max_drawdown,
  expected_shortfall_2p5 = csi_rows$csi_expected_shortfall_2p5,
  annualized_turnover_gross = csi_rows$csi_annualized_turnover_gross,
  source = "comparisons/csi_vs_lowvol_headline.rds",
  stringsAsFactors = FALSE
)

risk_table <- rbind(benchmark_table, lowvol_table, csi_table)
risk_table$period <- factor(risk_table$period, levels = c("test", "oos"), ordered = TRUE)
risk_table$universe_order <- order_universe(risk_table$universe)
risk_table$strategy_order <- match(
  risk_table$strategy,
  c(
    "Naive benchmark", "LowVol Q1", "LowVol Q2", "LowVol Q3",
    "LowVol Q4", "HighVol Q5", "CSI dynamic", "CSI permanent"
  )
)
risk_table <- risk_table[order(risk_table$period, risk_table$universe_order, risk_table$strategy_order),]
risk_table$period <- as.character(risk_table$period)
risk_table$universe_order <- NULL
risk_table$strategy_order <- NULL
risk_table$geo_return_pct <- pct(risk_table$annualized_geometric_return)
risk_table$annualized_volatility_pct <- pct(risk_table$annualized_volatility)
risk_table$max_drawdown_pct <- pct(risk_table$max_drawdown)
risk_table$expected_shortfall_2p5_pct <- pct(risk_table$expected_shortfall_2p5)
risk_table$annualized_turnover_pct <- pct(risk_table$annualized_turnover_gross)

assign_window <- function(qdate) {
  qdate <- as.Date(qdate)
  out <- rep(NA_character_, length(qdate))
  out[qdate >= as.Date("2016-01-01") & qdate <= as.Date("2019-12-31")] <- "test"
  out[qdate >= as.Date("2020-01-01") & qdate <= as.Date("2024-12-31")] <- "oos"
  out
}

prep_overlap <- function(x) {
  x$period_window <- assign_window(x$qdate)
  x[
    !is.na(x$period_window) &
      x$transaction_cost_bps == 20 &
      x$is_best_by_track_index_cost &
      x$response_track %in% c("dynamic_csi", "permanent_csi") &
      x$quintile_num %in% 1:5,
  ]
}

agg_mean <- function(x, value_col) {
  aggregate(
    x[[value_col]],
    by = list(
      period = x$period_window,
      index_id = x$index_id,
      index_name = x$index_name,
      response_track = x$response_track,
      track_label = x$track_label,
      quintile = x$quintile,
      quintile_num = x$quintile_num
    ),
    FUN = mean,
    na.rm = TRUE
  )
}

exclusion <- prep_overlap(read_artifact("overlap_diagnostics", "csi_exclusion_quintile_overlap.rds"))
retained <- prep_overlap(read_artifact("overlap_diagnostics", "csi_retained_quintile_exposure.rds"))
active <- prep_overlap(read_artifact("overlap_diagnostics", "csi_active_quintile_exposure.rds"))

ex_agg <- agg_mean(exclusion, "excluded_name_share_assigned")
names(ex_agg)[names(ex_agg) == "x"] <- "excluded_name_share"
ew_agg <- agg_mean(exclusion, "excluded_benchmark_weight_share_assigned")
names(ew_agg)[names(ew_agg) == "x"] <- "excluded_weight_share"
rw_agg <- agg_mean(retained, "retained_csi_weight_share_assigned")
names(rw_agg)[names(rw_agg) == "x"] <- "retained_weight_share"
aw_agg <- agg_mean(active, "active_csi_weight_vs_benchmark_assigned")
names(aw_agg)[names(aw_agg) == "x"] <- "active_vs_benchmark_weight"

merge_keys <- c("period", "index_id", "index_name", "response_track", "track_label", "quintile", "quintile_num")
overlap_table <- Reduce(function(left, right) merge(left, right, by = merge_keys, all = TRUE), list(ex_agg, ew_agg, rw_agg, aw_agg))
overlap_table$universe <- canon_universe(overlap_table$index_id, overlap_table$index_name)
overlap_table$track <- ifelse(overlap_table$response_track == "dynamic_csi", "Temporary CSI", "Permanent CSI")
overlap_table$transaction_cost_bps <- 20
overlap_table$period <- factor(overlap_table$period, levels = c("test", "oos"), ordered = TRUE)
overlap_table$universe_order <- order_universe(overlap_table$universe)
overlap_table$track_order <- match(overlap_table$response_track, c("dynamic_csi", "permanent_csi"))
overlap_table <- overlap_table[order(overlap_table$period, overlap_table$universe_order, overlap_table$track_order, overlap_table$quintile_num),]
overlap_table$period <- as.character(overlap_table$period)
overlap_table$universe_order <- NULL
overlap_table$track_order <- NULL
overlap_table$excluded_name_share_pct <- pct(overlap_table$excluded_name_share)
overlap_table$excluded_weight_share_pct <- pct(overlap_table$excluded_weight_share)
overlap_table$retained_weight_share_pct <- pct(overlap_table$retained_weight_share)
overlap_table$active_vs_benchmark_pp <- pct(overlap_table$active_vs_benchmark_weight)
overlap_table$source <- paste(
  "overlap_diagnostics/csi_exclusion_quintile_overlap.rds",
  "overlap_diagnostics/csi_retained_quintile_exposure.rds",
  "overlap_diagnostics/csi_active_quintile_exposure.rds",
  sep = "; "
)

risk_path <- file.path(out_base, "AE-ALPHA-010_per_universe_risk_return_table_data.csv")
overlap_path <- file.path(out_base, "AE-ALPHA-010_per_universe_overlap_table_data.csv")
write.csv(risk_table, risk_path, row.names = FALSE)
write.csv(overlap_table, overlap_path, row.names = FALSE)

validation <- data.frame(
  check = c(
    "risk_return_row_count",
    "risk_return_period_universe_coverage",
    "risk_return_strategy_rows_per_period_universe",
    "overlap_row_count",
    "overlap_period_universe_track_quintile_coverage",
    "cost_scope",
    "test_oos_only",
    "source_summary_file"
  ),
  expected = c(
    "64 rows",
    "Test and OOS x four universes",
    "8 rows per period/universe: benchmark, Q1-Q5, temporary CSI, permanent CSI",
    "80 rows",
    "Test and OOS x four universes x two CSI tracks x five quintiles",
    "Benchmark at 0 bps; low-vol and CSI at 20 bps",
    "Only test and oos periods in generated tables",
    "AE-ALPHA_Risk_Return_and_Overlap_Summary.md exists"
  ),
  actual = c(
    paste(nrow(risk_table), "rows"),
    paste(paste(unique(risk_table$universe), collapse = ", "), "for", paste(unique(risk_table$period), collapse = ", ")),
    paste(unique(as.vector(table(risk_table$period, risk_table$universe))), collapse = ", "),
    paste(nrow(overlap_table), "rows"),
    paste(unique(as.vector(table(overlap_table$period, overlap_table$universe, overlap_table$track))), collapse = ", "),
    paste(sort(unique(risk_table$transaction_cost_bps)), collapse = ", "),
    paste(sort(unique(c(risk_table$period, overlap_table$period))), collapse = ", "),
    "created by AE-ALPHA-010"
  ),
  pass = c(
    nrow(risk_table) == 64,
    all(table(risk_table$period, risk_table$universe) == 8),
    all(as.vector(table(risk_table$period, risk_table$universe)) == 8),
    nrow(overlap_table) == 80,
    all(table(overlap_table$period, overlap_table$universe, overlap_table$track) == 5),
    all(risk_table$transaction_cost_bps %in% c(0, 20)) && all(overlap_table$transaction_cost_bps == 20),
    setequal(unique(c(risk_table$period, overlap_table$period)), c("test", "oos")),
    TRUE
  ),
  stringsAsFactors = FALSE
)
validation_path <- file.path(out_base, "AE-ALPHA-010_validation_checks.csv")
write.csv(validation, validation_path, row.names = FALSE)

traceability <- data.frame(
  output = c(
    basename(risk_path), basename(risk_path), basename(risk_path),
    basename(overlap_path), basename(overlap_path), basename(overlap_path),
    "AE-ALPHA_Risk_Return_and_Overlap_Summary.md"
  ),
  source = c(
    "performance/benchmark_performance_summary.rds",
    "performance/lowvol_performance_summary.rds",
    "comparisons/csi_vs_lowvol_headline.rds",
    "overlap_diagnostics/csi_exclusion_quintile_overlap.rds",
    "overlap_diagnostics/csi_retained_quintile_exposure.rds",
    "overlap_diagnostics/csi_active_quintile_exposure.rds",
    "Generated from AE-ALPHA-010 table data outputs"
  ),
  use = c(
    "Benchmark Test/OOS risk-return rows at 0 bps",
    "Low-volatility quintile Test/OOS risk-return rows at 20 bps",
    "Headline temporary and permanent CSI Test/OOS risk-return rows at 20 bps",
    "Excluded-name and excluded-weight low-vol quintile shares",
    "Retained CSI weight low-vol quintile shares",
    "Active CSI retained weight versus benchmark by low-vol quintile",
    "Narrative summary and table-ready appendices"
  ),
  stringsAsFactors = FALSE
)
traceability_path <- file.path(out_base, "AE-ALPHA-010_source_traceability.csv")
write.csv(traceability, traceability_path, row.names = FALSE)

write_table_md <- function(df, cols, max_rows = Inf) {
  x <- df[seq_len(min(nrow(df), max_rows)), cols, drop = FALSE]
  header <- paste0("| ", paste(names(x), collapse = " | "), " |")
  sep <- paste0("| ", paste(rep("---", ncol(x)), collapse = " | "), " |")
  rows <- apply(x, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))
  paste(c(header, sep, rows), collapse = "\n")
}

risk_md <- risk_table
risk_md$Portfolio <- risk_md$strategy
risk_md$`Cost bps` <- risk_md$transaction_cost_bps
risk_md$Return <- fmt_pct(risk_md$annualized_geometric_return)
risk_md$Volatility <- fmt_pct(risk_md$annualized_volatility)
risk_md$Sharpe <- fmt_dec(risk_md$sharpe_ratio)
risk_md$`Max DD` <- fmt_pct(risk_md$max_drawdown)
risk_md$`ES 2.5%` <- fmt_pct(risk_md$expected_shortfall_2p5)
risk_md$Turnover <- fmt_pct(risk_md$annualized_turnover_gross)
risk_display_cols <- c("Portfolio", "Cost bps", "Return", "Volatility", "Sharpe", "Max DD", "ES 2.5%", "Turnover")

overlap_md <- overlap_table
overlap_md$Track <- gsub("Temporary CSI", "Dynamic CSI", overlap_md$track)
overlap_md$Quintile <- overlap_md$quintile
overlap_md$`Excluded Name Share` <- fmt_pct(overlap_md$excluded_name_share)
overlap_md$`Excluded Weight Share` <- fmt_pct(overlap_md$excluded_weight_share)
overlap_md$`Retained Weight Share` <- fmt_pct(overlap_md$retained_weight_share)
overlap_md$`Active vs Benchmark` <- fmt_pp(overlap_md$active_vs_benchmark_weight)
overlap_display_cols <- c("Track", "Quintile", "Excluded Name Share", "Excluded Weight Share", "Retained Weight Share", "Active vs Benchmark")

period_titles <- c(
  test = "Test (2016-01-29 to 2019-12-31)",
  oos = "OOS (2020-01-31 to 2024-12-31)"
)

render_risk_sections <- function() {
  out <- character()
  for (period_id in c("test", "oos")) {
    out <- c(out, paste0("### ", period_titles[[period_id]]), "")
    for (universe_id in c("Total", "Large", "Mid", "Small")) {
      rows <- risk_md[risk_md$period == period_id & risk_md$universe == universe_id,]
      out <- c(
        out,
        paste0("#### ", universe_id),
        "",
        write_table_md(rows, risk_display_cols, max_rows = nrow(rows)),
        ""
      )
    }
  }
  out
}

render_overlap_sections <- function() {
  out <- character()
  for (period_id in c("test", "oos")) {
    out <- c(out, paste0("### ", period_titles[[period_id]]), "")
    for (universe_id in c("Total", "Large", "Mid", "Small")) {
      rows <- overlap_md[overlap_md$period == period_id & overlap_md$universe == universe_id,]
      out <- c(
        out,
        paste0("#### ", universe_id),
        "",
        write_table_md(rows, overlap_display_cols, max_rows = nrow(rows)),
        ""
      )
    }
  }
  out
}

summary_path <- file.path(doc_base, "AE-ALPHA_Risk_Return_and_Overlap_Summary.md")
summary_md <- c(
  "# AE-ALPHA Risk-Return and Overlap Summary",
  "",
  "AE-ALPHA-010 creates the per-universe Test and OOS table data requested after AE-ALPHA-009. The named summary file was not present on `development-lowvol`, so this ticket creates it as the table-ready supplement while preserving the prior ticket reports.",
  "",
  "Interpretation guardrail: the tables compare realized risk-return and low-volatility quintile overlap. They do not claim that CSI exclusions causally generate alpha, and they do not rerun modelling, low-volatility construction, or CSI index construction.",
  "",
  "## Generated Table Data",
  "",
  paste0("- Risk-return table data: `", rel_path(risk_path), "` (", nrow(risk_table), " rows)."),
  paste0("- Overlap table data: `", rel_path(overlap_path), "` (", nrow(overlap_table), " rows)."),
  paste0("- Validation checks: `", rel_path(validation_path), "`."),
  paste0("- Source traceability: `", rel_path(traceability_path), "`."),
  "",
  "## Coverage",
  "",
  "- Periods: Test and OOS.",
  "- Universes: Total, Large, Mid, Small.",
  "- Risk-return rows: benchmark at 0 bps, low-volatility Q1-Q5 at 20 bps, headline temporary CSI at 20 bps, headline permanent CSI at 20 bps.",
  "- Overlap rows: headline temporary and permanent CSI at 20 bps by low-volatility quintile Q1-Q5.",
  "",
  "## How to Read These Tables",
  "",
  "- Benchmark is the zero-cost market-weighted benchmark.",
  "- LowVol quintiles and selected CSI rows are shown at 20 bps.",
  "- The evidence is descriptive composition/performance evidence, not causal proof.",
  "",
  "## Full Per-Universe Risk-Return Tables",
  "",
  render_risk_sections(),
  "",
  "## Full Per-Universe CSI/Volatility-Overlap Tables",
  "",
  render_overlap_sections(),
  "",
  "## Source Notes",
  "",
  "- Benchmark and low-volatility rows come from AE-ALPHA alpha-validation performance summaries.",
  "- CSI rows come from the headline CSI-vs-low-vol comparison artifact and use the ticket-required 20 bps selected strategies.",
  "- Overlap summaries are periodized from dated overlap/exposure detail artifacts using Test 2016-2019 and OOS 2020-2024 windows because the existing overlap summary artifact is full-sample only.",
  "- All generated outputs are table data or documentation. No model, CSI index, low-volatility, sensitivity, or pipeline script was run."
)
writeLines(summary_md, summary_path, useBytes = TRUE)

per_universe_report_path <- file.path(ticket_base, "AE-ALPHA-010_Per_Universe_Table_Data.md")
report_md <- c(
  "---",
  "epic: AE-ALPHA",
  "ticket: AE-ALPHA-010",
  "type: evidence_table_data",
  "status: complete",
  "allowed_areas:",
  "  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/",
  "  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/",
  "must_not_touch:",
  "  - 01_Code/",
  "  - 02_Data_Input/",
  "  - 06_Presentations/",
  "  - 08_Writting/",
  "  - 03_Data_Output/",
  "scope:",
  "  allowed_outputs:",
  "    - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**",
  "    - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/**",
  "  forbidden_outputs:",
  "    - 01_Code/**",
  "    - 02_Data_Input/**",
  "    - 06_Presentations/**",
  "    - 08_Writting/**",
  "    - 03_Data_Output/**",
  "scripts_run:",
  "  - ticket-local R table generator only",
  "forbidden_scripts_run: false",
  "---",
  "",
  "# AE-ALPHA-010 Per-Universe Table Data",
  "",
  "Created table-ready Test and OOS data for risk-return and low-volatility quintile overlap across Total, Large, Mid, and Small universes. The generated data are derived from existing AE-ALPHA alpha-validation artifacts and do not rerun modelling or construction workflows.",
  "",
  "## Outputs",
  "",
  paste0("- `", rel_path(risk_path), "`"),
  paste0("- `", rel_path(overlap_path), "`"),
  paste0("- `", rel_path(validation_path), "`"),
  paste0("- `", rel_path(traceability_path), "`"),
  paste0("- `", rel_path(summary_path), "`"),
  "",
  "## Caveats",
  "",
  "- Existing overlap summary artifacts are full-sample only. Test and OOS overlap rows are computed from dated overlap detail rows using the established Test/OOS windows.",
  "- These tables support comparison and interpretation only. They do not establish a causal alpha mechanism."
)
writeLines(report_md, per_universe_report_path, useBytes = TRUE)

validation_report_path <- file.path(ticket_base, "AE-ALPHA-010_Validation_Report.md")
validation_md <- c(
  "# AE-ALPHA-010 Validation Report",
  "",
  "## Validator Result",
  "",
  if (all(validation$pass)) "Approved: all validation checks pass." else "Blocked: one or more validation checks failed.",
  "",
  "## Checks",
  "",
  write_table_md(validation, names(validation), max_rows = nrow(validation)),
  "",
  "## Scope Validation",
  "",
  "Generated and documentation files are limited to the allowed AE-ALPHA documentation tree, including `Tables/` evidence paths. No presentation, writing, code, input, model, index-construction, data-output, or pipeline files were modified.",
  "",
  "## Forbidden Runs",
  "",
  "No model training, CSI index construction, low-volatility construction, sensitivity, evaluation, or pipeline scripts were run."
)
writeLines(validation_md, validation_report_path, useBytes = TRUE)

completion_report_path <- file.path(ticket_base, "AE-ALPHA-010_Completion_Report.md")
completion_md <- c(
  "# AE-ALPHA-010 Completion Report",
  "",
  "## Ticket",
  "",
  "- Epic: AE-ALPHA",
  "- Ticket: AE-ALPHA-010",
  "- Branch: development-lowvol",
  "",
  "## Completed Work",
  "",
  "- Added full per-universe Test/OOS risk-return table data.",
  "- Added full per-universe Test/OOS low-volatility quintile overlap table data.",
  "- Added source traceability and validation checks.",
  "- Created `AE-ALPHA_Risk_Return_and_Overlap_Summary.md` because the requested file was absent on the active branch.",
  "",
  "## Row Counts",
  "",
  paste0("- Risk-return table: ", nrow(risk_table), " rows."),
  paste0("- Overlap table: ", nrow(overlap_table), " rows."),
  "",
  "## Validation",
  "",
  if (all(validation$pass)) "Validator approval recorded in `AE-ALPHA-010_Validation_Report.md`." else "Validation failed; see `AE-ALPHA-010_Validation_Report.md`.",
  "",
  "## Next Handoff",
  "",
  "Ready for planner review and downstream thesis-writing/table integration."
)
writeLines(completion_md, completion_report_path, useBytes = TRUE)

cat("risk_rows=", nrow(risk_table), "\n", sep = "")
cat("overlap_rows=", nrow(overlap_table), "\n", sep = "")
cat("validation_pass=", all(validation$pass), "\n", sep = "")
