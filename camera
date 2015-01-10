#RaspberryPi CSI camera module to stream live video to RTMP server

## 启用摄像头

```
sudo apt-get update
sudo apt-get upgrade
sudo raspi-config
# Enable the camera
```

启用摄像头后，可以如下测试：

```
raspivid -o vid.h264
```

## 安装 ffmpeg
如果系统已安装，请卸载

```
sudo apt-get remove ffmpeg
cd /usr/src
sudo mkdir ffmpeg
sudo chown `whoami`:users ffmpeg
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
./configure
make
sudo make install
```

安装过程大概5个小时

## 推送视频流到远程服务器
```
raspivid -t 999999 -w 960 -h 540 -fps 25 -b 500000 -o - | ffmpeg -i - -vcodec copy -an -metadata title="Streaming from raspberry pi camera" -f flv [url]/[id]
```
