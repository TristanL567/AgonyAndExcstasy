#!/usr/bin/env bash
set -euo pipefail

export MT_ROOT="${MT_ROOT:-/workspace/AgonyAndExcstasy}"
export RESPONSE_TRACK="${RESPONSE_TRACK:-dynamic_csi}"
export CSI_USE_TERMINAL_FAILURE_INDICATORS=0
export CSI_RECOVERY_WORKERS="${CSI_RECOVERY_WORKERS:-27}"

cd "$MT_ROOT/01_Code/pipeline"

LOG_DIR="$MT_ROOT/03_Data_Output/2_Robustness_Checks/Additional/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/run_13c_old_csi_recovery_buckets_all_grid.log"

{
  echo "[run_13c_old_csi_recovery_buckets_all_grid_vast] START $(date -Is)"
  echo "MT_ROOT=$MT_ROOT"
  echo "RESPONSE_TRACK=$RESPONSE_TRACK"
  echo "CSI_USE_TERMINAL_FAILURE_INDICATORS=$CSI_USE_TERMINAL_FAILURE_INDICATORS"
  echo "CSI_RECOVERY_WORKERS=$CSI_RECOVERY_WORKERS"
  Rscript 13c_Old_CSI_Recovery_Buckets_All_Grid.R
  echo "[run_13c_old_csi_recovery_buckets_all_grid_vast] DONE $(date -Is)"
} 2>&1 | tee "$LOG_FILE"
