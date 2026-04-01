do_mirror_check() {
  section "Updating mirrorlist"

  local url="https://archlinux.org/mirrorlist/?use_mirror_status=on&protocol=${MIRROR_PROTOCOL}"
  
  for country in $MIRROR_COUNTRIES; do
    url+="&country=${country}"
  done

  for ip in $MIRROR_IP_VERSIONS; do
    url+="&ip_version=${ip}"
  done

  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

  curl -s --max-time 10 "$url" | sed 's/^#Server/Server/' > /tmp/mirrorlist.new

  local count
  count=$(grep -c "^Server" /tmp/mirrorlist.new)

  if [[ "$count" -eq 0 ]]; then
    warn "Failed to fetch mirrorlist — using existing"
    cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
    return 0
  fi

  cp /tmp/mirrorlist.new /etc/pacman.d/mirrorlist
  cp /etc/pacman.d/mirrorlist.bak /mnt/etc/pacman.d/mirrorlist 2>/dev/null || true

  log "Mirrorlist updated with $count mirrors — countries: ${MIRROR_COUNTRIES}"
  return 0
}