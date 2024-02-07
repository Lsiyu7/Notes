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

# 调试uos内核

注：下面的更改是基于开源的kernel pub上的4.19版本。UOS无法debug的问题参考13和14。

1. 复制uos自带的config到kernel目录下，重命名为.config，然后运行make menuconfig，什么都不改，直接save成.config。

2.  vi Makefile，更改667行，把全局的O2改成O1。更改513行，更改CC_HAVE_ASM_GOTO的值为0，注释掉514和515行。

3.  取消RODATA限制，高版的kernel没有直接设置RODATA的地方了，它由其它两个值控制，一个是kernel_rwx，另一个是module_rwx,更改arch/Kconfig，第800行，改成default n，关掉STRICT_KERNEL_RWX，第816行，改成default n，关掉STRICT_MODULE_RWX.
	注意：这个文件里还有arch_has_strict_kernel_rwx/arch_has_strict_module_rwx，这两个不能关，关了会build不过。

4.  X86有几个地方会依赖于ASM_GOTO，关了会打error，需要取消掉。
	更改arch/x86/Makefile, 第303行，注掉exit 1这一行。
	更改arch/x86/include/asm/cpufeature.h，第143行，将&&改成||，否则static_cpu_has宏会走到asm_goto的实现，导致build fail，注掉149到151的warning。

5. 重新make menuconfig，关闭KASLR，这个选项开启后，grub会把bzImage加载到随机的位置，导致symbol和address无法匹配，
	Processor type and features ---> 取消勾选 Randomize the address of kernel image(KASLR) //这一项在最下面的位置
	打开生成GDB脚本选项，这个会生成一些python脚本，提供了额外的命令，比如lx-symbols这些很好用。
	Kernel hacking ---> Compile-time checks and compiler options ---> 勾选 Provide GDB scritps for kernel debugging
	打开kgdb Kernel hacking ---> 勾选KGDB: kernel debugger //确认里面的kgdb over seriel 是选上的，以及internal suit/kdb这两个没选上全部改好后，save一下就行了。

6. 关掉trust key，这个是build kernel需要签名的key之类的，我们不需要，直接打开.config，大概在8243和8244行，有两个trusted_key的选项，注掉就行。

7.  可选操作，可以调整一些module的build顺序，比如说kgdb也是一个module，如果某个module在kgdb之前加载，我们就没办法trace它的加载过程，这时就可以把它放到kgdb的后面，更改drivers/Makefile，把23行的video模块放到56行的char后面。
	注：kgdb是tty里面的一个子模块。把video放到tty/char后面，有些video相关的加载过程就可以trace了。

8. 到这里，基本就改完了，哪些module需要build成O0的就自己改对应的Makefile就行了，
	比如更改drivers/gpu/drm/Makefile，在开头加上 subdir-ccflags-y := -ggdb3 –O0
	更改drivers/tty/Makefile，更改drivers/video/Makefile等等。

9. kernel如何安装？
	`make modules_install INSTALL_MOD_STRIP=1`
	`make install`
	注：INSTALL_MOD_STRIP=1，指定安装ko时strip掉debug section，加了-ggdb3 -O0的ko体积会变大好几倍，所有的ko不strip安装的话会导致initrd.img达到好几G我们只需要host机器里有带debug section的ko就行了，安装到target机器上的ko可以不要debug信息。

10. 如何在开机时用kgdb断住机器更改启动参数，在linux命令后加上kgdbwait kgdboc=ttyS1,115200然后按F10启动。
	注：这里的ttyS1是target机器的串口

11. 如何在host端gdb上连接已断住的target机器进入kernel目录，运行gdb vmlinux
	在gdb命令中，输入`set serial baud 115200 target remote /dev/ttyUSB0`
	注：这里的ttyUSB0是host机器的串口

12. 如果开机时没有连上，直接进了系统，该怎样连接在target机器shell下输入命令

	`echo ttyS1,115200 > /sys/module/kgdboc/parameters/kgdboc`
	`echo g > /proc/sysrq-trigger`
	注：在上面的trigger命令执行后，target机器就会断住。紧接着在host机器上操作步骤11就行了。
	后面任何时刻，想要断住target机器，都可以用上面的trigger命令。

13. 如何加载某个ko的symbol手动加载方式： add-symbol-file drivers/gpu/drm/drm.ko 0xffffffffa0148000 -s .data 0xffffffffa019a160 -s .bss 0xffffffffa019b400
	注：上面的3个数字分别是drm.ko的.text/.data/.bss段的加载地址。
	查看某个ko的3个地址方式为：cat /sys/module/drm/sections/.text, .data/.bss方法类似。
	自动加载方式：任意时刻断住机器并在host机连上gdb后，在gdb中输入lx-symbols命令即可，后续在kernel加载ko时gdb会自动寻找并加载symbol。

14. UOS上make install耗时非常久，至少要几个小时才能完成，查看task发现又在重新build了，怎么解决？
	不要运行make install命令，换成下面的几个命令：
	`cp arch/x86/boot/bzImage /boot/vmlinuz-4.19.0`
	`cp System.map /boot/System.map-4.19.0`
	`/etc/kernel/postinst.d/initramfs-tools 4.19.0 /boot/vmlinuz-4.19.0`
	`/etc/kernel/postinst.d/reconfigure-dde-daemon 4.19.0 /boot/vmlinuz-4.19.0`
	`/etc/kernel/postinst.d/zz-update-grub 4.19.0 /boot/vmlinuz-4.19.0`
	注：上面的4.19.0换成你自己build的版本就行了。

15. 试了几个UOS版本(1043/1050)，发现如果在启动时连了kgdb，进系统后gdb会挂掉，无论如何都不能再连接上。
	如果是输入了lx-symbols命令，快到登陆界面时系统会直接死机。只能先进系统，再连上kgdb才不会死。如何解决？
	删掉/usr/sbin/hwinfo就可以了。
