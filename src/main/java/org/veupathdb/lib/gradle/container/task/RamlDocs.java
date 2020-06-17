package org.veupathdb.lib.gradle.container.task;

import java.io.File;
import java.util.logging.Logger;

import org.gradle.api.DefaultTask;
import org.gradle.api.tasks.TaskAction;

public class RamlDocs extends DefaultTask
{
  private static final Logger log = Logger.getGlobal();

  private static final String
    pathDocs = "docs",
    pathRes  = "src/main/resources";

  private static final String[]
    cmdDocGen = "raml2html";

  private static final String
    errDocsIsFile = "Path \"./" + pathDocs + "\" exists and is not a directory",
    errDocsFailed = "Failed to create \"./" + pathDocs + "\" directory",
    errResIsFile  = "Path \"./" + pathRes + "\" exists and is not a directory",
    errResFailed  = "Failed to create \"./" + pathRes + "\" directory";


  @TaskAction
  public void run() throws Exception {
    log.info("Generating API Documentation");
    var proj = getProject();

    mkDocsDir(proj.getProjectDir());
    mkResourcesDir(proj.getProjectDir());

    var proc = new ProcessBuilder("raml2html", )
  }

  private static void mkDocsDir(File root) throws Exception {
    var docs = new File(root, pathDocs);

    if (docs.exists())
      if (docs.isDirectory())
        return;
      else
        throw new Exception(errDocsIsFile);

    if (!docs.mkdirs())
      throw new Exception(errDocsFailed);
  }

  private static void mkResourcesDir(File root) throws Exception {
    var res = new File(root, pathRes);

    if (res.exists()) {
      if (!res.isDirectory())
        throw new Exception(errResIsFile);
      return;
    }

    if (!res.mkdirs())
      throw new Exception(errResFailed);
  }
}
