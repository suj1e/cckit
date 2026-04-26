# Architecture Patterns

## Service Naming Convention

- Service name: `{domain}-center` (e.g., `user-center`, `order-center`)
- Domain segment: strip `-center` suffix
- Package: `com.flooc.{segment}`
- Class prefix: `{Segment}Center` (PascalCase)
- API module package: `com.flooc.{segment}.api`
- App module package: `com.flooc.{segment}.app` (note the `.app` layer)
- Boot module package: `com.flooc.{segment}`

## Module Structure

```
boot → app → api
```

- **api**: Pure interfaces and DTOs. No business logic. Dependable by other services.
- **app**: All business logic, controllers, services, repositories, infrastructure.
- **boot**: Thin entry point, configuration, Flyway migrations, integration tests.

## Repository Pattern

```
repository/
  {Name}Repository.java          # Domain interface
  impl/
    {Name}RepositoryImpl.java    # Delegates to JPA
  jpa/
    {Name}JpaRepository.java     # Spring Data JPA interface
```

## Dependency Graph per Module

### API Module
- `spring-web` (for @HttpExchange)
- `jakarta-validation-api`
- `jackson-annotations`

### App Module
- `api(project(":{name}-api"))` (api scope)
- `spring-boot-starter-web`
- `spring-boot-starter-validation`
- Selected capabilities (JPA, Security, Kafka, etc.)
- `mapstruct` + processor
- `lombok`

### Boot Module
- `implementation(project(":{name}-app"))`
- `spring-boot-starter-actuator`
- Flyway + database driver
- Nacos (discovery + config)
- Test dependencies

## Key Versions

| Component | Version |
|-----------|---------|
| Java | 21 |
| Spring Boot | 4.0.5 |
| Spring Cloud | 2025.1.0 |
| Spring Cloud Alibaba | 2025.1.0.0 |
| Gradle | 9.4.1 |
| Lombok | 1.18.38 |
| MapStruct | 1.6.3 |
| Flyway | 12.4.0 |
| Redisson | 4.3.1 |
| XXL-JOB | 3.4.0 |
| Testcontainers | 2.0.2 |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_URL` | Yes | JDBC connection URL (default database name: `{service-name}` with `-` → `_`) |
| `DB_USERNAME` | Yes | Database username |
| `DB_PASSWORD` | Yes | Database password |
| `REDIS_HOST` | Yes | Redis host |
| `REDIS_PORT` | No | Redis port (default: 6379) |
| `REDIS_PASSWORD` | Yes | Redis password |
| `KAFKA_SERVERS` | Yes | Kafka bootstrap servers |
| `NACOS_ADDR` | No | Nacos server address (default: localhost:8848) |
| `NACOS_USERNAME` | No | Nacos username (default: nacos) |
| `NACOS_PASSWORD` | No | Nacos password (default: nacos) |
| `XXL_JOB_ADMIN_ADDRESSES` | No | XXL-JOB admin address |
| `XXL_JOB_ACCESS_TOKEN` | No | XXL-JOB access token |

## Gradle Plugins

| Module | Plugins |
|--------|---------|
| root | `java`, `jacoco`, `spring-boot` (apply false) |
| api | (default from subprojects) |
| app | `java-library` |
| boot | `application`, `spring-boot` |

## Package Structure Convention

### API Module
```
com.flooc.{segment}.api/
├── client/        # @HttpExchange Feign-like client interfaces
├── constant/      # Topic names, header names
├── dto/
│   ├── request/   # Java records with Jakarta validation
│   └── response/  # Java records, R<T> wrapper
└── enums/
```

### App Module
```
com.flooc.{segment}.app/
├── config/        # @Configuration classes
├── entity/        # JPA entities
├── repository/    # Domain repository interfaces
│   ├── impl/      # Repository implementations
│   └── jpa/       # Spring Data JPA interfaces
├── service/       # Service interfaces
│   └── impl/      # Service implementations
├── mapper/        # MapStruct mapper interfaces
├── web/           # @RestController + GlobalExceptionHandler
├── security/      # Security config (conditional)
├── event/         # Event publisher interfaces (conditional)
│   └── kafka/     # Kafka implementations (conditional)
├── job/           # XXL-JOB handlers (conditional)
├── redis/         # Redisson repositories (conditional)
├── filter/        # Servlet filters (conditional)
```

### Boot Module
```
com.flooc.{segment}/
└── {ClassPrefix}Application.java

resources/
├── application.yml
├── application-dev.yml
├── application-staging.yml
├── application-prod.yml
└── db/migration/

test/
├── resources/
│   └── application-test.yml
├── container/
│   └── TestContainerConfig.java
└── integration/
```
