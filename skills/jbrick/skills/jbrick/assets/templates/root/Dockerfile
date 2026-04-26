# Build stage
FROM gradle:9.4.1-jdk21 AS build
WORKDIR /app
COPY . .
RUN gradle :{{SERVICE_NAME}}-boot:bootJar --no-daemon -x test

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/{{SERVICE_NAME}}-boot/build/libs/*.jar app.jar
EXPOSE {{APP_PORT}}
ENTRYPOINT ["java", "-jar", "app.jar"]
