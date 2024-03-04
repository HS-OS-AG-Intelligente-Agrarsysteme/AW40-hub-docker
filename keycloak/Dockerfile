ARG KC_VER
FROM quay.io/keycloak/keycloak:$KC_VER
ENV KC_HEALTH_ENABLED true

# Set the working directory
# WORKDIR /opt/keycloak

# Build Keycloak
RUN curl -sL https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -o /opt/keycloak/bin/jq
RUN chmod +x /opt/keycloak/bin/jq
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

# Run the script as the entrypoint
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl --head -fsS http://localhost:8080/health/ready || exit 1