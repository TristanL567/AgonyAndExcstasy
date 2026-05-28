#!/usr/bin/env bash
set -euo pipefail

ROOT="/root/AgonyAndExcstasy"
SENS="$ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
TICKET_LOG="$SENS/logs/AE-SENS-005"
mkdir -p "$TICKET_LOG"

cd "$ROOT"

python3 - <<'PY'
from pathlib import Path
files = [
    Path("01_Code/pipeline/ae_sens_prepare_raw_inputs.R"),
    Path("01_Code/pipeline/ae_sens_eval_raw.R"),
    Path("01_Code/pipeline/09C_AutoGluon.py"),
    Path("01_Code/pipeline/11C_IndexConstruction_Revised.R"),
    Path("01_Code/shell/run_ae_sens_raw_one.sh"),
]
for path in files:
    data = path.read_bytes()
    path.write_bytes(data.replace(b"\r\n", b"\n"))
print("LINE_ENDINGS_OK")
PY

cd "$ROOT/01_Code/pipeline"
Rscript -e 'invisible(parse(file="ae_sens_prepare_raw_inputs.R")); invisible(parse(file="ae_sens_eval_raw.R")); invisible(parse(file="11C_IndexConstruction_Revised.R")); cat("R_PARSE_OK\n")'
python3 -m py_compile 09C_AutoGluon.py
chmod +x "$ROOT/01_Code/shell/run_ae_sens_raw_one.sh"

cd "$ROOT"

{
  echo "PROCESS_GUARD_BEFORE"
  ps -eo pid,args | grep -E '09C_AutoGluon|10_Evaluation|11C_IndexConstruction|13_Robustness|CSI_RUN_GRID' | grep -v grep || true
} > "$TICKET_LOG/process_guard_before.txt"

{
  echo "CANONICAL_SNAPSHOT_BEFORE"
  find \
    "$ROOT/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi" \
    "$ROOT/03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi" \
    "$ROOT/02_Data_Input/05_PipelineResults/Necessary/temporary_csi" \
    -type f -ls 2>/dev/null | sort | sha256sum
} > "$TICKET_LOG/canonical_snapshot_before.txt"

echo "run_id,status,started_at,ended_at" > "$TICKET_LOG/pilot_status.csv"

run_one() {
  local run_id="$1"
  local c_value="$2"
  local m_value="$3"
  local t_value="$4"
  local started ended

  started="$(date -Iseconds)"
  export MT_ROOT="$ROOT"
  export AE_SENS_OUTPUT_ROOT="$SENS"
  export AE_SENS_RUN_ID="$run_id"
  export AE_SENS_C="$c_value"
  export AE_SENS_M="$m_value"
  export AE_SENS_T="$t_value"
  export MODEL="raw"
  export RESPONSE_TRACK="dynamic_csi"
  export CSI_RUN_GRID="0"
  export AG_FEATURE_IMPORTANCE="0"
  export AG_TIME_LIMIT="${AG_TIME_LIMIT:-900}"
  export AG_CV_TIME_LIMIT="${AG_CV_TIME_LIMIT:-300}"
  export AG_PRESET="${AG_PRESET:-good_quality}"
  export AG_CV_PRESET="${AG_CV_PRESET:-medium_quality}"

  bash "$ROOT/01_Code/shell/run_ae_sens_raw_one.sh"
  ended="$(date -Iseconds)"
  echo "$run_id,completed,$started,$ended" >> "$TICKET_LOG/pilot_status.csv"
}

run_one "C080_M020_T018" "-0.80" "-0.20" "18"
run_one "C090_M020_T028" "-0.90" "-0.20" "28"

{
  echo "PROCESS_GUARD_AFTER"
  ps -eo pid,args | grep -E '09C_AutoGluon|10_Evaluation|11C_IndexConstruction|13_Robustness|CSI_RUN_GRID' | grep -v grep || true
} > "$TICKET_LOG/process_guard_after.txt"

{
  echo "CANONICAL_SNAPSHOT_AFTER"
  find \
    "$ROOT/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi" \
    "$ROOT/03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi" \
    "$ROOT/02_Data_Input/05_PipelineResults/Necessary/temporary_csi" \
    -type f -ls 2>/dev/null | sort | sha256sum
} > "$TICKET_LOG/canonical_snapshot_after.txt"

find "$SENS" -maxdepth 4 -type f | sort > "$TICKET_LOG/sensitivity_file_inventory.txt"
echo "AE_SENS_005_DRIVER_COMPLETE" > "$TICKET_LOG/driver_complete.txt"
