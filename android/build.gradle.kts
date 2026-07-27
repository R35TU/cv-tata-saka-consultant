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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val configureProject = {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                // 1. Inject namespace if missing
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    val ns = when (project.name) {
                        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                        else -> {
                            val groupStr = project.group.toString()
                            if (groupStr.isNotEmpty()) groupStr else "com.example.${project.name.replace("-", "_").replace(".", "_")}"
                        }
                    }
                    setNamespace.invoke(android, ns)
                }

                // 2. Force compileSdk/compileSdkVersion to 36
                val methods = android.javaClass.methods
                var set = false
                for (method in methods) {
                    if (method.name == "setCompileSdk" && method.parameterCount == 1) {
                        try {
                            method.invoke(android, 36)
                            set = true
                        } catch (ex: Exception) {}
                    }
                }
                if (!set) {
                    for (method in methods) {
                        if (method.name == "compileSdkVersion" && method.parameterCount == 1) {
                            try {
                                method.invoke(android, 36)
                            } catch (ex: Exception) {}
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
    }

    if (state.executed) {
        configureProject()
    } else {
        afterEvaluate {
            configureProject()
        }
    }
}
