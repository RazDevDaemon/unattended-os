#!/usr/bin/env bash

do_mount() {
  section "Mounting partitions"

  # ── Root ──────────────────────────────────────────────
  if [[ "$LUKS_ROOT" == "true" ]]; then
    mount "/dev/mapper/$MAPPER_ROOT" /mnt
  else
    mount "$PART_ROOT" /mnt
  fi

  # ── ESP — never encrypted ─────────────────────────────
  mkdir -p /mnt/boot
  mount "$PART_ESP" /mnt/boot

  # ── Home ──────────────────────────────────────────────
  mkdir -p "/mnt${MOUNT_HOME}"
  if [[ "$LUKS_HOME" == "true" ]]; then
    mount "/dev/mapper/$MAPPER_HOME" "/mnt${MOUNT_HOME}"
  else
    mount "$PART_HOME" "/mnt${MOUNT_HOME}"
  fi

  # ── Media ─────────────────────────────────────────────
  mkdir -p "${MOUNT_MEDIA}"
  if [[ "$LUKS_MEDIA" == "true" ]]; then
    mount "/dev/mapper/$MAPPER_MEDIA" "${MOUNT_MEDIA}"
  else
    mount "$PART_MEDIA" "${MOUNT_MEDIA}"
  fi

  log "All partitions mounted"

  mkdir -p /mnt/etc
  echo "KEYMAP=${KEYMAP}" > /mnt/etc/vconsole.conf
  log "vconsole.conf created"
  return 0
}