#!/usr/bin/env bash

do_mount() {
  section "Mounting partitions"

  mount "$PART_ROOT" /mnt

  mkdir -p /mnt/boot
  mount "$PART_ESP" /mnt/boot

  mkdir -p /mnt/home
  mount "$PART_HOME" /mnt/home

  mkdir -p "/mnt${MEDIA_MOUNT}"
  mount "$PART_MEDIA" "/mnt${MEDIA_MOUNT}"

  log "All partitions mounted"
}