#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

readonly DEPS="raml2html:raml2html"

echo "${C_BLUE}Checking for required NPM packages${C_NONE}"

install=false

for dep in ${DEPS}; do
  com=$(echo "${dep}" | cut -d: -f1)
  if ! command -v "${com}" > /dev/null; then
    echo "${C_CYAN}  Not found. Installing.${C_NONE}"
    install=true
    break
  fi
done

if [ "${install}" = "true" ]; then
  npm install -gs $(echo ${DEPS} | grep -Eo ':[A-Za-z0-9-]+' | tr -d ':') 2>&1 \
    | sed 's/^/  /'
fi
