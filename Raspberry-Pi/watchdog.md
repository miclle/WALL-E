##看门狗

参考文档：http://pi.gadgetoid.com/post/001-who-watches-the-watcher

树莓派的CPU是保护有硬件看门狗的,可以通过安装模块和值守程序来实现看门狗,防止树莓派死机!

1. 加载看门狗模块, vim /etc/modules文件, 添加一行  

	```
	bcm2708_wdog
	```  

2. 安装
	```
	sudo apt-get install watchdog chkconfig
	```
		
3. 配置
	```
	sudo vim /etc/watchdog.conf
	```
	去掉`max-load-1 = 24` 前的#号，当1分钟load进程超过24个的时候（一般5个就是超高负载了，再高可以认为是死机，这在遭遇DDOS攻击的时候很容易遇到）就会触发重启  
	设置高温复位：温度超过80度就会引起重启，保护CPU  
	```
	temperature-device = /sys/class/thermal/thermal_zone0/temp
	max-temperature = 80000
	```
	
4. 配置看门狗程序，开机自动运行 
	```
	chkconfig watchdog on
	```
5. 启动看门狗 
```
sudo /etc/init.d/watchdog start
```
6. 测试:输入下面的符号，这个符号可以引起树莓派死机，如果看门狗正常的话，等一会就能复位了  
	```
	: (){ :|:& };:
	```
