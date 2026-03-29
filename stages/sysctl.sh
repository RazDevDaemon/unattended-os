do_sysctl_config() {
  section "Applying sysctl hardened configs"

  SYSCTL_CONFIG_FILE=/mnt/etc/sysctl.d/99-hardened-sysctl.conf
  CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/configs"

  cp "$CONFIG_DIR/99-hardened-sysctl.conf" "$SYSCTL_CONFIG_FILE"

  chmod 644 "$SYSCTL_CONFIG_FILE"

  log "Hardened sysctl configs applied"
  return 0
}