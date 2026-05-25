#==============================================================================#
#==== config.R ================================================================#
#==== Single Source of Truth — All Pipeline Parameters ========================#
#==============================================================================#
#
# PURPOSE:
#   Every threshold, date, seed, path, and figure directory used anywhere in
#   the pipeline is declared here and nowhere else. Source this file at the
#   top of every pipeline script with: source("config.R")
#
# PIPELINE OVERVIEW:
#   01_Universe.R            CRSP universe construction
#   02_Prices.R              Monthly/weekly prices + delisting returns
#   03_Fundamentals.R        Compustat annual fundamentals + CCM link
#   04_Macro.R               FRED macro variables
#   05_CSI_Label.R           CSI event labels (base + 27-parameter grid)
#   05B_Bucket_Labels.R      5-year forward CAGR bucket labels
#   05C_Structural_Labels.R  Combined CSI + bucket structural quality labels
#   06_Merge.R               Panel merge (prices + fundamentals + macro)
#   06B_Feature_Eng.R        Feature engineering → features_raw / features_fund
#   07_Feature_Sel.R         Feature selection diagnostics
#   08_Split.R               Train / test / OOS split construction
#   08B_Autoencoder.py       Beta-VAE latent features (M2/M4/B2/B4/S2/S4)
#   09C_AutoGluon.py         AutoML training (M1–M4, B1–B4, S1–S4)
#   10_Evaluate.R            Model evaluation (AUC, AP, decile tables, PR curves)
#   11_Results.R             Index construction (all strategies)
#   12_Evaluation.R          Index diagnostics (exclusion, sector, TE, turnover)
#   13_Robustness.R          Robustness checks Parts A–E
#   14_Comparison.R          Comparison vs naive benchmarks (low-vol, quality)
#
# OUTPUT DIRECTORY STRUCTURE:
#
#   03_Output/
#   ├── Tables/
#   │   ├── ag_fund/               M1 predictions + leaderboard
#   │   ├── ag_latent_fund/        M2
#   │   ├── ag_raw/                M3
#   │   ├── ag_latent_raw/         M4
#   │   ├── ag_bucket/             B1
#   │   ├── ag_bucket_latent_fund/ B2
#   │   ├── ag_bucket_raw/         B3
#   │   ├── ag_bucket_latent_raw/  B4
#   │   ├── ag_structural/         S1
#   │   ├── ag_structural_latent_fund/ S2
#   │   ├── ag_structural_raw/     S3
#   │   └── ag_structural_latent_raw/  S4
#   │
#   ├── Figures/
#   │   ├── 01_universe/
#   │   ├── 02_prices/
#   │   ├── 03_fundamentals/
#   │   ├── 04_macro/
#   │   ├── 05_labels/
#   │   │   ├── csi/
#   │   │   ├── bucket/
#   │   │   └── structural/
#   │   ├── 06_features/
#   │   │
#   │   ├── 09_models/             ← all model evaluation figures
#   │   │   ├── comparison/        cross-model comparison (all 12 side by side)
#   │   │   ├── csi/               Track 1 overview
#   │   │   │   ├── m1/
#   │   │   │   ├── m2/
#   │   │   │   ├── m3/
#   │   │   │   └── m4/
#   │   │   ├── bucket/            Track 2 overview
#   │   │   │   ├── b1/
#   │   │   │   ├── b2/
#   │   │   │   ├── b3/
#   │   │   │   └── b4/
#   │   │   └── structural/        Track 3 overview
#   │   │       ├── s1/
#   │   │       ├── s2/
#   │   │       ├── s3/
#   │   │       └── s4/
#   │   │
#   │   ├── 11_index/              ← index construction + returns figures
#   │   │   ├── general/           overall benchmark vs all strategies
#   │   │   ├── csi_track/         CSI-model-based index strategies
#   │   │   ├── bucket_track/      bucket-model-based index strategies
#   │   │   ├── structural_track/  structural-model-based index strategies
#   │   │   └── concentrated/      C1/C2/C3 concentrated portfolios
#   │   │
#   │   ├── 12_evaluation/         index diagnostics (exclusion, sector, TE)
#   │   ├── 13_robustness/
#   │   │   ├── partA/
#   │   │   ├── partB/
#   │   │   ├── partC/
#   │   │   ├── partD/
#   │   │   └── partE/
#   │   ├── 14_comparison/         vs naive benchmarks
#   │   └── explore/
#   │
#   └── Models/
#       ├── AutoGluon/             ag_fund/, ag_raw/, ... (one per model)
#       └── VAE/
#           ├── fund/
#           └── raw/
#
#==============================================================================#

suppressPackageStartupMessages(library(lubridate))

#==============================================================================#
# 1. Reproducibility
#==============================================================================#

SEED <- 123L
set.seed(SEED)

#==============================================================================#
# 1B. Response track switch
#
#   The pipeline supports two distinct response variables that share the
#   same upstream data (universe, prices, fundamentals, macro) but differ
#   in their label definition. Set RESPONSE_TRACK to choose which target
#   downstream consumers (06_Merge, 06B, 08+) align to. Outputs from 05A and
#   05B always go to their own fixed track folders; outputs from 06_Merge,
#   06B, and downstream go to the folder of the active track.
#
#     "dynamic_csi"   : Tewari-style C/M/T event-entry target (TCL)
#                       Event-contingent risk filter; firms re-enter the
#                       investable universe once the state clears.
#                       Cross-sectional avoidance, NVIDIA-friendly.
#
#     "permanent_csi" : Hybrid permanent-capital-loss target (PCL)
#                       Tier (i): adverse CRSP delisting within W years
#                                 of the CSI trigger date.
#                       Tier (ii): no recovery above the CSI M-ceiling
#                                  within PCL_FORWARD_YEARS of trigger.
#                       Absorbing exclusion at index-construction time.
#
#   To produce both tracks: flip RESPONSE_TRACK and re-run 06_Merge, 06B,
#   08_Split, and 08B. 05A and 05B do not change between runs.
#==============================================================================#

LABEL_TRACKS        <- c("dynamic_csi", "permanent_csi")
PRIMARY_LABEL_TRACK <- "dynamic_csi"
RESPONSE_TRACK      <- Sys.getenv("RESPONSE_TRACK", "dynamic_csi")

fn_env_flag <- function(name, default = TRUE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "1" else "0")
  tolower(trimws(value)) %in% c("1", "true", "t", "yes", "y", "on")
}

## Indicator-augmented temporary CSI methodology.
## TRUE keeps the original C/M/T confirmation path and adds the CRSP 572-574
## terminal-failure path. When active, model/run artifacts route to 03b_Output
## by default so the legacy 03_Output tree is not overwritten.
CSI_USE_TERMINAL_FAILURE_INDICATORS <-
  fn_env_flag("CSI_USE_TERMINAL_FAILURE_INDICATORS", default = TRUE)

stopifnot(
  "RESPONSE_TRACK must be one of LABEL_TRACKS" =
    RESPONSE_TRACK %in% LABEL_TRACKS
)

