#!/usr/bin/env bash
set -euo pipefail

export MT_ROOT="${MT_ROOT:-/workspace/AgonyAndExcstasy}"
export RESPONSE_TRACK="${RESPONSE_TRACK:-dynamic_csi}"
export CSI_USE_TERMINAL_FAILURE_INDICATORS="${CSI_USE_TERMINAL_FAILURE_INDICATORS:-1}"
export CSI_RUN_GRID="${CSI_RUN_GRID:-1}"
export CSI_GRID_WORKERS="${CSI_GRID_WORKERS:-27}"
export ROBUST_WORKERS="${ROBUST_WORKERS:-27}"
export ROBUST_METHOD_SLUG="${ROBUST_METHOD_SLUG:-dynamic_csi_revised_temporary_csi_572_574}"
# MT_OUTPUT_DIR is obsolete (single output tree in AgonyAndExcstasy layout);
# only honoured if explicitly set to an absolute path.
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export BLIS_NUM_THREADS="${BLIS_NUM_THREADS:-1}"
export VECLIB_MAXIMUM_THREADS="${VECLIB_MAXIMUM_THREADS:-1}"

cd "$MT_ROOT/01_Code/pipeline"

if [[ -n "${MT_OUTPUT_DIR:-}" ]]; then
  case "$MT_OUTPUT_DIR" in
    /*) OUTPUT_ROOT="$MT_OUTPUT_DIR" ;;
    *)  OUTPUT_ROOT="$MT_ROOT/$MT_OUTPUT_DIR" ;;
  esac
else
  OUTPUT_ROOT="$MT_ROOT/03_Data_Output"
fi

RUN_ROOT="$OUTPUT_ROOT/2_Robustness_Checks/Necessary/$ROBUST_METHOD_SLUG"
mkdir -p "$RUN_ROOT"

R_BIN="${R_BIN:-Rscript}"
LOG_PATH="$RUN_ROOT/run_revised_temporary_csi_572_574_robustness.log"

echo "[run_13_revised_temporary_csi_572_574_vast] START: $(date -Is)" | tee "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] MT_ROOT=$MT_ROOT" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] RESPONSE_TRACK=$RESPONSE_TRACK" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] CSI_USE_TERMINAL_FAILURE_INDICATORS=$CSI_USE_TERMINAL_FAILURE_INDICATORS" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] CSI_RUN_GRID=$CSI_RUN_GRID" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] CSI_GRID_WORKERS=$CSI_GRID_WORKERS" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] ROBUST_WORKERS=$ROBUST_WORKERS" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] ROBUST_METHOD_SLUG=$ROBUST_METHOD_SLUG" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] OUTPUT_ROOT=$OUTPUT_ROOT" | tee -a "$LOG_PATH"
echo "[run_13_revised_temporary_csi_572_574_vast] R_BIN=$R_BIN" | tee -a "$LOG_PATH"

echo "[run_13_revised_temporary_csi_572_574_vast] Step 1/3: rebuild revised 05A grid events" | tee -a "$LOG_PATH"
"$R_BIN" 05A_Dynamic_CSI_Label.R 2>&1 | tee -a "$LOG_PATH"

echo "[run_13_revised_temporary_csi_572_574_vast] Step 2/3: run A-D robustness checks" | tee -a "$LOG_PATH"
"$R_BIN" 13_Robustness_Checks_Revised_Temporary_CSI_572_574.R 2>&1 | tee -a "$LOG_PATH"

echo "[run_13_revised_temporary_csi_572_574_vast] Step 3/3: run E delisting/bankruptcy audit" | tee -a "$LOG_PATH"
"$R_BIN" 13b_Dynamic_CSI_Delisting_Detection_Revised_Temporary_CSI_572_574.R 2>&1 | tee -a "$LOG_PATH"

echo "[run_13_revised_temporary_csi_572_574_vast] DONE: $(date -Is)" | tee -a "$LOG_PATH"
