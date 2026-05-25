#!/usr/bin/env bash
set -euo pipefail

export MT_ROOT="${MT_ROOT:-/workspace/AgonyAndExcstasy}"
export RESPONSE_TRACK="${RESPONSE_TRACK:-dynamic_csi}"
export CSI_USE_TERMINAL_FAILURE_INDICATORS="${CSI_USE_TERMINAL_FAILURE_INDICATORS:-1}"
export ROBUST_WORKERS="${ROBUST_WORKERS:-27}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export BLIS_NUM_THREADS="${BLIS_NUM_THREADS:-1}"
export VECLIB_MAXIMUM_THREADS="${VECLIB_MAXIMUM_THREADS:-1}"

cd "$MT_ROOT/01_Code/pipeline"

# Single output tree in AgonyAndExcstasy layout.
if [[ -n "${MT_OUTPUT_DIR:-}" ]]; then
  case "$MT_OUTPUT_DIR" in
    /*) OUTPUT_ROOT="$MT_OUTPUT_DIR" ;;
    *)  OUTPUT_ROOT="$MT_ROOT/$MT_OUTPUT_DIR" ;;
  esac
else
  OUTPUT_ROOT="$MT_ROOT/03_Data_Output"
fi

LOG_DIR="$OUTPUT_ROOT/2_Robustness_Checks/Additional/logs"
mkdir -p "$LOG_DIR"

R_BIN="${R_BIN:-Rscript}"
LOG_PATH="$LOG_DIR/run_13_robustness.log"

echo "[run_13_dynamic_csi_vast] START: $(date -Is)" | tee "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] MT_ROOT=$MT_ROOT" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] RESPONSE_TRACK=$RESPONSE_TRACK" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] CSI_USE_TERMINAL_FAILURE_INDICATORS=$CSI_USE_TERMINAL_FAILURE_INDICATORS" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] OUTPUT_ROOT=$OUTPUT_ROOT" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] R_BIN=$R_BIN" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] ROBUST_WORKERS=$ROBUST_WORKERS" | tee -a "$LOG_PATH"
echo "[run_13_dynamic_csi_vast] OMP_NUM_THREADS=$OMP_NUM_THREADS" | tee -a "$LOG_PATH"

"$R_BIN" 13_Robustness_Checks.R 2>&1 | tee -a "$LOG_PATH"

echo "[run_13_dynamic_csi_vast] DONE: $(date -Is)" | tee -a "$LOG_PATH"