#==============================================================================#
# 2. Root Directories
#
#   AgonyAndExcstasy layout:
#     01_Code/                      pipeline scripts (this file lives in
#                                   01_Code/pipeline/)
#     02_Data_Input/                external inputs + derived pipeline data
#       ├── 01_CRSP/   {Necessary, Additional}/
#       ├── 02_Compustat/ {Necessary, Additional}/
#       ├── 03_FRED/ {Necessary, Additional}/
#       ├── 04_Index_Replication/ {Necessary, Additional}/
#       └── 05_PipelineResults/Necessary/{temporary_csi, permanent_csi}/
#                                            {Labels, Features, Panel}/
#     03_Data_Output/               results, organised by analysis category
#       ├── 1_Descriptive_Statistics/
#       ├── 2_Robustness_Checks/
#       ├── 3_Modelling_Results/
#       └── 4_IndexConstruction_Results/
#
#   The dual 03_Output / 03b_Output split is GONE — single output tree.
#   The CSI_USE_TERMINAL_FAILURE_INDICATORS flag still controls the label
#   methodology but no longer changes the output directory.
#==============================================================================#

DIR_ROOT        <- Sys.getenv("MT_ROOT", unset = here::here())
DIR_CODE        <- file.path(DIR_ROOT, "01_Code")
DIR_DATA_INPUT  <- file.path(DIR_ROOT, "02_Data_Input")
DIR_DATA_OUTPUT <- file.path(DIR_ROOT, "03_Data_Output")

## Track-folder mapping:
##   Code uses RESPONSE_TRACK = "dynamic_csi" or "permanent_csi".
##   On-disk folders use     "temporary_csi" or "permanent_csi".
fn_track_folder <- function(rt = RESPONSE_TRACK) {
  if (rt == "dynamic_csi") "temporary_csi" else rt
}
TRACK_FOLDER <- fn_track_folder(RESPONSE_TRACK)

## Back-compat alias: some scripts still reference DIR_OUTPUT
DIR_OUTPUT <- DIR_DATA_OUTPUT

#==============================================================================#
# 3. Input-Data Directories (02_Data_Input/)
#==============================================================================#

## Per-vendor Necessary / Additional split
DIR_CRSP_NEC   <- file.path(DIR_DATA_INPUT, "01_CRSP",              "Necessary")
DIR_CRSP_ADD   <- file.path(DIR_DATA_INPUT, "01_CRSP",              "Additional")
DIR_COMP_NEC   <- file.path(DIR_DATA_INPUT, "02_Compustat",         "Necessary")
DIR_COMP_ADD   <- file.path(DIR_DATA_INPUT, "02_Compustat",         "Additional")
DIR_FRED_NEC   <- file.path(DIR_DATA_INPUT, "03_FRED",              "Necessary")
DIR_FRED_ADD   <- file.path(DIR_DATA_INPUT, "03_FRED",              "Additional")
DIR_IDXREP_NEC <- file.path(DIR_DATA_INPUT, "04_Index_Replication", "Necessary")
DIR_IDXREP_ADD <- file.path(DIR_DATA_INPUT, "04_Index_Replication", "Additional")

## Back-compat aliases for legacy DIR_CRSP_RAW / DIR_CRSP_PROC etc.
## Most "raw" files now live under Additional, processed under Necessary.
## Two exceptions handled at the PATH_* level: delisting_raw.rds lives in
## Necessary because scripts 05+ read it directly; prices_weekly.rds lives in
## Additional because no script 05+ actually reads it (verified by grep).
DIR_CRSP_RAW  <- DIR_CRSP_ADD
DIR_CRSP_PROC <- DIR_CRSP_NEC
DIR_COMP_RAW  <- DIR_COMP_ADD
DIR_COMP_PROC <- DIR_COMP_NEC
DIR_MACRO     <- DIR_FRED_NEC   ## processed macro is the canonical macro dir

## Pipeline-results (derived data, written by 05A/05B/06/06B/08/08B)
PR_NEC             <- file.path(DIR_DATA_INPUT, "05_PipelineResults", "Necessary")
DIR_LABELS_DYN     <- file.path(PR_NEC, "temporary_csi", "Labels")
DIR_LABELS_PERM    <- file.path(PR_NEC, "permanent_csi", "Labels")
DIR_FEATURES_DYN   <- file.path(PR_NEC, "temporary_csi", "Features")
DIR_FEATURES_PERM  <- file.path(PR_NEC, "permanent_csi", "Features")
DIR_PANEL_DYN      <- file.path(PR_NEC, "temporary_csi", "Panel")
DIR_PANEL_PERM     <- file.path(PR_NEC, "permanent_csi", "Panel")

DIR_LABELS_TRACK   <- file.path(PR_NEC, TRACK_FOLDER, "Labels")
DIR_FEATURES_TRACK <- file.path(PR_NEC, TRACK_FOLDER, "Features")
DIR_PANEL_TRACK    <- file.path(PR_NEC, TRACK_FOLDER, "Panel")

## Back-compat aliases (parent of track dirs)
DIR_LABELS   <- PR_NEC
DIR_FEATURES <- PR_NEC
DIR_PANEL    <- PR_NEC

stopifnot(
  "Dynamic/permanent label directories must be separate" =
    DIR_LABELS_DYN != DIR_LABELS_PERM,
  "Dynamic/permanent feature directories must be separate" =
    DIR_FEATURES_DYN != DIR_FEATURES_PERM,
  "Dynamic/permanent panel directories must be separate" =
    DIR_PANEL_DYN != DIR_PANEL_PERM
)

#==============================================================================#
# 4. Output Directories — 03_Data_Output/
#==============================================================================#

## Top-level analysis categories
DIR_DESCRIPTIVE  <- file.path(DIR_DATA_OUTPUT, "1_Descriptive_Statistics")
DIR_ROBUSTNESS   <- file.path(DIR_DATA_OUTPUT, "2_Robustness_Checks")
DIR_MODELLING    <- file.path(DIR_DATA_OUTPUT, "3_Modelling_Results")
DIR_INDEX        <- file.path(DIR_DATA_OUTPUT, "4_IndexConstruction_Results")

## Modelling sub-tree (track-aware)
DIR_MODELLING_NEC          <- file.path(DIR_MODELLING, "Necessary")
DIR_MODELLING_TRACK        <- file.path(DIR_MODELLING_NEC, TRACK_FOLDER)
DIR_TABLES_AUTOGLUON_TRACK <- file.path(DIR_MODELLING_TRACK, "AutoGluon")
DIR_TABLES_XGB_TRACK       <- file.path(DIR_MODELLING_TRACK, "XGBoost")
DIR_TABLES_VAE_TRACK       <- file.path(DIR_MODELLING_TRACK, "VAE")
DIR_TABLES_EVAL_TRACK      <- file.path(DIR_MODELLING_TRACK, "evaluation")
DIR_FIGURES_MODEL_TRACK    <- file.path(DIR_MODELLING_TRACK, "figures")
DIR_MODELLING_SHARED       <- file.path(DIR_MODELLING_NEC, "shared")

## Per-track aliases (some scripts reference these by name)
DIR_TABLES_DYN  <- file.path(DIR_MODELLING_NEC, "temporary_csi")
DIR_TABLES_PERM <- file.path(DIR_MODELLING_NEC, "permanent_csi")
DIR_TABLES_TRACK <- DIR_MODELLING_TRACK
DIR_MODELS_DYN  <- file.path(DIR_TABLES_DYN, "VAE")
DIR_MODELS_PERM <- file.path(DIR_TABLES_PERM, "VAE")
DIR_MODELS_TRACK <- DIR_TABLES_VAE_TRACK
DIR_MODELS <- DIR_MODELS_TRACK  ## back-compat alias

DIR_TABLES_AUTOGLUON     <- DIR_TABLES_AUTOGLUON_TRACK  ## back-compat alias
DIR_TABLES_AUTOGLUON_DYN <- file.path(DIR_TABLES_DYN, "AutoGluon")
DIR_TABLES_AUTOGLUON_PERM <- file.path(DIR_TABLES_PERM, "AutoGluon")

