# dockers安装

``` bash
获取安装脚本
$ sudo install apt curl
# curl -fsSL test.docker.com -o get-docker.sh //测试版本docker
$ curl -fsSL get.docker.com -o get-docker.sh
# 运行脚本安装docker
$ sudo sh get-docker.sh --mirror Aliyun
# sudo sh get-docker.sh --mirror AzureChinaCloud
```

# 验证是否安装成功

``` bash
$ docker run --rm hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete
Digest: sha256:308866a43596e83578c7dfa15e27a73011bdd402185a84c5cd7f32a88b501a24
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

出现这些说明安装成功。

# docker 基于Dockerfile构建image

```bash
#在 Dockerfile 文件所在目录执行：
$ docker build -t {image_name} .
# 查看是否构建成功
$ docker image list 
# 导出image分发
$ sudo docker save {image_name/imageID} > {image_name}.img
# 导入
$ docker load  -i /path/{image_name}.img
```
**[Dockerfile](./scripts/dockers) **

```dockerfile
#基于官方镜像构建
FROM ubuntu:16.04
#安装依赖包，并在安装后完成清除多余缓存文件
RUN  apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
    tzdata net-tools iproute2 vim git apt-utils sudo fakeroot \
    build-essential cmake pkg-config debhelper libssl-dev libpciaccess-dev libudev-dev libvdpau-dev libdrm-dev \
    libgl1-mesa-dev libxext-dev libxrender-dev libxau-dev libxdmcp-dev libx11-xcb-dev libxcb-present-dev \
    libxcb-dri3-dev libxinerama-dev libxcb-dri2-0-dev libxdamage-dev libxfixes-dev libc6-dev-i386 \
    lib32gcc-5-dev crossbuild-essential-arm64 libva-dev libexpat1-dev \
    qt5-default libxrandr-dev\
 && apt clean && apt autoremove && rm -rf /var/cache/apt/
#设置user name：glenfly，password：123，以及将其加入sudo组 
RUN adduser --disabled-password --gecos "" glenfly && echo "glenfly:123" | chpasswd && usermod -a -G sudo glenfly
#以该用户执行命令，设置时区为亚洲上海
USER glenfly
ENV TZ=Asia/Shanghai

```

# docker run

```bash
$ docker run --rm -it -v /<host_path>:/<container_path> image_name
#docker run --rm -it -v /home/usrname:/home/glenfly/ build_driver  
```

1. `-rm`: 这个参数表示容器退出后会自动删除。即当容器执行完毕并退出后，Docker 会自动清理掉该容器及其文件系统。这有助于避免产生大量无用的容器占用存储空间。
2. `-it`: 这两个参数是组合使用的，`-i` 表示交互式操作，`-t` 表示为容器分配一个伪终端（pseudo-TTY）。这样可以使你能够与容器进行交互，例如进入容器内部的 shell 进行命令操作。
3. `-v`: 这个参数用来将主机（宿主机）的目录或文件挂载到容器内部。格式为 `-v <host_path>:<container_path>`，表示将主机上的 `host_path` 路径挂载到容器内的 `container_path` 路径上。这样做可以在容器内访问主机上的文件或目录，并且对这些文件或目录的修改也会同步到主机上。

# 删除本地镜像

`docker image rm {imageID}`