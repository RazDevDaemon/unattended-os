do_desktop() {
  section "Installing desktop environment"

  local enabled
  enabled=$(cfg '.desktop.enabled')

  if [[ "$enabled" != "true" ]]; then
    log "Desktop disabled — skipping"
    return 0
  fi

  log "installing desktop environment"
  pacman -S xorg-server xorg-xinit plasma sddm pipewire pipewire-pulse wireplumber mesa xf86-video-qxl noto-fonts ttf-liberation --noconfirm
  
  log "enabling display manager"
  systemctl enable ssdm

  log "desktop successfully installed"
  return 0
}