## Robustness sub-tree (track-aware)
DIR_ROB_NEC         <- file.path(DIR_ROBUSTNESS, "Necessary")
DIR_ROB_TRACK       <- file.path(DIR_ROB_NEC, TRACK_FOLDER)
DIR_ROB_GRID_TRACK  <- file.path(DIR_ROB_TRACK, "csi_parameter_grid_results")
DIR_ROB_FIGS_TRACK  <- file.path(DIR_ROB_TRACK, "figures")
DIR_ROB_SHARED      <- file.path(DIR_ROB_NEC, "shared")

## Index-construction sub-tree (track-aware)
DIR_INDEX_NEC          <- file.path(DIR_INDEX, "Necessary")
DIR_INDEX_TRACK        <- file.path(DIR_INDEX_NEC, TRACK_FOLDER)
DIR_TABLES_INDEX_TRACK <- file.path(DIR_INDEX_TRACK, "11_index")
DIR_INDEX_FIGS_TRACK   <- file.path(DIR_INDEX_TRACK, "figures")
DIR_INDEX_SHARED       <- file.path(DIR_INDEX_NEC, "shared")

## Descriptive sub-tree (track-aware)
DIR_DESC_NEC        <- file.path(DIR_DESCRIPTIVE, "Necessary")
DIR_DESC_TRACK      <- file.path(DIR_DESC_NEC, TRACK_FOLDER)
DIR_DESC_SHARED     <- file.path(DIR_DESC_NEC, "shared")

## Back-compat alias: DIR_TABLES used to be the VastAI Tables tree.
## Now point it at the modelling shared dir (where robust_*.rds etc. land).
DIR_TABLES <- DIR_MODELLING_SHARED
## Figures default: model-track figures (most R scripts wrote here);
## fn_setup_figure_dirs() returns the full track-aware tree below.
DIR_FIGURES <- DIR_FIGURES_MODEL_TRACK

stopifnot(
  "Dynamic/permanent table directories must be separate" =
    DIR_TABLES_DYN != DIR_TABLES_PERM,
  "Dynamic/permanent model directories must be separate" =
    DIR_MODELS_DYN != DIR_MODELS_PERM,
  "Dynamic/permanent AutoGluon table directories must be separate" =
    DIR_TABLES_AUTOGLUON_DYN != DIR_TABLES_AUTOGLUON_PERM
)

## ── AutoGluon prediction + leaderboard output — one directory per model ─────
## Current pipeline runs 4 model variants per track:
##   ag_fund            — fund features only
##   ag_raw             — full features (price + fundamentals + macro)
##   ag_latent_raw      — VAE latent space of raw features
##   ag_raw_plus_latent — raw + VAE latent concatenated
##
## The legacy 12-model setup (M1–M4, B1–B4, S1–S4 with bucket/structural tracks)
## is preserved as Additional/legacy_12_model_runs/ in 03_Data_Output/. The
## DIR_TABLES_M*/B*/S* aliases below remain so legacy scripts still resolve.

DIR_TABLES_AG_FUND            <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_fund")
DIR_TABLES_AG_RAW             <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_raw")
DIR_TABLES_AG_LATENT_RAW      <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_latent_raw")
DIR_TABLES_AG_RAW_PLUS_LATENT <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_raw_plus_latent")

## Legacy 12-model aliases (point at the same active dirs where they map)
DIR_TABLES_M1 <- DIR_TABLES_AG_FUND          ## CSI, fund features
DIR_TABLES_M2 <- file.path(DIR_TABLES_AUTOGLUON_TRACK, "ag_latent_fund")  ## not currently produced
DIR_TABLES_M3 <- DIR_TABLES_AG_RAW           ## CSI, raw features
DIR_TABLES_M4 <- DIR_TABLES_AG_LATENT_RAW    ## CSI, raw + VAE latent

## Legacy bucket/structural model dirs — no active production; reads should go
## to 03_Data_Output/3_Modelling_Results/Additional/legacy_12_model_runs/.
LEGACY_AG_DIR <- file.path(DIR_MODELLING, "Additional", "legacy_12_model_runs")
DIR_TABLES_B1 <- file.path(LEGACY_AG_DIR, "B1_bucket")
DIR_TABLES_B2 <- file.path(LEGACY_AG_DIR, "B2_bucket_latent_fund")
DIR_TABLES_B3 <- file.path(LEGACY_AG_DIR, "B3_bucket_raw")
DIR_TABLES_B4 <- file.path(LEGACY_AG_DIR, "B4_bucket_latent_raw")
DIR_TABLES_S1 <- file.path(LEGACY_AG_DIR, "S1_structural")
DIR_TABLES_S2 <- file.path(LEGACY_AG_DIR, "S2_structural_latent_fund")
DIR_TABLES_S3 <- file.path(LEGACY_AG_DIR, "S3_structural_raw")
DIR_TABLES_S4 <- file.path(LEGACY_AG_DIR, "S4_structural_latent_raw")

## Lookup list — index by model key for programmatic access
## Usage: DIR_TABLES_MODEL[["ag_fund"]]  or DIR_TABLES_MODEL[[MODEL_KEY]]
DIR_TABLES_MODEL <- list(
  ## Active (4 model variants per track)
  ag_fund            = DIR_TABLES_AG_FUND,
  ag_raw             = DIR_TABLES_AG_RAW,
  ag_latent_raw      = DIR_TABLES_AG_LATENT_RAW,
  ag_raw_plus_latent = DIR_TABLES_AG_RAW_PLUS_LATENT,
  ## Legacy aliases (kept for back-compat)
  m1 = DIR_TABLES_M1, m2 = DIR_TABLES_M2,
  m3 = DIR_TABLES_M3, m4 = DIR_TABLES_M4,
  b1 = DIR_TABLES_B1, b2 = DIR_TABLES_B2,
  b3 = DIR_TABLES_B3, b4 = DIR_TABLES_B4,
  s1 = DIR_TABLES_S1, s2 = DIR_TABLES_S2,
  s3 = DIR_TABLES_S3, s4 = DIR_TABLES_S4
)

#==============================================================================#
# 5. Create All Directories
#==============================================================================#

.dirs_to_create <- c(
  ## Input data (Necessary + Additional)
  DIR_CRSP_NEC, DIR_CRSP_ADD,
  DIR_COMP_NEC, DIR_COMP_ADD,
  DIR_FRED_NEC, DIR_FRED_ADD,
  DIR_IDXREP_NEC, DIR_IDXREP_ADD,
  ## Pipeline results (BOTH tracks always created so 05A/05B can write either)
  PR_NEC,
  DIR_LABELS_DYN,    DIR_LABELS_PERM,
  DIR_FEATURES_DYN,  DIR_FEATURES_PERM,
  DIR_PANEL_DYN,     DIR_PANEL_PERM,
  ## Output categories
  DIR_DESCRIPTIVE, DIR_ROBUSTNESS, DIR_MODELLING, DIR_INDEX,
  DIR_DESC_NEC, DIR_DESC_TRACK, DIR_DESC_SHARED,
  DIR_ROB_NEC, DIR_ROB_TRACK, DIR_ROB_GRID_TRACK, DIR_ROB_FIGS_TRACK, DIR_ROB_SHARED,
  DIR_MODELLING_NEC, DIR_MODELLING_TRACK, DIR_MODELLING_SHARED,
  DIR_TABLES_AUTOGLUON_TRACK, DIR_TABLES_XGB_TRACK, DIR_TABLES_VAE_TRACK,
  DIR_TABLES_EVAL_TRACK, DIR_FIGURES_MODEL_TRACK,
  DIR_INDEX_NEC, DIR_INDEX_TRACK, DIR_TABLES_INDEX_TRACK,
  DIR_INDEX_FIGS_TRACK, DIR_INDEX_SHARED,
  ## AutoGluon prediction dirs (4 active model variants)
  DIR_TABLES_AG_FUND, DIR_TABLES_AG_RAW,
  DIR_TABLES_AG_LATENT_RAW, DIR_TABLES_AG_RAW_PLUS_LATENT
)
invisible(lapply(.dirs_to_create, dir.create,
                 showWarnings = FALSE, recursive = TRUE))
