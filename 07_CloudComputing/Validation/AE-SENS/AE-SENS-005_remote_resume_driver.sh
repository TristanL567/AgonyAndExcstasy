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
  echo "PROCESS_GUARD_RESUME_BEFORE"
  ps -eo pid,args | grep -E 'AE-SENS-005|run_ae_sens_raw_one|ae_sens_|09C_AutoGluon|11C_IndexConstruction|CSI_RUN_GRID' | grep -v grep || true
} > "$TICKET_LOG/process_guard_resume_before.txt"

{
  echo "CANONICAL_SNAPSHOT_RESUME_BEFORE"
  find \
    "$ROOT/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi" \
    "$ROOT/03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi" \
    "$ROOT/02_Data_Input/05_PipelineResults/Necessary/temporary_csi" \
    -type f -ls 2>/dev/null | sort | sha256sum
} > "$TICKET_LOG/canonical_snapshot_resume_before.txt"

echo "run_id,status,started_at,ended_at,note" > "$TICKET_LOG/pilot_status_resume.csv"

require_file() {
  local path="$1"
  if [[ ! -s "$path" ]]; then
    echo "Required resume input missing or empty: $path" >&2
    exit 10
  fi
}

require_empty_dir() {
  local path="$1"
  if [[ -d "$path" ]] && [[ -n "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    echo "Resume fail-closed: destination is already non-empty: $path" >&2
    exit 11
  fi
}

require_completed_eval_or_empty() {
  local run_id="$1"
  local eval_dir="$SENS/evaluation/$run_id"
  if [[ ! -d "$eval_dir" ]] || [[ -z "$(find "$eval_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    echo "empty"
    return 0
  fi

  require_file "$eval_dir/ag_eval_summary_compact.csv"
  require_file "$eval_dir/raw_model_metrics.csv"
  require_file "$eval_dir/raw_prediction_row_counts.csv"
  if ! grep -q "^$run_id,03_raw_evaluation,completed," "$SENS/logs/$run_id/run_status.csv"; then
    echo "Resume fail-closed: evaluation outputs exist without completed run_status for $run_id" >&2
    exit 12
  fi
  echo "completed"
}

append_step_status() {
  local run_id="$1"
  local step="$2"
  local status="$3"
  local started="$4"
  local ended="$5"
  echo "$run_id,$step,$status,$started,$ended" >> "$SENS/logs/$run_id/run_status.csv"
}

run_logged_step() {
  local run_id="$1"
  local step="$2"
  shift 2
  local started ended
  started="$(date -Iseconds)"
  echo "[AE-SENS $run_id] RESUME START $step $started"
  "$@" > "$SENS/logs/$run_id/$step.stdout.log" 2> "$SENS/logs/$run_id/$step.stderr.log"
  ended="$(date -Iseconds)"
  append_step_status "$run_id" "$step" "completed" "$started" "$ended"
  echo "[AE-SENS $run_id] RESUME DONE $step $ended"
}

export MT_ROOT="$ROOT"
export AE_SENS_OUTPUT_ROOT="$SENS"
export MODEL="raw"
export RESPONSE_TRACK="dynamic_csi"
export CSI_RUN_GRID="0"
export AG_FEATURE_IMPORTANCE="0"
export AG_TIME_LIMIT="${AG_TIME_LIMIT:-900}"
export AG_CV_TIME_LIMIT="${AG_CV_TIME_LIMIT:-300}"
export AG_PRESET="${AG_PRESET:-good_quality}"
export AG_CV_PRESET="${AG_CV_PRESET:-medium_quality}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export R_DATATABLE_NUM_THREADS="${R_DATATABLE_NUM_THREADS:-1}"

# Explicit resume semantics for the failed first driver:
# C080_M020_T018 is allowed to resume only after completed isolated prepare
# and raw AutoGluon outputs exist, while evaluation and index destinations
# remain empty. The resume path does not regenerate labels, features, models,
# or predictions for this run ID.
run_id="C080_M020_T018"
export AE_SENS_RUN_ID="$run_id"
export AE_SENS_C="-0.80"
export AE_SENS_M="-0.20"
export AE_SENS_T="18"

require_file "$SENS/labels/$run_id/labels_model_ready.rds"
require_file "$SENS/raw_features/by_config/$run_id/features_raw.rds"
require_file "$SENS/raw_predictions/$run_id/ag_preds_test_eval.parquet"
require_file "$SENS/raw_predictions/$run_id/ag_preds_oos_eval.parquet"
require_file "$SENS/raw_predictions/$run_id/ag_cv_results.parquet"
eval_resume_state="$(require_completed_eval_or_empty "$run_id")"
require_empty_dir "$SENS/index_construction/$run_id"

c080_started="$(date -Iseconds)"
cd "$ROOT/01_Code/pipeline"
if [[ "$eval_resume_state" == "empty" ]]; then
  run_logged_step "$run_id" "03_raw_evaluation" Rscript ae_sens_eval_raw.R
else
  echo "[AE-SENS $run_id] REUSE completed isolated 03_raw_evaluation"
fi
run_logged_step "$run_id" "04_raw_11c_index" Rscript 11C_IndexConstruction_Revised.R
c080_ended="$(date -Iseconds)"
echo "$run_id,completed,$c080_started,$c080_ended,resumed_from_existing_isolated_raw_predictions_eval_state_${eval_resume_state}" >> "$TICKET_LOG/pilot_status_resume.csv"

if [[ "${AE_SENS_STOP_AFTER_BASELINE_11C:-0}" == "1" ]]; then
  echo "AE_SENS_STOP_AFTER_BASELINE_11C_COMPLETE" > "$TICKET_LOG/stop_after_baseline_11c.txt"
  exit 0
fi

# The second pilot config has no prior outputs and must use the normal
# fail-closed single-run wrapper.
run_id="C090_M020_T028"
export AE_SENS_RUN_ID="$run_id"
export AE_SENS_C="-0.90"
export AE_SENS_M="-0.20"
export AE_SENS_T="28"

c090_started="$(date -Iseconds)"
bash "$ROOT/01_Code/shell/run_ae_sens_raw_one.sh"
c090_ended="$(date -Iseconds)"
echo "$run_id,completed,$c090_started,$c090_ended,full_fail_closed_single_run_wrapper" >> "$TICKET_LOG/pilot_status_resume.csv"

{
  echo "PROCESS_GUARD_RESUME_AFTER"
  ps -eo pid,args | grep -E 'AE-SENS-005|run_ae_sens_raw_one|ae_sens_|09C_AutoGluon|11C_IndexConstruction|CSI_RUN_GRID' | grep -v grep || true
} > "$TICKET_LOG/process_guard_resume_after.txt"

{
  echo "CANONICAL_SNAPSHOT_RESUME_AFTER"
  find \
    "$ROOT/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi" \
    "$ROOT/03_Data_Output/4_IndexConstruction_Results/Necessary/temporary_csi" \
    "$ROOT/02_Data_Input/05_PipelineResults/Necessary/temporary_csi" \
    -type f -ls 2>/dev/null | sort | sha256sum
} > "$TICKET_LOG/canonical_snapshot_resume_after.txt"

{
  echo "source,hash"
  awk 'NR==2 {print "original_before," $1}' "$TICKET_LOG/canonical_snapshot_before.txt" 2>/dev/null || true
  awk 'NR==2 {print "resume_before," $1}' "$TICKET_LOG/canonical_snapshot_resume_before.txt" 2>/dev/null || true
  awk 'NR==2 {print "resume_after," $1}' "$TICKET_LOG/canonical_snapshot_resume_after.txt" 2>/dev/null || true
} > "$TICKET_LOG/canonical_hashes.csv"

{
  echo "run_id,step,status,started_at,ended_at"
  for rid in C080_M020_T018 C090_M020_T028; do
    if [[ -f "$SENS/logs/$rid/run_status.csv" ]]; then
      tail -n +2 "$SENS/logs/$rid/run_status.csv"
    fi
  done
} > "$TICKET_LOG/pilot_step_status.csv"

combine_csv() {
  local output="$1"
  shift
  local wrote_header=0
  : > "$output"
  for input in "$@"; do
    if [[ -f "$input" ]]; then
      if [[ "$wrote_header" -eq 0 ]]; then
        cat "$input" >> "$output"
        wrote_header=1
      else
        tail -n +2 "$input" >> "$output"
      fi
    fi
  done
}

combine_csv "$TICKET_LOG/pilot_label_counts.csv" \
  "$SENS/labels/C080_M020_T018/label_diagnostics.csv" \
  "$SENS/labels/C090_M020_T028/label_diagnostics.csv"

combine_csv "$TICKET_LOG/pilot_model_metrics.csv" \
  "$SENS/evaluation/C080_M020_T018/raw_model_metrics.csv" \
  "$SENS/evaluation/C090_M020_T028/raw_model_metrics.csv"

combine_csv "$TICKET_LOG/pilot_prediction_row_counts.csv" \
  "$SENS/evaluation/C080_M020_T018/raw_prediction_row_counts.csv" \
  "$SENS/evaluation/C090_M020_T028/raw_prediction_row_counts.csv"

combine_csv "$TICKET_LOG/pilot_11c_summary.csv" \
  "$SENS/index_construction/C080_M020_T018/run_status.csv" \
  "$SENS/index_construction/C090_M020_T028/run_status.csv"

find "$SENS" -maxdepth 4 -type f | sort > "$TICKET_LOG/sensitivity_file_inventory_resume.txt"
echo "AE_SENS_005_RESUME_DRIVER_COMPLETE" > "$TICKET_LOG/resume_driver_complete.txt"
