#!/usr/bin/env sh

docker=$1
dir=$(pwd)

echo "Cloning latest FgpUtil version"

git clone --depth 1 https://github.com/VEuPathDB/FgpUtil || exit 1
cd FgpUtil

echo "Building FgpUtil"

mvn clean install 2>&1 || exit 1

mkdir -p "${dir}/vendor"
cp \
  AccountDB/target/fgputil-accountdb-1.0.0.jar \
  Cache/target/fgputil-cache-1.0.0.jar \
  Cli/target/fgputil-cli-1.0.0.jar \
  Client/target/fgputil-client-1.0.0.jar \
  Core/target/fgputil-core-1.0.0.jar \
  Db/target/fgputil-db-1.0.0.jar \
  Events/target/fgputil-events-1.0.0.jar \
  Json/target/fgputil-json-1.0.0.jar \
  Server/target/fgputil-server-1.0.0.jar \
  Servlet/target/fgputil-servlet-1.0.0.jar \
  Solr/target/fgputil-solr-1.0.0.jar \
  Test/target/fgputil-test-1.0.0.jar \
  Web/target/fgputil-web-1.0.0.jar \
  Xml/target/fgputil-xml-1.0.0.jar \
  "${dir}/vendor"

cd "${dir}"
rm -rf FgpUtil
