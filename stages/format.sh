#!/usr/bin/env bash

do_format() {
  section "Formatting partitions"

  mkfs.fat -F32 "$PART_ESP"
  log "ESP formatted as FAT32"

  mkswap "$PART_SWAP"
  swapon "$PART_SWAP"
  log "Swap formatted and activated"

  mkfs."$FS_ROOT" -f "$PART_ROOT" 2>/dev/null || mkfs."$FS_ROOT" "$PART_ROOT"
  log "Root formatted as $FS_ROOT"

  mkfs."$FS_HOME" "$PART_HOME"
  log "Home formatted as $FS_HOME"

  mkfs."$FS_MEDIA" "$PART_MEDIA"
  log "Media formatted as $FS_MEDIA"
}