plugins {
    java
}

val springBootVersion = libs.versions.spring.boot.get()
val springCloudVersion = libs.versions.springCloud.get()
val springCloudAlibabaVersion = libs.versions.springCloudAlibaba.get()
val querydslVersion = libs.versions.querydsl.get()

extra["querydslVersion"] = querydslVersion

allprojects {
    group = "io.github.suj1e"
    version = "1.0.0"

    repositories {
        mavenLocal()
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        mavenCentral()
    }
}

subprojects {
    apply {
        plugin("java")
        plugin("java-library")
    }

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-parameters")
        options.encoding = "UTF-8"
    }

    tasks.withType<Test>().configureEach {
        useJUnitPlatform()
        maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2).coerceAtLeast(1)
    }

    dependencies {
        implementation(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        annotationProcessor(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        testImplementation(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        implementation(platform("org.springframework.cloud:spring-cloud-dependencies:$springCloudVersion"))
        implementation(platform("com.alibaba.cloud:spring-cloud-alibaba-dependencies:$springCloudAlibabaVersion"))
    }

    configurations {
        compileOnly {
            extendsFrom(configurations.annotationProcessor.get())
        }
    }
}