rm(.dirs_to_create)

#==============================================================================#
# 6. Figure Directory Setup
#==============================================================================#
#
# fn_setup_figure_dirs() creates the full figure subdirectory tree and returns
# a named list of paths for use in ggsave() calls throughout the pipeline.
#
# LAYOUT:
#
#   Figures/
#   ├── 01_universe/
#   ├── 02_prices/
#   ├── 03_fundamentals/
#   ├── 04_macro/
#   ├── 05_labels/
#   │   ├── csi/
#   │   ├── bucket/
#   │   └── structural/
#   ├── 06_features/
#   │
#   ├── 09_models/
#   │   ├── comparison/          all-model comparison plots (AUC/AP table, PR curves)
#   │   ├── csi/                 Track 1 summary
#   │   │   ├── m1/              M1 individual model figures
#   │   │   ├── m2/
#   │   │   ├── m3/
#   │   │   └── m4/
#   │   ├── bucket/              Track 2 summary
#   │   │   ├── b1/
#   │   │   ├── b2/
#   │   │   ├── b3/
#   │   │   └── b4/
#   │   └── structural/          Track 3 summary
#   │       ├── s1/
#   │       ├── s2/
#   │       ├── s3/
#   │       └── s4/
#   │
#   ├── 11_index/
#   │   ├── general/             benchmark vs all strategies, summary tables
#   │   ├── csi_track/           CSI-model index strategies (S1–S4 type)
#   │   ├── bucket_track/        bucket-model index strategies
#   │   ├── structural_track/    structural-model index strategies
#   │   └── concentrated/        C1/C2/C3 concentrated portfolios
#   │
#   ├── 12_evaluation/           exclusion diagnostics, sector, TE, turnover
#   ├── 13_robustness/
#   │   ├── partA/ … partE/
#   ├── 14_comparison/           vs naive benchmarks (low-vol, quality)
#   └── explore/
#
# USAGE:
#   FIGS <- fn_setup_figure_dirs()
#   ggsave(file.path(FIGS$m1,           "pr_curve.png"),         ...)
#   ggsave(file.path(FIGS$model_compare,"auc_ap_table.png"),     ...)
#   ggsave(file.path(FIGS$index_general,"cumulative_returns.png"),...)
#   ggsave(file.path(FIGS$index_conc,   "c1_vs_benchmark.png"),  ...)
#   ggsave(file.path(FIGS$rob_e,        "conc_oos_returns.png"), ...)
#
#==============================================================================#

fn_setup_figure_dirs <- function(base_dir = DIR_FIGURES) {
  ## NOTE: `base_dir` is kept as the function signature for back-compat but
  ## is IGNORED. Figure paths route to the analysis-category sub-trees in
  ## 03_Data_Output/ via the DIR_* constants computed above.
  ##
  ## Mapping from old base_dir/{XX_topic}/ → new track-aware homes:
  ##
  ##   01_universe, 02_prices, 03_fundamentals, 04_macro
  ##                       → 1_Descriptive_Statistics/Necessary/shared/
  ##   05_labels/{track}    → 1_Descriptive_Statistics/Necessary/{track}/
  ##                          (legacy {csi,bucket,structural} subdirs go to shared/)
  ##   06_features          → 1_Descriptive_Statistics/Necessary/shared/
  ##   09_models/{track}/   → 3_Modelling_Results/Necessary/{track}/figures/
  ##   11_index/            → 4_IndexConstruction_Results/Necessary/{...}/figures/
  ##   12_evaluation        → 2_Robustness_Checks/Necessary/{track}/figures/12_evaluation/
  ##   13_robustness/       → 2_Robustness_Checks/Necessary/{track}/figures/13_robustness/
  ##   14_comparison        → 4_IndexConstruction_Results/Necessary/shared/figures/14_comparison/
  ##   explore              → 3_Modelling_Results/Necessary/{track}/figures/explore/

  desc_shared   <- DIR_DESC_SHARED
  desc_track    <- DIR_DESC_TRACK
  rob_figs      <- DIR_ROB_FIGS_TRACK
  model_figs    <- DIR_FIGURES_MODEL_TRACK
  index_figs    <- DIR_INDEX_FIGS_TRACK
  index_shared  <- file.path(DIR_INDEX_SHARED, "general_figures")

  dirs <- c(
    ## Descriptive (shared across tracks)
    file.path(desc_shared, "01_universe"),
    file.path(desc_shared, "02_prices"),
    file.path(desc_shared, "03_fundamentals"),
    file.path(desc_shared, "04_macro"),
    file.path(desc_shared, "05_labels"),
    file.path(desc_shared, "06_features"),

    ## Descriptive (track-specific)
    file.path(desc_track, "05_labels"),
    file.path(desc_track, "06_features"),

    ## Models (track-specific, under 3_Modelling_Results/.../figures/)
    file.path(model_figs, "comparison"),
    file.path(model_figs, "csi"),
    file.path(model_figs, "csi", "m1"),
    file.path(model_figs, "csi", "m2"),
    file.path(model_figs, "csi", "m3"),
    file.path(model_figs, "csi", "m4"),
    file.path(model_figs, "bucket"),
    file.path(model_figs, "bucket", "b1"),
    file.path(model_figs, "bucket", "b2"),
    file.path(model_figs, "bucket", "b3"),
    file.path(model_figs, "bucket", "b4"),
    file.path(model_figs, "structural"),
    file.path(model_figs, "structural", "s1"),
    file.path(model_figs, "structural", "s2"),
    file.path(model_figs, "structural", "s3"),
    file.path(model_figs, "structural", "s4"),
    file.path(model_figs, "08_autoencoder"),
    file.path(model_figs, "explore"),

    ## Index construction (track-specific)
    file.path(index_figs, "general"),
    file.path(index_figs, "concentrated"),

    ## Index construction (shared)
    file.path(index_shared, "general"),
    file.path(index_shared, "csi_track"),
    file.path(index_shared, "bucket_track"),
    file.path(index_shared, "structural_track"),
    file.path(index_shared, "concentrated"),

    ## Robustness (track-specific)
    file.path(rob_figs, "12_evaluation"),
    file.path(rob_figs, "13_robustness", "partA"),
    file.path(rob_figs, "13_robustness", "partB"),
    file.path(rob_figs, "13_robustness", "partC"),
    file.path(rob_figs, "13_robustness", "partD"),
    file.path(rob_figs, "13_robustness", "partE"),
    file.path(rob_figs, "13_robustness", "partF"),
    file.path(rob_figs, "13_robustness", "partG"),
    file.path(rob_figs, "13_robustness", "csi_validity"),

    ## Comparison vs benchmarks
    file.path(DIR_INDEX_SHARED, "14_comparison")
  )

  created <- 0L
  for (d in dirs) {
    if (!dir.exists(d)) {
      dir.create(d, recursive = TRUE, showWarnings = FALSE)
      created <- created + 1L
    }
  }
  if (created > 0L)
    cat(sprintf("  [figures] %d new subdirectories created under 03_Data_Output\n",
                created))

  invisible(list(
    ## Data pipeline (descriptive shared)
    universe     = file.path(desc_shared, "01_universe"),
    prices       = file.path(desc_shared, "02_prices"),
    fundamentals = file.path(desc_shared, "03_fundamentals"),
    macro        = file.path(desc_shared, "04_macro"),

    ## Labels — track-aware
    labels          = file.path(desc_shared, "05_labels"),
    dynamic_labels  = file.path(DIR_DESC_NEC, "temporary_csi", "05_labels"),
    permanent_labels= file.path(DIR_DESC_NEC, "permanent_csi", "05_labels"),
    track_labels    = file.path(desc_track,   "05_labels"),
    ## Legacy aliases (route to shared 05_labels)
    csi_labels    = file.path(desc_shared, "05_labels"),
    bucket_labels = file.path(desc_shared, "05_labels"),
    struct_labels = file.path(desc_shared, "05_labels"),

    ## Features — track-aware
    features        = file.path(desc_shared, "06_features"),
    track_features  = file.path(desc_track,  "06_features"),

    ## Models — cross-track comparison
    model_compare = file.path(model_figs, "comparison"),

    ## Models — Track 1: CSI
    csi_track    = file.path(model_figs, "csi"),
    m1           = file.path(model_figs, "csi", "m1"),
    m2           = file.path(model_figs, "csi", "m2"),
    m3           = file.path(model_figs, "csi", "m3"),
    m4           = file.path(model_figs, "csi", "m4"),

    ## Models — Track 2: Bucket
    bucket_track = file.path(model_figs, "bucket"),
    b1           = file.path(model_figs, "bucket", "b1"),
    b2           = file.path(model_figs, "bucket", "b2"),
    b3           = file.path(model_figs, "bucket", "b3"),
    b4           = file.path(model_figs, "bucket", "b4"),

    ## Models — Track 3: Structural
    struct_track = file.path(model_figs, "structural"),
    s1           = file.path(model_figs, "structural", "s1"),
    s2           = file.path(model_figs, "structural", "s2"),
    s3           = file.path(model_figs, "structural", "s3"),
    s4           = file.path(model_figs, "structural", "s4"),

    ## Lookup list for programmatic access: FIGS$models[["m1"]]
    models = list(
      m1 = file.path(model_figs, "csi",        "m1"),
      m2 = file.path(model_figs, "csi",        "m2"),
      m3 = file.path(model_figs, "csi",        "m3"),
      m4 = file.path(model_figs, "csi",        "m4"),
      b1 = file.path(model_figs, "bucket",     "b1"),
      b2 = file.path(model_figs, "bucket",     "b2"),
      b3 = file.path(model_figs, "bucket",     "b3"),
      b4 = file.path(model_figs, "bucket",     "b4"),
      s1 = file.path(model_figs, "structural", "s1"),
      s2 = file.path(model_figs, "structural", "s2"),
      s3 = file.path(model_figs, "structural", "s3"),
      s4 = file.path(model_figs, "structural", "s4")
    ),

    ## Index construction (track-aware + shared)
    index_general  = file.path(index_shared, "general"),  ## cross-track summary
    index_track    = file.path(index_figs,   "general"),  ## current-track index plots
    index_csi      = file.path(index_shared, "csi_track"),
    index_bucket   = file.path(index_shared, "bucket_track"),
    index_struct   = file.path(index_shared, "structural_track"),
    index_conc     = file.path(index_shared, "concentrated"),

    ## Diagnostics and robustness (track-aware)
    evaluation   = file.path(rob_figs, "12_evaluation"),
    robustness   = file.path(rob_figs, "13_robustness"),
    rob_a        = file.path(rob_figs, "13_robustness", "partA"),
    rob_b        = file.path(rob_figs, "13_robustness", "partB"),
    rob_c        = file.path(rob_figs, "13_robustness", "partC"),
    rob_d        = file.path(rob_figs, "13_robustness", "partD"),
    rob_e        = file.path(rob_figs, "13_robustness", "partE"),

    ## Comparison vs benchmarks (shared)
    comparison   = file.path(DIR_INDEX_SHARED, "14_comparison"),

    ## Exploration / ad hoc
    explore      = file.path(model_figs, "explore")
  ))
}

