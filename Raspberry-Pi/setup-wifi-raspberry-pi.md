##Raspberry Pi通过命令行安装USB无线网卡

这里使用的是 `腾达（TENDA）W311MI 超级Mini无线USB网卡` 

Raspberry Pi上启动后运行 `lsusb`

    pi@raspberrypi:~$ lsusb
    Bus 001 Device 002: ID 0424:9512 Standard Microsystems Corp.
    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 001 Device 003: ID 0424:ec00 Standard Microsystems Corp.
    Bus 001 Device 004: ID 148f:5370 Ralink Technology, Corp. RT5370 Wireless Adapter
    Bus 001 Device 005: ID 03eb:0902 Atmel Corp. 4-Port Hub
    Bus 001 Device 006: ID 062a:0000 Creative Labs Optical mouse
    Bus 001 Device 007: ID 413c:2003 Dell Computer Corp. Keyboard

其中`Bus 001 Device 004: ID 148f:5370 Ralink Technology, Corp. RT5370 Wireless Adapter`并是W311MI路由器。

运行 `iwconfig`

    pi@raspberrypi:~$ iwconfig
    wlan0     IEEE 802.11bgn  ESSID:"TP-LINK_Z"
          Mode:Managed  Frequency:2.437 GHz  Access Point: 00:27:19:78:B2:E8
          Bit Rate=54 Mb/s   Tx-Power=20 dBm
          Retry  long limit:7   RTS thr:off   Fragment thr:off
          Power Management:on
          Link Quality=43/70  Signal level=-67 dBm
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:22  Invalid misc:6   Missed beacon:0

    lo        no wireless extensions.

    eth0      no wireless extensions.

`wlan0` 就是你的无线网卡信息了

####接下来步骤：配置网络

修改/etc/network/interfaces

    auto lo

    iface lo inet loopback
    iface eth0 inet dhcp

    allow-hotplug wlan0
    iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf

    iface default inet dhcp

网上说可以设置静态IP，我是linux文盲，尝试了下可惜失败了:(

修改 /etc/wpa_supplicant/wpa_supplicant.conf

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

    network={
      ssid="无线名称"
      psk="无线密码"
      proto=WPA
      key_mgmt=WPA-PSK
      pairwise=TKIP
      auth_alg=OPEN
    }

proto key_mgmt与pairwise的值与你无线网络的设置对应上即可

最后 `sudo reboot` 重启

运行`ifconfig -a`

    @raspberrypi:~$ ifconfig -a
    eth0      Link encap:Ethernet  HWaddr b8:27:eb:f8:c5:7f
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

    lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1104 (1.0 KiB)  TX bytes:1104 (1.0 KiB)

    wlan0     Link encap:Ethernet  HWaddr c8:3a:35:c5:cc:6b
          inet addr:192.168.2.104  Bcast:255.255.255.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:958 errors:0 dropped:0 overruns:0 frame:0
          TX packets:368 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:172315 (168.2 KiB)  TX bytes:47919 (46.7 KiB)

Raspberry Pi的局域网IP为 `192.168.2.104` 然后就可以ssh远程登录了
