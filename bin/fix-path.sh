#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

set -eu

readonly old="${1:?Old Directory}"
readonly new="${2:?New Directory}"

if [ "${old}" = "${new}" ]; then
  exit 0
fi

echo "${C_BLUE}Moving Files${C_NONE}"

mkdir -p ${new}
mv -t "${new}" "${old}/*"
mv -t "${new}" "${old}/*"
rm -rf "${old}"
