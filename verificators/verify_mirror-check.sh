verify_mirror_check() {
  local failed=0

  [[ -f "/etc/pacman.d/mirrorlist" ]] || \
    { warn "Verify failed: mirrorlist missing"; failed=1; }

  grep -q "^Server" /etc/pacman.d/mirrorlist || \
    { warn "Verify failed: no active servers in mirrorlist"; failed=1; }

  [[ $failed -eq 0 ]] || error "mirror verification failed"
  log "mirrors verified ✓"
  return 0
}