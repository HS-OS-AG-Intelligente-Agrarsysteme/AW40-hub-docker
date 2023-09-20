ARG KC_VER
FROM quay.io/keycloak/keycloak:$KC_VER
ENV KC_HEALTH_ENABLED true

# Set the working directory
WORKDIR /opt/keycloak

# Build Keycloak

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

# Run the script as the entrypoint
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl --head -fsS http://localhost:8080/health/ready || exit 1