FROM docker.io/alpine:latest AS openwrt

ARG OPENWRT_VERSION=23.05.3

RUN apk add curl
WORKDIR /virt
RUN curl -o vmlinux \
  https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-generic-kernel.bin
RUN curl -o rootfs.img.gz -LSsf \
  https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-generic-ext4-rootfs.img.gz && \
  gunzip rootfs.img.gz

FROM docker.io/alpine:latest AS config

RUN apk add xorriso
COPY config /config/
WORKDIR /virt
RUN mkisofs -o config.iso -r -V CONFIG /config

FROM docker.io/alpine:latest

RUN apk add \
  bash \
  qemu-system-x86_64 \
  qemu-bridge-helper \
  qemu-img \
  curl \
  iproute2 \
  tcpdump \
  iptables
WORKDIR /virt
COPY --from=openwrt /virt/* ./
COPY --from=config /virt/* ./
COPY run-openwrt.sh /usr/bin/run-openwrt
COPY setup-network.sh /usr/bin/setup-network
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
