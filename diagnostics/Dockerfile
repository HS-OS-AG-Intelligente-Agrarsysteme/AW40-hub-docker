FROM python:3.9.5-buster AS base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# create non-root user
RUN groupadd -r runtime && \
    useradd -r -g runtime runtime

# use runtime users home directory as workdir
WORKDIR /home/runtime
# chown whole workdir to runtime user for interaction with model files
RUN chown runtime /home/runtime

# install requirements
COPY ./requirements.txt /home/runtime/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# copy python package
COPY ./diagnostics /home/runtime/diagnostics

# production image runs with non-root runtime user
FROM base as prod

USER runtime

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=10s --retries=5 \
  CMD celery -A diagnostics.tasks inspect ping