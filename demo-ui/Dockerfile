# syntax=docker/dockerfile:1.7.0
FROM python:3.9.5-slim-buster AS base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install curl -y

# create non-root user
RUN groupadd -r demo-ui && \
    useradd -r -g demo-ui demo-ui

# use demo-ui users home directory as workdir
WORKDIR /home/demo-ui

# install minimal requirements
COPY ./requirements.txt /home/demo-ui/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# copy python package and chown to demo-ui user
COPY --chown=demo-ui:demo-ui ./demo_ui/ /home/demo-ui/demo_ui/

# production image runs with non-root demo-ui user
FROM base as prod

USER demo-ui

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=5s --retries=5 \
  CMD curl -fs http://localhost:8002/health/ping || exit 1
