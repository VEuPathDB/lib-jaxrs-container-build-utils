#!/usr/bin/env sh

. .tools/bin/lib/colors.sh
readonly LIBS="vendor/fgputil-accountdb-1.0.0.jar
  vendor/fgputil-core-1.0.0.jar
  vendor/fgputil-db-1.0.0.jar
  vendor/fgputil-web-1.0.0.jar"

echo "${C_BLUE}Checking for FgpUtil libraries${C_NONE}"

if ! stat ${LIBS} > /dev/null 2>&1; then
  echo "${C_CYAN}  Not found.  Installing${C_NONE}"
  .tools/bin/build-fgputil.sh 2>&1 | sed 's/^/  /'
fi
