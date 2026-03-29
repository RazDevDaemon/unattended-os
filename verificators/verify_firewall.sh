verify_firewall() {
  local failed=0

  # verify config file exists
  [[ -f "/mnt/etc/nftables.conf" ]] || \
    { warn "Verify failed: nftables.conf missing"; failed=1; }

  # verify default drop policies
  grep -q "policy drop" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: default drop policy missing"; failed=1; }

  # verify conntrack rules present
  grep -q "ct state invalid drop" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: invalid state drop missing"; failed=1; }

  grep -q "ct state established,related accept" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: established state accept missing"; failed=1; }

  # verify loopback rules
  grep -q "iif lo accept" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: loopback input rule missing"; failed=1; }

  grep -q "oif lo accept" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: loopback output rule missing"; failed=1; }

  # verify forward chain is drop
  grep -q "chain forward" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: forward chain missing"; failed=1; }

  # verify interface was injected
  grep -q "${FW_IFACE}" "/mnt/etc/nftables.conf" || \
    { warn "Verify failed: interface ${FW_IFACE} not found in config"; failed=1; }

  [[ $failed -eq 0 ]] || error "firewall verification failed"
  log "firewall verified ✓"
  return 0
}