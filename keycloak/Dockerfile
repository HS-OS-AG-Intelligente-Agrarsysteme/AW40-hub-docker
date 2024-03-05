FROM quay.io/keycloak/keycloak:20.0
ENV KC_HEALTH_ENABLED true
ARG TARGETARCH
ARG JQ_VER=1.7.1

# Set the working directory
WORKDIR /opt/keycloak

# Install jq
RUN curl -sL https://github.com/jqlang/jq/releases/download/jq-${JQ_VER}/jq-linux-${TARGETARCH} -o /opt/keycloak/bin/jq
RUN chmod +x /opt/keycloak/bin/jq

# Build Keycloak
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

# Run the script as the entrypoint
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=2s --retries=5 \
  CMD curl --head -fsS http://localhost:8080/health/ready || exit 1