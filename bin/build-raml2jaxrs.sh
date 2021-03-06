#!/usr/bin/env sh

echo "Cloning raml-for-jax-rs v3.0.7"
rm -rf tmp/raml
git clone \
  --branch 3.0.7 \
  --depth 1 \
  --quiet \
  https://github.com/mulesoft-labs/raml-for-jax-rs.git tmp/raml || exit 1

curDir=$(pwd)

cd tmp/raml/ || exit 1
for pomfile in $(find . -name pom.xml); do
  echo "Correcting ${pomfile}"
  sed 's/3.0.[0-9]-SNAPSHOT/3.0.7/' $pomfile > ${pomfile}.tmp
  mv ${pomfile}.tmp $pomfile
done

cd raml-to-jaxrs/raml-to-jaxrs-cli
echo "Running maven build"
mvn clean install || exit 1
mv target/raml-to-jaxrs-cli-3.0.7-jar-with-dependencies.jar "${curDir}"/.tools/bin/raml-to-jaxrs.jar
cd "${curDir}"
rm -rf tmp
