---
name: panck
description: Generate Spring Boot microservice scaffolds following DDD/Clean Architecture patterns. Use when creating a new service, generating scaffolds, or setting up microservice projects. Trigger with /panck or phrases like "create new service", "generate scaffold".
---

# Panck - Service Scaffold Generator

Generate production-ready microservice scaffolds with DDD layered architecture.

## Quick Start

```
/panck usersrv
```

Or simply say:
```
创建一个通知服务 notifysrv
```

## Interactive Workflow

### Step 1: Collect Service Name

Use `AskUserQuestion` to gather service name:

```
## Service Name

What is the name of your service?
- Pattern: lowercase with `srv` suffix (e.g., `usersrv`, `notifysrv`)
- If name doesn't end with `srv`, it will be appended automatically

[Input field]
```

### Step 2: Service Description (Optional)

```
## Service Description (Optional)

Briefly describe what this service does.
This will be used in documentation and Docker labels.

[Input field - can skip]
```

### Step 3: Select Dependencies

Present dependency options grouped by category:

```
## Select Dependencies

Which capabilities does your service need?

**Core Capabilities** (Domain layer)
- [x] JPA (Database entities) - Default
- [x] Redis (Caching) - Default
- [ ] Kafka (Event publishing)
- [ ] Resilience (Circuit breaker, retry)
- [ ] Audit (Entity change logging)
- [ ] Quartz (Scheduled tasks)

**Infrastructure** (Adapter layer)
- [x] Web (REST controllers) - Default
- [x] MySQL + Flyway - Default
- [ ] QueryDSL (Type-safe queries)

**Quality Assurance**
- [x] K6 (Performance testing) - Default
- [ ] JMH (Microbenchmarks)

Press Enter to confirm selections.
```

**Default dependencies:**
- Core: JPA, Redis
- Adapter: Web, MySQL+Flyway
- QA: K6

### Step 4: Confirm Configuration

Display full configuration and ask for confirmation:

```
## Service Configuration

| Property | Value |
|----------|-------|
| Service Name | `usersrv` |
| Description | User management service |
| Package | `io.github.suj1e.user` |
| Class Prefix | `User` |
| Context Path | `/user` |
| App Port | `40010` |
| Mgmt Port | `40011` |
| Docker Image | `nexora/usersrv` |

**Selected Dependencies:**
- Core: JPA, Redis, Kafka
- Adapter: Web, MySQL, QueryDSL

Does this look correct?
[Yes, generate] [Modify]
```

**Derivation rules:**

| From Input | Derive |
|------------|--------|
| `usersrv` | Package: `user`, Class: `User`, Context: `/user` |
| `notifysrv` | Package: `notify`, Class: `Notify`, Context: `/notify` |
| `paymentsrv` | Package: `payment`, Class: `Payment`, Context: `/payment` |

**Port allocation:**
- Check existing services in `/opt/dev/apps/tiz/` for highest used port
- App port = next available even port starting from 40010
- Mgmt port = App port + 1

### Step 5: Generate Scaffold

After confirmation, generate all files using templates.

**Template variables:**

| Variable | Example | Description |
|----------|---------|-------------|
| `{{SERVICE_NAME}}` | `usersrv` | Service name |
| `{{SERVICE_PACKAGE}}` | `user` | Package name (without `srv`) |
| `{{SERVICE_CLASS}}` | `User` | PascalCase class prefix |
| `{{SERVICE_COMPONENT}}` | `user` | Component label for Docker |
| `{{APP_PORT}}` | `40010` | Application port |
| `{{MGMT_PORT}}` | `40011` | Management/actuator port |
| `{{CONTEXT_PATH}}` | `user` | Servlet context path |
| `{{CORE_DEPENDENCIES}}` | (generated) | Core module dependencies based on user selection |
| `{{ADAPTER_QUERYDSL}}` | (generated) | QueryDSL dependencies if selected |
| `{{TEST_DEPENDENCIES}}` | (generated) | Testcontainers based on core dependencies |
| `{{JMH_DIRECTORY}}` | (generated) | JMH directory entry if selected |

**File generation order:**

1. **Root files** from `templates/root/`:
   - `settings.gradle.kts`
   - `build.gradle.kts`
   - `gradle.properties`
   - `gradle/libs.versions.toml`
   - `run.sh`
   - `z.sh`
   - `.env.example`
   - `Dockerfile`
   - `CLAUDE.md`
   - `README.md`
   - `.gitignore`

2. **Module build files** (customized based on selected dependencies):
   - `{service}-api/build.gradle.kts`
   - `{service}-core/build.gradle.kts`
   - `{service}-adapter/build.gradle.kts`
   - `{service}-boot/build.gradle.kts`

3. **Boot module resources:**
   - `{Service}Application.java`
   - `application.yml`
   - `logback-spring.xml`

4. **Package structure** with `.gitkeep` files

**Dynamic dependency generation:**

Replace `{{CORE_DEPENDENCIES}}` in core/build.gradle.kts based on user selection:

