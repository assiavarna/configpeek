#!/bin/bash

BASE_DIR="/Users/assia/workspace/BUILDS_C5/configpeek"
OUTPUT_FILE="$BASE_DIR/results/grandmerge.json"

LOG_FILE="$BASE_DIR/results/merge_log.txt"
mkdir -p "$(dirname "$OUTPUT_FILE")"

{
  echo "=== Merged at $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo ""
} > "$LOG_FILE"

{
  echo "[" > "$OUTPUT_FILE"

  first=1

  for CONFIG_DIR in \
    "$BASE_DIR/latestConfigs_prod" \
    "$BASE_DIR/latestConfigs_stage" \
    "$BASE_DIR/latestConfigs_test"; do

    dir_name=$(basename "$CONFIG_DIR")
    case "$dir_name" in
      *_test)    ENVIRONMENT="test" ;;  
      *_stage)   ENVIRONMENT="staging" ;;  
      *)         ENVIRONMENT="production" ;;  
    esac

    for file in "$CONFIG_DIR"/*.json; do
      [ -e "$file" ] || continue

      if [[ $first -eq 0 ]]; then
        echo "," >> "$OUTPUT_FILE"
      fi

      jq -c --arg env "$ENVIRONMENT" --arg file "$(basename "$file")" \
        '{filename: $file, environment: $env} + .' "$file" >> "$OUTPUT_FILE"

      first=0
    done
  done

  echo "]" >> "$OUTPUT_FILE"

  echo "✅ Merged $(ls -1 "$BASE_DIR/latestConfigs_prod"/*.json 2>/dev/null | wc -l) prod, \
$(ls -1 "$BASE_DIR/latestConfigs_stage"/*.json 2>/dev/null | wc -l) staging, and \
$(ls -1 "$BASE_DIR/latestConfigs_test"/*.json 2>/dev/null | wc -l) test files into $OUTPUT_FILE"

} 2>&1 | tee -a "$LOG_FILE"
