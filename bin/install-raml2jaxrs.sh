#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

echo "${C_BLUE}Checking for Raml to JaxRS${C_NONE}"

if ! stat ./tools/bin/raml-to-jaxrs.jar > /dev/null 2>&1; then
  echo "${C_CYAN}  Not found.  Installing.${C_NONE}"
  .tools/bin/build-raml2jaxrs.sh 2>&1 | sed 's/^/  /'
fi
