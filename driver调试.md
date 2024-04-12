# mod加载

```bash
sudo -E make -C /lib/modules/linux-header-**/build  M=$PWD modules DEBUG=1 -j4
sudo cp *.ko /lib/modules/linux-header-**/updates/
sudo update-initramfs -u
```

编译驱动，系统头文件path 是一致的 `/usr/src/linux-header-**` 与 `/lib/modules/linux-headers-**/build`



`sudo insmod` 或者安装驱动

尝试重启X服务 重启看情况

`sudo systemctl restart display-manager.service`
