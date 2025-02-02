#!/usr/bin/env ash

function use() {
  echo "Use: ${0} junior|config"
  exit 1
}

[ -z "${1}" ] && use
[ "${1}" != "junior" ] && [ "${1}" != "config" ] && use
echo "Rebooting to ${1} mode"
GRUBPATH="$(dirname $(find ${BOOTLOADER_PATH}/ -name grub.cfg | head -1))"
ENVFILE="${GRUBPATH}/grubenv"
[ ! -f "${ENVFILE}" ] && grub-editenv "${ENVFILE}" create
grub-editenv "${ENVFILE}" set next_entry="${1}"
reboot
