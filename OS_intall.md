

# 多系统分区

* 第一个分区 EFI  启动分区 所有系统挂载同一个efi分区

* 根分区  安装目录

	

# swap分区（可以共享，建议每个系统分配）

​	swap 分区关系系统S3 S4。

0.  查看swap 是否存在

​	`free -m`  看到swap分区大小为0，即没有swap分区。

​	开始创建swap分区

1. 使用dd命令创建一个swap分区，在这里创建一个4G大小的分区
    `dd if=/dev/zero of=/root/swapfile bs=1M count=4096`
	if=文件名：表示指定源文件
	of=文件名：表示指定目的文件，可以自己去设定目标文件路径。
	bs=xx：同时设置读入/写出的“块”大小 
	count=xx：表示拷贝多少个“块”
	bs * count 为拷贝的文件大小，即swap分区大小

2. 格式化新建的分区文件
`mkswap /root/swapfile`

3. 将新建的分区文件设为swap分区
`swapon /root/swapfile`

4. 设置开机自动挂载swap分区
`echo "/root/swapfile swap swap defaults 0 0" >> /etc/fstab`
