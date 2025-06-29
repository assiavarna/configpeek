#!/bin/bash

BASE_URL="https://cassie-test.channel5.com/admin/config_variants"
USER_AGENT="Mozilla/5.0"
COOKIE="_cassie_session=TjJkVBWURoFt5fk%2BHKWy9Fr0UbE%2FbS5NqymcwcfT0LInkwdLIWQrRDqRB3%2F7wsw1DCP7t1YVU4uATVPPQ44v%2BIpv3zEl1HbnDYxvlqlZ2XY7LDZOvqpUNwl1uWQ2Z9lispNjmw6v4elgKsduoeiLyZ7qsT621GTy9hx9mstUjvuCWag00KtGxd9yPFO02H4LjZjY37LNj6gKxf5IN6amnpU15AsVUZxNzB6cj88vKSsC43lzulsrdOjWx6kQdYOds0Y2v84CmgA%2BEtxfJeq0de4kp7mfesTgKv%2BduAedqLhj23l1hYC6y56EnrYbeGAOM9hZe5NVOZY6XEuBcR3gXalAYuBcMLM%3D--ZPJv%2B47VBAWsJYgI--qt9xvep8VCvL4MTpEd10QA%3D%3D"

DEST_DIR="./latestConfigs_test"
LOG_FILE="$DEST_DIR/download_log.txt"

mkdir -p "$DEST_DIR"
> "$LOG_FILE"

MAX_ID=999
FAIL_COUNT_AFTER_640=0
FAIL_LIMIT_AFTER_640=20

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

            if [[ $id -ge 640 ]]; then
                ((FAIL_COUNT_AFTER_640++))
                echo "   ⚠️ Failure count after 640: $FAIL_COUNT_AFTER_640" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_640 -ge $FAIL_LIMIT_AFTER_640 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_640 failures after ID 640." | tee -a "$LOG_FILE"
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

            if [[ $id -ge 640 ]]; then
                ((FAIL_COUNT_AFTER_640++))
                echo "   ⚠️ Failure count after 640: $FAIL_COUNT_AFTER_640" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_640 -ge $FAIL_LIMIT_AFTER_640 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_640 failures after ID 640." | tee -a "$LOG_FILE"
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


