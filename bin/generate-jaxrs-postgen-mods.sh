#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

APP_PACKAGE=${1:?Missing required application package param}

echo "${C_BLUE}Generating JaxRS Java Code - Post-generation Modifications${C_NONE}"

appPackageLocation="src/main/java/$(echo "${APP_PACKAGE}" | sed 's/\./\//g')/generated"

NAMES='[A-Za-z0-9_]'

# File update counter
counter=0

# Try to use gawk if available, if not fall back to awk.
AWK=$( command -v gawk || command -v awk || exit 1 );

# Iterate over all files with a String typed _DISCRIMINATOR_TYPE_NAME.
#
# Then filter the list down to only java files.
#
# Then expand each list item into both it's interface and implementation class
# names.
for pair in $(grep -irn 'String _DISCRIMINATOR_TYPE_NAME =' "${appPackageLocation}" \
  | grep '.java' \
  | ${AWK} '{ o = $1; gsub(/\.java/, "Impl.java", $1); print o ":" $1 }' \
); do
  # Split out each list entry into the interface file name, declaration line
  # number, and implementation file name.
  iface=$(echo $pair | cut -d: -f1)
  iline=$(echo $pair | cut -d: -f2)
  impl=$(echo $pair | cut -d: -f4)

  # Get the actual enum type from the implementation class.
  # Exclude discriminators that are builtin typed.
  type=$(grep -o "private final ${NAMES}\+ ${NAMES}\+ = _DISCRIMINATOR_TYPE_NAME;" $impl \
    | cut -d' ' -f3 \
    | grep -v 'String\|int\|long\|float\|double\|byte\|short')

  # If the type was a java builtin type, the $type variable will be empty.
  # In that case, skip and move on.
  if [ -z "${type}" ]; then
    continue
  fi

  # Get the name of the java interface.
  base="$(basename "${iface}" | cut -d. -f1)"

  # Parse the string value of the interface constant declaration and convert it
  # to the form that raml-to-jaxrs will have used as the enum value name.
  newValRaw="$(sed -n "${iline}p" "${iface}" | cut -d'"' -f2)"

  # If the interface name equals the raw string value for the discriminator,
  # then it's a base type and does not have a valid discriminator value.  Set it
  # to null instead.
  baseComparison="$(echo "$newValRaw" | sed "s#_##g")" # class name generation removes underscores
  if [ "${base}" = "${baseComparison}" ]; then
    newVal="null"
  else
    newVal="${type}.$(echo "${newValRaw}" | sed "s#[\W-]##g" | tr "[:lower:]" "[:upper:]")"
  fi

  # Replace the definition line in the interface with a form actually using the
  # enum type rather than string.
  sed "${iline}s#.*#  ${type} _DISCRIMINATOR_TYPE_NAME = ${newVal};#" $iface > tmp.java

  # Move the edited form of the file over the original file.
  mv tmp.java ${iface}

  counter=$(($counter+1))
done

echo "  Modified $counter generated Java files to use enum discriminator types";

# Reset update counter
counter=0

# Iterate over all generated enums and add a getter for the enum's name
for file in $(grep -irn "enum" "${appPackageLocation}" | grep '.java' | grep -v 'Impl.java' | awk -F: '{ print $1 }' | sort -u); do
  ${AWK} 'BEGIN {RS="enum" ; ORS = "enum"} {if ($0 ~ /private String name/) {print gensub(/}/, "  public String getValue(){ return name; } \n}", 2)} else {print}}' $file | sed 's/^enum$//g' > tmp.java
  mv tmp.java $file
  counter=$(($counter+1))
done

# Replace all primitives in generated model types with boxed types
find "${appPackageLocation}/model" -type f -name '*.java' | xargs -I'{}' sed -i 's/\b\(long\|double\|boolean\|byte\|short\|float\)\b/\u\1/g;s/\bint\b/Integer/g' '{}'
find "${appPackageLocation}/resources" -type f -name '*.java' | grep -v "Api.java" | grep -v "Health.java" | grep -v "Metrics.java" | xargs -I'{}' sed -i 's/\b\(long\|double\|boolean\|byte\|short\|float\)\b/\u\1/g;s/\bint\b/Integer/g' '{}'

echo "  Modified $counter generated Java files to provide a getter for the enum's JSON value";

# Convert javax.ws to jakarta.ws in generated classes
grep -Rl "javax\.ws" src | xargs -I{} sed -i 's/javax\.ws/jakarta\.ws/g' {}
