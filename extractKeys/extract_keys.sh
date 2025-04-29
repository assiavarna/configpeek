#!/bin/bash

set -e

echo "🔍 Starting key extraction from config folders..."

BASE_DIR="./"
KEYS_FILE="${BASE_DIR}extractKeys/keys.json"
LOG_FILE="${BASE_DIR}extractKeys/extraction.log"

mkdir -p "$(dirname "$KEYS_FILE")"
> "$KEYS_FILE"
> "$LOG_FILE"


{
  echo "=== Keys extracted at $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo ""
} > "$LOG_FILE"


total_files=0
skipped_files=0
skipped_list=()

process_folder() {
    local folder="$1"
    echo "📁 Processing: $folder" | tee -a "$LOG_FILE"

    if [ -d "$folder" ]; then
        while IFS= read -r -d '' file; do
            ((total_files++))
            error_output=$(jq '.' "$file" 2>&1)
            local jq_exit_code=$?

            if [[ "$error_output" =~ "parse error" || "$jq_exit_code" -ne 0 ]]; then
                echo "❌ Skipped (parse error): $file" | tee -a "$LOG_FILE"
                echo "   Error: $error_output" >> "$LOG_FILE"
                echo "   Preview:" >> "$LOG_FILE"
                head -n 5 "$file" | sed 's/^/   /' >> "$LOG_FILE"
                echo "" >> "$LOG_FILE"
                skipped_list+=("$file")
                ((skipped_files++))
            else
                jq -r 'paths(scalars) | join(".")' "$file" >> "$KEYS_FILE"
            fi
        done < <(find "$folder" -type f -name "*.json" -print0)
    else
        echo "⚠️ Warning: Folder '$folder' not found." | tee -a "$LOG_FILE"
    fi
}

process_folder "${BASE_DIR}latestConfigs_prod"
process_folder "${BASE_DIR}latestConfigs_stage"

sort "$KEYS_FILE" | uniq > "${KEYS_FILE}.tmp" && mv "${KEYS_FILE}.tmp" "$KEYS_FILE"
jq -Rs 'split("\n") | map(select(. != ""))' "$KEYS_FILE" > "${KEYS_FILE}.tmp" && mv "${KEYS_FILE}.tmp" "$KEYS_FILE"

final_key_count=$(wc -l < "$KEYS_FILE" 2>/dev/null)
processed_files=$((total_files - skipped_files))

{
echo ""
echo "✅ Done! Unique keys written to: $KEYS_FILE"
echo "📄 Full log: $LOG_FILE"
echo "📊 Total files: $total_files"
echo "⏭️  Files with errors: $skipped_files"
echo "➡️  Files processed: $processed_files"
echo "🗝️  Keys extracted: $final_key_count"

if (( skipped_files > 0 )); then
    echo ""
    echo "🛑 Skipped files:"
    for file in "${skipped_list[@]}"; do
        echo " - $file"
    done
fi
} | tee -a "$LOG_FILE"

