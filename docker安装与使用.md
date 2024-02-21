# dockers安装

``` bash
$ sudo install apt curl
# curl -fsSL test.docker.com -o get-docker.sh //测试版本docker
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh --mirror Aliyun
# sudo sh get-docker.sh --mirror AzureChinaCloud
```

# docker Dockerfile构建image

**[Dockerfile](./scripts/dockers) **

```bash
#在 Dockerfile 文件所在目录执行：
$ docker build -t <image_name> .
# 查看是否构建成功
$ docker images list 
# 导出image分发
$ docker save <image_name/imageID> > <image_name>.image
# 导入
$ docker load  -i /path/<image_name>.image
```



# docker run

```bash
$ docker run --rm -it -v /<host_path>:/<container_path> image_name
#docker run --rm -it -v /home/usrname:/home/glenfly/ build_driver  
```

1. `-rm`: 这个参数表示容器退出后会自动删除。即当容器执行完毕并退出后，Docker 会自动清理掉该容器及其文件系统。这有助于避免产生大量无用的容器占用存储空间。
2. `-it`: 这两个参数是组合使用的，`-i` 表示交互式操作，`-t` 表示为容器分配一个伪终端（pseudo-TTY）。这样可以使你能够与容器进行交互，例如进入容器内部的 shell 进行命令操作。
3. `-v`: 这个参数用来将主机（宿主机）的目录或文件挂载到容器内部。格式为 `-v <host_path>:<container_path>`，表示将主机上的 `host_path` 路径挂载到容器内的 `container_path` 路径上。这样做可以在容器内访问主机上的文件或目录，并且对这些文件或目录的修改也会同步到主机上。