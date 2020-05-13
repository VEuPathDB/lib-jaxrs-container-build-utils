#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

set -eu

echo "${C_BLUE}Generating API Documentation${C_NONE}"

mkdir -p "docs"
raml2html .tools/raml/full-api.raml > docs/api.html
cp docs/api.html src/main/resources/api.html
