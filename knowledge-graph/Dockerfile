FROM eclipse-temurin:11 AS fuseki-server

RUN apt-get update && apt-get install curl -y

RUN curl -o apache-jena-fuseki-4.9.0.tar.gz https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-4.9.0.tar.gz && \
    tar -xvzf apache-jena-fuseki-4.9.0.tar.gz #&& \
    chmod +x apache-jena-fuseki-4.9.0/fuseki-server

COPY shiro.ini /apache-jena-fuseki-4.9.0
ENV FUSEKI_BASE=/apache-jena-fuseki-4.9.0

ENTRYPOINT ./apache-jena-fuseki-4.9.0/fuseki-server

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:3030 || exit 1
