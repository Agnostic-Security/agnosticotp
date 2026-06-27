allprojects {
    repositories {
        google()
        mavenCentral()
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
    // Some plugins (e.g. biometric_storage) declare an older compileSdk (31)
    // than a transitive AndroidX dependency requires (androidx.window.extensions
    // .core:core needs consumers on API 33+). Force every Android module to
    // compile against 36, AFTER the plugin's own build script has run. Reflection
    // avoids needing the AGP types on the root buildscript classpath. Registered
    // before evaluationDependsOn so it lands before the project is evaluated.
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            runCatching {
                android.javaClass
                    .getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(android, 36)
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
