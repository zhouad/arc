#!/usr/bin/env bash

. /opt/arpl/include/functions.sh

set -o pipefail # Get exit code from process piped

# Sanity check
[ -f "${ORI_ZIMAGE_FILE}" ] || (die "${ORI_ZIMAGE_FILE} not found!" | tee -a "${LOG_FILE}")

echo -e "Patching zImage"

rm -f "${MOD_ZIMAGE_FILE}"
# Extract vmlinux
/opt/arpl/bzImage-to-vmlinux.sh "${ORI_ZIMAGE_FILE}" "${TMP_PATH}/vmlinux" >"${LOG_FILE}" 2>&1 || dieLog
# Patch boot params and ramdisk check
/opt/arpl/kpatch "${TMP_PATH}/vmlinux" "${TMP_PATH}/vmlinux-mod" >"${LOG_FILE}" 2>&1 || dieLog
# rebuild zImage
/opt/arpl/vmlinux-to-bzImage.sh "${TMP_PATH}/vmlinux-mod" "${MOD_ZIMAGE_FILE}" >"${LOG_FILE}" 2>&1 || dieLog
# Update HASH of new DSM zImage
ZIMAGE_HASH="$(sha256sum ${ORI_ZIMAGE_FILE} | awk '{print$1}')"
writeConfigKey "zimage-hash" "${ZIMAGE_HASH}" "${USER_CONFIG_FILE}"