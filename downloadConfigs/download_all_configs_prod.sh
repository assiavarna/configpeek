#!/bin/bash

BASE_URL="https://cassie.channel5.com/admin/config_variants"
USER_AGENT="Mozilla/5.0"
COOKIE="_cassie_session=l6UHZ3Kwrp77nhNLhKPaP3KpqN%2FOed%2BLGrYrUzwBmEH0J1oJZAV3YBcOhiBQgo7QIym0D0x%2Fn%2BWwpAQJrForBnbGqmcdP001v5%2FWLoK8v9cb8Yh0OzdJj5tIYOCMRwvUgBPAY6EuyQ2ZNClhqNW8PSp%2FD1MsTcWDzqOQV1qAScYMTwUeIL56Lairp8SG5DCu%2FZZBji7%2FIz6P26sKv58Qh81TEJp8tkcm2GVj071lLIP0ndag8CCS9fy6dtMnX40jBsyKj8Yne%2FT%2F66qAkcbi9xuPqdX5Du3%2BRU0oe%2BxljA%2BUre537CHGDLlmnk9aNBm1iZSu9Bd7pawiya6n7N%2B0u%2FXAVJwvrsbeCDkhNdsk8a3glnnAGlvSF7KyRy%2F6Rj05lbwcH%2Fj3IX9tN2qwFn3r6FGsfY8gnXF9ELvkZKMlbaSqir%2FQOSNySrEuNr1YZXuB3hpv8hNAYbvMwNPBdhOSQBVSuE2X9CB9eobuNLqsg1wQkS6rCsK1kwKUdG%2FqxK5gNH79ikuutV87H%2BXLblv6EIGkx03PvOvTFf39to8kz5X4XQUu59W2ocds5o6mp5B9iiUQ9unXYXlHS0mTuywRCAPRX4MdpZePW6VNLi3u1PU5--bmqMtgOaS6FwsA6%2B--xKWG%2ByN0hnUvAXsIdLMOwQ%3D%3D"

DEST_DIR="./latestConfigs_prod"
LOG_FILE="$DEST_DIR/download_log.txt"

mkdir -p "$DEST_DIR"
> "$LOG_FILE"

MAX_ID=999
FAIL_COUNT_AFTER_560=0
FAIL_LIMIT_AFTER_560=20

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

            if [[ $id -ge 560 ]]; then
                ((FAIL_COUNT_AFTER_560++))
                echo "   ⚠️ Failure count after 560: $FAIL_COUNT_AFTER_560" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_560 -ge $FAIL_LIMIT_AFTER_560 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_560 failures after ID 560." | tee -a "$LOG_FILE"
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

            if [[ $id -ge 560 ]]; then
                ((FAIL_COUNT_AFTER_560++))
                echo "   ⚠️ Failure count after 560: $FAIL_COUNT_AFTER_560" | tee -a "$LOG_FILE"
                if [[ $FAIL_COUNT_AFTER_560 -ge $FAIL_LIMIT_AFTER_560 ]]; then
                    echo "🚫 Stopping: Reached $FAIL_COUNT_AFTER_560 failures after ID 560." | tee -a "$LOG_FILE"
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


