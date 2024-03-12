# syntax=docker/dockerfile:1.7.0
FROM python:bookworm AS build
# build the documentation


RUN pip install --upgrade pip && \
    pip install --no-cache-dir mkdocs-with-pdf

COPY de/ de/
ARG BUILD_WITH_PDF
RUN mkdocs build -f de/mkdocs.yml  # puts static content in de/site

FROM nginx:alpine as serve

COPY --from=build de/site/ /usr/share/nginx/html

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:80|| exit 1
