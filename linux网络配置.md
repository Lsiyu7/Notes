# ssh 多网卡 config

``` bash
sudo ip route add 10.30.90.8 via 10.30.23.254 dev enp2s0
#网卡出错 
sudo apt install -y dkms git build-essential linux-headers-$(uname -r) dh-make 
```



# nmcli 网络配置

* 查看当前系统网络设备状态 `nmcli` or `nmcli device/dev status` 
* 查看当前可用wifi设备 `nmcli dev wifi list`
* 连接WiFi `nmcli dev wifi connect <SSID>  password <password>`
每次命令执行后，会在 /etc/NetworkManager/system-connections/ 目录下创建一个新文件来保存配置，重复执行则创建多个这样的文件。删除wifi连接，在 /etc/NetworkManager/system-connections/ 目录下的对应文件也会被删除。

`nmcli conn show` # 查看
`nmcli con del <SSID>` # 删除

启用wifi连接的示例：
`nmcli connection up Samsung-printer`或者`nmcli device con wlan0`

关闭wifi连接的示例：
`nmcli connection down Samsung-printer`或者 `nmcli device dis wlan0`
