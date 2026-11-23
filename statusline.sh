#!/bin/bash
input=$(cat)

CACHE_DIR=/tmp/statusline_cache
mkdir -p "$CACHE_DIR"

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
SESSION=$(echo "$input" | jq -r '.session_id // empty')
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
RATE5=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RATE7=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RESET5=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
RESET7=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RATE_CACHE="$CACHE_DIR/rates.json"
CTX_CACHE="$CACHE_DIR/ctx_${SESSION}.txt"

# persist rate limits (account-wide, survive restarts)
# gate on resets_at: at fresh session start percentages arrive but resets_at is null
if [[ -n "$RESET5" || -n "$RESET7" ]]; then
  echo "{\"r5\":\"${RATE5:-0}\",\"r7\":\"${RATE7:-0}\",\"reset5\":\"${RESET5:-}\",\"reset7\":\"${RESET7:-}\"}" > "$RATE_CACHE"
elif [[ -f "$RATE_CACHE" ]]; then
  RATE5=$(jq -r '.r5' "$RATE_CACHE")
  RATE7=$(jq -r '.r7' "$RATE_CACHE")
  RESET5=$(jq -r '.reset5 // empty' "$RATE_CACHE")
  RESET7=$(jq -r '.reset7 // empty' "$RATE_CACHE")
fi

fmt_reset() {
  [[ -z "$1" || "$1" == "null" ]] && { echo "?"; return; }
  date -r "${1%.*}" "+%H:%M" 2>/dev/null || echo "?"
}
fmt_reset_date() {
  [[ -z "$1" || "$1" == "null" ]] && { echo "?"; return; }
  date -r "${1%.*}" "+%A" 2>/dev/null || echo "?"
}
RESET5_FMT=$(fmt_reset "$RESET5")
RESET7_FMT=$(fmt_reset_date "$RESET7")

# persist context per session (resets on new session / /clear)
if [[ -n "$CTX" && -n "$SESSION" ]]; then
  echo "$CTX" > "$CTX_CACHE"
elif [[ -n "$SESSION" && -f "$CTX_CACHE" ]]; then
  CTX=$(cat "$CTX_CACHE")
fi

bar() {
  local pct=${1%.*} width=20
  local filled=$(( pct * width / 100 ))
  [[ $filled -eq 0 && $pct -gt 0 ]] && filled=1
  local empty=$(( width - filled ))
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
}

printf "[%s] ctx: %s %s%% | until %s: %s %s%% | until %s: %s %s%%\n\n" \
  "$MODEL" "$(bar "${CTX:-0}")" "${CTX%.*}" "$RESET5_FMT" "$(bar "${RATE5:-0}")" "${RATE5%.*}" "$RESET7_FMT" "$(bar "${RATE7:-0}")" "${RATE7%.*}"
