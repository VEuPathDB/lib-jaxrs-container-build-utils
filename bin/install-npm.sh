#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

readonly DEPS="raml2html raml2html-modern-theme"

echo "${C_BLUE}Checking for required NPM packages${C_NONE}"

install=false

for dep in ${DEPS}; do
  echo "  ${C_CYAN}${dep}${C_NONE}"
  if ! npm ls -g "${dep}" > /dev/null; then
    echo "${C_CYAN}  Not found. Installing.${C_NONE}"
    install=true
    break
  fi
done

if [ "${install}" = "true" ]; then
  npm install -gs ${DEPS} 2>&1 | sed 's/^/  /'
fi
