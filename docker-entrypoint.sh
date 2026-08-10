#!/bin/sh
set -eu

STORAGE_DIRECTORY='/app/Storage/'

mkdir -p "${STORAGE_DIRECTORY}"

if [ '1001' != "$(stat -c '%u' "${STORAGE_DIRECTORY}")" ]; then
    chown -R encore:encore "${STORAGE_DIRECTORY}"
fi

runuser -u encore -- ./EncoreApi migrate --yes --env production

exec runuser -u encore -- ./EncoreApi "$@"
