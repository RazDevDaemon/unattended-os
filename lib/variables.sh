#!/usr/bin/env bash

setup_variables() {
  # ── Partition names ──────────────────────────────────
  if [[ "$DISK" == *"nvme"* ]]; then
    PART_ESP="${DISK}p1"
    PART_SWAP="${DISK}p2"
    PART_ROOT="${DISK}p3"
    PART_HOME="${DISK}p4"
    PART_MEDIA="${DISK}p5"
  else
    PART_ESP="${DISK}1"
    PART_SWAP="${DISK}2"
    PART_ROOT="${DISK}3"
    PART_HOME="${DISK}4"
    PART_MEDIA="${DISK}5"
  fi

  # ── Mapper names (used if LUKS enabled) ──────────────
  MAPPER_ROOT="cryptroot"
  MAPPER_HOME="crypthome"
  MAPPER_SWAP="cryptswap"
  MAPPER_MEDIA="cryptmedia"
  return 0
}