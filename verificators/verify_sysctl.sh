#!/usr/bin/env bash

verify_sysctl_config() {
  local failed=0

  [[ -f "/mnt/etc/sysctl.d/99-hardened-sysctl.conf" ]] || \
    { warn "Verify failed: 99-hardened-sysctl.conf missing"; failed=1; }

  grep -q "kernel.randomize_va_space = 2" "/mnt/etc/sysctl.d/99-hardened-sysctl.conf" || \
    { warn "Verify failed: ASLR not configured"; failed=1; }

  grep -q "net.ipv4.ip_forward = 0" "/mnt/etc/sysctl.d/99-hardened-sysctl.conf" || \
    { warn "Verify failed: ip_forward not disabled"; failed=1; }

  grep -q "kernel.dmesg_restrict = 1" "/mnt/etc/sysctl.d/99-hardened-sysctl.conf" || \
    { warn "Verify failed: dmesg_restrict not set"; failed=1; }

  grep -q "fs.suid_dumpable = 0" "/mnt/etc/sysctl.d/99-hardened-sysctl.conf" || \
    { warn "Verify failed: suid_dumpable not disabled"; failed=1; }

  [[ $failed -eq 0 ]] || error "sysctl verification failed"
  log "sysctl verified ✓"
  return 0
}