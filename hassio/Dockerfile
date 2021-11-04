# syntax=docker/dockerfile:1

FROM franzbischoff/raspiandock-base:v1.0

ENV LANG C.UTF-8
ENV HOME /root
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TERM xterm-256color

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
  network-manager=1.14.6-2+deb10u1 \
  && rm -rf /var/lib/apt/lists/*

# curl -fsSL https://get.docker.com -o get-docker.sh

COPY get-docker.sh /root/

RUN chmod 755 get-docker.sh && ./get-docker.sh

# it will be bind later in host /sys/firmware/devicetree/base
RUN rm /proc/device-tree && mkdir /proc/device-tree

# hassio has the "boot" partition on /mnt/boot    /lib/systemd/systemd --unit=basic.target

# Build arguments
ARG BUILD_DATE="2021-06-27"
ARG BUILD_DESCRIPTION="Dockerized Raspian OS Lite"
ARG BUILD_NAME="raspiandock-lite"
ARG BUILD_REF="r0"
ARG BUILD_REPOSITORY="franzbischoff/raspiandock"
ARG BUILD_ARCH="armhf"
ARG BUILD_VERSION="v1.0"

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

EXPOSE 22/tcp

COPY run.sh /

RUN chmod 755 /run.sh

ENTRYPOINT "/sbin/init && /run.sh"

# next steps in README.md
