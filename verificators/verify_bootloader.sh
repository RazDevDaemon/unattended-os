#!/usr/bin/env bash

verify_bootloader() {
  local failed=0

  # verify GRUB is installed on ESP
  [[ -f "/mnt/boot/EFI/GRUB/grubx64.efi" ]] || \
    { warn "Verify failed: GRUB EFI binary missing"; failed=1; }

  # verify GRUB config exists
  [[ -f "/mnt/boot/grub/grub.cfg" ]] || \
    { warn "Verify failed: grub.cfg missing"; failed=1; }

  # verify both kernels are in grub config
  for kernel in $KERNELS; do
    grep -q "$kernel" "/mnt/boot/grub/grub.cfg" || \
      { warn "Verify failed: $kernel not found in grub.cfg"; failed=1; }
  done

  # verify cryptdevice in grub config if root is encrypted
  if [[ "$LUKS_ROOT" == "true" ]]; then
    grep -q "cryptdevice" "/mnt/boot/grub/grub.cfg" || \
      { warn "Verify failed: cryptdevice not in grub.cfg"; failed=1; }
  fi

  [[ $failed -eq 0 ]] || error "bootloader verification failed"
  log "bootloader verified ✓"
  return 0
}