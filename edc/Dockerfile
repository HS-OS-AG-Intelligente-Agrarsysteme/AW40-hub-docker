# syntax=docker/dockerfile:1.7.0

# Stage 1: Build stage
FROM gradle:8.0.0 AS builder

# Create a directory for the project
WORKDIR /app

# Copy the build files
COPY gradle/ /app/

# Setup wrapper
RUN gradle wrapper

# Perform the build
RUN ./gradlew clean build

# Stage 2: Production stage
FROM eclipse-temurin:17-alpine

RUN apk --no-cache add curl

# Create a directory for the application
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/build/libs/connector.jar .

# Copy script
COPY entrypoint.sh .

# Set permissions for the entrypoint script
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]

# Healthcheck
HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=2s --retries=5 \
  CMD curl --head -fsS http://localhost:8181/api/health || exit 1