```kotlin
// If JPA selected (default):
api(libs.nexora.spring.boot.starter.data.jpa)
api("jakarta.persistence:jakarta.persistence-api")
api("org.springframework:spring-context")

// If Redis selected (default):
api(libs.nexora.spring.boot.starter.redis)

// If Kafka selected:
api(libs.nexora.spring.boot.starter.kafka)

// If Resilience selected:
api(libs.nexora.spring.boot.starter.resilience)

// If Audit selected:
api(libs.nexora.spring.boot.starter.audit)

// If Quartz selected:
api(libs.spring.boot.quartz)
```

Replace `{{ADAPTER_QUERYDSL}}` in adapter/build.gradle.kts if QueryDSL selected:

```kotlin
// QueryDSL
implementation(libs.querydsl.jpa)
annotationProcessor(libs.querydsl.apt)
annotationProcessor("com.querydsl:querydsl-apt:${rootProject.extra["querydslVersion"]}:jakarta")
annotationProcessor(libs.jakarta.persistence.api)
```

Replace `{{TEST_DEPENDENCIES}}` in boot/build.gradle.kts based on core dependencies:

```kotlin
// If Kafka selected in core:
testImplementation(libs.testcontainers.kafka)
testImplementation(libs.testcontainers.junit)

// If JPA selected (default):
testImplementation(libs.testcontainers.mysql)
testImplementation(libs.testcontainers.junit)
```

### Step 6: Post-Generation Options

After scaffold is generated:

```
## Scaffold Generated!

{directory tree}

**Next steps:**

Would you like to:
1. Initialize OpenSpec for this service? (`openspec init`)
   - Creates `openspec/` directory for spec-driven development
2. Initialize Git repository? (`git init`)
3. Run Gradle wrapper to verify? (`gradle wrapper && ./gradlew build`)

[ ] Initialize OpenSpec
[ ] Initialize Git
[ ] Run Gradle build

[Skip all] [Run selected]
```

## Module Structure

```
{service}/
├── {service}-api/src/main/java/com/nexora/{package}/api/
│   ├── client/.gitkeep
│   ├── dto/request/.gitkeep
│   ├── dto/response/.gitkeep
│   └── event/.gitkeep
├── {service}-core/src/main/java/com/nexora/{package}/core/
│   ├── domain/.gitkeep
│   ├── domainservice/impl/.gitkeep
│   └── support/.gitkeep
├── {service}-adapter/src/main/java/com/nexora/{package}/
│   ├── adapter/infra/{event,id,job}/.gitkeep
│   ├── adapter/service/impl/.gitkeep
│   ├── config/.gitkeep
│   ├── exception/.gitkeep
│   ├── infra/repository/.gitkeep
│   ├── mapper/.gitkeep
│   ├── rest/.gitkeep
│   ├── security/.gitkeep
│   └── service/impl/.gitkeep
└── {service}-boot/src/main/
    ├── java/com/nexora/{package}/{Service}Application.java
    └── resources/
        ├── application.yml
        ├── db/migration/.gitkeep
        └── logback-spring.xml
```

## Dependency Options

### Core Module Dependencies

| Dependency | Library | Description |
|------------|---------|-------------|
| JPA | `nexora-spring-boot-starter-data-jpa` | JPA auditing, soft delete |
| Redis | `nexora-spring-boot-starter-redis` | Multi-level caching (Caffeine L1 + Redis L2) |
| Kafka | `nexora-spring-boot-starter-kafka` | Event publishing with DLQ |
| Resilience | `nexora-spring-boot-starter-resilience` | Circuit breaker, retry, timeout |
| Audit | `nexora-spring-boot-starter-audit` | Entity audit logging |
| Quartz | `spring-boot-starter-quartz` | Scheduled tasks |

**Always included:** `spring-boot-starter-validation`, `spring-aop`

### Adapter Module Dependencies

| Dependency | Library | Description |
|------------|---------|-------------|
| Web | `nexora-spring-boot-starter-web` | Unified `Result<T>` response |
| MySQL | `mysql-connector-j` + `flyway` | Database driver and migration |
| QueryDSL | `querydsl-jpa` | Type-safe queries |

**Always included:** `springdoc-openapi`, `mapstruct`, `observability` bundle

### Boot Module Dependencies

**Always included:** Nacos (discovery + config), Testing bundle

## Resources

### assets/templates/

Contains template files with `{{VARIABLE}}` placeholders:
- `root/` - Root-level build files
- `api/` - API module build file
- `core/` - Core module build file
- `adapter/` - Adapter module build file
- `boot/` - Boot module files

### references/patterns.md

Detailed documentation of architecture patterns and conventions.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring Cloud 2025.1.1
- Spring Cloud Alibaba 2025.1.0.0
- Gradle 9.3.0 (Kotlin DSL)
- Nacos (service discovery & config)

## Gradle Plugins

| Module | Plugin | Purpose |
|--------|--------|---------|
| root | `java` | Base configuration |
| api/core/adapter | `java-library` | Library with `api` dependencies |
| boot | `java` + `spring-boot` | Executable application |

## Notes

- All services use virtual threads by default
- Nacos integration is pre-configured
- Health checks configured on management port
- Use Dockerfile for containerization (Jib removed)
