# dockers

```bash
docker load -i docker_build_driver.img
docker run --rm -it -v /path/to/source/in/host:/path/to/source/in/docker build_driver
```

# 网卡 config

``` bash
sudo ip route add 10.30.90.8 via 10.30.23.254 dev enp2s0
#网卡出错 
sudo apt install -y dkms git build-essential linux-headers-$(uname -r) dh-make 
```

# pkg-config

pkg-config命令的基本用法如下：

**`pkg-config <options> <library-name>`**

pkg-config在编译应用程序和库的时候作为一个工具来使用。例如你在命令行通过如下命令编译程序时：

` gcc -o test test.c pkg-config --libs --cflags glib-2.0`

pkg-config可以帮助你插入正确的编译选项，而不需要你通过硬编码的方式来找到glib(或其他库）。

`--cflags` 一般用于指定头文件，

`--libs` 一般用于指定库文件。

在编译、链接的时候，必须要指定这些头文件和库文件的位置。对于一个比较大的第三方库，其头文件和库文件的数量是比较多的，如果我们一个个手动地写，那将是相当的麻烦的。因此，pkg-config就应运而生了。pkg-config能够把这些头文件和库文件的位置指出来，给编译器使用。pkg-config主要提供了下面几个功能：

* 检查库的版本号。 如果所需要的库的版本不满足要求，它会打印出错误信息，避免链接错误版本的库文件
* 获得编译预处理参数，如宏定义、头文件的位置
* 获得链接参数，如库及依赖的其他库的位置，文件名及其他一些链接参数
* 自动加入所依赖的其他库的设置

---

#  串口调试

修改GRUB配置文件

接下来需要修改GRUB配置文件，以便在系统启动时自动加载串口驱动程序。使用以下命令打开GRUB配置文件：

`$sudo vi /etc/default/grub`

找到以下行并将其注释掉：
` #GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"`

在其后添加以下内容：
` GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8 no_console_suspend ignore_loglevel"`

​	其中“ttyS0”表示串口设备名称，“115200n8”表示串口通信参数。

​	保存并退出文件，然后使用以下命令更新GRUB配置：

`$sudo update-grub`

最后查看是否有 

`$ Cat Sudo vim /boot/grub/grub.cfg`

console=tty0 console=ttyS1,115200n8 no_console_suspend ignore_loglevel



`ls /dev/tty*`

[来自 ](<https://www.itcool.net/189.html>)

---

# plymount lightdm

查看Plymouth 何时退出

`systemctl status plymouth-quit-wait.service`

查看lightdm 何时启动

`systemctl show -p ActiveEnterTimestamp lightdm.service`

查看哪些服务等待plymount退出 

`systemctl list-dependencies plymouth-quit-wait.service`

---

# journalctl 参数详解

- `-n` 或 `--lines=`：限制输出的行数。例如，`journalctl -n 10` 将只显示最近的10条日志。
- `-f` 或 `--follow`：实时显示新的日志条目，类似于 `tail -f`。
- `--since` 和 `--until`：按时间过滤日志。例如，`journalctl --since "2024-02-05"` 将显示从2024年2月5日开始的日志。
- `-b` 或 `--boot=`：按启动序列号过滤日志。例如，`journalctl -b` 将只显示当前启动序列的日志。
- `-u` 或 `--unit=`：按服务单元过滤日志。例如，`journalctl -u httpd.service` 将只显示 `httpd.service` 的日志[1]。
- `-p` 或 `--priority=`：按优先级过滤日志。例如，`journalctl -p err` 将只显示错误级别的日志[1]。
- `--no-pager`：直接将输出发送到标准输出，而不是通过分页器（例如 `less` 或 `more`）显示。这在需要处理数据或将数据重定向到文件时非常有用。
- `-o` 或 `--output=`：指定输出格式。例如，`journalctl -o json-pretty` 将以易于阅读的JSON格式显示日志。
- `--no-full`：限制输出，使其适应屏幕大小，并在截断的地方添加省略号