#==============================================================================#
# 7. File Paths — Data Pipeline
#==============================================================================#

## 01_Universe.R
## universe_raw → Additional (intermediate); universe → Necessary (read by 05+)
PATH_UNIVERSE_RAW <- file.path(DIR_CRSP_ADD, "universe_raw.rds")
PATH_UNIVERSE     <- file.path(DIR_CRSP_NEC, "universe.rds")

## 02_Prices.R
## *_raw, weekly → Additional; monthly → Necessary; delisting_raw → Necessary
## (delisting_raw is consumed directly by 05A/05B/13b — not just an intermediate)
PATH_PRICES_DAILY_RAW   <- file.path(DIR_CRSP_ADD, "prices_daily_raw.rds")
PATH_PRICES_MONTHLY_RAW <- file.path(DIR_CRSP_ADD, "prices_monthly_raw.rds")
PATH_PRICES_WEEKLY      <- file.path(DIR_CRSP_ADD, "prices_weekly.rds")
PATH_PRICES_MONTHLY     <- file.path(DIR_CRSP_NEC, "prices_monthly.rds")
PATH_DELISTING          <- file.path(DIR_CRSP_NEC, "delisting_raw.rds")

## 03_Fundamentals.R
## fundamentals_raw, ccm_link_raw → Additional (intermediates within 03)
## fundamentals → Necessary (consumed by 06_Merge and 11B_Quality)
PATH_FUNDAMENTALS_RAW <- file.path(DIR_COMP_ADD, "fundamentals_raw.rds")
PATH_FUNDAMENTALS     <- file.path(DIR_COMP_NEC, "fundamentals.rds")
PATH_CCM_LINK         <- file.path(DIR_COMP_ADD, "ccm_link_raw.rds")

## 04_Macro.R
PATH_MACRO_RAW     <- file.path(DIR_FRED_ADD, "macro_raw.rds")
PATH_MACRO_MONTHLY <- file.path(DIR_FRED_NEC, "macro_monthly.rds")

## 05A_Dynamic_CSI_Label.R
## Monthly event/state outputs for the Tewari-style C/M/T CSI methodology.
## Always written to DIR_LABELS_DYN regardless of RESPONSE_TRACK.
PATH_CSI_EVENTS_BASE    <- file.path(DIR_LABELS_DYN, "csi_events_base.rds")
PATH_CSI_EVENTS_GRID    <- file.path(DIR_LABELS_DYN, "csi_events_all_grid.rds")
PATH_CSI_STATE_MONTHLY  <- file.path(DIR_LABELS_DYN, "csi_state_monthly_base.rds")
PATH_CSI_DIAG           <- file.path(DIR_LABELS_DYN, "csi_event_diagnostics.rds")
## Descriptive figure: belongs under 1_Descriptive_Statistics, not Modelling.
## Uses fixed "temporary_csi" folder name (matches on-disk layout for dynamic track).
PATH_FIGURE_CSI         <- file.path(DIR_DESC_NEC, "temporary_csi",
                                     "csi_events_per_year.png")

## Compatibility aliases retained for legacy scripts.
PATH_LABELS_BASE        <- file.path(DIR_LABELS_DYN, "labels_base.rds")
PATH_LABELS_GRID        <- file.path(DIR_LABELS_DYN, "labels_all_grid.rds")
PATH_LABELS_DIAG        <- file.path(DIR_LABELS_DYN, "csi_diagnostics.rds")

