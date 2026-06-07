#!/usr/bin/env bash
set -euo pipefail

: "${MT_ROOT:?MT_ROOT is required}"
: "${AE_SENS_OUTPUT_ROOT:?AE_SENS_OUTPUT_ROOT is required}"
: "${AE_SENS_RUN_ID:?AE_SENS_RUN_ID is required}"
: "${AE_SENS_C:?AE_SENS_C is required}"
: "${AE_SENS_M:?AE_SENS_M is required}"
: "${AE_SENS_T:?AE_SENS_T is required}"
: "${MODEL:?MODEL is required}"
: "${RESPONSE_TRACK:?RESPONSE_TRACK is required}"

if [[ "${MODEL}" != "raw" ]]; then
  echo "AE-SENS runner only permits MODEL=raw" >&2
  exit 2
fi
if [[ "${RESPONSE_TRACK}" != "dynamic_csi" ]]; then
  echo "AE-SENS runner only permits RESPONSE_TRACK=dynamic_csi" >&2
  exit 2
fi
if [[ ! "${AE_SENS_OUTPUT_ROOT}" =~ /03_Data_Output/3_Modelling_Results/Necessary/sensitivity$ ]]; then
  echo "AE_SENS_OUTPUT_ROOT is outside the approved sensitivity root" >&2
  exit 2
fi

case "${AE_SENS_RUN_ID}" in
  C060_M000_T012|C060_M000_T018|C060_M000_T028|C060_M020_T012|C060_M020_T018|C060_M020_T028|C060_M030_T012|C060_M030_T018|C060_M030_T028|C080_M000_T012|C080_M000_T018|C080_M000_T028|C080_M020_T012|C080_M020_T018|C080_M020_T028|C080_M030_T012|C080_M030_T018|C080_M030_T028|C090_M000_T012|C090_M000_T018|C090_M000_T028|C090_M020_T012|C090_M020_T018|C090_M020_T028|C090_M030_T012|C090_M030_T018|C090_M030_T028) ;;
  *) echo "Invalid AE_SENS_RUN_ID: ${AE_SENS_RUN_ID}" >&2; exit 2 ;;
esac

cd "${MT_ROOT}/01_Code/pipeline"

SENS_ROOT="${AE_SENS_OUTPUT_ROOT}"
for cat in labels raw_features/by_config raw_models raw_predictions evaluation index_construction; do
  dest="${SENS_ROOT}/${cat}/${AE_SENS_RUN_ID}"
  if [[ -d "${dest}" ]] && [[ -n "$(find "${dest}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    echo "AE-SENS fail-closed: non-empty destination ${dest}" >&2
    exit 3
  fi
done

LOG_DIR="${AE_SENS_OUTPUT_ROOT}/logs/${AE_SENS_RUN_ID}"
mkdir -p "${LOG_DIR}"
STATUS_FILE="${LOG_DIR}/run_status.csv"

echo "run_id,step,status,started_at,ended_at" > "${STATUS_FILE}"

run_step() {
  local step="$1"
  shift
  local start_ts end_ts
  start_ts="$(date -Iseconds)"
  echo "[AE-SENS ${AE_SENS_RUN_ID}] START ${step} ${start_ts}"
  "$@" > "${LOG_DIR}/${step}.stdout.log" 2> "${LOG_DIR}/${step}.stderr.log"
  end_ts="$(date -Iseconds)"
  echo "${AE_SENS_RUN_ID},${step},completed,${start_ts},${end_ts}" >> "${STATUS_FILE}"
  echo "[AE-SENS ${AE_SENS_RUN_ID}] DONE ${step} ${end_ts}"
}

run_step "01_prepare_raw_inputs" Rscript ae_sens_prepare_raw_inputs.R
run_step "02_raw_autogluon" python3 09C_AutoGluon.py
run_step "03_raw_evaluation" Rscript ae_sens_eval_raw.R
run_step "04_raw_11c_index" Rscript 11C_IndexConstruction_Revised.R

echo "[AE-SENS ${AE_SENS_RUN_ID}] COMPLETE"
