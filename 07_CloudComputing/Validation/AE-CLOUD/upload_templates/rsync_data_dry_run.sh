#!/usr/bin/env bash
set -euo pipefail

# Inert future-use template. Do not execute until all placeholders are replaced:
# <SSH_KEY_PATH>, <PORT>, <USER>, <HOST>, <REMOTE_PROJECT>
# Run from the repository root.

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <manifest.tsv>" >&2
  exit 2
fi

MANIFEST="$1"
FILE_LIST="$(mktemp)"
trap 'rm -f "$FILE_LIST"' EXIT

awk -F '\t' '
  NR > 1 &&
  $2 != "produced_by_AE_VALIDATE" &&
  $3 != "" &&
  $3 != "NA" &&
  $3 !~ /^<.*>$/ {
    print $3
  }
' "$MANIFEST" | while IFS= read -r local_path; do
  if [ -f "$local_path" ]; then
    printf '%s\n' "$local_path"
  else
    printf 'Skipping missing local_path: %s\n' "$local_path" >&2
  fi
done > "$FILE_LIST"

if [ ! -s "$FILE_LIST" ]; then
  echo "No uploadable existing local_path rows found in $MANIFEST" >&2
  exit 1
fi

rsync --dry-run -av \
  --files-from="$FILE_LIST" \
  -e "ssh -i <SSH_KEY_PATH> -p <PORT>" \
  ./ \
  <USER>@<HOST>:<REMOTE_PROJECT>/

