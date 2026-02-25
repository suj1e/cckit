# Microservice Patterns

## Service Naming Convention

| Pattern | Example | Description |
|---------|---------|-------------|
| Service name | `usersrv`, `notifysrv` | Lowercase, `srv` suffix |
| Package | `io.github.suj1e.user` | Derived from service name (without `srv`) |
| Class prefix | `User` | PascalCase from package |
| Docker image | `nexora/usersrv` | Lowercase service name |

## Port Allocation

Services use sequential port pairs (app + management):

| Service | App Port | Mgmt Port | Context Path |
|---------|----------|-----------|--------------|
| gatewaysrv | 40004 | 40005 | - |
| authsrv | 40006 | 40007 | `/auth` |
| tizsrv | 40008 | 40009 | `/tiz` |
| usersrv | 40010 | 40011 | `/user` |
| ... | +2 | +2 | `/{name}` |

**Formula:**
- App port = 40000 + (service_index * 2)
- Mgmt port = App port + 1

## Module Structure

Every service has 4 modules:

```
{service}/
├── {service}-api/      # Public SDK (@HttpExchange, DTOs)
├── {service}-core/     # Domain (entities, domain services)
├── {service}-adapter/  # Infrastructure (REST, repos, config)
└── {service}-boot/     # Entry point (Application.java, resources)
```

## Dependency Graph

```
boot → adapter → core
                ↘ api
```

- `api`: No internal dependencies
- `core`: No internal dependencies
- `adapter`: Depends on `core` and `api`
- `boot`: Depends on `adapter`

## Package Structure per Module

### api module
```
io.github.suj1e.{service}.api/
├── client/      # @HttpExchange interfaces
├── dto/
│   ├── request/
│   └── response/
└── event/       # Kafka event DTOs
```

### core module
```
io.github.suj1e.{service}.core/
├── domain/          # JPA entities
├── domainservice/   # Domain service interfaces
│   └── impl/        # Domain service implementations
└── support/         # Value objects, helpers
```

### adapter module
```
io.github.suj1e.{service}/
├── adapter/
│   ├── infra/       # Infrastructure adapters
│   │   ├── event/
│   │   ├── id/
│   │   └── job/
│   └── service/     # Adapter services
│       └── impl/
├── config/          # Spring @Configuration
├── exception/       # @ExceptionHandler
├── infra/
│   └── repository/  # JPA repositories
├── mapper/          # MapStruct mappers
├── rest/            # @RestController
├── security/        # Security config
└── service/         # Application services
    └── impl/
```

### boot module
```
io.github.suj1e.{service}/
└── {Service}Application.java

resources/
├── application.yml
├── db/migration/    # Flyway SQL files
└── logback-spring.xml
```

## Module Dependencies

### api module
No external dependencies. Pure Java interfaces and DTOs.

### core module
| Dependency | Description |
|------------|-------------|
| `nexora-spring-boot-starter-data-jpa` | JPA auditing, soft delete (default) |
| `nexora-spring-boot-starter-redis` | Multi-level caching (default) |
| `nexora-spring-boot-starter-kafka` | Event publishing with DLQ (optional) |
| `nexora-spring-boot-starter-resilience` | Circuit breaker, retry (optional) |
| `nexora-spring-boot-starter-audit` | Entity audit logging (optional) |
| `spring-boot-starter-validation` | Bean validation |
| `spring-aop` | AOP support |
| `spring-boot-starter-quartz` | Scheduled tasks (optional) |

### adapter module
| Dependency | Description |
|------------|-------------|
| `nexora-spring-boot-starter-web` | Unified `Result<T>` response |
| `springdoc-openapi` | API documentation |
| `flyway` + `mysql-connector-j` | Database migration |
| `observability` bundle | Actuator, Prometheus, OTel, Logstash |
| `mapstruct` | Object mapping |
| `querydsl-jpa` | Type-safe queries (optional) |

### boot module
| Dependency | Description |
|------------|-------------|
| `{service}-adapter` | Includes core and api transitively |
| `spring-cloud-starter-alibaba-nacos-*` | Service discovery & config |
| `spring-boot-starter-test` | Testing |
| `testcontainers-*` | Integration testing (auto: Kafka → testcontainers-kafka) |

## Dynamic Test Dependencies

| Core Selection | Boot Test Dependency |
|----------------|---------------------|
| Kafka | `testcontainers-kafka` + `testcontainers-junit` |
| JPA | `testcontainers-mysql` + `testcontainers-junit` |

## Key Versions

| Component | Version |
|-----------|---------|
| Java | 21 |
| Spring Boot | 4.0.2 |
| Spring Cloud | 2025.1.1 |
| Spring Cloud Alibaba | 2025.1.0.0 |
| Gradle | 9.3.0 |

## Environment Variables

Copy `.env.example` to `.env.local` and configure:

| Variable | Required | Description |
|----------|----------|-------------|
| `NACOS_HOST` | Yes | Nacos server hostname |
| `NACOS_PORT` | Yes | Nacos port |
| `DB_HOST` | Yes | MySQL host |
| `DB_PORT` | Yes | MySQL port |
| `DB_NAME` | Yes | Database name |
| `DB_USERNAME` | Yes | Database username |
| `DB_PASSWORD` | Yes | Database password |
| `REDIS_HOST` | Yes | Redis host |
| `REDIS_PORT` | Yes | Redis port |
| `KAFKA_BOOTSTRAP_SERVERS` | No | Kafka brokers |
| `OTLP_ENDPOINT` | No | OpenTelemetry endpoint |
| `SPRING_PROFILES_ACTIVE` | No | Environment (dev/test/prod) |

## Nexora Starters

Custom Spring Boot Starters providing zero-configuration auto-configuration:

| Starter | Purpose |
|---------|---------|
| `nexora-spring-boot-starter-web` | Unified `Result<T>` response, global exception handling |
| `nexora-spring-boot-starter-data-jpa` | JPA auditing, soft delete |
| `nexora-spring-boot-starter-redis` | Multi-level caching (Caffeine L1 + Redis L2) |
| `nexora-spring-boot-starter-kafka` | Event publishing with DLQ support |
| `nexora-spring-boot-starter-resilience` | Circuit breaker, retry, timeout |
| `nexora-spring-boot-starter-audit` | Entity audit logging |

## Gradle Plugins

| Module | Plugin | Purpose |
|--------|--------|---------|
| root | `java` | Base configuration |
| api/core/adapter | `java-library` | Library with `api` dependencies |
| boot | `java` + `spring-boot` | Executable application |

**Note:** `java-library` includes `java` plugin, so declaring both is redundant.

## Notes

- All services use virtual threads by default
- Nacos integration is pre-configured
- Health checks configured on management port
- Use Dockerfile for containerization
