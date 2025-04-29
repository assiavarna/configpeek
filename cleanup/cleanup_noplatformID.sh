#!/bin/bash

BASE_DIR="/Users/assia/workspace/BUILDS_C5/configpeek"
FOLDERS=("$BASE_DIR/latestConfigs_prod" "$BASE_DIR/latestConfigs_stage")
LOG_FILE="$BASE_DIR/cleanup/cleanup_deleted_files.log"

> "$LOG_FILE"  # Clear old log

echo "🧹 Starting cleanup of config files missing the 'platformId' key..."

for DIR in "${FOLDERS[@]}"; do
  echo "📁 Scanning: $DIR"
  while IFS= read -r -d '' file; do
    # Extract platformId using grep
    platform_id=$(grep -o '"platformId"[[:space:]]*:[[:space:]]*"[^"]*"' "$file" | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)"/\1/')
    
    if [[ -z "$platform_id" ]]; then
      echo "❌ Deleting $file (missing 'platformId')" | tee -a "$LOG_FILE"
      rm -f "$file"
    fi
  done < <(find "$DIR" -type f -name "*.json" -print0)
done

# Count deleted files based on the log file
DELETED_COUNT=$(grep -c '^❌ Deleting ' "$LOG_FILE")

echo ""
echo "✅ Cleanup complete."
echo "🗑️  Total files deleted: $DELETED_COUNT"
echo "📄 Log saved to: $LOG_FILE"
