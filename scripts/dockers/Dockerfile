FROM ubuntu:16.04

RUN  apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
    tzdata net-tools iproute2 vim git apt-utils sudo fakeroot \
    build-essential cmake pkg-config debhelper libssl-dev libpciaccess-dev libudev-dev libvdpau-dev libdrm-dev \
    libgl1-mesa-dev libxext-dev libxrender-dev libxau-dev libxdmcp-dev libx11-xcb-dev libxcb-present-dev \
    libxcb-dri3-dev libxinerama-dev libxcb-dri2-0-dev libxdamage-dev libxfixes-dev libc6-dev-i386 \
    lib32gcc-5-dev crossbuild-essential-arm64 libva-dev libexpat1-dev \
    qt5-default libxrandr-dev\
 && apt clean && apt autoremove && rm -rf /var/cache/apt/

RUN adduser --disabled-password --gecos "" glenfly && echo "glenfly:123" | chpasswd && usermod -a -G sudo glenfly

USER glenfly
ENV TZ=Asia/Shanghai