## 05B_Permanent_Capital_Loss.R
## Always written to DIR_LABELS_PERM regardless of RESPONSE_TRACK.
PATH_PCL_EVENTS_BASE    <- file.path(DIR_LABELS_PERM, "permanent_loss_events_base.rds")
PATH_PCL_EVENTS_GRID    <- file.path(DIR_LABELS_PERM, "permanent_loss_events_all_grid.rds")
PATH_PCL_DIAG           <- file.path(DIR_LABELS_PERM, "permanent_loss_diagnostics.rds")
## Descriptive figure: belongs under 1_Descriptive_Statistics, not Modelling.
PATH_FIGURE_PCL         <- file.path(DIR_DESC_NEC, "permanent_csi",
                                     "pcl_events_per_year.png")

## Active-track annual labels prepared by 06_Merge.R
## Per-track exports always go to their own folder (so both can co-exist).
## PATH_LABELS_MODEL_READY routes to the ACTIVE track via DIR_LABELS_TRACK.
PATH_LABELS_DYNAMIC     <- file.path(DIR_LABELS_DYN,   "labels_dynamic_csi.rds")
PATH_LABELS_PERMANENT   <- file.path(DIR_LABELS_PERM,  "labels_permanent_loss.rds")
PATH_LABELS_MODEL_READY <- file.path(DIR_LABELS_TRACK, "labels_model_ready.rds")

## Legacy experimental bucket/structural outputs. These are no longer the main
## thesis target after the dynamic/permanent split, but paths are kept so old
## analysis scripts can still be run if needed. Now under Additional/legacy.
DIR_LABELS_LEGACY_FLAT  <- file.path(DIR_DATA_INPUT, "05_PipelineResults",
                                     "Additional", "legacy_flat_pre_track_split",
                                     "Labels")
PATH_LABELS_BUCKET      <- file.path(DIR_LABELS_LEGACY_FLAT, "labels_bucket.rds")
PATH_LABELS_STRUCTURAL  <- file.path(DIR_LABELS_LEGACY_FLAT, "labels_structural.rds")

## 06_Merge.R
## Same filename for both response tracks, but written under separate folders:
##   02_Data/Panel/dynamic_csi/panel_raw.rds
##   02_Data/Panel/permanent_csi/panel_raw.rds
PATH_PANEL_RAW <- file.path(DIR_PANEL_TRACK, "panel_raw.rds")

## 06B_Feature_Eng.R
## Routed to the ACTIVE track folder. Each track gets its own y-aligned
## features_raw and features_fund. Re-run 06B after toggling RESPONSE_TRACK
## to populate the other track's folder.
PATH_FEATURES_RAW  <- file.path(DIR_FEATURES_TRACK, "features_raw.rds")
PATH_FEATURES_FUND <- file.path(DIR_FEATURES_TRACK, "features_fund.rds")

## 08B_Autoencoder.py (outputs — parquets read by 09C)
PATH_FEATURES_LATENT_FUND <- file.path(DIR_FEATURES_TRACK, "features_latent_fund.parquet")
PATH_FEATURES_LATENT_RAW  <- file.path(DIR_FEATURES_TRACK, "features_latent_raw.parquet")
PATH_FEATURES_RAW_PLUS_LATENT <- file.path(DIR_FEATURES_TRACK,
                                            "features_raw_plus_latent.parquet")
PATH_FEATURES_LATENT      <- PATH_FEATURES_LATENT_FUND   ## default alias

## 07_Feature_Sel.R
PATH_FEATURES_SELECTED <- file.path(DIR_FEATURES_TRACK, "features_selected.rds")

## 08_Split.R
PATH_SPLITS <- file.path(DIR_FEATURES_TRACK, "splits.rds")

#==============================================================================#
# 8. File Paths — Output
#==============================================================================#

## 10_Evaluate.R — track-aware evaluation outputs
PATH_EVAL_RESULTS <- file.path(DIR_TABLES_EVAL_TRACK, "evaluation_results.rds")

## 11_Results.R — track-aware index construction outputs
## (DIR_TABLES_INDEX_TRACK already defined in Section 4 — re-statement removed)
PATH_INDEX_WEIGHTS           <- file.path(DIR_TABLES_INDEX_TRACK, "index_weights.rds")
PATH_INDEX_RETURNS           <- file.path(DIR_TABLES_INDEX_TRACK, "index_returns.rds")
PATH_INDEX_PERF              <- file.path(DIR_TABLES_INDEX_TRACK, "index_performance.rds")
PATH_INDEX_EXCLUSION_SUMMARY <- file.path(DIR_TABLES_INDEX_TRACK, "index_exclusion_summary.rds")
PATH_INDEX_OPT_THRESHOLDS    <- file.path(DIR_TABLES_INDEX_TRACK, "index_opt_thresholds.rds")

## 12_Evaluation.R — index diagnostics (shared, benchmark summaries)
PATH_INDEX_EXCLUSION <- file.path(DIR_INDEX_SHARED, "benchmark_summaries",
                                  "index_csi_avoidance.rds")

## 13_Robustness.R — outputs into 2_Robustness_Checks/Necessary/shared/
PATH_ROBUST_GRID   <- file.path(DIR_ROB_SHARED, "robust_grid_performance.rds")
PATH_ROBUST_TREE   <- file.path(DIR_ROB_SHARED, "robust_recovery_classifier.rds")
PATH_ROBUST_INDEX  <- file.path(DIR_ROB_SHARED, "robust_index_returns.rds")
PATH_ROBUST_TIERED <- file.path(DIR_ROB_SHARED, "robust_tiered_results.rds")
PATH_ROBUST_CONC   <- file.path(DIR_ROB_SHARED, "robust_conc_returns.rds")
PATH_ROBUST_CONC_P <- file.path(DIR_ROB_SHARED, "robust_conc_performance.rds")

## 14_Comparison.R — comparison vs naive benchmarks (under index shared)
PATH_COMPARISON_RETURNS <- file.path(DIR_INDEX_SHARED, "final_strategy_summary",
                                     "comparison_returns.rds")
PATH_COMPARISON_PERF    <- file.path(DIR_INDEX_SHARED, "final_strategy_summary",
                                     "comparison_performance.rds")

#==============================================================================#
# 9. Date Range
#==============================================================================#

START_DATE <- as.Date("1993-01-01")
END_DATE   <- as.Date("2024-12-31")

#==============================================================================#
# 10. Universe Construction Parameters
#==============================================================================#

VALID_EXCHANGES     <- c("N", "A", "Q")
EXCLUDE_SECTYPES    <- c("FUND")
VALID_SHARETYPES    <- c("NS", NA)
VALID_SUBTYPES      <- c("COM", NA)
MIN_LIFETIME_YEARS  <- 5L

UNIVERSE_SIZE       <- 3000L
UNIVERSE_MIN_MKTCAP <- 100      ## $M

#==============================================================================#
# 11. CSI Label Parameters
#==============================================================================#

CSI_BASE <- list(C = -0.80, M = -0.20, T = 18L)

CSI_GRID <- expand.grid(
  C = c(-0.60, -0.80, -0.90),
  M = c( 0.00, -0.20, -0.30),
  T = c(  12L,   18L,   24L),
  stringsAsFactors = FALSE
) |>
  dplyr::arrange(C, M, T) |>
  dplyr::mutate(
    param_id = sprintf(
      "C%s_M%s_T%s",
      sub("\\.", "", formatC(abs(C), format = "f", digits = 2)),
      sub("\\.", "", formatC(abs(M), format = "f", digits = 2)),
      formatC(T, width = 3L, flag = "0")
    )
  )

