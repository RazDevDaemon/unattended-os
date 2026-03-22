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
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_ROOT" cryptroot -
    mkfs."$FS_ROOT" /dev/mapper/cryptroot
    log "Root encrypted and formatted as $FS_ROOT"
  else
    mkfs."$FS_ROOT" -f "$PART_ROOT" 2>/dev/null || mkfs."$FS_ROOT" "$PART_ROOT"
    log "Root formatted as $FS_ROOT"
  fi

  # ── Home ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_HOME" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_HOME" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_HOME" crypthome -
    mkfs."$FS_HOME" /dev/mapper/crypthome
    log "Home encrypted and formatted as $FS_HOME"
  else
    mkfs."$FS_HOME" "$PART_HOME"
    log "Home formatted as $FS_HOME"
  fi

  # ── Swap ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_SWAP" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_SWAP" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_SWAP" cryptswap -
    mkswap /dev/mapper/cryptswap
    swapon /dev/mapper/cryptswap
    log "Swap encrypted and activated"
  else
    mkswap "$PART_SWAP"
    swapon "$PART_SWAP"
    log "Swap formatted and activated"
  fi

  # ── Media ──────────────────────────────────────────────
  if [[ "$LUKS_ENABLED" == "true" && "$LUKS_MEDIA" == "true" ]]; then
    echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_MEDIA" -
    echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_MEDIA" cryptmedia -
    mkfs."$FS_MEDIA" /dev/mapper/cryptmedia
    log "Media encrypted and formatted as $FS_MEDIA"
  else
    mkfs."$FS_MEDIA" "$PART_MEDIA"
    log "Media formatted as $FS_MEDIA"
  fi
}