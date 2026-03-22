#!/usr/bin/env bash

do_pacstrap() {
  section "Installing base system (pacstrap)"

  # shellcheck disable=SC2086
  pacstrap /mnt base $KERNELS linux-firmware $EXTRA_PACKAGES

  log "Base system installed"
}

do_fstab() {
  section "Generating fstab"

  genfstab -U /mnt >> /mnt/etc/fstab
  log "fstab generated"
}