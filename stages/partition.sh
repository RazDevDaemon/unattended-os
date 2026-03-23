#!/usr/bin/env bash

do_partition() {
  section "Partitioning $DISK"

  # ── Cleanup previous run ──────────────────────────────
  log "Cleaning up previous mounts..."
  swapoff -a 2>/dev/null || true
  cryptsetup close "$MAPPER_MEDIA" 2>/dev/null || true
  cryptsetup close "$MAPPER_HOME"  2>/dev/null || true
  cryptsetup close "$MAPPER_SWAP"  2>/dev/null || true
  cryptsetup close "$MAPPER_ROOT"  2>/dev/null || true
  umount -R /mnt 2>/dev/null || true
  sleep 2

  wipefs -af "$DISK"
  sgdisk -Z "$DISK"

  fdisk "$DISK" <<EOF
g
n
1

+${ESP_SIZE}M
t
1
n
2

+${SWAP_SIZE}M
t
2
19
n
3

+${ROOT_SIZE}M
n
4

+${HOME_SIZE}M
n
5


w
EOF

  partprobe "$DISK"
  sleep 2

  log "Partitions created"
  return 0
}