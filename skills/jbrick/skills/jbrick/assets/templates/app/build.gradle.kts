plugins {
    `java-library`
}

dependencies {
    api(project(":{{SERVICE_NAME}}-api"))

    implementation(libs.spring.boot.starter.web)
    implementation(libs.spring.boot.starter.validation)
{{APP_DEPENDENCIES}}

    implementation(libs.mapstruct)
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
    annotationProcessor(libs.mapstruct.processor)
    annotationProcessor(libs.lombok.mapstruct.binding)
}
