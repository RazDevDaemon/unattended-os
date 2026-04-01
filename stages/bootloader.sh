do_bootloader() {
  section "Installing bootloader"

  # ── Get partition UUIDs ───────────────────────────────
  ROOT_UUID=$(blkid -s UUID -o value "$PART_ROOT")
  LOG_UUID=$(blkid -s UUID -o value "$PART_LOG")
  HOME_UUID=$(blkid -s UUID -o value "$PART_HOME")
  SWAP_UUID=$(blkid -s UUID -o value "$PART_SWAP")

  arch-chroot /mnt /bin/bash <<EOF
# ── GRUB cryptdevice ──────────────────────────────────────
if [[ "${LUKS_ROOT}" == "true" ]]; then
  sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=${ROOT_UUID}:${MAPPER_ROOT} root=/dev/mapper/${MAPPER_ROOT}\"|" /etc/default/grub
  echo "GRUB cryptdevice configured"
fi

# ── crypttab ──────────────────────────────────────────────
[[ "${LUKS_LOG}" == "true" ]]  && echo "${MAPPER_LOG}  UUID=${LOG_UUID}  none luks" >> /etc/crypttab
[[ "${LUKS_HOME}" == "true" ]] && echo "${MAPPER_HOME} UUID=${HOME_UUID} none luks" >> /etc/crypttab
[[ "${LUKS_SWAP}" == "true" ]] && echo "${MAPPER_SWAP} UUID=${SWAP_UUID} none luks" >> /etc/crypttab
echo "crypttab configured"

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB installed and configured"
EOF

  log "Bootloader installed"
  return 0
}