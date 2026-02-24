plugins {
    `java-library`
}

dependencies {
    // Internal modules
    api(project(":{{SERVICE_NAME}}-core"))
    api(project(":{{SERVICE_NAME}}-api"))

    // Nexora Spring Boot Starters
    implementation(libs.nexora.spring.boot.starter.web)

    // SpringDoc OpenAPI
    implementation(libs.springdoc.openapi)

    // Database
    implementation(libs.flyway)
    implementation(libs.flyway.mysql)
    runtimeOnly(libs.mysql)

    // Observability
    implementation(libs.bundles.observability)

    // Spring Cloud for @RefreshScope
    implementation("org.springframework.cloud:spring-cloud-context")

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
    annotationProcessor(libs.lombok.mapstruct.binding)

    // QueryDSL (optional)
    // {{ADAPTER_QUERYDSL}}
}
