#!/usr/bin/env sh
trap "exit 1" TERM
export TOP_PID=$$

readonly PATH=".tools/bin"
readonly TOOL="${PATH}/gh-latest"

getTool() {
  if [ ! -f "${TOOL}" ]; then
    (/bin/wget "https://github.com/Foxcapades/gh-latest/releases/download/v1.0.4/gh-latest-$(os).v1.0.4.tar.gz" -O "${PATH}/tmp.tar.gz" \
    && /bin/tar -xvf "${PATH}/tmp.tar.gz" -C "${PATH}" \
    && /bin/rm "${PATH}/tmp.tar.gz" \
    && /bin/chmod 754 ${TOOL}) || kill -s TERM ${TOP_PID}
  fi
}

getLatestVersionData() {
  if [ -z "${1}" ]; then
    echo "function getLatestVersionData called without required project slug parameter.
    Example call: 'getLatestVersionData Foxcapades/Argonaut'" >&2
    kill -s TERM ${TOP_PID}
  fi

  if ! "${TOOL}" -t "${1}"; then
    echo "Failed to fetch version information from ${fullUrl}" >&2
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
  OSTYPE="$(/bin/uname)"
  if [ "$OSTYPE" = "Linux" ]; then
    echo "linux"
  elif [ "$OSTYPE" = "darwin" ]; then
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

  fileName="$(basename "${fileUrl}")"

  wget -q "${fileUrl}" && tar -xzf "${fileName}" && rm "${fileName}"
}

getTool
downloadIfDifferent "${1:?Package Name}" "${2:-"-1"}"
