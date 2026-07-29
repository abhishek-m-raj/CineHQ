import com.android.build.api.dsl.LibraryExtension
import org.gradle.kotlin.dsl.configure

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
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureSubproject: Project.() -> Unit = {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension>("android") {
                compileSdk = 36

                if (namespace == null) {
                    val manifestFile = layout.projectDirectory.file("src/main/AndroidManifest.xml").asFile
                    val manifestPackage =
                        if (manifestFile.exists()) {
                            Regex("""package\s*=\s*"([^"]+)"""")
                                .find(manifestFile.readText())
                                ?.groupValues
                                ?.get(1)
                        } else {
                            null
                        }

                    val fallbackNamespace =
                        buildString {
                            append("com.cinehq.plugins")
                            path
                                .split(":")
                                .filter { it.isNotBlank() }
                                .map { it.replace(Regex("[^A-Za-z0-9_]"), "_").lowercase() }
                                .map { if (it.firstOrNull()?.isDigit() == true) "_$it" else it }
                                .forEach {
                                    append('.')
                                    append(it)
                                }
                        }

                    namespace = manifestPackage?.takeIf { it.isNotBlank() } ?: fallbackNamespace
                }
            }
        }
    }

    if (state.executed) {
        configureSubproject()
    } else {
        afterEvaluate {
            configureSubproject()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
