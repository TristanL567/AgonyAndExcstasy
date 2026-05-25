#==============================================================================#
#==== 02_compute_top10_weights.R ==============================================#
#==== Top-10 constituent weights over time for CRSP-like indexes ===============#
#==============================================================================#
#
# Purpose:
#   Compute the top 10 constituent weights at each quarterly rebalance for each
#   reconstructed CRSP-like index.
#
# Inputs:
#   02_Data_Input/04_Index_Replication/Necessary/
#     crsp_like_index_constituents_quarterly.rds
#
# Outputs:
#   02_Data_Input/04_Index_Replication/Additional/
#     crsp_like_top10_weights_quarterly_long.rds
#     crsp_like_top10_weights_quarterly_long.csv
#     crsp_like_top10_weights_quarterly_wide.csv
#     diagnostics/crsp_like_top10_weights_summary.md
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

required_packages <- c("data.table")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing required packages: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(data.table)
})

save_rds_atomic <- function(object, path) {
  tmp <- paste0(path, ".", Sys.getpid(), ".tmp")
  if (file.exists(tmp)) unlink(tmp)
  saveRDS(object, tmp)
  if (file.exists(path)) unlink(path)
  if (!file.rename(tmp, path)) {
    stop("Could not move temporary RDS into place: ", path, call. = FALSE)
  }
}

fwrite_atomic <- function(object, path) {
  tmp <- paste0(path, ".", Sys.getpid(), ".tmp")
  if (file.exists(tmp)) unlink(tmp)
  fwrite(object, tmp)
  if (file.exists(path)) unlink(path)
  if (!file.rename(tmp, path)) {
    stop("Could not move temporary CSV into place: ", path, call. = FALSE)
  }
}

script_dir <- get_script_dir()
project_root <- normalizePath(file.path(script_dir, "..", ".."),
                              winslash = "/", mustWork = TRUE)
idxrep_nec_dir <- file.path(project_root, "02_Data_Input",
                            "04_Index_Replication", "Necessary")
idxrep_add_dir <- file.path(project_root, "02_Data_Input",
                            "04_Index_Replication", "Additional")
diagnostics_dir <- file.path(idxrep_add_dir, "diagnostics")
dir.create(idxrep_nec_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(idxrep_add_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(diagnostics_dir, recursive = TRUE, showWarnings = FALSE)

path_constituents <- file.path(idxrep_nec_dir, "crsp_like_index_constituents_quarterly.rds")
path_top10_long_rds <- file.path(idxrep_add_dir, "crsp_like_top10_weights_quarterly_long.rds")
path_top10_long_csv <- file.path(idxrep_add_dir, "crsp_like_top10_weights_quarterly_long.csv")
path_top10_wide_csv <- file.path(idxrep_add_dir, "crsp_like_top10_weights_quarterly_wide.csv")
path_summary <- file.path(diagnostics_dir, "crsp_like_top10_weights_summary.md")

if (!file.exists(path_constituents)) {
  stop("Missing constituents input: ", path_constituents, call. = FALSE)
}

cat("[top10] Loading constituents...\n")
constituents <- as.data.table(readRDS(path_constituents))

required_cols <- c(
  "qdate", "index_id", "index_name", "crsp_reference_price_code",
  "permno", "permco", "ticker", "issuernm", "size_segment",
  "company_rank", "security_mktcap", "index_mktcap", "weight"
)
missing_cols <- setdiff(required_cols, names(constituents))
if (length(missing_cols) > 0) {
  stop("Constituent file missing required columns: ", paste(missing_cols, collapse = ", "), call. = FALSE)
}

if (!inherits(constituents$qdate, "Date")) {
  constituents[, qdate := as.Date(qdate)]
}

cat("[top10] Computing ranks...\n")
setorder(constituents, qdate, index_id, -weight, permno)
constituents[, weight_rank := seq_len(.N), by = .(qdate, index_id)]

top10_long <- constituents[
  weight_rank <= 10L,
  .(
    qdate,
    index_id,
    index_name,
    crsp_reference_price_code,
    weight_rank,
    permno,
    permco,
    ticker,
    issuernm,
    size_segment,
    company_rank,
    security_mktcap,
    index_mktcap,
    weight,
    weight_pct = 100 * weight
  )
]

setorder(top10_long, qdate, index_id, weight_rank)

top10_wide <- dcast(
  top10_long[
    ,
    .(
      qdate,
      index_id,
      index_name,
      weight_rank,
      label = paste0(ticker, " (", sprintf("%.2f", weight_pct), "%)")
    )
  ],
  qdate + index_id + index_name ~ paste0("rank_", weight_rank),
  value.var = "label"
)
rank_cols <- paste0("rank_", 1:10)
setcolorder(top10_wide, c("qdate", "index_id", "index_name", rank_cols))
setorder(top10_wide, qdate, index_id)

summary_dt <- top10_long[
  ,
  .(
    top10_weight_sum = sum(weight, na.rm = TRUE),
    top1_ticker = ticker[which.min(weight_rank)],
    top1_weight_pct = weight_pct[which.min(weight_rank)]
  ),
  by = .(qdate, index_id, index_name)
]
setorder(summary_dt, qdate, index_id)

cat("[top10] Writing outputs...\n")
save_rds_atomic(top10_long, path_top10_long_rds)
fwrite_atomic(top10_long, path_top10_long_csv)
fwrite_atomic(top10_wide, path_top10_wide_csv)

if (file.exists(path_summary)) unlink(path_summary)
append_line <- function(...) cat(..., "\n", file = path_summary, append = TRUE, sep = "")

latest_qdate <- max(summary_dt$qdate, na.rm = TRUE)
latest_summary <- summary_dt[qdate == latest_qdate]

append_line("# CRSP-like Top-10 Weights Summary")
append_line("")
append_line("Run time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"))
append_line("")
append_line("Input: ", path_constituents)
append_line("")
append_line("Outputs:")
append_line("")
append_line("- Long RDS: ", path_top10_long_rds)
append_line("- Long CSV: ", path_top10_long_csv)
append_line("- Wide CSV: ", path_top10_wide_csv)
append_line("")
append_line("Rows in long output: ", nrow(top10_long))
append_line("Quarterly dates: ", uniqueN(top10_long$qdate))
append_line("Date range: ", as.character(min(top10_long$qdate)), " to ", as.character(max(top10_long$qdate)))
append_line("")
append_line("Latest quarter: ", as.character(latest_qdate))
append_line("")

for (i in seq_len(nrow(latest_summary))) {
  row <- latest_summary[i]
  append_line(
    "- ", row$index_id,
    ": top-10 weight sum = ", sprintf("%.2f%%", 100 * row$top10_weight_sum),
    "; top name = ", row$top1_ticker,
    " (", sprintf("%.2f%%", row$top1_weight_pct), ")"
  )
}

cat("[top10] Done.\n")
cat("Long output:", path_top10_long_csv, "\n")
cat("Wide output:", path_top10_wide_csv, "\n")
