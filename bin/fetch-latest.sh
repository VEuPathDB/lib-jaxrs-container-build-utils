#!/usr/bin/env sh
trap "exit 1" TERM
export TOP_PID=$$

readonly CUR_PATH="$(pwd)/.tools/bin"
readonly TOOL="${CUR_PATH}/gh-latest"

getLatestVersionData() {
  if [ -z "${1}" ]; then
    echo "function getLatestVersionData called without required project slug parameter.
    Example call: 'getLatestVersionData Foxcapades/Argonaut'" >&2
    kill -s TERM ${TOP_PID}
  fi

  if ! curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/${1}/releases/latest" | jq '.["tag_name"]'; then
    echo "Failed to fetch version information for ${1}" >&2
    kill -s TERM ${TOP_PID}
  fi
}

#######################################
# Fetches the release file URL for the given repository
# Arguments:
#   $1: GitHub repo in form <OWNER>/<REPO>
#   $2: Version of currently downloaded release from repo specified in first arg
# Outputs:
#   Version tag of the latest release of the repo in GitHub.
#######################################
parseReleaseFile() {
  if [ -z "${1}" ]; then
    echo "function parseReleaseFile called without required project release data." >&2
    kill -s TERM ${TOP_PID}
  fi

  curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/${1}/releases/latest" | jq '.assets | .[] | .browser_download_url' | grep "$(os)"
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

#######################################
# Download the latest release of a specified repo if the latest version is newer than the currently downloaded version.
# Arguments:
#   $1: GitHub repo in form <OWNER>/<REPO>
#   $2: Version of currently downloaded release from repo specified in first arg
# Outputs:
#   Writes unstructured logs to stdout
#######################################
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

downloadIfDifferent "${1:?Package Name}" "${2:-"-1"}"
