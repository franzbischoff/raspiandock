# syntax=docker/dockerfile:1

ARG BUILD_FROM=franzbischoff/raspiandock-base:latest

FROM --platform=linux/armhf ${BUILD_FROM}

ENV LANG C.UTF-8

# Build arguments
ARG BUILD_DATE="2021-06-27"
ARG BUILD_DESCRIPTION="Dockerized Raspian OS Lite"
ARG BUILD_NAME="raspiandock-lite"
ARG BUILD_REF="r0"
ARG BUILD_REPOSITORY="franzbischoff/raspiandock"
ARG BUILD_ARCH="armhf"
ARG BUILD_VERSION="v0.9"

# Labels
LABEL \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.authors="Francisco Bischoff <franzbischoff@gmail.com>" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.url="https://hub.docker.com/repository/docker/franzbischoff/raspiandock" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}

ARG DEBIAN_FRONTEND=noninteractive

# Base image doesn't have host keys
RUN dpkg-reconfigure openssh-server && service ssh restart

EXPOSE 22/tcp

WORKDIR /home/pi

USER pi

CMD /bin/bash
