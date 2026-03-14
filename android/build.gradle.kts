allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// The following block overrides the build directory to be at the root of the Flutter project.
// This can cause issues ("different roots") if the Flutter SDK or pub cache is on a different drive.
/*
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
*/

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
