# Stage 1: Build stage
FROM gradle:8.0.0 AS builder

# Create a directory for the project
WORKDIR /app

# Copy the build files
COPY gradle/* .

# Setup wrapper
RUN gradle wrapper

# Perform the build
RUN ./gradlew clean build

# Stage 2: Production stage
FROM eclipse-temurin:17-alpine

# Create a directory for the application
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/build/libs/connector.jar .

# Copy any other necessary files
COPY config.properties .
COPY entrypoint.sh .

# Set permissions for the entrypoint script
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]
