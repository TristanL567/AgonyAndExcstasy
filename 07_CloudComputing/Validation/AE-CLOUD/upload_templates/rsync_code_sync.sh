#!/usr/bin/env bash
set -euo pipefail

# Inert future-use template. Do not execute until all placeholders are replaced:
# <SSH_KEY_PATH>, <PORT>, <USER>, <HOST>, <REMOTE_PROJECT>
# Sync code/config separately from data. Review every include/exclude rule before use.
# This template intentionally omits --delete. If --delete is later added, deletion must
# apply only to reviewed code-sync paths and never to data or output directories.
# Run from the repository root.

rsync -av \
  -e "ssh -i <SSH_KEY_PATH> -p <PORT>" \
  --include='01_Code/***' \
  --include='07_CloudComputing/' \
  --include='07_CloudComputing/Validation/' \
  --include='07_CloudComputing/Validation/***' \
  --include='.gitignore' \
  --exclude='02_Data_Input/***' \
  --exclude='03_Data_Output/***' \
  --exclude='04_Research/***' \
  --exclude='05_Documentation/***' \
  --exclude='06_Presentations/***' \
  --exclude='.git/***' \
  --exclude='**/.Rproj.user/***' \
  --exclude='**/.ipynb_checkpoints/***' \
  --exclude='**/__pycache__/***' \
  --exclude='**/.pytest_cache/***' \
  --exclude='**/.mypy_cache/***' \
  --exclude='**/.ruff_cache/***' \
  --exclude='**/renv/library/***' \
  --exclude='**/AutoGluonModels/***' \
  --exclude='**/autogluon_models/***' \
  --exclude='**/model_artifacts/***' \
  --exclude='**/models/***' \
  --exclude='**/*.zip' \
  --exclude='**/*.tar' \
  --exclude='**/*.tar.gz' \
  --exclude='**/*.tgz' \
  --exclude='**/*.7z' \
  --exclude='**/*.rds' \
  --exclude='**/*.RDS' \
  --exclude='**/*.parquet' \
  --exclude='**/*.csv' \
  --exclude='**/*.tsv' \
  --exclude='**/*.feather' \
  --exclude='**/*.fst' \
  --exclude='**/*.pdf' \
  --exclude='**/*.docx' \
  --exclude='**/*.pptx' \
  --exclude='*' \
  ./ \
  <USER>@<HOST>:<REMOTE_PROJECT>/

