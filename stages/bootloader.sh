#!/usr/bin/env bash

do_bootloader() {
  section "Installing bootloader"

  arch-chroot /mnt /bin/bash <<EOF
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB installed and configured"
EOF

  log "Bootloader installed"
}