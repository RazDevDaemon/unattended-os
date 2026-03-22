#!/usr/bin/env bash
# ============================================================
# Arch Linux Automated Installer
# Usage: ./install.sh [config_file] [--unattended]
# ============================================================

set -euo pipefail

# ── Parse arguments ─────────────────────────────────────────
UNATTENDED=false
for arg in "$@"; do
  case $arg in
    --unattended) UNATTENDED=true ;;
  esac
done

# ── Load libraries ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/config.sh"

# ── Load stages ─────────────────────────────────────────────
source "$SCRIPT_DIR/stages/partition.sh"
source "$SCRIPT_DIR/stages/format.sh"
source "$SCRIPT_DIR/stages/mount.sh"
source "$SCRIPT_DIR/stages/pacstrap.sh"
source "$SCRIPT_DIR/stages/chroot-setup.sh"
source "$SCRIPT_DIR/stages/bootloader.sh"

# ── Dependency check ─────────────────────────────────────────
command -v yq    &>/dev/null || error "yq is required"
command -v fdisk &>/dev/null || error "fdisk not found"

# ── Load config ──────────────────────────────────────────────
load_config "${1:-install-conf.yaml}"

# ── Pre-flight checks ────────────────────────────────────────
section "Pre-flight checks"
[[ $EUID -eq 0 ]] || error "Must be run as root"
[[ -d /sys/firmware/efi ]] || error "Not booted in UEFI mode"

log "Waiting for network..."
for i in {1..10}; do
  ping -c 1 -W 3 archlinux.org &>/dev/null && break
  warn "Network not ready, retry $i/10..."
  sleep 5
done
ping -c 1 -W 3 archlinux.org &>/dev/null || error "No internet connection after retries"
log "All pre-flight checks passed"

# ── Auto-detect disk ─────────────────────────────────────────
section "Detecting disk"
DISK=$(lsblk -dpno NAME,TYPE,RM,SIZE \
  | awk '$2=="disk" && $3=="0" {print $1, $4}' \
  | sort -k2 -h \
  | tail -1 \
  | awk '{print $1}')
[[ -n "$DISK" ]] || error "No suitable disk found"
log "Target disk: $DISK"

warn "ALL DATA ON $DISK WILL BE DESTROYED"
if [[ "$UNATTENDED" == false ]]; then
  read -rp "Type 'yes' to continue: " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || error "Aborted by user"
else
  warn "Unattended mode — skipping confirmation"
fi

# ── Run stages ───────────────────────────────────────────────
do_partition
do_format
do_mount
do_pacstrap
do_fstab
do_chroot
do_bootloader

# ── Done ─────────────────────────────────────────────────────
section "Installation complete"
log "Rebooting in 10 seconds..."
sleep 10
reboot