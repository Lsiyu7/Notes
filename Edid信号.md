# edid

![image-20240204141757616](D:\markdown\image-20240204141757616.png)

00h-07h 数据头

08h-11h 显示器厂商信息

12h-13h edid版本信息

14h-18h

14h 显示器基本信息，主要区分数字信号与模拟信号

15h-16h 显示器实际物理尺寸和宽高比

17h伽马值

18h 显示器支持功能和色彩空间

19h-22h 支持的色彩范围

23h-25h edid标准中的基本时序表 分辨率与刷新率

26h-35h  定义标准八个时序的分辨率和刷新率等

36h-7Dh 72字节分成4组，表示详细时序

Block1必须为detailed timing，前0-16字节为视频时序，17为音频设置

Block2-4 detailed timing或者显示器详细参数设置



![image-20240204141831009](D:\markdown\image-20240204141831009.png)



![image-20240204141857351](D:\markdown\image-20240204141857351.png)

``` c
// CBios.h-> CBIOS_TIMING_ATTRIB    640x480 @60Hz
/* 
HorTotal: active video + blanking   / 800

HorBstart : (Blanking start)     / 640
HorBEnd:(back porch)            / 800

HorSyncStart :           / 640+16 / Front Porch default=16
HorSyncEnd:             /(640+16)+96

HorSyncBackPor: HorToal - HorSyncEnd / 800-(640+16+96)
*/
```

![image-20240204142640970](D:\markdown\image-20240204142640970.png)

**Horizontal Sync pulse **,也称为行同步脉冲,是LCD屏幕每一行画面的开始处产生的一个同步信号脉冲。用于通知显示器一行的扫描即将开始,以保证图像的稳定和同步。

**Horizontal Sync Offset(witdth) **,又称水平同步补偿,是Horizontal Sync pulse相对于行有效数据开始位置的时间偏移量。pulse前沿相对于行有效数据开始位置的时间间隔。主要作用是补偿显示信号在传输线路上的延迟,保证显示图像稳定。