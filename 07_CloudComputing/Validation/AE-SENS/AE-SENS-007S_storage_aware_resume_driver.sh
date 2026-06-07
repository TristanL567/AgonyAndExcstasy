#!/usr/bin/env bash
set -euo pipefail

: "${MT_ROOT:?MT_ROOT is required}"
: "${AE_SENS_OUTPUT_ROOT:?AE_SENS_OUTPUT_ROOT is required}"

if [[ "${AE_SENS_OUTPUT_ROOT}" != */03_Data_Output/3_Modelling_Results/Necessary/sensitivity ]]; then
  echo "AE_SENS_OUTPUT_ROOT is outside the approved sensitivity root" >&2
  exit 2
fi

RUNNER="${MT_ROOT}/01_Code/shell/run_ae_sens_raw_one.sh"
PRUNE="${AE_SENS_OUTPUT_ROOT}/logs/AE-SENS-007S_storage_retention/AE-SENS-007S_storage_retention_remote.py"
LOG_DIR="${AE_SENS_OUTPUT_ROOT}/logs/AE-SENS-007S_storage_aware_resume"
mkdir -p "${LOG_DIR}"

STATUS="${LOG_DIR}/AE-SENS-007S_storage_aware_status.csv"
DECISIONS="${LOG_DIR}/AE-SENS-007S_storage_aware_resume_decisions.csv"
STEP_STATUS="${LOG_DIR}/AE-SENS-007S_storage_aware_step_status.csv"

echo "run_id,C,M,T,status,started_at,ended_at,exit_code,note" > "${STATUS}"
echo "run_id,decision,reason" > "${DECISIONS}"
echo "run_id,step,status" > "${STEP_STATUS}"

ordered_runs=(
  C090_M000_T012 C090_M000_T018 C090_M000_T028
  C090_M020_T012 C090_M020_T018 C090_M020_T028
  C090_M030_T012 C090_M030_T018 C090_M030_T028
  C080_M000_T012 C080_M000_T018 C080_M000_T028
  C080_M020_T012 C080_M020_T018 C080_M020_T028
  C080_M030_T012 C080_M030_T018 C080_M030_T028
  C060_M000_T012 C060_M000_T018 C060_M000_T028
  C060_M020_T012 C060_M020_T018 C060_M020_T028
  C060_M030_T012 C060_M030_T018 C060_M030_T028
)

params_for_run() {
  local run_id="$1"
  local c="${run_id:1:3}"
  local m="${run_id:6:3}"
  local t="${run_id:11:3}"
  case "${c}" in
    060) c="-0.60" ;;
    080) c="-0.80" ;;
    090) c="-0.90" ;;
    *) return 2 ;;
  esac
  case "${m}" in
    M00|000) m="0.00" ;;
    020) m="-0.20" ;;
    030) m="-0.30" ;;
    *) return 2 ;;
  esac
  case "${t}" in
    012) t="12" ;;
    018) t="18" ;;
    028) t="28" ;;
    *) return 2 ;;
  esac
  printf '%s,%s,%s' "${c}" "${m}" "${t}"
}

