FROM python:alpine AS build
# build the documentation

RUN pip install --upgrade pip && \
    pip install --no-cache-dir mkdocs

COPY de/ de/
RUN mkdocs build -f de/mkdocs.yml  # puts static content in de/site

FROM nginx:alpine as serve

COPY --from=build de/site/ /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:80|| exit 1