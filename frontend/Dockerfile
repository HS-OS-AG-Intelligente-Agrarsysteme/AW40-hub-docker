FROM ubuntu:20.04 as build

ARG BACKEND_URL
ARG BASIC_AUTH_KEY
ARG KC_CLIENT
ARG KC_BASE_URL
ARG KC_REALM
ARG LOG_LEVEL
ARG ROOT_DOMAIN
ARG REDIRECT_URI_MOBILE

RUN apt-get update \
 && apt-get install -y bash curl file git libglu1-mesa unzip xz-utils zip \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -r -g 1234 flutter \
 && useradd --no-log-init -r -u 1234 -g flutter -m flutter
USER flutter:flutter
WORKDIR /home/flutter

RUN curl -o flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.12-stable.tar.xz \
 && mkdir flutter-sdk \
 && tar -xJf flutter_sdk.tar.xz -C flutter-sdk --strip-components=1 \
 && rm flutter_sdk.tar.xz

ENV PATH="$PATH:/home/flutter/flutter-sdk/bin:/home/flutter/flutter-sdk/bin/cache/dart-sdk/bin"

RUN flutter precache
RUN flutter config --no-analytics

COPY --chown=flutter:flutter ./app /home/flutter/app
COPY --chown=flutter:flutter ./frontend.env /home/flutter/frontend.env
WORKDIR /home/flutter/app
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs --release
RUN flutter build web

FROM nginx:alpine as serve

COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:80 || exit 1
