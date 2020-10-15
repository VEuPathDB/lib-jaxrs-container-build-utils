#!/usr/bin/env sh

. .tools/bin/lib/colors.sh

APP_PACKAGE=${1:?Missing required application package param}

echo "${C_BLUE}Generating JaxRS Java Code - Streaming${C_NONE}"
appPackageLocation="src/main/java/$(echo "${APP_PACKAGE}" | sed 's/\./\//g')/generated"

# Supplemental code generation to support streaming output
for responseClassPath in $(\ls ${appPackageLocation}/model/*Response.java | sed 's/\.java//g'); do

    responseClass=$(basename $responseClassPath)
    streamingOutputClassTemplate="
package ${APP_PACKAGE}.generated.model;

import java.io.IOException;
import java.io.OutputStream;
import java.util.function.Consumer;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.StreamingOutput;

public class ${responseClass}Stream extends ${responseClass}Impl implements StreamingOutput {

  private final Consumer<OutputStream> _streamer;

  public ${responseClass}Stream(Consumer<OutputStream> streamer) {
    _streamer = streamer;
  }

  @Override
  public void write(OutputStream output) throws IOException, WebApplicationException {
    _streamer.accept(output);
  }

}
"
    echo "$streamingOutputClassTemplate" > $appPackageLocation/model/${responseClass}Stream.java
done