CSI_RUN_GRID <- fn_env_flag("CSI_RUN_GRID", default = FALSE)

MAX_IMPLOSION_RATE <- 0.15

## Dynamic CSI terminal-failure override:
## triggers followed by CRSP bankruptcy-related delisting codes before the
## T-month confirmation date are positive temporary CSI events.
CSI_TERMINAL_FAILURE_CODES <- 572:574
CSI_POSITIVE_EVENT_STATUSES <- c("confirmed_csi")
if (CSI_USE_TERMINAL_FAILURE_INDICATORS) {
  CSI_POSITIVE_EVENT_STATUSES <- c(
    CSI_POSITIVE_EVENT_STATUSES,
    "terminal_failure_before_confirmation"
  )
}
CSI_GRID_WORKERS <- as.integer(Sys.getenv("CSI_GRID_WORKERS", "1"))
if (is.na(CSI_GRID_WORKERS) || CSI_GRID_WORKERS < 1L) {
  CSI_GRID_WORKERS <- 1L
}

#==============================================================================#
# 11B. Annual Label Alignment (06_Merge)
#==============================================================================#

## Paper-style annual alignment:
##   monthly CSI trigger in calendar year t + 1 -> annual row y_{i,t} = 1.
## Example: trigger_date = 2011-09-30 -> label_year = 2010.
LABEL_ALIGNMENT_METHOD <- "event_year_minus_1"
LABEL_EVENT_YEAR_LAG   <- 1L

#==============================================================================#
# 11C. Permanent Capital Loss (PCL) — Hybrid Definition
#
#   Layered on top of the base CSI events from 05A. A confirmed CSI event is
#   labelled PCL = 1 if EITHER tier holds; PCL = 0 if the firm recovers above
#   the CSI M-ceiling within PCL_FORWARD_MONTHS; otherwise NA (right-censored).
#
#     Tier (i)  : adverse CRSP delisting within PCL_DELISTING_WINDOW_MONTHS
#                 of trigger_date. Codes follow CHS (2008): liquidations
#                 (400-490) and dropped-for-cause (550-585).
#
#     Tier (ii) : NO recovery above wealth_trigger * (1 + M_BASE) within
#                 PCL_FORWARD_MONTHS of trigger_date. Reuses the existing
#                 late_recovery / months_to_late_recovery fields from 05A.
#
#   Reference date for both tiers: trigger_date (the official CSI flag date).
#
#   Shumway-style imputation: when an adverse delisting has dlret = NA, we
#   substitute PCL_DLRET_IMPUTE_VALUE (= -0.55, per Shumway 1997). This keeps
#   forward returns internally consistent for total-return computation.
#==============================================================================#

## Active hybrid parameters
PCL_FORWARD_YEARS             <- 5L
PCL_FORWARD_MONTHS            <- 60L
PCL_DELISTING_WINDOW_YEARS    <- 3L
PCL_DELISTING_WINDOW_MONTHS   <- 36L

## CHS (2008) standard adverse-cause codes:
##   400-490 : liquidations
##   550-585 : dropped by exchange for cause (performance, regulatory, etc.)
PCL_DELISTING_ADVERSE_CODES   <- c(400:490, 550:585)

## Shumway (1997) imputation: missing dlret on adverse delistings -> -0.55.
## Codes that trigger imputation if dlret is NA. Includes the broader 500-599
## block because performance delistings often arrive with no dlret recorded.
PCL_DLRET_IMPUTE_VALUE        <- -0.55
PCL_DLRET_IMPUTE_TRIGGER_CODES <- c(400:490, 500:599)

## Legacy placeholder constants — retained for back-compat with the archival
## 05B branch and 14c audit script. NOT used by the new hybrid 05B.
PCL_VALIDATION_MONTHS         <- 60L
PCL_MAX_TERMINAL_VS_PEAK      <- -0.80
PCL_REQUIRE_NO_LATE_RECOVERY  <- TRUE

#==============================================================================#
# 12. Bucket Label Parameters (legacy 05B / 05C)
#
#   These constants are retained for legacy bucket/structural scripts.
#   Both scripts should source config.R and use these constants directly
#   rather than hardcoding local copies.
#==============================================================================#

BUCKET_FWD_YEARS      <- 5L
BUCKET_MIN_MONTHS     <- 48L
BUCKET_LOSER_THRESH   <- -0.02   ## CAGR < -2%  → terminal loser (y=1)
BUCKET_PHOENIX_THRESH <-  0.00   ## CAGR >= 0%  → phoenix        (y=0)
BUCKET_LAST_YEAR      <- year(END_DATE) - BUCKET_FWD_YEARS   ## 2019

#==============================================================================#
# 13. Data Quality Thresholds
#==============================================================================#

MAX_CONSECUTIVE_NA <- 3L

#==============================================================================#
# 14. Feature Engineering Parameters
#==============================================================================#

WINDOW_SHORT         <- 36L    ## 3-year rolling window (months)
WINDOW_LONG          <- 60L    ## 5-year rolling window (months)
REPORTING_LAG_MONTHS <- 0L     ## Thesis setting: no accounting-release lag

ROLLING_STATS <- c(
  "mean", "min", "max", "median", "sd", "var",
  "mean_abs_diff", "median_abs_diff", "autocorr_lag1"
)

#==============================================================================#
# 15. Train / Test / OOS Split
#
#   Three-period design:
#     Train      : 1993–2015  model learning + HPO on holdout 2011–2014
#     Test       : 2016–2019  model selection + cross-model comparison
#     Live OOS   : 2020–2024  index construction ONLY (never model selection)
#
#   Boundary years (label shift artefact, CSI models only):
#     year = 2015  →  y_next = y(2016)  [test label after shift]
#     year = 2019  →  y_next = y(2020)  [OOS label after shift]
#     These rows are flagged "train_boundary"/"test_boundary" in eval_split
#     (08_Split.R). Excluded from AUC/AP metrics; predictions still generated
#     for index construction.
#
#   CV design:
#     CV_FOLDS = 4  →  4 year blocks; fold 1 always in training (no data
#                       precedes it in expanding window); folds 2–4 are
#                       the 3 usable validation folds.
#     09C_AutoGluon.py uses FOLD_BOUNDARIES (3 explicit time-anchored folds)
#     which matches the 3 usable folds from CV_FOLDS = 4.
#==============================================================================#

TRAIN_END  <- as.Date("2015-12-31")
TEST_START <- as.Date("2016-01-01")
TEST_END   <- as.Date("2019-12-31")
OOS_START  <- as.Date("2020-01-01")

TRAIN_END_YR  <- 2015L
TEST_START_YR <- 2016L
TEST_END_YR   <- 2019L
OOS_START_YR  <- 2020L

SPLIT_GAP_MONTHS <- 0L

## R-side CV (08_Split.R): 4 folds → fold 1 omitted → 3 usable validation folds
CV_FOLDS         <- 4L

## Python-side CV (09C): 3 explicit time-anchored expanding window folds
## Corresponds to the 3 usable folds from CV_FOLDS = 4 above
CV_FOLDS_PYTHON  <- 3L

CV_MIN_TRAIN_YRS <- 3L

#==============================================================================#
# 16. Modelling Parameters
#==============================================================================#

