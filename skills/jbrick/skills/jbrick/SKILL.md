---
name: jbrick
description: Generate Spring Boot microservice scaffolds following flooc 3-module architecture. Trigger with /jbrick or phrases like "create new center service", "generate scaffold", "创建服务", "生成脚手架".
---

# jbrick — Microservice Scaffold Generator

Generate production-ready Spring Boot microservice scaffolds with 3-module architecture and Repository pattern.

## Quick Start

```
/jbrick user-center
```

Or use natural language:
- "创建一个用户服务 user-center"
- "generate order-center service"

## Interactive Workflow

### Step 1: Collect Service Name

Ask the user for a service name via `AskUserQuestion`. The naming convention uses `{domain}-center` suffix (e.g., `user-center`, `order-center`, `notification-center`).

If the name does not end with `-center`, append it automatically.

Derivation rules:
- Strip `-center` suffix to get the **domain segment**
- Package: `com.flooc.{segment}` (e.g., `user-center` → `com.flooc.user`)
- Class prefix: PascalCase of `{Segment}Center` (e.g., `user-center` → `UserCenter`)
- DB name: `{service-name}` with `-` → `_` (e.g., `user-center` → `user_center`)
- DB test name: `{db_name}_test` (e.g., `user_center_test`)

### Step 2: Service Description (Optional)

Ask for a brief description. Used in generated README and Docker labels.

### Step 3: Select Database

Ask the user to choose:
- **PostgreSQL** (default)
- **MySQL**

This affects JDBC driver, Flyway dialect module, Hibernate dialect, and testcontainers dependency.

| Database | Driver | Flyway Module | Dialect | Testcontainers |
|----------|--------|---------------|---------|----------------|
| PostgreSQL | `org.postgresql.Driver` | `flyway-database-postgresql` | `PostgreSQLDialect` | `postgresql` |
| MySQL | `com.mysql.cj.jdbc.Driver` | `flyway-database-mysql` | `MySQLDialect` | `mysql` |

### Step 4: Select Capabilities

Present as grouped checkboxes with defaults marked:

```
**Infrastructure**
- [x] JPA (Database entities) — Default
- [x] Flyway (Database migration) — Default
- [x] MapStruct (Object mapping) — Default

**Security**
- [ ] Redisson (Distributed locks, advanced Redis)

**Messaging**
- [ ] Kafka (Event publishing)

**Scheduling**
- [ ] XXL-JOB (Distributed task scheduling)

**Quality**
- [x] Testcontainers (Integration testing) — Default
- [x] JaCoCo (Code coverage) — Default
```

### Step 5: Confirm Configuration

Display derived values and ask for confirmation:

```
| Property | Value |
|----------|-------|
| Service Name | `user-center` |
| Description | User management service |
| Package | `com.flooc.user` |
| Class Prefix | `UserCenter` |
| App Port | `8081` |
| Database | PostgreSQL |
| Gradle | 9.4.1 |
| Spring Boot | 4.0.5 |
```

### Step 6: Generate Scaffold

After confirmation, generate all files using templates from `assets/templates/`.

**File generation order:**

1. Root files: `build.gradle.kts`, `settings.gradle.kts`, `gradle.properties`, `gradle-wrapper.properties`, `libs.versions.toml`, `Dockerfile`, `docker-compose.yml`, `.env.example`, `.gitignore`
2. API module: `build.gradle.kts`, `R.java` (always generated)
3. App module: `build.gradle.kts`, `JpaConfig.java`, `WebConfig.java`, `GlobalExceptionHandler.java` (always generated)
4. App module (conditional): additional Java files based on selections
5. Boot module: `build.gradle.kts`, `Application.java`, `application.yml`, `application-dev.yml`, `application-staging.yml`, `application-prod.yml`
6. Boot module test: `application-test.yml` (in `src/test/resources/`), `TestContainerConfig.java` (if Testcontainers selected)
7. Package structure with `.gitkeep` files for empty directories

**Template variables:**

| Variable | Description |
|----------|-------------|
| `{{SERVICE_NAME}}` | Full service name (e.g., `user-center`) |
| `{{SERVICE_PACKAGE}}` | Domain segment (e.g., `user`) |
| `{{SERVICE_CLASS}}` | PascalCase class prefix (e.g., `UserCenter`) |
| `{{FULL_PACKAGE}}` | Full package (e.g., `com.flooc.user`) |
| `{{APP_PORT}}` | Application port (e.g., `8081`) |
| `{{DB_DRIVER}}` | JDBC driver class |
| `{{DB_DIALECT}}` | Hibernate dialect class |
| `{{DB_DIALECT_KEY}}` | Database type key (`postgresql` or `mysql`) |
| `{{DB_NAME}}` | Database name (service name with `-` → `_`, e.g., `user_center`) |
| `{{DB_NAME}}_test` | Test database name (e.g., `user_center_test`) |
| `{{FLYWAY_MODULE}}` | Flyway database-specific module |
| `{{APP_DEPENDENCIES}}` | Dynamic dependency block for app module |
| `{{BOOT_DEPENDENCIES}}` | Dynamic dependency block for boot module |
| `{{BOOT_TEST_DEPENDENCIES}}` | Dynamic test dependency block for boot module |
| `{{ENABLE_SCHEDULING}}` | `import org.springframework.scheduling.annotation.EnableScheduling;` or empty |
| `{{SCHEDULING_ANNOTATION}}` | `@EnableScheduling` or empty |
| `{{SERVICE_CONFIG}}` | Dynamic YAML config block for application.yml |
| `{{JPA_BASE_PACKAGE}}` | JPA repository scan package |

**Dynamic dependency replacement for `{{APP_DEPENDENCIES}}`:**

