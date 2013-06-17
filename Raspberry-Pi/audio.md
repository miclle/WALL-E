##Audio 音频

* ###Install supporting packages
	```
	sudo apt-get update
	sudo apt-get upgrade
	```
	
	```
	sudo apt-get install alsa-utils
	```

* ###编辑文件 `/etc/modules`
	
	```
	sudo nano /etc/modules
	```
	添加:
	
	```
	snd_bcm2835 
	```

* ###Configure ALSA driver for n Analog=1 HDMI=2 (Auto=0 Not recommended)
	1. 通过音频 `analog` 输出
	
		```
		amixer cset numid=3 1
		speaker-test -t sine -f 600
		```
	2. 通过 `HDMI` 输出
	
		```
		amixer cset numid=3 2
		speaker-test -t sine -f 600				
		```

##Player
* ###mpg123 - Fast console MPEG Audio Player and decoder library
	```
	sudo apt-get install mpg123
	```	
	Download test mp3 file Hello.mp3  
	```
	wget http://semilleroadt.upbbga.edu.co/Raspberry-Pi/Hello.mp3
	```
	
	Play MP3 file  
	```
	mpg123 Hello.mp3
	```


