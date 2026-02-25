plugins {
    `java-library`
}

dependencies {
    // Nexora Spring Boot Starters
    // {{CORE_DEPENDENCIES}}

    // Spring Boot starters (always included)
    api(libs.spring.boot.validation)
    api(libs.spring.boot.aop)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
}
