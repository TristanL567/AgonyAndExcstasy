#!/usr/bin/env bash
set -euo pipefail

: "${MT_ROOT:?MT_ROOT is required}"
: "${AE_SENS_OUTPUT_ROOT:?AE_SENS_OUTPUT_ROOT is required}"

if [[ "${MT_ROOT}" != "/root/AgonyAndExcstasy" ]]; then
  echo "Unexpected MT_ROOT: ${MT_ROOT}" >&2
  exit 2
fi

if [[ "${AE_SENS_OUTPUT_ROOT}" != "/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity" ]]; then
  echo "Unexpected AE_SENS_OUTPUT_ROOT: ${AE_SENS_OUTPUT_ROOT}" >&2
  exit 2
fi

DRIVER_LOG_DIR="${AE_SENS_OUTPUT_ROOT}/logs/AE-SENS-007S_full_grid_resume"
mkdir -p "${DRIVER_LOG_DIR}"
OVERALL_STATUS="${DRIVER_LOG_DIR}/full_grid_status.csv"
STEP_STATUS="${DRIVER_LOG_DIR}/full_grid_step_status.csv"
RESUME_DECISIONS="${DRIVER_LOG_DIR}/resume_decisions.csv"
FAILED_RUNS="${DRIVER_LOG_DIR}/failed_runs.csv"

echo "run_id,C,M,T,status,started_at,ended_at,exit_code,note" > "${OVERALL_STATUS}"
echo "run_id,step,status,started_at,ended_at" > "${STEP_STATUS}"
echo "run_id,decision,reason,next_step" > "${RESUME_DECISIONS}"
echo "run_id,failed_step,exit_code,reason" > "${FAILED_RUNS}"

configs=(
  "C060_M000_T012 -0.60 0.00 12"
  "C060_M000_T018 -0.60 0.00 18"
  "C060_M000_T028 -0.60 0.00 28"
  "C060_M020_T012 -0.60 -0.20 12"
  "C060_M020_T018 -0.60 -0.20 18"
  "C060_M020_T028 -0.60 -0.20 28"
  "C060_M030_T012 -0.60 -0.30 12"
  "C060_M030_T018 -0.60 -0.30 18"
  "C060_M030_T028 -0.60 -0.30 28"
  "C080_M000_T012 -0.80 0.00 12"
  "C080_M000_T018 -0.80 0.00 18"
  "C080_M000_T028 -0.80 0.00 28"
  "C080_M020_T012 -0.80 -0.20 12"
  "C080_M020_T018 -0.80 -0.20 18"
  "C080_M020_T028 -0.80 -0.20 28"
  "C080_M030_T012 -0.80 -0.30 12"
  "C080_M030_T018 -0.80 -0.30 18"
  "C080_M030_T028 -0.80 -0.30 28"
  "C090_M000_T012 -0.90 0.00 12"
  "C090_M000_T018 -0.90 0.00 18"
  "C090_M000_T028 -0.90 0.00 28"
  "C090_M020_T012 -0.90 -0.20 12"
  "C090_M020_T018 -0.90 -0.20 18"
  "C090_M020_T028 -0.90 -0.20 28"
  "C090_M030_T012 -0.90 -0.30 12"
  "C090_M030_T018 -0.90 -0.30 18"
  "C090_M030_T028 -0.90 -0.30 28"
)

step1_files() {
  local run_id="$1"
  cat <<EOF
${AE_SENS_OUTPUT_ROOT}/labels/${run_id}/labels_model_ready.rds
${AE_SENS_OUTPUT_ROOT}/labels/${run_id}/csi_events.rds
${AE_SENS_OUTPUT_ROOT}/raw_features/by_config/${run_id}/features_raw.rds
${AE_SENS_OUTPUT_ROOT}/raw_features/by_config/${run_id}/split_labels_oot.parquet
EOF
}

step2_files() {
  local run_id="$1"
  cat <<EOF
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_eval_summary.json
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_leaderboard.csv
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_cv_results.parquet
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_preds_test.parquet
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_preds_oos.parquet
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_preds_train_boundary.parquet
EOF
}

step3_files() {
  local run_id="$1"
  cat <<EOF
${AE_SENS_OUTPUT_ROOT}/evaluation/${run_id}/raw_model_metrics.csv
${AE_SENS_OUTPUT_ROOT}/evaluation/${run_id}/raw_prediction_row_counts.csv
EOF
}

step4_files() {
  local run_id="$1"
  cat <<EOF
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_thresholds_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_returns_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_performance_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_exclusion_summary_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/error_cost_decomposition_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/run_status.csv
EOF
}