exists_nonempty() {
  local d="$1"
  [[ -d "${d}" ]] && [[ -n "$(find "${d}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]
}

complete_run() {
  local r="$1"
  local root="${AE_SENS_OUTPUT_ROOT}"
  local pred="${root}/raw_predictions/${r}"
  local eval="${root}/evaluation/${r}"
  local idx="${root}/index_construction/${r}"
  [[ -s "${pred}/ag_eval_summary.json" ]] || return 1
  [[ -s "${pred}/ag_leaderboard.csv" ]] || return 1
  [[ -s "${pred}/ag_cv_results.parquet" ]] || return 1
  [[ -s "${pred}/ag_preds_test_eval.parquet" ]] || return 1
  [[ -s "${pred}/ag_preds_oos_eval.parquet" ]] || return 1
  [[ -s "${eval}/raw_model_metrics.csv" ]] || return 1
  [[ -s "${eval}/raw_prediction_row_counts.csv" ]] || return 1
  [[ -s "${idx}/index_thresholds_by_crsp_universe.csv" ]] || return 1
  [[ -s "${idx}/index_thresholds_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/index_weights_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/index_returns_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/index_performance_by_crsp_universe.csv" ]] || return 1
  [[ -s "${idx}/index_performance_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/index_exclusion_summary_by_crsp_universe.csv" ]] || return 1
  [[ -s "${idx}/index_exclusion_summary_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/error_cost_decomposition_by_crsp_universe.csv" ]] || return 1
  [[ -s "${idx}/error_cost_decomposition_by_crsp_universe.rds" ]] || return 1
  [[ -s "${idx}/run_status.csv" ]] || return 1
  return 0
}

partial_run() {
  local r="$1"
  local root="${AE_SENS_OUTPUT_ROOT}"
  local cat
  for cat in labels raw_features/by_config raw_models raw_predictions evaluation index_construction logs; do
    if exists_nonempty "${root}/${cat}/${r}"; then
      return 0
    fi
  done
  return 1
}

record_steps_from_log() {
  local r="$1"
  local status_file="${AE_SENS_OUTPUT_ROOT}/logs/${r}/run_status.csv"
  if [[ -s "${status_file}" ]]; then
    awk -F, -v run_id="${r}" 'NR>1 { print run_id "," $2 "," $3 }' "${status_file}" >> "${STEP_STATUS}" || true
  fi
}

prune_completed() {
  if [[ -s "${PRUNE}" ]]; then
    python3 "${PRUNE}" > "${LOG_DIR}/storage_prune_latest.stdout.log" 2> "${LOG_DIR}/storage_prune_latest.stderr.log" || return 1
  fi
}

run_one() {
  local r="$1"
  local params c m t started ended exit_code
  params="$(params_for_run "${r}")"
  IFS=, read -r c m t <<< "${params}"
  started="$(date -Iseconds)"

  if complete_run "${r}"; then
    prune_completed || true
    ended="$(date -Iseconds)"
    echo "${r},${c},${m},${t},skipped_complete_storage_pruned,${started},${ended},0,reused retained complete run" >> "${STATUS}"
    echo "${r},reuse_complete,retained outputs already complete" >> "${DECISIONS}"
    record_steps_from_log "${r}"
    return 0
  fi

  if partial_run "${r}"; then
    ended="$(date -Iseconds)"
    echo "${r},${c},${m},${t},blocked_partial,${started},${ended},3,non-empty partial outputs lack documented safe overwrite resume" >> "${STATUS}"
    echo "${r},blocked_partial,non-empty partial output directories present before run" >> "${DECISIONS}"
    record_steps_from_log "${r}"
    return 0
  fi

  echo "${r},run_full,empty isolated directories" >> "${DECISIONS}"
  set +e
  (
    export AE_SENS_RUN_ID="${r}"
    export AE_SENS_C="${c}"
    export AE_SENS_M="${m}"
    export AE_SENS_T="${t}"
    export MODEL=raw
    export RESPONSE_TRACK=dynamic_csi
    bash "${RUNNER}"
  ) > "${LOG_DIR}/${r}.stdout.log" 2> "${LOG_DIR}/${r}.stderr.log"
  exit_code=$?
  set -e
  record_steps_from_log "${r}"

  if [[ ${exit_code} -eq 0 ]] && complete_run "${r}"; then
    prune_completed || true
    ended="$(date -Iseconds)"
    echo "${r},${c},${m},${t},completed_full_storage_pruned,${started},${ended},0,full isolated raw-only run completed and storage policy applied" >> "${STATUS}"
    return 0
  fi

  local avail
  avail="$(df -B1 --output=avail "${AE_SENS_OUTPUT_ROOT}" | tail -n 1 | tr -d ' ')"
  ended="$(date -Iseconds)"
  echo "${r},${c},${m},${t},failed_full,${started},${ended},${exit_code},full isolated run failed or required retained outputs missing" >> "${STATUS}"
  if [[ "${avail}" =~ ^[0-9]+$ ]] && (( avail < 5000000000 )); then
    echo "Stopping because available disk is below 5GB after ${r}: ${avail}" >&2
    return 20
  fi
  return 0
}

for r in "${ordered_runs[@]}"; do
  run_one "${r}"
done

prune_completed || true
df -h "${AE_SENS_OUTPUT_ROOT}" > "${LOG_DIR}/disk_after.txt"
echo "storage-aware resume complete"
