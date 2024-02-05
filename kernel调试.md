# kernel build

[使用 GDB + Qemu 调试 Linux 内核 - 深入浅出 eBPF](https://www.ebpf.top/post/qemu_gdb_busybox_debug_kernel/)

> make menuconfig
>
> >kernel hacking =>
> >
> >compile type =>

### kernel 编译报错

``` bash
make[1]: *** No rule to make target 'debian/canonical-certs.pem', needed by 'certs/x509_certificate_list'. Stop.
make: *** [Makefile:1868: certs] Error 2

$ scripts/config --disable SYSTEM_TRUSTED_KEYS

make[1]: *** No rule to make target 'debian/canonical-revoked-certs.pem', needed by 'certs/x509_revocation_list'. Stop.
make: *** [Makefile:1868: certs] Error 2

$ scripts/config --disable SYSTEM_REVOCATION_KEYS

```

**Make 后一直回车 不需要输入**

---

## 启动内存文件系统制作

**[脚本文件目录](scripts/kernel调试)**

```bash
# 首先安装静态依赖，否则会有报错，参见后续的排错章节
$ sudo apt-get install libc6-dev glibc-static.x86_64

$ wget https://busybox.net/downloads/busybox-1.32.1.tar.bz2
$ tar -xvf busybox-1.32.1.tar.bz2
$ cd busybox-1.32.1/
$ make menuconfig
-> Settings
--- Build Options
[*] Build static binary (no shared libs) #进行静态编译 (CONFIG_STATIC)
# 安装完成后生成的相关文件会在 _install 目录下
$ make && make install   
$ cd _install
$ mkdir proc
$ mkdir sys
$ touch init

#  init为内核启动的初始化程序
$ vim init   
# 必须设置成可执行文件
$ chmod +x init  

$ find . | cpio -o --format=newc > ./rootfs.img
# cpio: File ./rootfs.img grew, 2758144 new bytes not copied 10777 blocks
$ ls -hl rootfs.img
-rw-r--r-- 1 root root 5.3M Feb  2 11:23 rootfs.img

```

- `find .`：这个命令会在当前目录及其所有子目录中查找所有文件和目录。`.`表示当前目录，`find`命令会递归地查找所有子目录和文件。

- `|`：这是一个管道符号，它将`find`命令的输出作为下一个命令的输入。

- `cpio -o --format=newc`：`cpio`是一个用于处理归档文件的命令。`-o`选项告诉`cpio`以输出模式运行，也就是说，它会从stdin读取文件列表，然后将这些文件打包到stdout。`--format=newc`选项指定了归档文件的格式，`newc`是一种老式的格式，用于在早期的UNIX系统中。

- `> ./rootfs.img`：这是一个重定向操作符，它将`cpio`命令的输出重定向到`./rootfs.img`文件。如果文件已经存在，它会被覆盖；如果文件不存在，它会被创建。

## init

``` sh
#!/bin/sh
echo "{==DBG==} INIT SCRIPT"
mkdir /tmp
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t tmpfs none /tmp
mdev -s 
echo -e "{==DBG==} Boot took $(cut -d' ' -f1 /proc/uptime) seconds"
# normal user
setsid /bin/cttyhack setuidgid 1000 /bin/sh
```

## Qemu 启动内核

在上述步骤准备好以后，我们需要在调试的 Ubuntu 20.04 的系统中安装 Qemu 工具，其中调测的 Ubuntu 系统使用 VirtualBox 安装。

`$ apt install qemu qemu-utils qemu-kvm virt-manager libvirt-daemon-system libvirt-clients bridge-utils ` 

把上述编译好的 vmlinux、bzImage、rootfs.img 和编译的源码拷贝到我们当前 Unbuntu 机器中。
拷贝 Linux 编译的源码主要是在 gdb 的调试过程中查看源码，其中 vmlinux 和 linux 源码处于相同的目录
`$ qemu-system-x86_64 -kernel ./bzImage -initrd  ./rootfs.img -append "nokaslr console=ttyS0" -s -S -nographic ` 

使用上述命令启动调试，启动后会停止在界面处，并等待远程 gdb 进行调试，在使用 GDB 调试之前，可以先使用以下命令进程测试内核启动是否正常。
`qemu-system-x86_64 -kernel ./bzImage -initrd  ./rootfs.img -append "nokaslr console=ttyS0" -nographic `
其中命令行中各参数如下：

- `-kernel ./bzImage`： 指定启用的内核镜像；
- `-initrd ./rootfs.img`：指定启动的内存文件系统；
- `-append "nokaslr console=ttyS0"` ： 附加参数，其中 **`nokaslr `**参数必须添加进来，防止内核起始地址随机化，这样会导致 gdb 断点不能命中；参数说明可以参见[这里](https://www.zhihu.com/question/270476360)。
- `-s` ：监听在 gdb 1234 端口；
- `-S` ：表示启动后就挂起，等待 gdb 连接；
- `-nographic`：不启动图形界面，调试信息输出到终端与参数 `console=ttyS0` 组合使用

## vscode 脚本

### debug launch文件

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [

        {
            "name":"kernel",
            "type": "cppdbg",
            "request": "launch",
            "miDebuggerServerAddress":"127.0.0.1:1234",
            "program": "${workspaceFolder}/vmlinux",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "logging": {
                "engineLogging":false
            },
            "MIMode": "gdb"
        }
    ]
}
```

启动sh脚本

### debug.sh

```sh
set -v
qemu-system-x86_64 \
	-kernel arch/x86_64/boot/bzImage \
	-initrd \
	rootfs.img \
	-append "nokaslr console=ttyS0" \
	-s -S \
	-nographic
```

