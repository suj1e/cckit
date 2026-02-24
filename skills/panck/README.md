# Panck

A Claude Code skill for generating Spring Boot microservice scaffolds with interactive workflow.

## Installation

```bash
# Clone the repository
git clone git@github.com:suj1e/panck.git

# Run installer
cd panck
./install.sh
```

One-liner:

```bash
git clone git@github.com:suj1e/panck.git && cd panck && ./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Usage

After installation, use `/panck` command in Claude Code:

```
/panck usersrv
```

Or describe what you need:

```
创建一个通知服务 notifysrv
生成 paymentsrv 支付服务脚手架
```

## Interactive Workflow

Panck guides you through an interactive process:

### Step 1: Service Name
Enter the service name (e.g., `usersrv`, `notifysrv`)

### Step 2: Service Description (Optional)
Briefly describe the service purpose

### Step 3: Select Dependencies

**Core Capabilities:**
| Option | Description | Default |
|--------|-------------|---------|
| JPA | Database entities, auditing | ✓ |
| Redis | Multi-level caching | ✓ |
| Kafka | Event publishing | |
| Resilience | Circuit breaker, retry | |
| Audit | Entity change logging | |
| Quartz | Scheduled tasks | |

**Infrastructure:**
| Option | Description | Default |
|--------|-------------|---------|
| Web | REST controllers | ✓ |
| MySQL + Flyway | Database driver and migration | ✓ |
| QueryDSL | Type-safe queries | |

**Quality Assurance:**
| Option | Description | Default |
|--------|-------------|---------|
| K6 | Performance testing | ✓ |
| JMH | Microbenchmarks | |

### Step 4: Confirm Configuration
Review and confirm all settings before generation

### Step 5: Generate Scaffold
All files are created based on your selections

### Step 6: Post-Generation Options
- Copy `.env.example` to `.env.local` and configure
- Initialize OpenSpec (`openspec init`)
- Initialize Git (`git init`)
- Run Gradle build (`gradle wrapper && ./gradlew build`)

## Dynamic Dependencies

| Placeholder | Module | Trigger |
|-------------|--------|---------|
| `{{CORE_DEPENDENCIES}}` | core | User selects JPA/Redis/Kafka/Resilience/Audit/Quartz |
| `{{ADAPTER_QUERYDSL}}` | adapter | User selects QueryDSL |
| `{{TEST_DEPENDENCIES}}` | boot | Auto: Kafka → testcontainers-kafka, JPA → testcontainers-mysql |
| `{{JMH_DIRECTORY}}` | qa/README.md | User selects JMH |

## Features

- Interactive workflow with dependency selection
- 4-module Gradle structure (`*-api`, `*-core`, `*-adapter`, `*-boot`)
- Auto port allocation
- DDD layered architecture
- Pre-configured with Nacos, virtual threads
- Optional OpenSpec and Git initialization

## Generated Structure

```
{service}/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── gradle/
│   ├── libs.versions.toml
│   └── wrapper/
├── run.sh
├── z.sh
├── .env.example
├── Dockerfile
├── CLAUDE.md
├── README.md
├── .gitignore
├── qa/
│   ├── README.md
│   └── k6/
│       ├── load-test.js
│       ├── load-test.sh
│       └── benchmark.sh
├── {service}-api/
│   └── src/main/java/com/nexora/{package}/api/
│       ├── client/
│       ├── dto/request/
│       ├── dto/response/
│       └── event/
├── {service}-core/
│   └── src/main/java/com/nexora/{package}/core/
│       ├── domain/
│       ├── domainservice/impl/
│       └── support/
├── {service}-adapter/
│   └── src/main/java/com/nexora/{package}/
│       ├── adapter/infra/
│       ├── config/
│       ├── exception/
│       ├── infra/repository/
│       ├── mapper/
│       ├── rest/
│       └── service/impl/
└── {service}-boot/
    └── src/main/
        ├── java/com/nexora/{package}/{Service}Application.java
        └── resources/
            ├── application.yml
            ├── db/migration/
            └── logback-spring.xml
```

## Module Dependencies

| Module | Dependencies |
|--------|--------------|
| **api** | None (pure interfaces and DTOs) |
| **core** | JPA, Redis, Kafka (optional), Resilience (optional), Audit (optional), Quartz (optional) |
| **adapter** | Web, MySQL + Flyway, QueryDSL (optional), MapStruct, Observability |
| **boot** | Adapter (transitive), Nacos, Testing |

## Tech Stack

| Component | Version |
|-----------|---------|
| Java | 21 |
| Spring Boot | 4.0.2 |
| Spring Cloud | 2025.1.1 |
| Spring Cloud Alibaba | 2025.1.0.0 |
| Gradle | 9.3.0 |
| Nacos | Service discovery & config |

## Project Structure

```
panck/
├── install.sh          # Installation script
├── uninstall.sh        # Uninstallation script
├── panck-plugin/       # Skill files
│   ├── SKILL.md        # Skill definition
│   ├── assets/         # Templates
│   │   └── templates/
│   │       ├── root/   # Root build files
│   │       ├── api/    # API module
│   │       ├── core/   # Core module
│   │       ├── adapter/# Adapter module
│   │       └── boot/   # Boot module
│   └── references/     # Documentation
│       └── patterns.md
└── README.md
```

## License

MIT
