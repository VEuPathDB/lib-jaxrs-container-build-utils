#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

APP_PACKAGE=${1:?Missing required application package param}

echo "${C_BLUE}Generating JaxRS Java Code - Post-generation Modifications${C_NONE}"

appPackageLocation="src/main/java/$(echo "${APP_PACKAGE}" | sed 's/\./\//g')/generated"

NAMES='[A-Za-z0-9_]'

# File update counter
counter=0

# Iterate over all files with a String typed _DISCRIMINATOR_TYPE_NAME.
#
# Then filter the list down to only java files.
#
# Then expand each list item into both it's interface and implementation class
# names.
for pair in $(grep -irn 'String _DISCRIMINATOR_TYPE_NAME =' "${appPackageLocation}" \
  | grep '.java' \
  | awk '{ o = $1; gsub(/\.java/, "Impl.java", $1); print o ":" $1 }' \
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

  # Parse the string value of the interface constant declaration and convert it
  # to the form that raml-to-jaxrs will have used as the enum value name.
  newVal="$(sed -n "${iline}p" "${iface}" \
    | cut -d'"' -f2 \
    | sed "s#\W#_#g" \
    | tr "[:lower:]" "[:upper:]")"

  # Replace the definition line in the interface with a form actually using the
  # enum type rather than string.
  sed "${iline}s#.\+#  ${type} _DISCRIMINATOR_TYPE_NAME = ${type}.${newVal};#" $iface > tmp.java

  # Move the edited form of the file over the original file.
  mv tmp.java ${iface}

  counter=$(($counter+1))
done

echo "  Modified $counter generated Java files to use enum discriminator types";
