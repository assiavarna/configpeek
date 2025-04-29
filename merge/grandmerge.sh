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

  for CONFIG_DIR in "$BASE_DIR/latestConfigs_prod" "$BASE_DIR/latestConfigs_stage"; do
    ENVIRONMENT=$(basename "$CONFIG_DIR" | grep -qi "stage" && echo "staging" || echo "production")
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

  echo "✅ Merged $(ls -1 "$BASE_DIR/latestConfigs_prod"/*.json 2>/dev/null | wc -l) prod and $(ls -1 "$BASE_DIR/latestConfigs_stage"/*.json 2>/dev/null | wc -l) staging files into $OUTPUT_FILE"

} 2>&1 | tee -a "$LOG_FILE"   
