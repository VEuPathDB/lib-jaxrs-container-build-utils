#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

APP_PACKAGE=${1:?Missing required application package param}

compile() {
  java -jar .tools/bin/raml-to-jaxrs.jar api.raml \
    --directory src/main/java \
    --generate-types-with jackson \
    --model-package "${APP_PACKAGE}".generated.model \
    --resource-package "${APP_PACKAGE}".generated.resources \
    --support-package "${APP_PACKAGE}".generated.support 2>&1
}

.tools/bin/install-raml2jaxrs.sh

echo "${C_BLUE}Generating JaxRS Java Code${C_NONE}"
rm -rf "src/main/java/$(echo "${APP_PACKAGE}" | sed 's/\./\//g')/generated"

out="$(compile)"
foo=$?

echo "${out}" | sed 's/^/  /'

if [ $foo -gt 0 ]; then
  exit 1
fi

