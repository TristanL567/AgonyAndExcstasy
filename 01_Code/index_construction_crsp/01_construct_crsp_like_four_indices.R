#==============================================================================#
#==== 01_construct_crsp_like_four_indices.R ===================================#
#==== Reconstruct CRSP-like Total/Large/Mid/Small indexes ======================#
#==============================================================================#
#
# Purpose:
#   Build four CRSP-like market-cap indexes from the local CRSP stock universe:
#     - Total Market
#     - Large Cap
#     - Mid Cap
#     - Small Cap
#
# Construction:
#   - Ranking universe: local CRSP monthly stock file at quarter-end months.
#   - Company size: sum of security market caps by PERMCO.
#   - Breakpoint score: cumulative market cap before the company plus half of
#     company market cap, divided by total eligible market cap.
#   - Size breakpoints: 70%, 85%, 98%.
#   - Constituents: securities inherit their PERMCO company segment.
#   - Weights: security market cap divided by total index market cap.
#   - Returns: monthly total-return portfolio, drifted between quarterly
#     rebalances using local CRSP ret_adj.
#
# Important limitations relative to official CRSP Market Indexes:
#   - Does not use CRSP official float factors.
#   - Does not use CRSP random ranking price day or shares freeze dates.
#   - Does not implement CRSP banding/packeting migration.
#   - Does not use five-day transition windows.
#   - Uses the project CRSP stock universe, not licensed CRSPMI constituents.
#
# Outputs are written under:
#   02_Data_Input/04_Index_Replication/Necessary/
#     crsp_like_index_constituents_quarterly.rds
#     crsp_like_index_returns_monthly.rds
#     crsp_like_index_summary_quarterly.csv
#   02_Data_Input/04_Index_Replication/Additional/
#     crsp_like_company_assignments_quarterly.rds
#     crsp_like_index_constituents_quarterly.csv
#     crsp_like_index_returns_monthly.csv
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
    "\nInstall them before running this script.",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(data.table)
})

script_dir <- get_script_dir()
project_root <- normalizePath(file.path(script_dir, "..", ".."), winslash = "/", mustWork = TRUE)
idxrep_nec_dir <- file.path(project_root, "02_Data_Input", "04_Index_Replication", "Necessary")
idxrep_add_dir <- file.path(project_root, "02_Data_Input", "04_Index_Replication", "Additional")
diagnostics_dir <- file.path(idxrep_add_dir, "diagnostics")