all_files_exist() {
  local file
  while IFS= read -r file; do
    [[ -s "${file}" ]] || return 1
  done
}

step1_complete() { step1_files "$1" | all_files_exist; }
step2_complete() {
  local run_id="$1"
  step2_files "${run_id}" | all_files_exist || return 1
  find "${AE_SENS_OUTPUT_ROOT}/raw_models/${run_id}" -name predictor.pkl -type f -size +0c -print -quit | grep -q .
}
step3_complete() { step3_files "$1" | all_files_exist; }
step4_complete() { step4_files "$1" | all_files_exist; }
run_complete() {
  local run_id="$1"
  step1_complete "${run_id}" && step2_complete "${run_id}" && step3_complete "${run_id}" && step4_complete "${run_id}"
}

run_partial() {
  local run_id="$1"
  local dirs=(
    "${AE_SENS_OUTPUT_ROOT}/labels/${run_id}"
    "${AE_SENS_OUTPUT_ROOT}/raw_features/by_config/${run_id}"
    "${AE_SENS_OUTPUT_ROOT}/raw_models/${run_id}"
    "${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}"
    "${AE_SENS_OUTPUT_ROOT}/evaluation/${run_id}"
    "${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}"
  )
  local dir
  for dir in "${dirs[@]}"; do
    if [[ -d "${dir}" ]] && [[ -n "$(find "${dir}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
      return 0
    fi
  done
  return 1
}

append_step_status() {
  local run_id="$1"
  local step_file="${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv"
  if [[ -s "${step_file}" ]]; then
    tail -n +2 "${step_file}" >> "${STEP_STATUS}"
  fi
}

record_step() {
  local run_id="$1"
  local step="$2"
  local status="$3"
  local started="$4"
  local ended="$5"
  echo "${run_id},${step},${status},${started},${ended}" >> "${STEP_STATUS}"
}

run_logged_step() {
  local run_id="$1"
  local step="$2"
  shift 2
  local log_dir="${AE_SENS_OUTPUT_ROOT}/logs/${run_id}"
  mkdir -p "${log_dir}"
  local start_ts end_ts
  start_ts="$(date -Iseconds)"
  echo "[AE-SENS-007S ${run_id}] START ${step} ${start_ts}"
  set +e
  "$@" > "${log_dir}/${step}_007S.stdout.log" 2> "${log_dir}/${step}_007S.stderr.log"
  local code=$?
  set -e
  end_ts="$(date -Iseconds)"
  if [[ "${code}" -eq 0 ]]; then
    record_step "${run_id}" "${step}" "completed" "${start_ts}" "${end_ts}"
    echo "[AE-SENS-007S ${run_id}] DONE ${step} ${end_ts}"
  else
    record_step "${run_id}" "${step}" "failed" "${start_ts}" "${end_ts}"
    echo "${run_id},${step},${code},step command failed" >> "${FAILED_RUNS}"
    echo "[AE-SENS-007S ${run_id}] FAILED ${step} exit=${code}"
  fi
  return "${code}"
}

run_eval_only() {
  local run_id="$1"
  (
    cd "${MT_ROOT}/01_Code/pipeline"
    env MT_ROOT="${MT_ROOT}" \
        AE_SENS_OUTPUT_ROOT="${AE_SENS_OUTPUT_ROOT}" \
        AE_SENS_RUN_ID="${run_id}" \
        MODEL=raw \
        RESPONSE_TRACK=dynamic_csi \
        Rscript ae_sens_eval_raw.R
  )
}

run_11c_only() {
  local run_id="$1"
  (
    cd "${MT_ROOT}/01_Code/pipeline"
    env MT_ROOT="${MT_ROOT}" \
        AE_SENS_OUTPUT_ROOT="${AE_SENS_OUTPUT_ROOT}" \
        AE_SENS_RUN_ID="${run_id}" \
        MODEL=raw \
        RESPONSE_TRACK=dynamic_csi \
        Rscript 11C_IndexConstruction_Revised.R
  )
}

run_full() {
  local run_id="$1"
  local c_value="$2"
  local m_value="$3"
  local t_value="$4"
  env MT_ROOT="${MT_ROOT}" \
      AE_SENS_OUTPUT_ROOT="${AE_SENS_OUTPUT_ROOT}" \
      AE_SENS_RUN_ID="${run_id}" \
      AE_SENS_C="${c_value}" \
      AE_SENS_M="${m_value}" \
      AE_SENS_T="${t_value}" \
      MODEL=raw \
      RESPONSE_TRACK=dynamic_csi \
      bash "${MT_ROOT}/01_Code/shell/run_ae_sens_raw_one.sh"
}

echo "[AE-SENS-007S] resume driver started $(date -Iseconds)"
shared_11c_failures=0

for cfg in "${configs[@]}"; do
  read -r run_id c_value m_value t_value <<< "${cfg}"
  start_ts="$(date -Iseconds)"
  echo "[AE-SENS-007S] considering ${run_id} at ${start_ts}"

  if run_complete "${run_id}"; then
    end_ts="$(date -Iseconds)"
    echo "${run_id},reuse_complete,all required output families already present,none" >> "${RESUME_DECISIONS}"
    echo "${run_id},${c_value},${m_value},${t_value},skipped_complete,${start_ts},${end_ts},0,reused complete isolated run" >> "${OVERALL_STATUS}"
    append_step_status "${run_id}"
    continue
  fi

  if step1_complete "${run_id}" && step2_complete "${run_id}" && step3_complete "${run_id}"; then
    echo "${run_id},resume_11c_only,prepare raw autogluon and evaluation outputs complete,04_raw_11c_index" >> "${RESUME_DECISIONS}"
    if run_logged_step "${run_id}" "04_raw_11c_index" run_11c_only "${run_id}" && step4_complete "${run_id}"; then
      end_ts="$(date -Iseconds)"
      echo "${run_id},${c_value},${m_value},${t_value},completed_resume_11c,${start_ts},${end_ts},0,resumed 11C only" >> "${OVERALL_STATUS}"
      shared_11c_failures=0
    else
      end_ts="$(date -Iseconds)"
      echo "${run_id},${c_value},${m_value},${t_value},failed_11c_resume,${start_ts},${end_ts},1,11C resume failed or required outputs missing" >> "${OVERALL_STATUS}"
      shared_11c_failures=$((shared_11c_failures + 1))
      if [[ "${shared_11c_failures}" -ge 3 ]]; then
        echo "[AE-SENS-007S] stopping after ${shared_11c_failures} consecutive 11C failures"
        break
      fi
    fi
    continue
  fi

  if step1_complete "${run_id}" && step2_complete "${run_id}" && ! step3_complete "${run_id}"; then
    echo "${run_id},resume_eval_then_11c,prepare and raw autogluon outputs complete,03_raw_evaluation" >> "${RESUME_DECISIONS}"
    if run_logged_step "${run_id}" "03_raw_evaluation" run_eval_only "${run_id}" && step3_complete "${run_id}" &&
       run_logged_step "${run_id}" "04_raw_11c_index" run_11c_only "${run_id}" && step4_complete "${run_id}"; then
      end_ts="$(date -Iseconds)"
      echo "${run_id},${c_value},${m_value},${t_value},completed_resume_eval_11c,${start_ts},${end_ts},0,resumed evaluation and 11C" >> "${OVERALL_STATUS}"
      shared_11c_failures=0
    else
      end_ts="$(date -Iseconds)"
      echo "${run_id},${c_value},${m_value},${t_value},failed_resume_eval_11c,${start_ts},${end_ts},1,evaluation or 11C resume failed" >> "${OVERALL_STATUS}"
    fi
    continue
  fi

  if run_partial "${run_id}"; then
    end_ts="$(date -Iseconds)"
    echo "${run_id},blocked_partial,partial non-empty outputs lack documented safe resume point,manual follow-up" >> "${RESUME_DECISIONS}"
    echo "${run_id},${c_value},${m_value},${t_value},blocked_partial,${start_ts},${end_ts},3,partial non-empty outputs lack documented safe resume point" >> "${OVERALL_STATUS}"
    echo "${run_id},partial_state,3,partial non-empty outputs lack documented safe resume point" >> "${FAILED_RUNS}"
    continue
  fi

  echo "${run_id},run_full,no existing run outputs,01_prepare_raw_inputs" >> "${RESUME_DECISIONS}"
  set +e
  run_full "${run_id}" "${c_value}" "${m_value}" "${t_value}"
  code=$?
  set -e
  end_ts="$(date -Iseconds)"
  append_step_status "${run_id}"
  if [[ "${code}" -eq 0 ]] && run_complete "${run_id}"; then
    echo "${run_id},${c_value},${m_value},${t_value},completed_full,${start_ts},${end_ts},0,full isolated raw-only run completed" >> "${OVERALL_STATUS}"
    shared_11c_failures=0
  else
    echo "${run_id},${c_value},${m_value},${t_value},failed_full,${start_ts},${end_ts},${code},full isolated run failed or required outputs missing" >> "${OVERALL_STATUS}"
    echo "${run_id},full_run,${code},full isolated run failed or required outputs missing" >> "${FAILED_RUNS}"
  fi
done

echo "[AE-SENS-007S] resume driver ended $(date -Iseconds)"
