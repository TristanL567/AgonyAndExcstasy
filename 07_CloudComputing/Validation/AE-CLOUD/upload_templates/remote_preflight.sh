#!/usr/bin/env bash
set -euo pipefail

# Inert future-use template. Do not execute until all placeholders are replaced:
# <SSH_KEY_PATH>, <PORT>, <USER>, <HOST>, <REMOTE_PROJECT>
# Read-only checks only. This does not install packages and does not run project scripts.

ssh -i <SSH_KEY_PATH> -p <PORT> <USER>@<HOST> 'bash -s' <<'REMOTE_PREFLIGHT'
set -euo pipefail

cd <REMOTE_PROJECT>

echo "## pwd"
pwd

echo "## uname -a"
uname -a

echo "## df -h"
df -h

echo "## free -h"
free -h

echo "## nvidia-smi"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi
else
  echo "nvidia-smi not available"
fi

echo "## Rscript --version"
if command -v Rscript >/dev/null 2>&1; then
  Rscript --version
else
  echo "Rscript not available"
fi

echo "## python --version"
if command -v python >/dev/null 2>&1; then
  python --version
else
  echo "python not available"
fi

echo "## R package checks"
if command -v Rscript >/dev/null 2>&1; then
  Rscript -e 'for (pkg in c("data.table", "arrow")) { cat(pkg, ": "); cat(requireNamespace(pkg, quietly = TRUE), "\n") }'
else
  echo "Skipping R package checks because Rscript is not available"
fi

echo "## Python package checks"
if command -v python >/dev/null 2>&1; then
  python - <<'PY_CHECKS'
import importlib.util

for package in ["pyreadr", "pandas", "autogluon"]:
    print(f"{package}: {importlib.util.find_spec(package) is not None}")
PY_CHECKS
else
  echo "Skipping Python package checks because python is not available"
fi

echo "## git status --short --branch"
git status --short --branch
REMOTE_PREFLIGHT

