#!/usr/bin/env bash
# ── Colours ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()     { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }
section() { echo -e "\n${CYAN}══ $* ══${NC}"; }

# ── State tracking ───────────────────────────────────────────
STATE_FILE="/mnt/install-state"

stage_done() {
  grep -q "^${1}$" "$STATE_FILE" 2>/dev/null
}

mark_done() {
  echo "$1" >> "$STATE_FILE"
}

run_stage() {
  local stage=$1
  local fn=$2

  if stage_done "$stage"; then
    log "Skipping '$stage' — already completed"
    return
  fi

  $fn
  mark_done "$stage"
}
