FROM docker.io/alpine:latest AS openwrt

ARG OPENWRT_VERSION=23.05.3

RUN apk add curl
WORKDIR /virt
RUN curl -o vmlinux \
  https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/malta/be/openwrt-${OPENWRT_VERSION}-malta-be-vmlinux.elf
RUN curl -o rootfs.img.gz -LSsf \
  https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/malta/be/openwrt-${OPENWRT_VERSION}-malta-be-rootfs-ext4.img.gz && \
  gunzip rootfs.img.gz

FROM docker.io/alpine:latest

RUN apk add \
  bash \
  qemu-system-mips \
  qemu-system-mipsel \
  qemu-bridge-helper \
  qemu-img \
  curl \
  iproute2 \
  tcpdump
WORKDIR /virt
COPY --from=openwrt /virt/* ./
COPY run-openwrt.sh /usr/bin/run-openwrt
COPY setup-network.sh /usr/bin/setup-network
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
