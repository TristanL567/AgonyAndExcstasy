#==============================================================================#
#==== 01_Download_SP500_Constituents_Daily.R ==================================#
#==== S&P 500 Daily Constituent Membership from WRDS / CRSP ====================#
#==============================================================================#
#
# PURPOSE:
#   Download historical S&P 500 constituent membership intervals from WRDS CRSP
#   and expand them to a daily trading-day panel from 1990 to the latest
#   available CRSP S&P 500 membership update.
#
# INPUT:
#   - WRDS credentials available to tidyfinance::get_wrds_connection()
#     For first-time setup, run interactively:
#       tidyfinance::set_wrds_credentials()
#   - CRSP subscription with one of:
#       crsp_a_indexes.dsp500list_v2
#       crsp_a_indexes.dsp500list
#       crsp.dsp500list_v2
#       crsp.dsp500list
#
# OUTPUTS:
#   - data/raw/sp500_constituents_intervals_raw.rds
#   - data/processed/sp500_constituents_daily.rds
#   - data/processed/sp500_constituents_daily.parquet  (if arrow is installed)
#   - data/diagnostics/sp500_constituents_daily_summary.csv
#
# DAILY SCHEMA:
#   permno, date, mbrstartdt, mbrenddt, in_sp500
#
# MEMBERSHIP DEFINITION:
#   A stock is an S&P 500 constituent on trading day t if:
#     mbrstartdt <= t AND mbrenddt >= t
#
# NOTES:
#   CRSP S&P 500 constituent records are interval records keyed by PERMNO.
#   The daily panel is expanded in R after collecting the small interval table.
#   Trading days are taken from CRSP daily stock file dates rather than plain
#   calendar dates, so weekends/market holidays are excluded.
#
#==============================================================================#

options(stringsAsFactors = FALSE)

#==============================================================================#
# 1. Script Directory, Parameters, and Output Paths
#==============================================================================#

get_script_dir <- function() {
  file_arg <- "--file="
  cmd_args <- commandArgs(trailingOnly = FALSE)
  script_arg <- cmd_args[startsWith(cmd_args, file_arg)][1]

  if (!is.na(script_arg)) {
    script_path <- sub(file_arg, "", script_arg, fixed = TRUE)
    return(dirname(normalizePath(script_path, winslash = "/", mustWork = TRUE)))
  }

  sourced_path <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)

  if (!is.null(sourced_path) && length(sourced_path) == 1 && !is.na(sourced_path)) {
    return(dirname(normalizePath(sourced_path, winslash = "/", mustWork = TRUE)))
  }

  getwd()
}

load_wrds_renviron <- function(start_dir) {
  current_dir <- normalizePath(start_dir, winslash = "/", mustWork = TRUE)

  repeat {
    renviron_path <- file.path(current_dir, ".Renviron")

    if (file.exists(renviron_path)) {
      readRenviron(renviron_path)

      if (nzchar(Sys.getenv("WRDS_USER")) && nzchar(Sys.getenv("WRDS_PASSWORD"))) {
        return(renviron_path)
      }
    }

    parent_dir <- dirname(current_dir)

    if (identical(parent_dir, current_dir)) {
      return(NA_character_)
    }

    current_dir <- parent_dir
  }
}

script_dir <- get_script_dir()
setwd(script_dir)

WRDS_RENVIRON_PATH <- load_wrds_renviron(script_dir)

START_DATE <- as.Date("1990-01-01")
END_DATE_REQUESTED <- Sys.Date()

DIR_RAW <- file.path(script_dir, "data", "raw")
DIR_PROCESSED <- file.path(script_dir, "data", "processed")
DIR_DIAGNOSTICS <- file.path(script_dir, "data", "diagnostics")

dir.create(DIR_RAW, recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_PROCESSED, recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_DIAGNOSTICS, recursive = TRUE, showWarnings = FALSE)

PATH_INTERVALS_RAW <- file.path(DIR_RAW, "sp500_constituents_intervals_raw.rds")
PATH_DAILY_RDS <- file.path(DIR_PROCESSED, "sp500_constituents_daily.rds")
PATH_DAILY_PARQUET <- file.path(DIR_PROCESSED, "sp500_constituents_daily.parquet")
PATH_SUMMARY <- file.path(DIR_DIAGNOSTICS, "sp500_constituents_daily_summary.csv")

#==============================================================================#
# 2. Libraries
#==============================================================================#

required_packages <- c(
  "DBI",
  "dplyr",
  "dbplyr",
  "data.table",
  "readr",
  "tidyfinance"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing required packages: ",
    paste(missing_packages, collapse = ", "),
    "\nInstall them before running this script.",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(DBI)
  library(dplyr)
  library(dbplyr)
  library(data.table)
  library(readr)
  library(tidyfinance)
})

