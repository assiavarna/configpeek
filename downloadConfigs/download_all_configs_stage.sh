#!/bin/bash

BASE_URL="https://cassie-staging.channel5.com/admin/config_variants"
USER_AGENT="Mozilla/5.0"
COOKIE="_cassie_session=QLixQGgtT4t9Tle9eloY5JoHnPa7HcUVdqktsuPAzH76TKfQ6wzl99rJmihfD1fG1KrVeYKyl%2BCVZMF2M%2F0rsESRdg1YydML5Ruoh6%2FfWPiUoxjE3pq5L2fDg%2FeFoovGUqyE0F9KU4j%2FBtVrXNtM%2FhaDX7K%2BE74Emn2txpwJg6DknGZygvlJ9ZzWtBucsM9IdCXE%2FnUa4Pt%2BChuYTJCNAFfDiaYIbt8%2Bv4kqKTZoUZlpCe7xI4WajALHD1IwdT2nBytExPSlvB7zlCz8nAA8XKNppXdYOBmaDBeb5jdbgr0OR1uDsuMh4KY%2BA9rwnGAIueSltM7wE3BhevIix9gveQ%3D%3D--NiuOEZKDu8QxS7ki--DOAQhoU7EDgzVkhx5DvqFQ%3D%3D"

DEST_DIR="./latestConfigs_stage"
LOG_FILE="$DEST_DIR/download_log.txt"

mkdir -p "$DEST_DIR"
> "$LOG_FILE"

MAX_ID=999
FAIL_COUNT_AFTER_710=0
FAIL_LIMIT_AFTER_710=20

# Counters
NEW_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0

for (( id=1; id<=MAX_ID; id++ )); do
    URL="${BASE_URL}/${id}/download"
    OUTPUT_FILE="${DEST_DIR}/config_variant_${id}.json"
    TEMP_FILE="${DEST_DIR}/temp_config_${id}.json"

    echo "Downloading ID $id..." | tee -a "$LOG_FILE"

    if [[ -f "$OUTPUT_FILE" ]]; then
        # Download to temp file to compare
        curl -s -L \
            --header "User-Agent: $USER_AGENT" \
            --header "Cookie: $COOKIE" \
            "$URL" -o "$TEMP_FILE"

        if grep -q "DOCTYPE html" "$TEMP_FILE"; then
            echo "❌ ID $id: Download failed or the page doesn't exist." | tee -a "$LOG_FILE"
            rm -f "$TEMP_FILE"

            if [[ $id -ge 710 ]]; then
                ((FAIL_COUNT_AFTER_710++))
                echo "   ⚠️ Failure count after 710: $FAIL_COUNT_AFTER_710" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_710 -ge $FAIL_LIMIT_AFTER_710 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_710 failures after ID 710." | tee -a "$LOG_FILE"
                    break
                fi
            fi
            continue
        fi

        if cmp -s "$OUTPUT_FILE" "$TEMP_FILE"; then
            echo "⏭️  ID $id: Skipped (unchanged)." | tee -a "$LOG_FILE"
            rm -f "$TEMP_FILE"
            ((SKIPPED_COUNT++))
        else
            mv "$TEMP_FILE" "$OUTPUT_FILE"
            echo "🔁 ID $id: Updated with new content." | tee -a "$LOG_FILE"
            ((UPDATED_COUNT++))
        fi
    else
        # Fresh download
        curl -s -L \
            --header "User-Agent: $USER_AGENT" \
            --header "Cookie: $COOKIE" \
            "$URL" -o "$OUTPUT_FILE"

        if grep -q "DOCTYPE html" "$OUTPUT_FILE"; then
            echo "❌ ID $id: Download failed or the page doesn't exist." | tee -a "$LOG_FILE"
            rm -f "$OUTPUT_FILE"

            if [[ $id -ge 710 ]]; then
                ((FAIL_COUNT_AFTER_710++))
                echo "   ⚠️ Failure count after 710: $FAIL_COUNT_AFTER_710" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_710 -ge $FAIL_LIMIT_AFTER_710 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_710 failures after ID 710." | tee -a "$LOG_FILE"
                    break
                fi
            fi
        else
            echo "✅ ID $id: Downloaded successfully as $OUTPUT_FILE" | tee -a "$LOG_FILE"
            ((NEW_COUNT++))
        fi
    fi
done

# Final summary
echo "" | tee -a "$LOG_FILE"
echo "📊 Summary:" | tee -a "$LOG_FILE"
echo "   ✅ New downloads:   $NEW_COUNT" | tee -a "$LOG_FILE"
echo "   🔁 Updated files:   $UPDATED_COUNT" | tee -a "$LOG_FILE"
echo "   ⏭️  Skipped (same): $SKIPPED_COUNT" | tee -a "$LOG_FILE"
echo "✅ Done. Full log saved to $LOG_FILE" | tee -a "$LOG_FILE"