dir.create(idxrep_nec_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(idxrep_add_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(diagnostics_dir, recursive = TRUE, showWarnings = FALSE)

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

## AgonyAndExcstasy layout: CRSP processed inputs live under
##   02_Data_Input/01_CRSP/Necessary/
path_prices_monthly <- file.path(project_root, "02_Data_Input", "01_CRSP", "Necessary", "prices_monthly.rds")
path_universe       <- file.path(project_root, "02_Data_Input", "01_CRSP", "Necessary", "universe.rds")

path_company_assignments <- file.path(idxrep_add_dir, "crsp_like_company_assignments_quarterly.rds")
path_constituents_rds <- file.path(idxrep_nec_dir, "crsp_like_index_constituents_quarterly.rds")
path_constituents_csv <- file.path(idxrep_add_dir, "crsp_like_index_constituents_quarterly.csv")
path_returns_rds <- file.path(idxrep_nec_dir, "crsp_like_index_returns_monthly.rds")
path_returns_csv <- file.path(idxrep_add_dir, "crsp_like_index_returns_monthly.csv")
path_summary_csv <- file.path(idxrep_nec_dir, "crsp_like_index_summary_quarterly.csv")
path_run_summary <- file.path(diagnostics_dir, "crsp_like_four_indices_run_summary.md")

cat("[CRSP-like indices] Loading inputs...\n")
monthly <- as.data.table(readRDS(path_prices_monthly))
universe <- as.data.table(readRDS(path_universe))

required_monthly_cols <- c("permno", "date", "ret_adj", "mktcap", "price", "shrout")
required_universe_cols <- c("permno", "permco", "ticker", "issuernm")

missing_monthly_cols <- setdiff(required_monthly_cols, names(monthly))
missing_universe_cols <- setdiff(required_universe_cols, names(universe))

if (length(missing_monthly_cols) > 0) {
  stop("prices_monthly.rds missing required columns: ", paste(missing_monthly_cols, collapse = ", "), call. = FALSE)
}
if (length(missing_universe_cols) > 0) {
  stop("universe.rds missing required columns: ", paste(missing_universe_cols, collapse = ", "), call. = FALSE)
}

if (!inherits(monthly$date, "Date")) {
  monthly[, date := as.Date(date)]
}

universe_keep_cols <- intersect(
  c("permno", "permco", "ticker", "issuernm", "exchange", "securitytype", "securitysubtype", "sharetype", "shareclass"),
  names(universe)
)

monthly <- merge(
  monthly,
  unique(universe[, ..universe_keep_cols], by = "permno"),
  by = "permno",
  all.x = TRUE
)

monthly[is.na(permco), permco := permno]
monthly <- monthly[
  !is.na(date) &
    !is.na(permno) &
    !is.na(permco) &
    !is.na(mktcap) &
    mktcap > 0 &
    !is.na(price) &
    price > 0
]

monthly[, `:=`(
  year = as.integer(format(date, "%Y")),
  month = as.integer(format(date, "%m"))
)]

rebalance_months <- c(3L, 6L, 9L, 12L)
breakpoints <- c(mega_mid = 0.70, mid_small = 0.85, small_micro = 0.98)

index_defs <- data.table(
  index_id = c("total_market", "large_cap", "mid_cap", "small_cap"),
  index_name = c(
    "CRSP-like US Total Market",
    "CRSP-like US Large Cap",
    "CRSP-like US Mid Cap",
    "CRSP-like US Small Cap"
  ),
  crsp_reference_price_code = c("CRSPTM1", "CRSPLC1", "CRSPMI1", "CRSPSC1"),
  crsp_reference_total_return_code = c("CRSPTMT", "CRSPLCT", "CRSPMIT", "CRSPSCT"),
  included_segments = c("mega,mid,small,micro", "mega,mid", "mid", "small")
)

cat("[CRSP-like indices] Building quarterly company assignments...\n")
q_dates <- monthly[
  month %in% rebalance_months,
  .(qdate = max(date)),
  by = .(year, month)
]
setorder(q_dates, qdate)

ranking_monthly <- monthly[
  date %in% q_dates$qdate,
  .(
    permno,
    permco,
    ticker,
    issuernm,
    exchange = if ("exchange" %in% names(monthly)) exchange else NA_character_,
    securitytype = if ("securitytype" %in% names(monthly)) securitytype else NA_character_,
    sharetype = if ("sharetype" %in% names(monthly)) sharetype else NA_character_,
    qdate = date,
    security_mktcap = as.numeric(mktcap),
    price = as.numeric(price),
    shrout = as.numeric(shrout)
  )
]

company_caps <- ranking_monthly[
  ,
  .(
    company_mktcap = sum(security_mktcap, na.rm = TRUE),
    n_securities = uniqueN(permno)
  ),
  by = .(qdate, permco)
]

setorder(company_caps, qdate, -company_mktcap, permco)
company_caps[, company_rank := seq_len(.N), by = qdate]
company_caps[, total_market_mktcap := sum(company_mktcap, na.rm = TRUE), by = qdate]
company_caps[, cumulative_mktcap_before := shift(cumsum(company_mktcap), fill = 0), by = qdate]
company_caps[, cumulative_mktcap_midpoint := cumulative_mktcap_before + 0.5 * company_mktcap]
company_caps[, cumulative_mktcap_score := cumulative_mktcap_midpoint / total_market_mktcap]
company_caps[, size_segment := fifelse(
  cumulative_mktcap_score <= breakpoints[["mega_mid"]],
  "mega",
  fifelse(
    cumulative_mktcap_score <= breakpoints[["mid_small"]],
    "mid",
    fifelse(cumulative_mktcap_score <= breakpoints[["small_micro"]], "small", "micro")
  )
)]

company_assignments <- company_caps[
  ,
  .(
    qdate,
    permco,
    company_rank,
    company_mktcap,
    total_market_mktcap,
    cumulative_mktcap_score,
    size_segment,
    n_securities
  )
]

save_rds_atomic(company_assignments, path_company_assignments)

cat("[CRSP-like indices] Building quarterly constituents and weights...\n")
constituent_base <- merge(
  ranking_monthly,
  company_assignments,
  by = c("qdate", "permco"),
  all.x = TRUE
)

build_index_constituents <- function(base_dt, index_row) {
  segments <- strsplit(index_row$included_segments, ",", fixed = TRUE)[[1]]
  out <- base_dt[size_segment %chin% segments]
  if (nrow(out) == 0L) return(NULL)

  out[, `:=`(
    index_id = index_row$index_id,
    index_name = index_row$index_name,
    crsp_reference_price_code = index_row$crsp_reference_price_code,
    crsp_reference_total_return_code = index_row$crsp_reference_total_return_code
  )]

  out[, index_mktcap := sum(security_mktcap, na.rm = TRUE), by = .(qdate, index_id)]
  out[, weight := security_mktcap / index_mktcap]

  out[
    ,
    .(
      qdate,
      index_id,
      index_name,
      crsp_reference_price_code,
      crsp_reference_total_return_code,
      permno,
      permco,
      ticker,
      issuernm,
      exchange,
      securitytype,
      sharetype,
      size_segment,
      company_rank,
      cumulative_mktcap_score,
      company_mktcap,
      security_mktcap,
      index_mktcap,
      weight
    )
  ]
}

constituents <- rbindlist(
  lapply(seq_len(nrow(index_defs)), function(i) build_index_constituents(constituent_base, index_defs[i])),
  use.names = TRUE,
  fill = TRUE
)

setorder(constituents, qdate, index_id, -weight, permno)

summary_q <- constituents[
  ,
  .(
    n_constituents = uniqueN(permno),
    n_companies = uniqueN(permco),
    weight_sum = sum(weight, na.rm = TRUE),
    index_mktcap = max(index_mktcap, na.rm = TRUE),
    largest_weight = max(weight, na.rm = TRUE),
    min_company_score = min(cumulative_mktcap_score, na.rm = TRUE),
    max_company_score = max(cumulative_mktcap_score, na.rm = TRUE)
  ),
  by = .(qdate, index_id, index_name, crsp_reference_price_code, crsp_reference_total_return_code)
]
setorder(summary_q, qdate, index_id)

save_rds_atomic(constituents, path_constituents_rds)
fwrite_atomic(constituents, path_constituents_csv)
fwrite_atomic(summary_q, path_summary_csv)

cat("[CRSP-like indices] Computing monthly drifted index returns...\n")
monthly_returns <- monthly[
  ,
  .(
    permno,
    date,
    ret = pmax(as.numeric(ret_adj), -1),
    dlret_applied = if ("dlret_applied" %in% names(monthly)) as.logical(dlret_applied) else FALSE
  )
]
monthly_returns[, date_key := as.character(date)]
monthly_returns_by_date <- split(
  monthly_returns[, .(date_key, permno, ret, dlret_applied)],
  by = "date_key",
  keep.by = FALSE
)
monthly_returns_by_date <- lapply(monthly_returns_by_date, function(x) {
  setkey(x, permno)
  x
})

all_month_dates <- sort(unique(monthly_returns$date))
qdate_vec <- sort(unique(constituents$qdate))
max_return_date <- max(all_month_dates, na.rm = TRUE)

returns_list <- vector("list", length(qdate_vec) * nrow(index_defs) * 3L)
entry <- 0L

for (idx in index_defs$index_id) {
  cat("  - ", idx, "\n", sep = "")
  for (q_i in seq_along(qdate_vec)) {
    qdate_i <- qdate_vec[q_i]
    qdate_next <- if (q_i < length(qdate_vec)) qdate_vec[q_i + 1L] else max_return_date
    hold_dates <- all_month_dates[all_month_dates > qdate_i & all_month_dates <= qdate_next]

    if (length(hold_dates) == 0L) next

    holdings <- constituents[
      qdate == qdate_i & index_id == idx,
      .(permno, weight)
    ]
    setnames(holdings, "weight", "w")

    if (nrow(holdings) == 0L) next

    for (hold_date_raw in hold_dates) {
      hold_date <- as.Date(hold_date_raw, origin = "1970-01-01")
      month_returns <- monthly_returns_by_date[[as.character(hold_date)]]
      if (is.null(month_returns)) break

      active <- month_returns[holdings, on = "permno", nomatch = 0]

      active <- active[!is.na(ret)]
      if (nrow(active) == 0L) break

      pre_weight_sum <- sum(active$w, na.rm = TRUE)
      if (!is.finite(pre_weight_sum) || pre_weight_sum <= 0) break

      active[, w_pre := w / pre_weight_sum]
      port_ret <- sum(active$w_pre * active$ret, na.rm = TRUE)
      active[, post_value := w_pre * (1 + ret)]

      valid_next <- active[!is.na(post_value) & post_value > 0 & !(dlret_applied %in% TRUE)]
      next_total <- sum(valid_next$post_value, na.rm = TRUE)

      entry <- entry + 1L
      returns_list[[entry]] <- data.table(
        date = hold_date,
        qdate = qdate_i,
        index_id = idx,
        index_name = index_defs[index_id == idx, index_name],
        crsp_reference_price_code = index_defs[index_id == idx, crsp_reference_price_code],
        crsp_reference_total_return_code = index_defs[index_id == idx, crsp_reference_total_return_code],
        port_ret = port_ret,
        n_holdings_start = nrow(holdings),
        n_holdings_with_return = nrow(active),
        active_weight_before_rescale = pre_weight_sum
      )

      if (!is.finite(next_total) || next_total <= 0) break

      holdings <- valid_next[, .(permno, w = post_value / next_total)]
    }
  }
}

index_returns <- rbindlist(returns_list[seq_len(entry)], use.names = TRUE, fill = TRUE)
setorder(index_returns, index_id, date)
index_returns[, cumulative_index := cumprod(1 + port_ret), by = index_id]

save_rds_atomic(index_returns, path_returns_rds)
fwrite_atomic(index_returns, path_returns_csv)

cat("[CRSP-like indices] Writing run summary...\n")
if (file.exists(path_run_summary)) unlink(path_run_summary)

append_line <- function(...) cat(..., "\n", file = path_run_summary, append = TRUE, sep = "")

append_line("# CRSP-like Four-Index Reconstruction Run Summary")
append_line("")
append_line("Run time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"))
append_line("")
append_line("## Inputs")
append_line("")
append_line("- Monthly prices: ", path_prices_monthly)
append_line("- Universe: ", path_universe)
append_line("- Monthly rows used after filters: ", nrow(monthly))
append_line("- Distinct PERMNO used after filters: ", uniqueN(monthly$permno))
append_line("- Rebalance quarters: ", uniqueN(q_dates$qdate))
append_line("- Rebalance date range: ", as.character(min(q_dates$qdate)), " to ", as.character(max(q_dates$qdate)))
append_line("")
append_line("## Construction")
append_line("")
append_line("- Company size unit: sum of local CRSP security market cap by PERMCO.")
append_line("- Breakpoint score: cumulative market cap before company plus half company market cap divided by total market cap.")
append_line("- Breakpoints: 70%, 85%, 98%.")
append_line("- Assignment: hard quarterly assignment; CRSP banding/packeting is not implemented.")
append_line("- Weights: security market cap / index market cap at quarter-end rebalance date.")
append_line("- Returns: monthly drifted total-return portfolio using local `ret_adj`.")
append_line("")
append_line("## Outputs")
append_line("")
append_line("- Company assignments: ", path_company_assignments)
append_line("- Quarterly constituents RDS: ", path_constituents_rds)
append_line("- Quarterly constituents CSV: ", path_constituents_csv)
append_line("- Quarterly summary CSV: ", path_summary_csv)
append_line("- Monthly returns RDS: ", path_returns_rds)
append_line("- Monthly returns CSV: ", path_returns_csv)

cat("[CRSP-like indices] Done.\n")
cat("Constituents:", path_constituents_rds, "\n")
cat("Returns:", path_returns_rds, "\n")
