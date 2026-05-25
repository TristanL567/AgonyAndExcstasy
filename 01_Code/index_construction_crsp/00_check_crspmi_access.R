#==============================================================================#
#==== 00_check_crspmi_access.R ================================================#
#==== Check availability of CRSPMI historical index constituents ===============#
#==============================================================================#
#
# Purpose:
#   Verify which CRSP Market Index constituent sources are accessible from the
#   current machine/account.
#
# Output:
#   02_Data_Input/04_Index_Replication/Additional/diagnostics/
#     crspmi_access_summary.md
#     public_quarterly_constituents_summary.csv
#     wrds_crspmi_candidate_tables.csv
#     wrds_crsp_index_table_access_tests.csv
#
# Notes:
#   - The public CRSP quarterly constituent CSV is a delayed current snapshot,
#     not a historical constituent database.
#   - Historical daily constituents require licensed CRSPMI Historical Database
#     files or a redistributor that exposes the same content.
#
#==============================================================================#

get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  match <- grep(file_arg, args, fixed = TRUE)

  if (length(match) > 0) {
    return(dirname(normalizePath(sub(file_arg, "", args[match[1]]), winslash = "/", mustWork = TRUE)))
  }

  if (!is.null(sys.frames()[[1]]$ofile)) {
    return(dirname(normalizePath(sys.frames()[[1]]$ofile, winslash = "/", mustWork = TRUE)))
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
    if (identical(parent_dir, current_dir)) return(NA_character_)
    current_dir <- parent_dir
  }
}

write_csv_base <- function(x, path) {
  utils::write.csv(x, path, row.names = FALSE, na = "")
}

append_line <- function(path, ...) {
  cat(..., "\n", file = path, append = TRUE, sep = "")
}

script_dir <- get_script_dir()
project_root <- normalizePath(file.path(script_dir, "..", ".."),
                              winslash = "/", mustWork = TRUE)
diagnostics_dir <- file.path(project_root, "02_Data_Input",
                             "04_Index_Replication", "Additional",
                             "diagnostics")
dir.create(diagnostics_dir, recursive = TRUE, showWarnings = FALSE)

summary_path <- file.path(diagnostics_dir, "crspmi_access_summary.md")
public_summary_path <- file.path(diagnostics_dir, "public_quarterly_constituents_summary.csv")
wrds_tables_path <- file.path(diagnostics_dir, "wrds_crspmi_candidate_tables.csv")
wrds_access_tests_path <- file.path(diagnostics_dir, "wrds_crsp_index_table_access_tests.csv")

if (file.exists(summary_path)) unlink(summary_path)

append_line(summary_path, "# CRSPMI Historical Constituent Access Check")
append_line(summary_path, "")
append_line(summary_path, "Run time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"))
append_line(summary_path, "")

#==============================================================================#
# 1. Public delayed quarterly constituent snapshot
#==============================================================================#

public_url <- "https://crsp.org/wp-content/uploads/quarterly-index-constituents/crsp_quarterly_constituents.csv"
public_local <- file.path(diagnostics_dir, "public_crsp_quarterly_constituents.csv")
public_status <- "not_checked"
public_message <- NA_character_

public_result <- tryCatch(
  {
    if (!file.exists(public_local)) {
      utils::download.file(public_url, public_local, mode = "wb", quiet = TRUE)
    }
    public_status <- "available"

    q <- utils::read.csv(public_local, stringsAsFactors = FALSE, check.names = FALSE)
    keep <- q[q[["Index Name"]] %in% c("Total Market", "Large Cap", "Mid Cap", "Small Cap"), ]

    public_summary <- aggregate(
      as.numeric(keep[["Weight"]]),
      by = list(
        TradeDate = keep[["TradeDate"]],
        Index_Ticker = keep[["Index Ticker"]],
        Index_Name = keep[["Index Name"]]
      ),
      FUN = function(z) c(constituents = length(z), weight_sum = sum(z, na.rm = TRUE))
    )

    public_summary <- data.frame(
      TradeDate = public_summary$TradeDate,
      Index_Ticker = public_summary$Index_Ticker,
      Index_Name = public_summary$Index_Name,
      Constituents = as.integer(public_summary$x[, "constituents"]),
      Weight_Sum = as.numeric(public_summary$x[, "weight_sum"])
    )

    write_csv_base(public_summary, public_summary_path)
    public_message <- paste0("Read current delayed public constituent snapshot. Rows: ", nrow(q), ".")
    TRUE
  },
  error = function(e) {
    public_status <<- "unavailable"
    public_message <<- conditionMessage(e)
    FALSE
  }
)

append_line(summary_path, "## Public CRSP Quarterly Constituents")
append_line(summary_path, "")
append_line(summary_path, "- URL: ", public_url)
append_line(summary_path, "- Status: ", public_status)
append_line(summary_path, "- Result: ", public_message)
if (isTRUE(public_result)) {
  append_line(summary_path, "- Local CSV: ", public_local)
  append_line(summary_path, "- Diagnostic CSV: ", public_summary_path)
  append_line(summary_path, "- Limitation: public file is quarterly, delayed, and contains ticker/company/weight only; it is not historical and does not include PERMNO.")
}
append_line(summary_path, "")

#==============================================================================#
# 2. WRDS metadata check for CRSPMI historical constituent tables
#==============================================================================#

