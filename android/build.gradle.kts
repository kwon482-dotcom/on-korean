allprojects {
    repositories {
        google()
        mavenCentral()
    }
    tasks.configureEach {
        doFirst {
            try {
                fileTree(project.layout.buildDirectory) {
                    include("**/desktop.ini")
                    include("**/Thumbs.db")
                }.forEach {
                    it.setWritable(true)
                    it.delete()
                }
            } catch (_: Exception) {}
        }
    }
    tasks.withType<Copy> {
        exclude("**/desktop.ini")
        exclude("**/Thumbs.db")
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
