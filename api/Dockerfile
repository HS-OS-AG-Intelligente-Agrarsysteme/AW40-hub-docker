FROM python:3.9.5-slim-buster AS base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install curl -y

# create non-root user
RUN groupadd -r api && \
    useradd -r -g api api

# use api users home directory as workdir
WORKDIR /home/api

# install minimal requirements
COPY ./requirements.txt /home/api/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# copy python package and chown to api user
COPY --chown=api:api ./api/ /home/api/api/

# production image runs with non-root api user
FROM base as prod

USER api

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:8000/v1/health/ping|| exit 1