#==============================================================================#
# 3. Helpers
#==============================================================================#

select_first_available_table <- function(wrds, candidates) {
  available_tables <- dbGetQuery(
    wrds,
    "
    select table_schema, table_name
    from information_schema.tables
    where table_schema in (
      'crsp_a_indexes', 'crsp_m_indexes', 'crsp_q_indexes',
      'crsp', 'crspm', 'crspq'
    )
      and table_name in ('dsp500list_v2', 'dsp500list', 'msp500list')
    order by table_schema, table_name
    "
  )

  available_full_names <- paste(
    available_tables$table_schema,
    available_tables$table_name,
    sep = "."
  )

  visible_candidates <- candidates[candidates %in% available_full_names]

  if (length(visible_candidates) == 0) {
    stop(
      "No S&P 500 constituent table found in WRDS CRSP schemas.\n",
      "Checked candidates: ", paste(candidates, collapse = ", "), "\n",
      "Available matching tables: ",
      if (length(available_full_names) == 0) "<none>" else paste(available_full_names, collapse = ", "),
      call. = FALSE
    )
  }

  access_errors <- character()

  for (candidate in visible_candidates) {
    access_test <- tryCatch(
      {
        dbGetQuery(wrds, paste0("select count(*) as n from ", candidate))
        TRUE
      },
      error = function(e) {
        access_errors <<- c(
          access_errors,
          paste0(candidate, ": ", conditionMessage(e))
        )
        FALSE
      }
    )

    if (isTRUE(access_test)) {
      return(candidate)
    }
  }

  stop(
    "S&P 500 constituent tables are visible in WRDS metadata but are not queryable ",
    "with the current account.\n",
    "Checked candidates: ", paste(visible_candidates, collapse = ", "), "\n",
    "Access errors:\n- ", paste(access_errors, collapse = "\n- "),
    call. = FALSE
  )
}

assert_required_columns <- function(wrds, full_table_name, required_columns) {
  table_parts <- strsplit(full_table_name, ".", fixed = TRUE)[[1]]
  table_schema <- table_parts[1]
  table_name <- table_parts[2]

  columns <- dbGetQuery(
    wrds,
    paste0(
      "
      select column_name, data_type
      from information_schema.columns
      where table_schema = ", dbQuoteString(wrds, table_schema), "
        and table_name = ", dbQuoteString(wrds, table_name), "
      order by ordinal_position
      "
    )
  )

  missing_columns <- setdiff(required_columns, columns$column_name)

  if (length(missing_columns) > 0) {
    stop(
      "Table ", full_table_name, " is missing required columns: ",
      paste(missing_columns, collapse = ", "),
      "\nAvailable columns: ", paste(columns$column_name, collapse = ", "),
      call. = FALSE
    )
  }

  columns
}

#==============================================================================#
# 4. Connect to WRDS and Resolve Source Tables
#==============================================================================#

cat("\n[SPX] START:", format(Sys.time()), "\n")
cat("[SPX] Working directory:", script_dir, "\n")
cat("[SPX] WRDS credential source:",
    if (is.na(WRDS_RENVIRON_PATH)) "<environment>" else WRDS_RENVIRON_PATH,
    "\n")
cat("[SPX] Requested range:", as.character(START_DATE), "to", as.character(END_DATE_REQUESTED), "\n")

wrds <- tidyfinance::get_wrds_connection()
print(wrds)
on.exit({
  try(DBI::dbDisconnect(wrds), silent = TRUE)
}, add = TRUE)

sp500_table_candidates <- c(
  "crsp_a_indexes.dsp500list_v2",
  "crsp_a_indexes.dsp500list",
  "crsp_m_indexes.dsp500list_v2",
  "crsp_m_indexes.dsp500list",
  "crsp_q_indexes.dsp500list_v2",
  "crsp_q_indexes.dsp500list",
  "crsp.dsp500list_v2",
  "crsp.dsp500list",
  "crspm.dsp500list_v2",
  "crspm.dsp500list",
  "crspq.dsp500list_v2",
  "crspq.dsp500list"
)

sp500_table <- select_first_available_table(wrds, sp500_table_candidates)
cat("[SPX] Using constituent table:", sp500_table, "\n")

sp500_columns <- assert_required_columns(
  wrds = wrds,
  full_table_name = sp500_table,
  required_columns = c("permno", "mbrstartdt", "mbrenddt")
)

# Existing project code uses crsp_a_stock.* for complete CRSP stock data.
dsf_columns <- assert_required_columns(
  wrds = wrds,
  full_table_name = "crsp_a_stock.dsf",
  required_columns = c("date")
)

