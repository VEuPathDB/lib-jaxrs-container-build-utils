#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

readonly TOOL="VEuPathDB/script-raml-merge"

echo "${C_BLUE}Checking for RAML merge tool${C_NONE}"

if [ -f ".tools/bin/merge-raml" ]; then
  cur="$(.tools/bin/merge-raml -V)"
  echo "  ${C_CYAN}Found version ${cur}${C_NONE}"
  echo "  ${C_CYAN}Checking for updates${C_NONE}"

  ((((.tools/bin/fetch-latest.sh "${TOOL}" "$(.tools/bin/merge-raml -V)" 2>&1; echo $? >&3) \
    | sed 's/^/  /' >&2) 3>&1) | (read xs; exit $xs)) 2>&1

  if [ $? -gt 0 ]; then
    echo "  ${C_RED}UPDATE FAILED${C_NONE}"
  fi

  echo "  ${C_CYAN}Using version $(.tools/bin/merge-raml -V)${C_NONE}"
else
  echo "  ${C_CYAN}Downloading RAML merge tool${C_NONE}"

  ((((.tools/bin/fetch-latest.sh "${TOOL}" "-1" 2>&1; echo $? >&3) \
    | sed 's/^/  /' >&2) 3>&1) | (read xs; exit $xs)) 2>&1

  if [ $? -gt 0 ]; then
    echo "  ${C_RED}DOWNLOAD FAILED${C_NONE}" >&2
    exit 1
  else
    echo "  ${C_CYAN}Downloaded version $(.tools/bin/merge-raml -V)${C_NONE}"
  fi
fi
