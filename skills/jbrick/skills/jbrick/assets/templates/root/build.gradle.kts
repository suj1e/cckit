plugins {
    java
    jacoco
    alias(libs.plugins.spring.boot) apply false
}

val javaVersion = libs.versions.java.get()
val springBootVersion = libs.versions.spring.boot.get()
val springCloudVersion = libs.versions.spring.cloud.get()
val springCloudAlibabaVersion = libs.versions.springcloud.alibaba.get()
val jacocoVersion = libs.versions.jacoco.get()


java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(javaVersion)
    }
}

subprojects {
    apply(plugin = "java")
    apply(plugin = "jacoco")

    repositories {
        mavenCentral()
    }

    dependencies {
        add("implementation", platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        add("implementation", platform("org.springframework.cloud:spring-cloud-dependencies:$springCloudVersion"))
        add("implementation", platform("com.alibaba.cloud:spring-cloud-alibaba-dependencies:$springCloudAlibabaVersion"))
    }

    tasks.withType<JavaCompile> {
        options.encoding = "UTF-8"
    }

    tasks.test {
        useJUnitPlatform()
    }

    jacoco {
        toolVersion = jacocoVersion
    }
}
