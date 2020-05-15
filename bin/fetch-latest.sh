#!/bin/sh
trap "exit 1" TERM
export TOP_PID=$$

readonly GITHUB_API_URL="https://api.github.com/repos/"
readonly GITHUB_TARGET="/releases/latest"

makeGhApiUrl() {
  if [ -z "${1}" ]; then
    echo "function makeGhApiUrl called without required project slug parameter.
    Example call: 'makeGhApiUrl Foxcapades/Argonaut'" >&2
    kill -s TERM ${TOP_PID}
  fi

  echo "${GITHUB_API_URL}${1}${GITHUB_TARGET}"
}

getLatestVersionData() {
  if [ -z "${1}" ]; then
    echo "function getLatestVersionData called without required project slug parameter.
    Example call: 'getLatestVersionData Foxcapades/Argonaut'" >&2
    kill -s TERM ${TOP_PID}
  fi

  fullUrl="$(makeGhApiUrl "${1}")"
  if ! curl -sf "${fullUrl}"; then
    echo "Failed to fetch version information from ${fullUrl}" >&2
    kill -s TERM ${TOP_PID}
  fi
}

parseVersionNumber() {
  if [ -z "${1}" ]; then
    echo "function parseVersionNumber called without required project release data." >&2
    kill -s TERM ${TOP_PID}
  fi

  echo "${1}" | grep "tag_name" | cut -d '"' -f 4
}

parseReleaseFile() {
  if [ -z "${1}" ]; then
    echo "function parseReleaseFile called without required project release data." >&2
    kill -s TERM ${TOP_PID}
  fi

  echo "${1}" | grep "browser_download_url" | grep "$(os)" | cut -d '"' -f 4
}

os() {
  OSTYPE="$(uname)"
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

  json="$(getLatestVersionData "${1}")"
  if [ -z "${json}" ]; then
    echo "empty github response"
    kill -s TERM ${TOP_PID}
  fi

  vn="$(parseVersionNumber "${json}")"
  if [ -z "${vn}" ]; then
    echo "failed to parse version number from github response json" >&2
    kill -s TERM ${TOP_PID}
  fi

  if versionEquals "${vn}" "${2}"; then
    return 0
  fi

  fileUrl="$(parseReleaseFile "${json}")"
  if [ -z "${fileUrl}" ]; then
    echo "failed to parse release file name from github response json" >&2
    kill -s TERM ${TOP_PID}
  fi

  fileName="$(basename "${fileUrl}")"

  wget -q "${fileUrl}" && tar -xzf "${fileName}" && rm "${fileName}"
}

downloadIfDifferent "${1:?Package Name}" "${2:-"-1"}"