```
# If Redisson selected:
    implementation(libs.redisson.spring.boot.starter)

# If JPA selected:
    implementation(libs.spring.boot.starter.data.jpa)

# If Kafka selected:
    implementation(libs.spring.boot.starter.kafka)

# If XXL-JOB selected:
    implementation(libs.xxl.job.core)

# If Nacos selected:
    implementation(libs.spring.cloud.starter.alibaba.nacos.discovery)
    implementation(libs.spring.cloud.starter.alibaba.nacos.config)
```

**Dynamic dependency replacement for `{{BOOT_DEPENDENCIES}}`:**

```
# If Flyway selected:
    implementation(libs.flyway.core)
    implementation(libs.{{FLYWAY_MODULE}})

# Database driver (always):
    runtimeOnly(libs.postgresql)  # or libs.mysql
```

**Dynamic dependency replacement for `{{BOOT_TEST_DEPENDENCIES}}`:**

```
# If Testcontainers selected:
    testImplementation(libs.spring.boot.test.containers)
    testImplementation(libs.testcontainers.junit.jupiter)
    testImplementation(libs.testcontainers.postgresql)  # or testcontainers.mysql
```

**Dynamic config for `{{SERVICE_CONFIG}}` in application.yml:**

```yaml
# If XXL-JOB selected:
xxl:
  job:
    admin:
      addresses: ${XXL_JOB_ADMIN_ADDRESSES:http://localhost:8088/xxl-job-admin}
    accessToken: ${XXL_JOB_ACCESS_TOKEN:dev123}
    executor:
      appname: {{SERVICE_NAME}}
      port: 9999
      logpath: ${XXL_JOB_LOG_PATH:/tmp/xxl-job-log}
```

### Step 7: Post-Generation Options

Offer the user:
1. Initialize Git repository (`git init && git add -A && git commit -m "init: scaffold from jbrick"`)
2. Verify Gradle build (`./gradlew clean build -x test`)

## Module Structure

3-module layout:

```
{service-name}-api/     — API contracts, DTOs, constants, enums
{service-name}-app/     — Business logic, controllers, services, repositories
{service-name}-boot/    — Application entry point, config, Flyway, tests
```

**Dependency graph:** `boot → app → api`

### API Module (`{name}-api`)

Pure interfaces and DTOs. No business logic.

```
com.flooc.{segment}.api/
├── client/            # @HttpExchange interfaces
├── constant/          # Constants
├── dto/
│   ├── request/       # Input DTOs (Java records)
│   └── response/      # Output DTOs (R.java always generated)
└── enums/             # Shared enumerations
```

### App Module (`{name}-app`)

All business logic and infrastructure.

```
com.flooc.{segment}.app/
├── config/            # JpaConfig, WebConfig
├── entity/            # JPA entities
├── repository/        # Domain repository interfaces
├── repository/impl/   # Repository implementations (delegate to JPA)
├── repository/jpa/    # Spring Data JPA interfaces
├── service/           # Service interfaces
├── service/impl/      # Service implementations
├── mapper/            # MapStruct mapper interfaces
├── web/               # @RestController + GlobalExceptionHandler
├── security/          # (conditional) Security config, JWT providers
├── event/             # (conditional) Event publisher interfaces
├── event/kafka/       # (conditional) Kafka implementations
├── job/               # (conditional) XXL-JOB handlers
├── redis/             # (conditional) Redisson-backed repositories
├── ratelimit/         # (conditional) Rate limiting
└── filter/            # (conditional) Servlet filters (e.g., access logging)
```

### Boot Module (`{name}-boot`)

Thin boot module.

```
com.flooc.{segment}/
└── {ClassPrefix}Application.java

resources/
├── application.yml          # Base config
├── application-dev.yml      # Dev profile (Nacos dev namespace)
├── application-staging.yml  # Staging profile
├── application-prod.yml     # Prod profile
└── db/migration/            # Flyway SQL migrations

test/
├── resources/
│   └── application-test.yml  # Test profile (Nacos disabled, create-drop)
├── container/
│   └── TestContainerConfig.java
└── integration/
```

## Dependency Options

### Always included (non-selectable)

| Dependency | Module | Purpose |
|------------|--------|---------|
| `spring-boot-starter-validation` | app | Bean validation |
| `spring-boot-starter-web` | app | REST framework |
| `spring-boot-starter-actuator` | boot | Health checks, metrics |
| `mapstruct` + `mapstruct-processor` | app | Object mapping |
| `lombok` | all | Boilerplate reduction |

### Selectable capabilities

| Option | Dependencies Added | Module |
|--------|--------------------|--------|
| **JPA** | `spring-boot-starter-data-jpa` | app |
| **Flyway** | `flyway-core`, `flyway-database-{db}` | boot |
| **MapStruct** | `mapstruct`, `mapstruct-processor`, `lombok-mapstruct-binding` | app |
| **Redisson** | `redisson-spring-boot-starter` | app |
| **Kafka** | `spring-boot-starter-kafka` | app |
| **XXL-JOB** | `xxl-job-core` | app |
| **Nacos** | `spring-cloud-starter-alibaba-nacos-discovery`, `spring-cloud-starter-alibaba-nacos-config` | app |
| **Testcontainers** | `spring-boot-testcontainers`, `testcontainers-junit-jupiter`, `testcontainers-{db}` | boot (test) |
| **JaCoCo** | `jacoco` plugin | root |

## Tech Stack

- Java 21
- Spring Boot 4.0.5
- Spring Cloud 2025.1.0
- Spring Cloud Alibaba 2025.1.0.0
- Gradle 9.4.1 (Kotlin DSL)
- Nacos (service discovery & config)

## Resources

- Templates: `assets/templates/`
- Architecture patterns: `references/patterns.md`
