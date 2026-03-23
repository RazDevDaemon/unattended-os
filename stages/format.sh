#!/usr/bin/env bash

do_format() {
  section "Formatting partitions"

  # ── ESP ───────────────────────────────────────────────
  if [[ "$WIPE_ESP" == "true" ]]; then
    mkfs.fat -F32 "$PART_ESP"
    log "ESP formatted as FAT32"
  else
    log "Skipping ESP format — wipe disabled"
  fi

  mkswap "$PART_SWAP"
  swapon "$PART_SWAP"
  log "Swap formatted and activated"

  # ── Root ──────────────────────────────────────────────
  if [[ "$WIPE_ROOT" == "true" ]]; then
    if [[ "$LUKS_ROOT" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_ROOT" -
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_ROOT" "$MAPPER_ROOT" -
      mkfs."$FS_ROOT" "/dev/mapper/$MAPPER_ROOT"
      log "Root encrypted and formatted as $FS_ROOT"
    else
      mkfs."$FS_ROOT" -f "$PART_ROOT" 2>/dev/null || mkfs."$FS_ROOT" "$PART_ROOT"
      log "Root formatted as $FS_ROOT"
    fi
  else
    if [[ "$LUKS_ROOT" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_ROOT" "$MAPPER_ROOT" -
    fi
    log "Skipping root format — wipe disabled, opened existing"
  fi

  # ── Home ──────────────────────────────────────────────
  if [[ "$WIPE_HOME" == "true" ]]; then
    if [[ "$LUKS_HOME" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_HOME" -
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_HOME" "$MAPPER_HOME" -
      mkfs."$FS_HOME" "/dev/mapper/$MAPPER_HOME"
      log "Home encrypted and formatted as $FS_HOME"
    else
      mkfs."$FS_HOME" "$PART_HOME"
      log "Home formatted as $FS_HOME"
    fi
  else
    if [[ "$LUKS_HOME" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_HOME" "$MAPPER_HOME" -
    fi
    log "Skipping home format — wipe disabled, opened existing"
  fi

  # ── Swap ──────────────────────────────────────────────
  swapoff "$PART_SWAP" 2>/dev/null || true   # deactivate if in use
  if [[ "$WIPE_SWAP" == "true" ]]; then
    if [[ "$LUKS_SWAP" == "true" ]]; then
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
  else
    # just activate existing swap
    if [[ "$LUKS_SWAP" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_SWAP" "$MAPPER_SWAP" -
      swapon "/dev/mapper/$MAPPER_SWAP"
    else
      swapon "$PART_SWAP"
    fi
    log "Skipping swap format — wipe disabled, activated existing"
  fi

  # ── Media ──────────────────────────────────────────────
  if [[ "$WIPE_MEDIA" == "true" ]]; then
    if [[ "$LUKS_MEDIA" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat "$PART_MEDIA" -
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_MEDIA" "$MAPPER_MEDIA" -
      mkfs."$FS_MEDIA" "/dev/mapper/$MAPPER_MEDIA"
      log "Media encrypted and formatted as $FS_MEDIA"
    else
      mkfs."$FS_MEDIA" "$PART_MEDIA"
      log "Media formatted as $FS_MEDIA"
    fi
  else
    if [[ "$LUKS_MEDIA" == "true" ]]; then
      echo -n "$LUKS_PASSPHRASE" | cryptsetup open "$PART_MEDIA" "$MAPPER_MEDIA" -
    fi
    log "Skipping media format — wipe disabled, opened existing"
  fi

  return 0
}