#!/usr/bin/env bash
set -Eeuo pipefail

export MT_ROOT="${MT_ROOT:-/workspace/AgonyAndExcstasy}"
export RESPONSE_TRACK="${RESPONSE_TRACK:-dynamic_csi}"
export CSI_USE_TERMINAL_FAILURE_INDICATORS="${CSI_USE_TERMINAL_FAILURE_INDICATORS:-1}"
export CSI_RUN_GRID="${CSI_RUN_GRID:-0}"
export CSI_GRID_WORKERS="${CSI_GRID_WORKERS:-8}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export BLIS_NUM_THREADS="${BLIS_NUM_THREADS:-1}"
export VECLIB_MAXIMUM_THREADS="${VECLIB_MAXIMUM_THREADS:-1}"

CODE_DIR="$MT_ROOT/01_Code/pipeline"
# Single output tree in AgonyAndExcstasy layout (no more 03_Output/03b_Output split).
# MT_OUTPUT_DIR still honoured if set to an absolute path (override for ad-hoc runs).
if [[ -n "${MT_OUTPUT_DIR:-}" ]]; then
  case "$MT_OUTPUT_DIR" in
    /*) OUTPUT_ROOT="$MT_OUTPUT_DIR" ;;
    *)  OUTPUT_ROOT="$MT_ROOT/$MT_OUTPUT_DIR" ;;
  esac
else
  OUTPUT_ROOT="$MT_ROOT/03_Data_Output"
fi
LOG_DIR="$OUTPUT_ROOT/2_Robustness_Checks/Additional/logs"
LOG_PATH="$LOG_DIR/05A_dynamic_csi_terminal_failure_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"
cd "$CODE_DIR"

{
  echo "[run_05A_dynamic_csi_vast] START: $(date -Is)"
  echo "[run_05A_dynamic_csi_vast] MT_ROOT=$MT_ROOT"
  echo "[run_05A_dynamic_csi_vast] RESPONSE_TRACK=$RESPONSE_TRACK"
  echo "[run_05A_dynamic_csi_vast] CSI_USE_TERMINAL_FAILURE_INDICATORS=$CSI_USE_TERMINAL_FAILURE_INDICATORS"
  echo "[run_05A_dynamic_csi_vast] CSI_RUN_GRID=$CSI_RUN_GRID"
  echo "[run_05A_dynamic_csi_vast] OUTPUT_ROOT=$OUTPUT_ROOT"
  echo "[run_05A_dynamic_csi_vast] CSI_GRID_WORKERS=$CSI_GRID_WORKERS"
  Rscript --version
  Rscript 05A_Dynamic_CSI_Label.R
  Rscript 06_Merge.R
  Rscript -e '
    source("config.R")
    library(data.table)
    events <- as.data.table(readRDS(PATH_CSI_EVENTS_BASE))
    print(events[, .N, by = event_status])
    cat("positive_event_rows", nrow(events[event_status %in% CSI_POSITIVE_EVENT_STATUSES]), "\n")
    labels <- as.data.table(readRDS(PATH_LABELS_DYNAMIC))
    cat("dynamic_label_positives", sum(labels$y_dynamic_csi == 1L, na.rm = TRUE), "\n")
  '
  echo "[run_05A_dynamic_csi_vast] DONE: $(date -Is)"
} 2>&1 | tee "$LOG_PATH"
