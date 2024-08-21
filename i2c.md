# i2c write&read

```c
struct i2c_msg
{
    u16 addr; 		//	default addr =  0x37;
    u16 flags； 	   // #kernel define
    u16 len ; 		//	需要写的长度 defaule = 7
    u8 *buf;		// {0x51,  byte_num | 0x80,  0x3,  0x10,  (value>>8)&0xff,  value&0xff,  checksum} 
};
```

### Set brightness sequence : 

> 0x51:      实际是0x28<<1+1，表示source address
>
> byte_num | 0x80:   byte_num表示后面跟有几个byte(除checksum byte, 上述就是4)
>
> 0x3:        表示ddc_packet_set_vcp_request
>
> 0x10:       vcp opcode, 0x10表示的是亮度信息
>
> (value>>8)&0xff    亮度值的高8位
>
> value&0xff    亮度值的低8位
>
> checksum    校验和，前面所有byte异或之后再异或0x6e的结果  
>
> **normal example: 0x51 0x84 0x03 0x10 0x00 0xlight 0x(A8^light)  **

* i2c enable .

* i2c start :   I2c写入slave address .  //例如本次就是0x6e, (0x37<<1) , Loop 7次，每次写一个byte, 依次写入 i2c_msg.buf里的每个byte.

* I2c stop

* i2c disable.

目前ddcutil 和 i2ctransfer 都可以完成对i2c亮度的写入。

本质原理都是一样的 命令有所区别。

```shell
#ddcutil
$ ddcutil setvcp 10 value

$ sudo i2ctransfer -f -y 0(bus) w7@0x37 0x51 0x84 0x03 0x10 0x00 0xlight 0x(A8^light) #write len=7 buf
```

## get brightness sequence

先写入信息 再获取亮度信息。

```c
//写
i2c_msg.len //5 
i2c_msg.buf //{0x51,  byte_num|0x80,  0x1，0x10, checksum}
```

```c
//读亮度信息，也是通过i2c_msg去操作的，填到i2c_msg里的信息如下：
i2c_msg.addr = 0x37；
i2c_msg.buf = readbuf  //readbuff是我们申请的一块buffer，12byte
i2c_msg.len = 12       //读12byte
i2c.flags = I2C_M_RD   //表示i2c读操作
```

读回的12byte信息中，第7，8两个byte表示当前显示器支持的最大亮度的高8bit和低8bit, 第9，10两个byte表示当前显示器正在使用的亮度值的高8bit和低8bit,

```shell
#ddcutil
$ ddcutil getvcp 10
# i2ctransfer
$ Sudo i2ctransfer -f -y 0 w5@0x37 0x51 0x82 0x01 0x10 0xac  #wirte len=5 buf
$ Sudo i2ctransfer -f -y 0 r12@0x37				#read len=12
```

