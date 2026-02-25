# {{SERVICE_NAME}}

{{SERVICE_DESCRIPTION}}

## Module Structure

```
{{SERVICE_NAME}}/
├── {{SERVICE_NAME}}-api/      # Public SDK (@HttpExchange, DTOs)
├── {{SERVICE_NAME}}-core/     # Domain (entities, domain services)
├── {{SERVICE_NAME}}-adapter/  # Infrastructure (REST, repos, config)
└── {{SERVICE_NAME}}-boot/     # Entry point (Application.java, resources)
```

## Dependency Graph

```
boot → adapter → core
                ↘ api
```

## Quick Start

```bash
# Run in development mode
./run.sh dev

# Run in background
./run.sh bg dev

# Check status
./run.sh status

# View logs
./run.sh logs [-f]

# Stop service
./run.sh stop
```

## Build

```bash
# Build all modules
./gradlew clean build

# Run tests
./gradlew test

# Build without tests
./gradlew build -x test
```

## Docker

```bash
# Build image
docker build -t nexora/{{SERVICE_NAME}}:latest .

# Run container
docker run -p {{APP_PORT}}:8080 nexora/{{SERVICE_NAME}}:latest
```

## Ports

| Port | Purpose |
|------|---------|
| {{APP_PORT}} | Application |
| {{MGMT_PORT}} | Management/Actuator |

## Configuration

- **application.yml**: Main configuration
- **.env.example**: Environment variables template (copy to .env.local)
- **Nacos**: Dynamic configuration (if enabled)

---

## Development Guidelines

### Layer Responsibilities

| Layer | Responsibility | Allowed Dependencies |
|-------|---------------|---------------------|
| **api** | Public interfaces, DTOs | None (pure Java) |
| **core** | Business logic, entities | api |
| **adapter** | REST, repositories, external | core, api |
| **boot** | Configuration, startup | adapter |

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Entity | `{Name}` | `User`, `Order` |
| Repository | `{Entity}Repository` | `UserRepository` |
| Service | `{Entity}Service` | `UserService` |
| Service Impl | `{Entity}ServiceImpl` | `UserServiceImpl` |
| Controller | `{Entity}Controller` | `UserController` |
| DTO Request | `{Action}{Entity}Request` | `CreateUserRequest` |
| DTO Response | `{Entity}Response` | `UserResponse` |
| Mapper | `{Entity}Mapper` | `UserMapper` |

### Package Structure

```
io.github.suj1e.{{SERVICE_PACKAGE}}/
├── api/
│   ├── client/          # @HttpExchange interfaces
│   ├── dto/
│   │   ├── request/
│   │   └── response/
│   └── event/           # Kafka event DTOs
├── core/
│   ├── domain/          # JPA entities
│   ├── domainservice/   # Domain service interfaces
│   │   └── impl/
│   └── support/         # Value objects, helpers
├── adapter/
│   ├── infra/
│   │   ├── event/       # Kafka listeners
│   │   ├── id/          # ID generators
│   │   └── job/         # Scheduled jobs
│   └── service/         # Adapter services
├── config/              # @Configuration
├── exception/           # Custom exceptions
├── infra/repository/    # JPA repositories
├── mapper/              # MapStruct mappers
├── rest/                # @RestController
├── security/            # Security config
└── service/             # Application services
    └── impl/
```

### API Design

**REST Endpoint Pattern:**
```
POST   /v1/{resources}          # Create
GET    /v1/{resources}/{id}     # Get by ID
GET    /v1/{resources}          # List (with pagination)
PUT    /v1/{resources}/{id}     # Update
DELETE /v1/{resources}/{id}     # Delete
```

**Response Format (via nexora-spring-boot-starter-web):**
```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

### Exception Handling

```java
// Business exception
throw new BusinessException("USER_NOT_FOUND", "User not found");

// Use @ExceptionHandler in GlobalExceptionHandler
```

### Database

**Flyway Migration:**
- Location: `{{SERVICE_NAME}}-boot/src/main/resources/db/migration/`
- Naming: `V{number}__{description}.sql`
- Example: `V1__create_user_table.sql`

**Entity Guidelines:**
```java
@Entity
@Table(name = "t_user")
public class User extends BaseEntity {
    // Use BaseEntity for auditing (createdAt, updatedAt)
}
```

### Testing

```bash
# Run all tests
./gradlew test

# Run single test
./gradlew test --tests "*UserServiceTest"
```

**Test Naming:**
- Unit: `{Class}Test`
- Integration: `{Class}IT`

### Logging

```java
@Slf4j
public class UserService {
    public void method() {
        log.info("Processing user: {}", userId);
        log.debug("Detail: {}", detail);
        log.error("Error occurred", exception);
    }
}
```

### Event (Kafka)

**Topic Naming:**
```
{domain}.{entity}.{action}.v{version}

Examples:
- user.user.created.v1
- user.user.updated.v1
- order.order.paid.v1
```

**Event Format:**
```json
{
  "eventId": "uuid",
  "eventType": "user.created",
  "timestamp": "2024-01-01T00:00:00Z",
  "source": "{{SERVICE_NAME}}",
  "data": { ... }
}
```

**Publishing:**
```java
@Autowired
private EventPublisher eventPublisher;

eventPublisher.publish("user.user.created.v1", userEvent);
```

### Cache (Redis)

**Key Naming:**
```
{service}:{type}:{id}

Examples:
- {{SERVICE_PACKAGE}}:info:123
- {{SERVICE_PACKAGE}}:session:abc
- {{SERVICE_PACKAGE}}:lock:123
```

**TTL Strategy:**
| Type | TTL |
|------|-----|
| Info | 30 minutes |
| Session | 7 days |
| Lock | 10 seconds |

**Usage:**
```java
@Autowired
private RedisTemplate<String, Object> redisTemplate;

// Set
redisTemplate.opsForValue().set(key, value, 30, TimeUnit.MINUTES);

// Get
Object value = redisTemplate.opsForValue().get(key);

// Delete
redisTemplate.delete(key);
```

**Cache Patterns:**
- **Cache-Aside**: Check cache first, then DB, then update cache
- **Write-Through**: Write to cache and DB together
- **Write-Behind**: Write to cache, async to DB

### Health Check

```bash
curl http://localhost:{{MGMT_PORT}}/actuator/health
```

---

## Key Dependencies

| Module | Purpose |
|--------|---------|
| nexora-spring-boot-starter-web | Unified REST response |
| nexora-spring-boot-starter-data-jpa | JPA with auditing |
| spring-cloud-starter-alibaba-nacos | Service discovery & config |