append_line(summary_path, "## WRDS / Database Metadata")
append_line(summary_path, "")

required_packages <- c("DBI", "RPostgres", "tidyfinance")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  append_line(summary_path, "- Status: not checked")
  append_line(summary_path, "- Reason: missing R packages: ", paste(missing_packages, collapse = ", "))
} else {
  suppressPackageStartupMessages({
    library(DBI)
    library(tidyfinance)
  })

  wrds_renviron_path <- load_wrds_renviron(script_dir)
  append_line(summary_path, "- WRDS .Renviron loaded: ", ifelse(is.na(wrds_renviron_path), "no", wrds_renviron_path))

  wrds_result <- tryCatch(
    {
      wrds <- tidyfinance::get_wrds_connection()
      on.exit(try(DBI::dbDisconnect(wrds), silent = TRUE), add = TRUE)

      candidate_tables <- DBI::dbGetQuery(
        wrds,
        "
        select table_schema, table_name
        from information_schema.tables
        where table_schema ilike '%crspmi%'
           or table_schema ilike '%crsp%index%'
           or table_schema in ('crsp_a_indexes', 'crsp_m_indexes', 'crsp_q_indexes')
           or table_name ilike '%crspmi%'
           or table_name ilike '%constitu%'
           or table_name ilike '%constituent%'
           or table_name ilike '%index_const%'
        order by table_schema, table_name
        limit 1000
        "
      )

      write_csv_base(candidate_tables, wrds_tables_path)

      constituent_hits <- candidate_tables[
        grepl("crspmi|constitu|constituent|index_const", candidate_tables$table_schema, ignore.case = TRUE) |
          grepl("crspmi|constitu|constituent|index_const", candidate_tables$table_name, ignore.case = TRUE),
        ,
        drop = FALSE
      ]

      append_line(summary_path, "- Status: checked")
      append_line(summary_path, "- Candidate metadata rows: ", nrow(candidate_tables))
      append_line(summary_path, "- Constituent-like rows: ", nrow(constituent_hits))
      append_line(summary_path, "- Candidate table CSV: ", wrds_tables_path)

      if (nrow(constituent_hits) > 0) {
        append_line(summary_path, "- Interpretation: metadata contains constituent-like CRSP/index tables. Inspect the CSV and test row counts before assuming CRSPMI Historical Database access.")
      } else {
        append_line(summary_path, "- Interpretation: no CRSPMI historical constituent table was visible through WRDS metadata for this account/query.")
      }

      probe_tables <- c(
        "crsp_a_indexes.stkindmembership_ind",
        "crsp_m_indexes.stkindmembership_ind",
        "crsp_q_indexes.stkindmembership_ind",
        "crsp_a_indexes.indseriesinfohdr_ind",
        "crsp_m_indexes.indseriesinfohdr_ind",
        "crsp_q_indexes.indseriesinfohdr_ind",
        "crsp_a_indexes.inddlyseriesdata_ind",
        "crsp_a_indexes.dsp500list_v2"
      )

      access_tests <- do.call(
        rbind,
        lapply(probe_tables, function(full_table_name) {
          count_result <- tryCatch(
            DBI::dbGetQuery(wrds, paste0("select count(*) as n from ", full_table_name)),
            error = function(e) e
          )

          sample_result <- tryCatch(
            DBI::dbGetQuery(wrds, paste0("select * from ", full_table_name, " limit 1")),
            error = function(e) e
          )

          data.frame(
            table_name = full_table_name,
            count_status = if (inherits(count_result, "error")) "error" else "ok",
            count_value = if (inherits(count_result, "error")) NA_real_ else as.numeric(count_result$n[1]),
            count_message = if (inherits(count_result, "error")) conditionMessage(count_result) else NA_character_,
            sample_status = if (inherits(sample_result, "error")) "error" else "ok",
            sample_message = if (inherits(sample_result, "error")) conditionMessage(sample_result) else NA_character_,
            stringsAsFactors = FALSE
          )
        })
      )

      write_csv_base(access_tests, wrds_access_tests_path)
      denied_tables <- access_tests[
        access_tests$count_status == "error" &
          grepl("permission denied", access_tests$count_message, ignore.case = TRUE),
        ,
        drop = FALSE
      ]

      append_line(summary_path, "- Specific CRSP index table access test CSV: ", wrds_access_tests_path)
      append_line(summary_path, "- Specific CRSP index tables tested: ", nrow(access_tests))
      append_line(summary_path, "- Permission-denied table count: ", nrow(denied_tables))

      TRUE
    },
    error = function(e) {
      append_line(summary_path, "- Status: unavailable")
      append_line(summary_path, "- Error: ", conditionMessage(e))
      FALSE
    }
  )
}

append_line(summary_path, "")
append_line(summary_path, "## Practical Conclusion")
append_line(summary_path, "")
append_line(summary_path, "- The public CRSP file can verify the latest delayed quarterly weights but cannot support historical backtests.")
append_line(summary_path, "- Historical constituents require the licensed CRSPMI Historical Database or a redistributor feed exposing the same constituent open/close files.")
append_line(summary_path, "- For thesis index construction, use CRSPMI Historical constituent open or close files when available because they include PERMNO and official Index_Weight.")

cat("Wrote access summary to:\n", summary_path, "\n", sep = "")