#==============================================================================#
# 5. Download Raw S&P 500 Membership Intervals
#==============================================================================#

sp500_db <- tbl(wrds, I(sp500_table))

intervals_raw <- sp500_db |>
  select(permno, mbrstartdt, mbrenddt) |>
  filter(
    mbrenddt >= !!START_DATE,
    mbrstartdt <= !!END_DATE_REQUESTED
  ) |>
  distinct() |>
  collect() |>
  mutate(
    permno = as.integer(permno),
    mbrstartdt = as.Date(mbrstartdt),
    mbrenddt = as.Date(mbrenddt)
  ) |>
  arrange(permno, mbrstartdt, mbrenddt)

if (nrow(intervals_raw) == 0) {
  stop("No S&P 500 membership intervals returned for the requested date range.", call. = FALSE)
}

saveRDS(intervals_raw, PATH_INTERVALS_RAW)

latest_membership_date <- max(intervals_raw$mbrenddt, na.rm = TRUE)
END_DATE_EFFECTIVE <- min(END_DATE_REQUESTED, latest_membership_date)

cat("[SPX] Raw intervals:", nrow(intervals_raw), "\n")
cat("[SPX] Latest membership end date in WRDS table:", as.character(latest_membership_date), "\n")
cat("[SPX] Effective expansion end date:", as.character(END_DATE_EFFECTIVE), "\n")

#==============================================================================#
# 6. Download CRSP Trading-Day Calendar
#==============================================================================#

dsf_db <- tbl(wrds, I("crsp_a_stock.dsf"))

trading_days <- dsf_db |>
  select(date) |>
  filter(
    date >= !!START_DATE,
    date <= !!END_DATE_EFFECTIVE
  ) |>
  distinct() |>
  arrange(date) |>
  collect() |>
  mutate(date = as.Date(date)) |>
  pull(date)

if (length(trading_days) == 0) {
  stop("No CRSP trading days returned for the requested date range.", call. = FALSE)
}

cat("[SPX] Trading days:", length(trading_days), "\n")

#==============================================================================#
# 7. Expand Intervals to Daily Trading-Day Membership
#==============================================================================#

intervals_dt <- as.data.table(intervals_raw)
trading_days <- sort(unique(trading_days))

sp500_daily <- intervals_dt[
  ,
  {
    active_dates <- trading_days[
      trading_days >= mbrstartdt &
        trading_days <= mbrenddt
    ]
    .(date = active_dates)
  },
  by = .(permno, mbrstartdt, mbrenddt)
]

setorder(sp500_daily, date, permno)
sp500_daily[, in_sp500 := TRUE]

duplicate_count <- sp500_daily[, .N, by = .(permno, date)][N > 1, .N]

if (duplicate_count > 0) {
  warning(
    "Found ", duplicate_count,
    " duplicate permno-date rows after interval expansion. Deduplicating."
  )

  sp500_daily <- unique(
    sp500_daily,
    by = c("permno", "date", "mbrstartdt", "mbrenddt")
  )

  setorder(sp500_daily, date, permno)
}

sp500_daily_df <- as_tibble(sp500_daily)

saveRDS(sp500_daily_df, PATH_DAILY_RDS)

if (requireNamespace("arrow", quietly = TRUE)) {
  arrow::write_parquet(sp500_daily_df, PATH_DAILY_PARQUET)
  cat("[SPX] Wrote parquet:", PATH_DAILY_PARQUET, "\n")
} else {
  cat("[SPX] Package 'arrow' not installed; skipped parquet output.\n")
}

#==============================================================================#
# 8. Diagnostics
#==============================================================================#

summary_daily <- sp500_daily_df |>
  group_by(date) |>
  summarise(
    n_constituents = n_distinct(permno),
    .groups = "drop"
  ) |>
  arrange(date)

readr::write_csv(summary_daily, PATH_SUMMARY)

cat("[SPX] Daily rows:", nrow(sp500_daily_df), "\n")
cat("[SPX] Distinct permno:", dplyr::n_distinct(sp500_daily_df$permno), "\n")
cat("[SPX] Date range:", as.character(min(sp500_daily_df$date)), "to", as.character(max(sp500_daily_df$date)), "\n")
cat("[SPX] Constituents per day, min/median/max:",
    min(summary_daily$n_constituents),
    median(summary_daily$n_constituents),
    max(summary_daily$n_constituents),
    "\n")
cat("[SPX] Wrote raw intervals:", PATH_INTERVALS_RAW, "\n")
cat("[SPX] Wrote daily RDS:", PATH_DAILY_RDS, "\n")
cat("[SPX] Wrote diagnostics:", PATH_SUMMARY, "\n")
cat("[SPX] DONE:", format(Sys.time()), "\n\n")
