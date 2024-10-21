# syntax=docker/dockerfile:1.7.0

FROM node:alpine3.20

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /usr/src/app

COPY package.json /usr/src/app/package.json
COPY package-lock.json /usr/src/app/package-lock.json
RUN npm ci

COPY . /usr/src/app

EXPOSE 3000

CMD [ "npm", "start" ]

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=5s --retries=5 \
    CMD curl -fs http://localhost:3000/health || exit 1
