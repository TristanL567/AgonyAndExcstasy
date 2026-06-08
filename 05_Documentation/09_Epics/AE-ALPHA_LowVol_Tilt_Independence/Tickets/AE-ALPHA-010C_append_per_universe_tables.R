repo <- "C:/tmp/ae-alpha-010"
baseline_repo <- "C:/Users/Tristan Leiter/Documents/AgonyAndExcstasy"
doc_rel <- "05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence"
summary_rel <- file.path(doc_rel, "AE-ALPHA_Risk_Return_and_Overlap_Summary.md")
summary_path <- file.path(repo, summary_rel)
baseline_summary_path <- file.path(baseline_repo, summary_rel)
tables_dir <- file.path(repo, doc_rel, "Tables")
tickets_dir <- file.path(repo, doc_rel, "Tickets")
risk_path <- file.path(tables_dir, "AE-ALPHA-010_per_universe_risk_return_table_data.csv")

dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tickets_dir, recursive = TRUE, showWarnings = FALSE)

fmt_pct <- function(x, digits = 2) {
  ifelse(is.na(x), "n/a", sprintf(paste0("%.", digits, "f%%"), 100 * as.numeric(x)))
}
fmt_dec <- function(x, digits = 2) {
  ifelse(is.na(x), "n/a", sprintf(paste0("%.", digits, "f"), as.numeric(x)))
}

table_md <- function(df) {
  lines <- c(
    "| Portfolio | Cost bps | Return | Volatility | Sharpe | Max DD | ES 2.5% | Turnover |",
    "|---|---:|---:|---:|---:|---:|---:|---:|"
  )
  rows <- apply(df, 1, function(r) {
    paste0(
      "| ", r[["Portfolio"]],
      " | ", r[["Cost bps"]],
      " | ", r[["Return"]],
      " | ", r[["Volatility"]],
      " | ", r[["Sharpe"]],
      " | ", r[["Max DD"]],
      " | ", r[["ES 2.5%"]],
      " | ", r[["Turnover"]],
      " |"
    )
  })
  c(lines, rows)
}

extract_block <- function(lines, start_heading, next_heading = NULL) {
  start <- grep(paste0("^## ", start_heading, "$"), lines)
  if (length(start) != 1) stop("missing or duplicate heading: ", start_heading)
  if (is.null(next_heading)) {
    ends <- grep("^## ", lines)
    ends <- ends[ends > start]
    end <- if (length(ends)) ends[1] - 1 else length(lines)
  } else {
    end <- grep(paste0("^## ", next_heading, "$"), lines)
    end <- end[end > start]
    if (length(end) != 1) stop("missing or duplicate next heading after ", start_heading, ": ", next_heading)
    end <- end - 1
  }
  paste(lines[start:end], collapse = "\n")
}

baseline <- readLines(baseline_summary_path, warn = FALSE, encoding = "UTF-8")
risk <- read.csv(risk_path, stringsAsFactors = FALSE)

strategy_order <- c(
  "Naive benchmark", "LowVol Q1", "LowVol Q2", "LowVol Q3",
  "LowVol Q4", "HighVol Q5", "CSI dynamic", "CSI permanent"
)
display_names <- c(
  "Naive benchmark" = "Benchmark",
  "LowVol Q1" = "LowVol Q1",
  "LowVol Q2" = "LowVol Q2",
  "LowVol Q3" = "LowVol Q3",
  "LowVol Q4" = "LowVol Q4",
  "HighVol Q5" = "HighVol Q5",
  "CSI dynamic" = "CSI dynamic",
  "CSI permanent" = "CSI permanent"
)
periods <- c(test = "Test", oos = "OOS")
universes <- c("Total", "Large", "Mid", "Small")

