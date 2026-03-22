#!/usr/bin/env bash
# ── Helper: read from yaml ───────────────────────────────────
cfg() { yq e "$1" "$CONFIG"; }

load_config() {
  CONFIG="${1:-install-conf.yaml}"
  [[ -f "$CONFIG" ]] || error "Config file not found: $CONFIG"

  ESP_SIZE=$(cfg '.partitions.esp')
  SWAP_SIZE=$(cfg '.partitions.swap')
  ROOT_SIZE=$(cfg '.partitions.root')
  HOME_SIZE=$(cfg '.partitions.home')
  FS_ROOT=$(cfg '.filesystems.root')
  FS_HOME=$(cfg '.filesystems.home')
  FS_MEDIA=$(cfg '.filesystems.media')
  MEDIA_MOUNT=$(cfg '.mounts.media')
  LOCALE_LANG=$(cfg '.locale.lang')
  TIMEZONE=$(cfg '.locale.timezone')
  HOSTNAME=$(cfg '.system.hostname')
  USERNAME=$(cfg '.user.name')
  USERGROUPS=$(cfg '.user.groups')
  ROOT_HASH=$(openssl passwd -6 "$(cfg '.root.password')")
  USER_HASH=$(openssl passwd -6 "$(cfg '.user.password')")
  KERNELS=$(cfg '.system.kernels[]' | tr '\n' ' ')
  EXTRA_PACKAGES=$(cfg '.packages[]' | tr '\n' ' ')
  LUKS_ENABLED=$(cfg '.encryption.enabled')
  LUKS_PASSPHRASE=$(cfg '.encryption.passphrase')
  LUKS_ROOT=$(cfg '.encryption.partitions.root')
  LUKS_HOME=$(cfg '.encryption.partitions.home')
  LUKS_SWAP=$(cfg '.encryption.partitions.swap')
  LUKS_MEDIA=$(cfg '.encryption.partitions.media')

  log "Config loaded from $CONFIG"
  log "Hostname: $HOSTNAME | User: $USERNAME | Kernels: $KERNELS"
}