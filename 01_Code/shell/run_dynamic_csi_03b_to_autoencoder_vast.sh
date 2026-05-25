#!/usr/bin/env bash
set -Eeuo pipefail

export MT_ROOT="${MT_ROOT:-/workspace/AgonyAndExcstasy}"
export RESPONSE_TRACK="${RESPONSE_TRACK:-dynamic_csi}"
export CSI_USE_TERMINAL_FAILURE_INDICATORS="${CSI_USE_TERMINAL_FAILURE_INDICATORS:-1}"
export CSI_RUN_GRID="${CSI_RUN_GRID:-0}"
export CSI_GRID_WORKERS="${CSI_GRID_WORKERS:-8}"
# MT_OUTPUT_DIR is obsolete (single output tree); honoured only if absolute.

export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export BLIS_NUM_THREADS="${BLIS_NUM_THREADS:-1}"
export VECLIB_MAXIMUM_THREADS="${VECLIB_MAXIMUM_THREADS:-1}"

CODE_DIR="$MT_ROOT/01_Code/pipeline"
if [[ -n "${MT_OUTPUT_DIR:-}" && "$MT_OUTPUT_DIR" == /* ]]; then
  OUTPUT_ROOT="$MT_OUTPUT_DIR"
else
  OUTPUT_ROOT="$MT_ROOT/03_Data_Output"
fi
LOG_DIR="$OUTPUT_ROOT/3_Modelling_Results/Additional/run_logs"
LOG_PATH="$LOG_DIR/dynamic_csi_03b_to_autoencoder_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"
cd "$CODE_DIR"

{
  echo "[run_dynamic_csi_03b_to_autoencoder_vast] START: $(date -Is)"
  echo "MT_ROOT=$MT_ROOT"
  echo "RESPONSE_TRACK=$RESPONSE_TRACK"
  echo "CSI_USE_TERMINAL_FAILURE_INDICATORS=$CSI_USE_TERMINAL_FAILURE_INDICATORS"
  echo "CSI_RUN_GRID=$CSI_RUN_GRID"
  echo "CSI_GRID_WORKERS=$CSI_GRID_WORKERS"
  echo "MT_OUTPUT_DIR=$MT_OUTPUT_DIR"
  echo "OUTPUT_ROOT=$OUTPUT_ROOT"

  Rscript --version
  python3 --version

  Rscript 05A_Dynamic_CSI_Label.R
  Rscript 06_Merge.R
  Rscript 06B_FeatureEngineering.R
  Rscript 08_Split.R

  VAE_INPUT=fund python3 08B_Autoencoder.py
  VAE_INPUT=raw python3 08B_Autoencoder.py

  Rscript -e '
    source("config.R")
    library(data.table)
    events <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE))
    labels <- as.data.table(readRDS(PATH_LABELS_DYNAMIC))
    features <- as.data.table(readRDS(PATH_FEATURES_RAW))
    cat("event_status_counts\n")
    print(events[, .N, by = event_status][order(event_status)])
    cat("positive_event_rows", nrow(events[event_status %in% CSI_POSITIVE_EVENT_STATUSES]), "\n")
    cat("dynamic_label_positives", sum(labels$y_dynamic_csi == 1L, na.rm = TRUE), "\n")
    cat("feature_rows", nrow(features), "\n")
    cat("output_dir", DIR_OUTPUT, "\n")
  '

  echo "[run_dynamic_csi_03b_to_autoencoder_vast] DONE: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"
