plugins {
  `java-gradle-plugin`
}

//gradlePlugin {
//  plugins {
//    create("jaxrs-container") {
//      id = "org.veupathdb.jaxrs-container"
//    }
//  }
//}

tasks.wrapper {
  gradleVersion = "6.5"
}
