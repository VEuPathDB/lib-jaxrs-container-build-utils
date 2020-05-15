#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

readonly TOOL="VEuPathDB/script-raml-merge"

echo "${C_BLUE}Checking for RAML merge tool${C_NONE}"

if [ -f ".tools/bin/merge-raml" ]; then
  cur="$(.tools/bin/merge-raml -V)"
  echo "  ${C_CYAN}Found version ${cur}${C_NONE}"
  echo "  ${C_CYAN}Checking for updates${C_NONE}"

  if ! .tools/bin/fetch-latest.sh "${TOOL}" "${cur}"; then
    echo "  ${C_RED}UPDATE FAILED${C_NONE}" >&2
  elif [ -f "merge-raml" ]; then
    mv "merge-raml" ".tools/bin/merge-raml"
    echo "  ${C_CYAN}Updated to version $(.tools/bin/merge-raml -V)${C_NONE}"
  else
    echo "  ${C_CYAN}Already have latest version${C_NONE}"
  fi
else
  echo "  ${C_CYAN}Downloading RAML merge tool${C_NONE}"

  if ! .tools/bin/fetch-latest.sh "${TOOL}" "-1"; then
    echo "  ${C_RED}DOWNLOAD FAILED${C_NONE}" >&2
    exit 1
  else
    mv "merge-raml" ".tools/bin/merge-raml"
    echo "  ${C_CYAN}Downloaded version $(.tools/bin/merge-raml -V)${C_NONE}"
  fi
fi
