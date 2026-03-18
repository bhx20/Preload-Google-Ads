allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Optional but safe (prevents plugin lint crash globally)
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            try {
                val clazz = Class.forName("com.android.build.gradle.BaseExtension")
                if (clazz.isInstance(ext)) {
                    val method = clazz.getMethod("getLintOptions")
                    val lintOptions = method.invoke(ext)
                    val abortMethod = lintOptions.javaClass.getMethod("setAbortOnError", Boolean::class.java)
                    abortMethod.invoke(lintOptions, false)
                }
            } catch (_: Exception) {}
        }
    }
}

// build dir config (your existing)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}