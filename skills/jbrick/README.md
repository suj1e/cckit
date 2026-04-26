# jbrick — Microservice Scaffold Generator

Generates production-ready Spring Boot microservice scaffolds with 3-module architecture and Repository pattern.

## Installation

```bash
./install.sh jbrick
```

## Usage in Claude Code

```
/jbrick user-center
```

## Generated Service Architecture

- 3-module Gradle structure: `*-api`, `*-app`, `*-boot`
- Repository pattern: domain interface → impl → JPA
- Package base: `com.flooc.{segment}`
- Tech stack: Java 21, Spring Boot 4.0.5, Spring Cloud 2025.1.0, Gradle 9.4.1, Nacos

## Uninstall

```bash
./uninstall.sh jbrick
```
