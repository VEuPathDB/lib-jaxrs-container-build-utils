#!/usr/bin/env sh

echo "Cloning raml-for-jax-rs v3.0.5"
git clone \
  --branch 3.0.5 \
  --depth 1 \
  --quiet \
  https://github.com/mulesoft-labs/raml-for-jax-rs.git tmp/raml || exit 1

curDir=$(pwd)

cd tmp/raml/ || exit 1
for i in $(find -name pom.xml); do
  echo "Correcting ${i}"
  sed -i 's/3.0.5-SNAPSHOT/3.0.5/' $i
done

echo "Running maven build"
mvn clean install || exit 1
mv target/raml-to-jaxrs-cli-3.0.5-jar-with-dependencies.jar "${curDir}"/.tools/bin/raml-to-jaxrs.jar
cd "${curDir}"
rm -rf tmp
