#Raspberry Pi LED状态

来源资料：http://elinux.org/R-Pi_Troubleshooting#Normal_LED_status

###LED亮灯状态

First Header | Second Header | Third Header
------------ | ------------- | ------------
Content Cell | Content Cell  | Content Cell


LED | 颜色 | 功能 | 正常状态
----|-----|-----|-----
ACT | 绿色 | card status | 闪烁:SD卡正在活动（类似电脑的硬盘灯）
PWR | 红色 | power | 不闪烁:正常
FDX | 橙 | full duplex | 亮:全双工/不亮:半双工
LNK | 橙 | link | 亮:网络连接成功
100 | 橙 | 100 Mbps | 亮:100 Mbps/不亮:10 Mbps

###常见亮灯状态：

ACT | PWR | FDX | LNK | 100 | 状态解读 | 解读/原因
----|-----|-----|-----|-----|---------|----
○●○ | ●●● | ○○○ | ○○○ | ○○○ | 正常 | ACT灯:SD卡正在活动
○○○ | ●●● | ○○○ | ○○○ | ○○○ | 不正常 | SD卡启动文件损坏或没有SD卡
○○○ | ○●○ | ○○○ | ○○○ | ○○○ | 不正常 | 电源电压不正常
●○● | ●●● | ○○○ | ○○○ | ○○○ | 不正常 | 看下文解释
○●○ | ●●● | ●●● | ●●● | ●●● | 正常 | 全双工/100 Mbps
○●○ | ●●● | ●●● | ●●● | ○○○ | 正常 | 全双工/10 Mbps
○●○ | ●●● | ○○○ | ●●● | ●●● | 正常 | 半双工/100 Mbps
○●○ | ●●● | ○○○ | ●●● | ○○○ | 正常 | 半双工/10 Mbps

○●○:闪烁 ●●●:常亮 ○○○:不亮 ●○●:有规律闪烁

●○●:ACT灯有规律闪烁的解读

2012年10月以后的固件：

	•	3闪烁：start.elf未找到
	•	4闪烁：start.elf没有启动
	•	7闪烁：kernel.img未找到
	
2012年10月以前的旧固件：

	•	3闪烁：loader.bin未找到
	•	4闪烁：loader.bin没有启动
	•	5闪烁：start.elf未找到
	•	6闪烁：start.elf没有推出
	•	7闪烁：kernel.img未找到
