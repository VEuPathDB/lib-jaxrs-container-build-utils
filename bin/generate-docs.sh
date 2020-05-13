#!/usr/bin/env sh

. bin/lib/colors.sh

set -eu

echo "${C_BLUE}Generating API Documentation${C_NONE}"

raml2html .tools/raml/lib/full-api.raml > docs/api.html
cp docs/api.html src/main/resources/api.html