render_one <- function(period_id, universe_id) {
  rows <- risk[risk$period == period_id & risk$universe == universe_id,]
  rows$strategy_order <- match(rows$strategy, strategy_order)
  rows <- rows[order(rows$strategy_order),]
  if (nrow(rows) != 8) stop("expected 8 risk-return rows for ", period_id, " / ", universe_id)
  display <- data.frame(
    Portfolio = unname(display_names[rows$strategy]),
    `Cost bps` = rows$transaction_cost_bps,
    Return = fmt_pct(rows$annualized_geometric_return),
    Volatility = fmt_pct(rows$annualized_volatility),
    Sharpe = fmt_dec(rows$sharpe_ratio, 3),
    `Max DD` = fmt_pct(rows$max_drawdown, 1),
    `ES 2.5%` = fmt_pct(rows$expected_shortfall_2p5),
    Turnover = fmt_pct(rows$annualized_turnover_gross, 1),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  c(
    paste0("### ", periods[[period_id]], " - ", universe_id),
    "",
    table_md(display),
    ""
  )
}

appendix <- c(
  "## Per-Universe Risk-Return Tables",
  "",
  "These tables expand the aggregate Test and OOS risk-return summaries above without changing the four existing summary table blocks.",
  ""
)
for (period_id in names(periods)) {
  for (universe_id in universes) {
    appendix <- c(appendix, render_one(period_id, universe_id))
  }
}

insert_before <- grep("^## How to State the Result$", baseline)
if (length(insert_before) != 1) stop("expected exactly one insertion point: ## How to State the Result")
final <- c(
  baseline[seq_len(insert_before - 1)],
  appendix,
  baseline[insert_before:length(baseline)]
)
writeLines(final, summary_path, useBytes = TRUE)

final_lines <- readLines(summary_path, warn = FALSE, encoding = "UTF-8")
block_names <- c(
  "Test Period Risk-Return",
  "OOS Period Risk-Return",
  "Test Period CSI/Volatility Overlap",
  "OOS Period CSI/Volatility Overlap"
)
next_names <- c(
  "OOS Period Risk-Return",
  "CSI and Volatility-Bucket Overlap",
  "OOS Period CSI/Volatility Overlap",
  "Per-Universe Risk-Return Tables"
)
block_unchanged <- mapply(
  function(block, next_block) {
    identical(
      extract_block(baseline, block, if (block == "OOS Period CSI/Volatility Overlap") "How to State the Result" else next_block),
      extract_block(final_lines, block, next_block)
    )
  },
  block_names,
  next_names
)

appended_headers <- grep("^### (Test|OOS) - (Total|Large|Mid|Small)$", final_lines, value = TRUE)
portfolio_headers <- grep("^\\| Portfolio \\| Cost bps \\| Return \\| Volatility \\| Sharpe \\| Max DD \\| ES 2.5% \\| Turnover \\|$", final_lines, value = TRUE)
coverage <- expand.grid(period = names(periods), universe = universes, stringsAsFactors = FALSE)
coverage$key <- paste(periods[coverage$period], "-", coverage$universe)

validation <- data.frame(
  check = c(
    "existing_four_blocks_unchanged",
    "exactly_8_appended_risk_return_tables",
    "test_oos_four_universe_coverage",
    "risk_rows_available",
    "summary_contains_required_headers",
    "no_03_data_output_target"
  ),
  expected = c(
    "All four named aggregate blocks match pre-ticket baseline",
    "8 appended per-universe risk-return tables",
    "Test/OOS x Total/Large/Mid/Small",
    "64 documentation-local risk-return rows",
    "10 risk-return table headers total: 2 existing aggregate + 8 appended",
    "Summary and ticket evidence written under 05_Documentation only"
  ),
  actual = c(
    paste(block_unchanged, collapse = ", "),
    as.character(length(appended_headers)),
    paste(appended_headers, collapse = "; "),
    as.character(nrow(risk)),
    as.character(length(portfolio_headers)),
    summary_rel
  ),
  pass = c(
    all(block_unchanged),
    length(appended_headers) == 8,
    setequal(appended_headers, paste0("### ", coverage$key)),
    nrow(risk) == 64,
    length(portfolio_headers) == 10,
    !grepl("^03_Data_Output/", summary_rel)
  ),
  stringsAsFactors = FALSE
)
validation_path <- file.path(tables_dir, "AE-ALPHA-010C_validation_checks.csv")
write.csv(validation, validation_path, row.names = FALSE)

report <- c(
  "---",
  "epic: AE-ALPHA",
  "ticket: AE-ALPHA-010C",
  "type: summary_append",
  "status: complete",
  "allowed_areas:",
  "  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/",
  "must_not_touch:",
  "  - 01_Code/",
  "  - 02_Data_Input/",
  "  - 03_Data_Output/",
  "  - 06_Presentations/",
  "  - 08_Writting/",
  "forbidden_scripts_run: false",
  "---",
  "",
  "# AE-ALPHA-010C Per-Universe Risk-Return Append Report",
  "",
  "## Summary",
  "",
  "Appended eight per-universe risk-return tables to the AE-ALPHA summary while preserving the four existing aggregate table blocks from the pre-ticket summary source.",
  "",
  "## Added Tables",
  "",
  paste0("- ", appended_headers),
  "",
  "## Validation",
  "",
  paste0("- Existing four table blocks unchanged: ", all(block_unchanged), "."),
  paste0("- Risk-return rows available in documentation evidence: ", nrow(risk), "."),
  paste0("- Appended per-universe tables: ", length(appended_headers), "."),
  paste0("- Validation checks: `", file.path(doc_rel, "Tables/AE-ALPHA-010C_validation_checks.csv"), "`."),
  "",
  "## Scope",
  "",
  "No `03_Data_Output/**`, `01_Code/**`, presentation, thesis, model, index-output, or chart files were modified."
)
writeLines(report, file.path(tickets_dir, "AE-ALPHA-010C_Append_Report.md"), useBytes = TRUE)

cat("appended_tables=", length(appended_headers), "\n", sep = "")
cat("risk_rows=", nrow(risk), "\n", sep = "")
cat("validation_pass=", all(validation$pass), "\n", sep = "")
