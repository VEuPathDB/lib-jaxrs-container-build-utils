#!/usr/bin/env sh

. .tools/bin/lib/colors.sh


set -eu

readonly base="${1:?Base Dir}"

echo "${C_BLUE}Removing demo code${C_NONE}"

rm -rf "${base}/generated"
rm "${base}/service/HelloWorld.java"
