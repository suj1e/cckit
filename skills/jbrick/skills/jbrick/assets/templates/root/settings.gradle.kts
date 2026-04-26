val projectName = "{{SERVICE_NAME}}"

rootProject.name = projectName

include(
    "${projectName}-api",
    "${projectName}-app",
    "${projectName}-boot",
)
