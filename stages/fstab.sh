#!/usr/bin/env bash

do_fstab() {
  section "Generating fstab"

  genfstab -U /mnt >> /mnt/etc/fstab
  log "fstab generated"
}