HPO_ITER        <- 50L
HPO_METRIC      <- "average_precision"
CLASS_WEIGHT    <- NULL
FPR_CONSTRAINTS <- c(0.03, 0.05)

MODELS_TO_RUN <- c(
  "logistic_regression", "random_forest",
  "xgboost", "catboost", "lightgbm"
)

AG_TIME_LIMIT_MAIN <- 3600L
AG_TIME_LIMIT_CV   <- 900L

#==============================================================================#
# 17. Portfolio Construction Parameters
#
#   EXCLUSION_RATE_CSI    : rank-based exclusion for M1–M4 (top 5% by p_csi)
#   EXCLUSION_RATE_BUCKET : rank-based exclusion for B1–B4 / S1–S4
#                           (higher rate needed — bucket positives are ~42%
#                           prevalence vs ~12% for CSI; 20% captures a
#                           meaningful tail without excessive dilution)
#   Both rates are applied annually, ranking all universe firms by p_csi
#   within each year and excluding the top X%.
#==============================================================================#

EXCLUSION_RATE_CSI    <- 0.05    ## M1–M4: top 5% flagged for exclusion
EXCLUSION_RATE_BUCKET <- 0.20    ## B1–B4 / S1–S4: top 20% flagged

PORT_CONC_SIZE_C1   <- 200L    ## C1 concentrated portfolio size
PORT_CONC_SIZE_C2   <- 100L    ## C2 concentrated portfolio size
PORT_M1_VETO_RATE   <- 0.10    ## C3 M1 veto threshold
PORT_RF_ANNUAL      <- 0.03    ## annualised risk-free rate for Sharpe

## Altman Z-score zombie threshold (from recovery classifier robustness Part B)
ZOMBIE_Z2_THRESH    <- -2.768814

#==============================================================================#
# 18. Plotting Parameters
#==============================================================================#

PLOT_WIDTH  <- 10
PLOT_HEIGHT <- 6
PLOT_DPI    <- 150

## Consistent strategy colours across all index plots
STRAT_COLOURS <- c(
  bench              = "#9E9E9E",
  ## CSI track
  s1_m1              = "#2196F3",
  s1_m3              = "#1565C0",
  ## Bucket track
  s1_b1              = "#4CAF50",
  s1_b3              = "#1B5E20",
  ## Structural track
  s1_s1              = "#9C27B0",
  s1_s3              = "#4A148C",
  ## Special strategies
  s4_zombie          = "#FF9800",
  c1_bucket          = "#E91E63",
  c1_structural      = "#880E4F",
  c2                 = "#CE93D8",
  c3                 = "#F44336",
  ## Naive benchmarks
  low_vol            = "#00BCD4",
  quality            = "#FF5722"
)

STRAT_LABELS <- c(
  bench              = "Benchmark (EW 3000)",
  s1_m1              = "M1 Excl. 5% (fund)",
  s1_m3              = "M3 Excl. 5% (raw)",
  s1_b1              = "B1 Excl. 20% (fund)",
  s1_b3              = "B3 Excl. 20% (raw)",
  s1_s1              = "S1 Excl. 20% (fund)",
  s1_s3              = "S3 Excl. 20% (raw)",
  s4_zombie          = "M1 + Zombie Filter",
  c1_bucket          = "C1: B1-Bucket Long 200",
  c1_structural      = "C1: B1-Structural Long 200",
  c2                 = "C2: B1 Long 100",
  c3                 = "C3: Structural + M1 Veto",
  low_vol            = "Low-Vol 200",
  quality            = "Quality 200 (Altman Z)"
)

#==============================================================================#
# 19. Model key → human label mapping
#
#   Used by 10_Evaluate.R and 11_Results.R when building comparison tables
#   and multi-model plots. Keys match MODEL values in 09C_AutoGluon.py.
#==============================================================================#

MODEL_LABELS <- c(
  fund                      = "M1 — Fundamentals",
  latent_fund               = "M2 — VAE (fund)",
  raw                       = "M3 — Full features",
  latent_raw                = "M4 — VAE (raw)",
  bucket                    = "B1 — Bucket (fund)",
  bucket_latent_fund        = "B2 — Bucket VAE (fund)",
  bucket_raw                = "B3 — Bucket (raw)",
  bucket_latent_raw         = "B4 — Bucket VAE (raw)",
  structural                = "S1 — Structural (fund)",
  structural_latent_fund    = "S2 — Structural VAE (fund)",
  structural_raw            = "S3 — Structural (raw)",
  structural_latent_raw     = "S4 — Structural VAE (raw)"
)

MODEL_TRACK <- c(
  fund                      = "CSI",
  latent_fund               = "CSI",
  raw                       = "CSI",
  latent_raw                = "CSI",
  bucket                    = "Bucket",
  bucket_latent_fund        = "Bucket",
  bucket_raw                = "Bucket",
  bucket_latent_raw         = "Bucket",
  structural                = "Structural",
  structural_latent_fund    = "Structural",
  structural_raw            = "Structural",
  structural_latent_raw     = "Structural"
)

#==============================================================================#
# 20. Confirm Load
#==============================================================================#

cat("[config.R] Loaded.\n")
cat(sprintf("  Root           : %s\n", DIR_ROOT))
cat(sprintf("  RESPONSE_TRACK : %s  (downstream consumers route here)\n", RESPONSE_TRACK))
cat(sprintf("  Terminal CSI   : %s  (CRSP codes %s)\n",
            if (CSI_USE_TERMINAL_FAILURE_INDICATORS) "enabled" else "disabled",
            paste(CSI_TERMINAL_FAILURE_CODES, collapse=", ")))
cat(sprintf("  Output         : %s\n", DIR_OUTPUT))
cat(sprintf("  Period         : %s to %s\n",
            format(START_DATE), format(END_DATE)))
cat(sprintf("  Split          : Train ≤%d | Test %d–%d | OOS ≥%d\n",
            TRAIN_END_YR, TEST_START_YR, TEST_END_YR, OOS_START_YR))
cat(sprintf("  CV folds (R/Py): %d / %d  (fold 1 omitted in expanding window)\n",
            CV_FOLDS, CV_FOLDS_PYTHON))
cat(sprintf("  CSI base       : C=%.2f | M=%.2f | T=%d months\n",
            CSI_BASE$C, CSI_BASE$M, CSI_BASE$T))
cat(sprintf("  CSI grid       : %s\n",
            if (CSI_RUN_GRID) "enabled" else "disabled"))
cat(sprintf("  PCL hybrid     : forward=%d months | delisting window=%d months | impute dlret=%.2f\n",
            PCL_FORWARD_MONTHS, PCL_DELISTING_WINDOW_MONTHS, PCL_DLRET_IMPUTE_VALUE))
cat(sprintf("  Bucket         : %d-yr fwd | loser < %.0f%% | phoenix ≥ %.0f%% | last year=%d\n",
            BUCKET_FWD_YEARS, BUCKET_LOSER_THRESH*100,
            BUCKET_PHOENIX_THRESH*100, BUCKET_LAST_YEAR))
cat(sprintf("  Exclusion rate : CSI=%.0f%% | Bucket/Structural=%.0f%%\n",
            EXCLUSION_RATE_CSI*100, EXCLUSION_RATE_BUCKET*100))
cat(sprintf("  Universe       : Top %d | min $%dM mktcap\n",
            UNIVERSE_SIZE, UNIVERSE_MIN_MKTCAP))
cat(sprintf("  Seed           : %d\n", SEED))
cat(sprintf("  Models         : %d  (%s)\n",
            length(MODEL_LABELS),
            paste(names(MODEL_LABELS), collapse=", ")))
