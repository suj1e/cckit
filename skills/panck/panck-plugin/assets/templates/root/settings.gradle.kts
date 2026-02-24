rootProject.name = "{{SERVICE_NAME}}"

include(
    "{{SERVICE_NAME}}-api",
    "{{SERVICE_NAME}}-core",
    "{{SERVICE_NAME}}-adapter",
    "{{SERVICE_NAME}}-boot"
)
