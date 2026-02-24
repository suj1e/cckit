plugins {
    java
    alias(libs.plugins.spring.boot)
}

dependencies {
    // Adapter module (includes core and api transitively)
    implementation(project(":{{SERVICE_NAME}}-adapter"))

    // Nacos
    implementation(libs.spring.cloud.alibaba.nacos.discovery)
    implementation(libs.spring.cloud.alibaba.nacos.config)
    implementation(libs.spring.cloud.bootstrap)
    implementation(libs.spring.cloud.loadbalancer)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Test
    testImplementation(libs.bundles.testing)

    // Test containers (based on core dependencies)
    // {{TEST_DEPENDENCIES}}
}

tasks.bootJar {
    archiveFileName.set("{{SERVICE_NAME}}.jar")
}

tasks.jar {
    enabled = false
}
