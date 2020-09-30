#!/usr/bin/env sh
trap "exit 1" TERM
export TOP_PID=$$

readonly CUR_PATH="$(pwd)/.tools/bin"
readonly TOOL="${CUR_PATH}/gh-latest"

getTool() {
  if [ ! -f "${TOOL}" ]; then
    file="${CUR_PATH}/tmp.tar.gz"

    (echo "Downloading gh-latest" \
      && curl -s -L "https://github.com/Foxcapades/gh-latest/releases/download/v1.0.4/gh-latest-$(os).v1.0.4.tar.gz" > "${file}" \
      && echo "Extracting ${file}" \
      && tar -xzf "${file}" -C "${CUR_PATH}" 2>&1 \
      && echo "Cleaning up" \
      && rm "${file}" 2>&1) || kill -s TERM ${TOP_PID}
  fi
}

getLatestVersionData() {
  if [ -z "${1}" ]; then
    echo "function getLatestVersionData called without required project slug parameter.
    Example call: 'getLatestVersionData Foxcapades/Argonaut'" >&2
    kill -s TERM ${TOP_PID}
  fi

  if ! "${TOOL}" -t "${1}"; then
    echo "Failed to fetch version information for ${1}" >&2
    kill -s TERM ${TOP_PID}
  fi
}

parseReleaseFile() {
  if [ -z "${1}" ]; then
    echo "function parseReleaseFile called without required project release data." >&2
    kill -s TERM ${TOP_PID}
  fi

  "${TOOL}" -u "${1}" | grep "$(os)"
}

os() {
  OSTYPE="$(uname)"
  if [ "$OSTYPE" = "Linux" ]; then
    echo "linux"
  elif [ "$OSTYPE" = "Darwin" ]; then
    echo "darwin"
  else
    echo "Unsupported OS: $OSTYPE" >&2
    kill -s TERM ${TOP_PID}
  fi
}

versionEquals() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "function versionEquals must be passed 2 parameters containing the versions to check" >&2
    kill -s TERM ${TOP_PID}
  fi

  va="$(echo "${1}" | sed 's/-.\+//')"
  vb="$(echo "${2}" | sed 's/-.\+//')"
  if [ "${va}" = "${vb}" ]; then
    return 0
  fi
  return 1
}

downloadIfDifferent() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "function downloadIfDifferent must be passed a github project slug and a version number to check against" >&2
    kill -s TERM ${TOP_PID}
  fi

  vn="$(getLatestVersionData "${1}")"

  if versionEquals "${vn}" "${2}"; then
    return 0
  fi

  fileUrl="$(parseReleaseFile "${1}")"
  if [ -z "${fileUrl}" ]; then
    echo "failed to parse release file name from github response json" >&2
    kill -s TERM ${TOP_PID}
  fi

  echo "Downloading ${fileUrl}" \
    && curl -s -L "${fileUrl}" > "${CUR_PATH}/tmp.tar.gz" \
    && echo "Extracting ${CUR_PATH}/tmp.tar.gz" \
    && tar -xf "${CUR_PATH}/tmp.tar.gz" -C ${CUR_PATH} 2>&1 \
    && echo "Cleaning up" \
    && rm "${CUR_PATH}/tmp.tar.gz"
}

getTool
downloadIfDifferent "${1:?Package Name}" "${2:-"-1"}"
