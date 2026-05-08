#!/bin/sh
set -e

CHANNEL=${FLATCAR_CHANNEL:-stable}
BASE_URL="https://${CHANNEL}.release.flatcar-linux.net/amd64-usr"
ASSETS_DIR="/var/lib/matchbox/assets/flatcar"

mkdir -p "${ASSETS_DIR}"

while true; do
  echo "Checking for latest Flatcar ${CHANNEL} release..."
  LATEST_VERSION=$(curl --silent --show-error --location "${BASE_URL}/current/version.txt" | grep 'FLATCAR_VERSION=' | cut -d = -f 2)

  if [ -z "${LATEST_VERSION}" ]; then
    echo "Failed to get latest version, retrying in 1 hour..."
    sleep 3600
    continue
  fi

  VERSION_DIR="${ASSETS_DIR}/${LATEST_VERSION}"

  if [ ! -d "${VERSION_DIR}" ]; then
    echo "New version found: ${LATEST_VERSION}. Downloading..."
    mkdir --parents "${VERSION_DIR}"

    curl --silent --show-error --location "${BASE_URL}/${LATEST_VERSION}/flatcar_production_pxe.vmlinuz" --output "${VERSION_DIR}/flatcar_production_pxe.vmlinuz"
    curl --silent --show-error --location "${BASE_URL}/${LATEST_VERSION}/flatcar_production_pxe_image.cpio.gz" --output "${VERSION_DIR}/flatcar_production_pxe_image.cpio.gz"

    # Create/Update symlink for 'current'
    ln -snf "${LATEST_VERSION}" "${ASSETS_DIR}/current"
    echo "Downloaded and updated 'current' symlink to ${LATEST_VERSION}"
  else
    echo "Version ${LATEST_VERSION} is already up to date."
  fi

  echo "Sleeping for 24 hours..."
  sleep 86400
done
