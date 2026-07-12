#!/usr/bin/env bash
# transcript.sh — Transcript content extraction for barnhk notifications

debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "/tmp/barnhk-transcript-debug.log" 2>/dev/null || true
}

# Extract specific content from transcript file
# Usage: extract_transcript_content <transcript_path> <session_id> [max_length]
extract_transcript_content() {
    local transcript_path="$1"
    local current_session="$2"
    local max_len="${3:-200}"

    debug_log "=== extract_transcript_content called ==="
    debug_log "transcript_path: $transcript_path"
    debug_log "current_session: $current_session"
    debug_log "max_len: $max_len"

    if [[ ! -f "$transcript_path" ]]; then
        debug_log "ERROR: transcript file not found"
        return 1
    fi

    local extracted_text=""
    local line_count=0
    local matched_lines=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        ((line_count++))
        [[ $line_count -gt 30 ]] && break

        local line_session
        line_session=$(echo "$line" | jq -r '.sessionId // .session_id // empty' 2>/dev/null)

        if [[ "$line_session" != "$current_session" ]]; then
            continue
        fi

        ((matched_lines++))
        debug_log "Line $line_count: session matched ($line_session)"

        local msg_type
        msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
        debug_log "Line $line_count: type=$msg_type"

        if [[ "$msg_type" != "assistant" ]]; then
            continue
        fi

        local text_content=""
        text_content=$(echo "$line" | jq -r '.message.content[] | select(.type == "text") | .text' 2>/dev/null | head -1)
        [[ -z "$text_content" ]] && text_content=$(echo "$line" | jq -r '.content[] | select(.type == "text") | .text' 2>/dev/null | head -1)
        [[ -z "$text_content" ]] && text_content=$(echo "$line" | jq -r '.message.text // empty' 2>/dev/null)
        [[ -z "$text_content" ]] && text_content=$(echo "$line" | jq -r '.text // empty' 2>/dev/null)

        if [[ -n "$text_content" ]]; then
            debug_log "Line $line_count: extracted text (${#text_content} chars)"
            extracted_text="$text_content"
        else
            debug_log "Line $line_count: no text content found"
        fi
    done < <(tac "$transcript_path" 2>/dev/null)

    debug_log "Processed $line_count lines, $matched_lines session matches"

    if [[ -n "$extracted_text" ]]; then
        extracted_text=$(echo "$extracted_text" | tr '\n' ' ' | sed 's/  */ /g')
        if [[ ${#extracted_text} -gt $max_len ]]; then
            echo "${extracted_text:0:$max_len}..."
        else
            echo "$extracted_text"
        fi
        debug_log "SUCCESS: returning text (${#extracted_text} chars)"
        return 0
    fi

    debug_log "FAILURE: no text extracted"
    return 1
}
