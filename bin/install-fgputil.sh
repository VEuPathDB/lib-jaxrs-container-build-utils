#!/usr/bin/env sh

FGP_UTILS_HASH=${1:-master}

. .tools/bin/lib/colors.sh
readonly LIBS="vendor/fgputil-accountdb-1.0.0.jar
  vendor/fgputil-cache-1.0.0.jar
  vendor/fgputil-cli-1.0.0.jar
  vendor/fgputil-client-1.0.0.jar
  vendor/fgputil-core-1.0.0.jar
  vendor/fgputil-db-1.0.0.jar
  vendor/fgputil-events-1.0.0.jar
  vendor/fgputil-json-1.0.0.jar
  vendor/fgputil-server-1.0.0.jar
  vendor/fgputil-servlet-1.0.0.jar
  vendor/fgputil-solr-1.0.0.jar
  vendor/fgputil-test-1.0.0.jar
  vendor/fgputil-web-1.0.0.jar
  vendor/fgputil-xml-1.0.0.jar"

echo "${C_BLUE}Checking for FgpUtil libraries${C_NONE}"

if ! stat ${LIBS} > /dev/null 2>&1; then
  echo "${C_CYAN}  Not found.  Installing${C_NONE}"
  .tools/bin/build-fgputil.sh ${FGP_UTILS_HASH} 2>&1 | sed 's/^/  /'
fi
