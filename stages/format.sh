#!/usr/bin/env bash

do_format() {
  section "Formatting partitions"

  # ── ESP — never encrypted ──────────────────────────────
  mkfs.fat -F32 "$PART_ESP"
  log "ESP formatted as FAT32"

  mkswap "$PART_SWAP"
  swapon "$PART_SWAP"
  log "Swap formatted and activated"

  # ── Root ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_ROOT" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_ROOT" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_ROOT" "$MAPPER_ROOT" -
    mkfs."$FS_ROOT" "/dev/mapper/$MAPPER_ROOT"
    log "Root encrypted and formatted as $FS_ROOT"
  else
    mkfs."$FS_ROOT" -f "$PART_ROOT" 2>/dev/null || mkfs."$FS_ROOT" "$PART_ROOT"
    log "Root formatted as $FS_ROOT"
  fi

  # ── Home ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_HOME" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_HOME" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_HOME" "$MAPPER_HOME" -
    mkfs."$FS_HOME" "/dev/mapper/$MAPPER_HOME"
    log "Home encrypted and formatted as $FS_HOME"
  else
    mkfs."$FS_HOME" "$PART_HOME"
    log "Home formatted as $FS_HOME"
  fi

  # ── Swap ──────────────────────────────────────────────
  swapoff "$PART_SWAP" 2>/dev/null || true   # deactivate if in use
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_SWAP" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_SWAP" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_SWAP" "$MAPPER_SWAP" -
    mkswap "/dev/mapper/$MAPPER_SWAP"
    swapon "/dev/mapper/$MAPPER_SWAP"
    log "Swap encrypted and activated"
  else
    mkswap "$PART_SWAP"
    swapon "$PART_SWAP"
    log "Swap formatted and activated"
  fi

  # ── Media ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_MEDIA" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_MEDIA" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_MEDIA" "$MAPPER_MEDIA" -
    mkfs."$FS_MEDIA" "/dev/mapper/$MAPPER_MEDIA"
    log "Media encrypted and formatted as $FS_MEDIA"
  else
    mkfs."$FS_MEDIA" "$PART_MEDIA"
    log "Media formatted as $FS_MEDIA"
  fi
  return 0
}