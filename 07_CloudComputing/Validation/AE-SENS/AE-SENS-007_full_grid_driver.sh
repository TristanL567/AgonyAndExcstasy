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

DRIVER_LOG_DIR="${AE_SENS_OUTPUT_ROOT}/logs/AE-SENS-007_full_grid"
mkdir -p "${DRIVER_LOG_DIR}"
OVERALL_STATUS="${DRIVER_LOG_DIR}/full_grid_status.csv"
STEP_STATUS="${DRIVER_LOG_DIR}/full_grid_step_status.csv"

echo "run_id,C,M,T,status,started_at,ended_at,exit_code,note" > "${OVERALL_STATUS}"
echo "run_id,step,status,started_at,ended_at" > "${STEP_STATUS}"

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

required_files_for_run() {
  local run_id="$1"
  cat <<EOF
${AE_SENS_OUTPUT_ROOT}/labels/${run_id}/labels_model_ready.rds
${AE_SENS_OUTPUT_ROOT}/labels/${run_id}/csi_events.rds
${AE_SENS_OUTPUT_ROOT}/raw_features/by_config/${run_id}/features_raw.rds
${AE_SENS_OUTPUT_ROOT}/raw_features/by_config/${run_id}/split_labels_oot.parquet
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_eval_summary.json
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_leaderboard.csv
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_preds_test.parquet
${AE_SENS_OUTPUT_ROOT}/raw_predictions/${run_id}/ag_preds_oos.parquet
${AE_SENS_OUTPUT_ROOT}/evaluation/${run_id}/raw_model_metrics.csv
${AE_SENS_OUTPUT_ROOT}/evaluation/${run_id}/raw_prediction_row_counts.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_thresholds_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_returns_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_performance_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/index_exclusion_summary_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/error_cost_decomposition_by_crsp_universe.csv
${AE_SENS_OUTPUT_ROOT}/index_construction/${run_id}/run_status.csv
${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv
EOF
}

run_complete() {
  local run_id="$1"
  local file
  while IFS= read -r file; do
    [[ -s "${file}" ]] || return 1
  done < <(required_files_for_run "${run_id}")

  find "${AE_SENS_OUTPUT_ROOT}/raw_models/${run_id}" -name predictor.pkl -type f -size +0c -print -quit | grep -q .
  grep -q "${run_id},01_prepare_raw_inputs,completed" "${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv"
  grep -q "${run_id},02_raw_autogluon,completed" "${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv"
  grep -q "${run_id},03_raw_evaluation,completed" "${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv"
  grep -q "${run_id},04_raw_11c_index,completed" "${AE_SENS_OUTPUT_ROOT}/logs/${run_id}/run_status.csv"
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

echo "[AE-SENS-007] full-grid driver started $(date -Iseconds)"
for cfg in "${configs[@]}"; do
  read -r run_id c_value m_value t_value <<< "${cfg}"
  start_ts="$(date -Iseconds)"
  echo "[AE-SENS-007] considering ${run_id} at ${start_ts}"

  if run_complete "${run_id}"; then
    end_ts="$(date -Iseconds)"
    echo "${run_id},${c_value},${m_value},${t_value},skipped_complete,${start_ts},${end_ts},0,reused existing complete isolated run" >> "${OVERALL_STATUS}"
    append_step_status "${run_id}"
    echo "[AE-SENS-007] reused complete ${run_id}"
    continue
  fi

  if run_partial "${run_id}"; then
    end_ts="$(date -Iseconds)"
    echo "${run_id},${c_value},${m_value},${t_value},blocked_partial,${start_ts},${end_ts},3,non-empty incomplete run directory requires manual scoped resume" >> "${OVERALL_STATUS}"
    append_step_status "${run_id}"
    echo "[AE-SENS-007] partial incomplete ${run_id}; continuing"
    continue
  fi

  echo "[AE-SENS-007] running ${run_id}"
  set +e
  env MT_ROOT="${MT_ROOT}" \
      AE_SENS_OUTPUT_ROOT="${AE_SENS_OUTPUT_ROOT}" \
      AE_SENS_RUN_ID="${run_id}" \
      AE_SENS_C="${c_value}" \
      AE_SENS_M="${m_value}" \
      AE_SENS_T="${t_value}" \
      MODEL=raw \
      RESPONSE_TRACK=dynamic_csi \
      bash "${MT_ROOT}/01_Code/shell/run_ae_sens_raw_one.sh"
  exit_code=$?
  set -e
  end_ts="$(date -Iseconds)"

  append_step_status "${run_id}"
  if [[ "${exit_code}" -eq 0 ]] && run_complete "${run_id}"; then
    echo "${run_id},${c_value},${m_value},${t_value},completed,${start_ts},${end_ts},0,new isolated run completed" >> "${OVERALL_STATUS}"
    echo "[AE-SENS-007] completed ${run_id}"
  else
    echo "${run_id},${c_value},${m_value},${t_value},failed,${start_ts},${end_ts},${exit_code},runner exited nonzero or required outputs missing" >> "${OVERALL_STATUS}"
    echo "[AE-SENS-007] failed ${run_id} exit=${exit_code}; continuing"
  fi
done

echo "[AE-SENS-007] full-grid driver ended $(date -Iseconds)"
