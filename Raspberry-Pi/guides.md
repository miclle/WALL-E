##Getting Started
下载镜像文件: http://www.raspberrypi.org/downloads  
我这里下载的是：`2013-05-25-wheezy-raspbian.zip`

###制作镜像
以下步骤适用于Mac OS X：

1. `2013-05-25-wheezy-raspbian.zip`解压后得到`2013-05-25-wheezy-raspbian.img`，打开终端，cd到这个目录  
![ls](https://raw.github.com/miclle/WALL-E/master/Raspberry-Pi/images/guides-dir-ls.png)

2. 插入你的SD卡，再运行`df –h` 会发现多了一个`/dev/disk1s1`的设备  
![df -h](https://raw.github.com/miclle/WALL-E/master/Raspberry-Pi/images/guides-df-h.png)

3. 卸载SD卡，输入`sudo diskutil unmount /dev/disk1s1`  
![diskutil unmount](https://raw.github.com/miclle/WALL-E/master/Raspberry-Pi/images/guides-diskutil-unmount.png)   
最后一行`Volume NO NAME on disk1s1 unmounted` disk1s1便是SD卡的名称

4. 写入镜像：  
将你的设备名（例如`/dev/disk1s1`）最后的s1去掉，然后在disk前面加上r，变成`/dev/rdisk1`，这样你就得到SD卡的原始设备名称了。
也就是说，`/dev/disk1s1` = `/dev/rdisk1`  
在终端中输入以下命令：`sudo dd bs=1m if=2013-05-25-wheezy-raspbian.img of=/dev/YOURDISKNAME`。将YOURDISKNAME改成你的原始设备名称，通常这个都是`/dev/rdisk1`  
![dd](https://raw.github.com/miclle/WALL-E/master/Raspberry-Pi/images/guides-dd.png)   

写入的过程需要一点时间。当`dd`完成了它的工作以后，将SD卡安全移除。

###初次启动Raspberry Pi
![setup-options](https://raw.github.com/miclle/WALL-E/master/Raspberry-Pi/images/guides-setup-options-1-select.png)   