#!/usr/bin/env bash

verify_users() {
  local failed=0

  # verify user exists
  arch-chroot /mnt id "$USERNAME" &>/dev/null || \
    { warn "Verify failed: user $USERNAME not found"; failed=1; }

  # verify user is in correct groups
  arch-chroot /mnt groups "$USERNAME" | grep -q "$USERGROUPS" || \
    { warn "Verify failed: user $USERNAME not in group $USERGROUPS"; failed=1; }
  arch-chroot /mnt grep -q "^${USERNAME}:[^:*!]" /etc/shadow || \
    { warn "Verify failed: $USERNAME password not set"; failed=1; }

  # verify sudo configured
  grep -q "^%wheel ALL=(ALL:ALL) ALL" "/mnt/etc/sudoers" || \
    { warn "Verify failed: wheel sudo not configured"; failed=1; }
  arch-chroot /mnt grep -q "^root:[^:*!]" /etc/shadow || \
    { warn "Verify failed: root password not set"; failed=1; }

  [[ $failed -eq 0 ]] || error "users verification failed"
  log "users verified ✓"
  return 0
}