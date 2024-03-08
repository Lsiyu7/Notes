# 软连接与硬链接

## 硬链接
具有相同inode节点号的多个文件互为硬链接文件；
删除硬链接文件或者删除源文件任意之一，文件实体并未被删除；
只有删除了源文件和所有对应的硬链接文件，文件实体才会被删除；
硬链接文件是文件的另一个入口；
可以通过给文件设置硬链接文件来防止重要文件被误删；
创建硬链接命令` ln `源文件 硬链接文件；
硬链接文件是普通文件，可以用rm删除；
对于静态文件（没有进程正在调用），当硬链接数为0时文件就被删除。注意：如果有进程正在调用，则无法删除或者即使文件名被删除但空间不会释放。



## 软链接
软链接类似windows系统的快捷方式；
软链接里面存放的是源文件的路径，指向源文件；
删除源文件，软链接依然存在，但无法访问源文件内容；
软链接失效时一般是白字红底闪烁；
创建软链接命令 `ln -s` 源文件 软链接文件；
软链接和源文件是不同的文件，文件类型也不同，inode号也不同；
软链接的文件类型是“l”，可以用rm删除。

## 硬链接和软链接的区别
原理上，硬链接和源文件的inode节点号相同，两者互为硬链接。软连接和源文件的inode节点号不同，进而指向的block也不同，软连接block中存放了源文件的路径名。 实际上，硬链接和源文件是同一份文件，而软连接是独立的文件，类似于快捷方式，存储着源文件的位置信息便于指向。 使用限制上，不能对目录创建硬链接，不能对不同文件系统创建硬链接，不能对不存在的文件创建硬链接；可以对目录创建软连接，可以跨文件系统创建软连接，可以对不存在的文件创建软连接。

类似于引用（硬链接）和指针（软连接，指向一个路径）


* -i 交互模式，文件存在进行提醒
* -s 软连接
* -d 允许使用超级用户制作目录的硬链接
* -b 删除， 覆盖之前的建立的链接
* -v 详细过程
* -f 强制执行
* -n 把符号链接视为一般目录




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

`console=tty0 console=ttyS1,115200n8 no_console_suspend ignore_loglevel`



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

# smbclient

使用smbclient访问共享文件夹

```bash
# 列出某个IP地址所提供的共享文件夹
smbclient -L 198.168.0.1 -U username%password
#smbclient -L 10.30.252.17 -U siyuli@glenfly%password

#像FTP客户端一样使用smbclient
smbclient //192.168.0.1/tmp  -U username%password
#smbclient //10.30.252.17/SWTemp -U siyuli@glenfly%password
```

- `cd <目录名>`: 更改远程共享上的当前工作目录。例如，`cd documents` 会将当前目录更改为远程共享中的 `documents` 目录。
- `lcd <目录名>`: 更改本地机器上的当前工作目录。这对于准备上传或下载文件到特定的本地目录很有用。例如，`lcd /home/user/downloads` 会将当前的本地目录更改为 `/home/user/downloads`。
- `get <远程文件> [本地文件]`: 从远程共享下载文件。如果指定了本地文件名，下载的文件将被重命名为该名称。例如，`get report.doc` 会下载远程文件 `report.doc` 到当前的本地目录。
- `mget <文件模式>`: 使用模式（如通配符）从远程共享批量下载文件。例如，`mget *.pdf` 会下载当前远程目录下的所有 PDF 文件。
- `put <本地文件> [远程文件]`: 将文件从本地上传到远程共享。如果指定了远程文件名，上传的文件将被重命名为该名称。例如，`put proposal.doc` 会上传本地文件 `proposal.doc` 到当前的远程目录。
- `mput <文件模式>`: 使用模式（如通配符）批量上传本地文件到远程共享。例如，`mput *.txt` 会上传当前本地目录下的所有文本文件。
- `ls` 或 `dir`: 列出当前远程目录中的文件和子目录。
- `lls` 或 `ldir`: 列出当前本地目录中的文件和子目录。
