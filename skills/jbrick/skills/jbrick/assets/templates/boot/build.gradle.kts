plugins {
    application
    alias(libs.plugins.spring.boot)
}

val appClass = "{{FULL_PACKAGE}}.{{SERVICE_CLASS}}Application"

// Load .env file for run/bootRun tasks
val envFile = rootProject.file(".env")
if (envFile.exists()) {
    val envVars = envFile.readLines()
        .filter { it.isNotBlank() && !it.startsWith("#") && it.contains("=") }
        .associate { line ->
            val (key, value) = line.split("=", limit = 2)
            key.trim() to value.trim()
        }
    tasks.withType<JavaExec>().configureEach { environment(envVars) }
}


application {
    mainClass.set(appClass)
}

dependencies {
    implementation(project(":{{SERVICE_NAME}}-app"))

    implementation(libs.spring.boot.starter.actuator)
{{BOOT_DEPENDENCIES}}

    testImplementation(libs.spring.boot.starter.test)
{{BOOT_TEST_DEPENDENCIES}}
}
