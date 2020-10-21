#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

APP_PACKAGE=${1:?Missing required application package param}

echo "${C_BLUE}Generating JaxRS Java Code - Post-generation Modifications${C_NONE}"
appPackageLocation="src/main/java/$(echo "${APP_PACKAGE}" | sed 's/\./\//g')/generated"

#echo "$APP_PACKAGE"
#echo "$appPackageLocation"

desiredFiles="./$appPackageLocation/model/*.java"
discriminatorRegex="private final.*_DISCRIMINATOR_TYPE_NAME"
awkScript='{ print $1 $4 }'
counter=0
for target in $(\ls $desiredFiles | xargs grep -e "$discriminatorRegex" | awk "$awkScript"); do
  if [[ $target =~ (.+)":"(.+) ]]; then
    file=${BASH_REMATCH[1]}
    className=${BASH_REMATCH[2]}
    #echo "file: $file, class: $className"
    sedScript="s/_DISCRIMINATOR_TYPE_NAME/${className}.valueOf(_DISCRIMINATOR_TYPE_NAME.toUpperCase().replaceAll(\"[^A-Za-z0-9]\",\"\"))/"
    sed "$sedScript" $file > ${file}.tmp
    mv ${file}.tmp $file
    counter=$((counter+1))
  else
    echo "Error: search results not as expected: $file"
    exit 1
  fi
done
echo "  Modified $counter generated Java source files to respect discriminator enums";
