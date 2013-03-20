#!/bin/bash

# A very crude script to setup debian6-19-04-2012 to use Realtek RRTL8188CUS based Wireless LAN Adapters
# written by MrEngman.

# Update: 20/05/2012 - It is no longer necessary to edit the script to setup the network SSID & PASSWORD
# The script will ask you to input these values when it needs them.

# Update: 25/05/2012 - I have added an option to enable the wifi adapter to be hotpluggable.
# i.e. you can remove the adapter while the Pi is powered on and then plug it back in later
# and the wifi will automatically re-install and reconnect to the wireless network.

# Update: 08/06/2012 - I have compiled a new driver that overcomes the problems found using rpi-update
# recently. This driver also does not require additional firmware so is a little simpler to install.
# The script will detect if you have an ethernet connection and update the Pi's firmware and software
# automatically and download and install the new driver automatically if you have.
# If you do not have a network connection it will expect the old driver and it's firmware to be installed
# in the /boot directory of the SD card before running the script. The driver will be installed and the
# wifi started and then the Pi's firmware and software will be downloaded and installed. Finally the new
# driver will be installed to ensure the wifi continues working with the updated software.

# Update: 11/06/2012 - Updated driver to take care of latest rpi-updates

# Update: 17/06/2012 - Updated driver to take care of latest rpi-updates

# Update: 24/06/2012 - Updated to allow selecting a connection to an unsecured network or a secured network
# with either WEP or WPA/WPA2 security. Added option to enable DHCP to be installed or not as required.

# Update: 06/07/2012 - Major update. The script will now install, upgrade or repair the wifi driver.
# It will allow more than one wifi adapter to be installed, adding the rtl8188cus drive if another
# driver is installed, or add a second rtl8188cus adapter if one is already installed.
# The script can be run on a system with the rtl8188cus already installed to upgrade/repair the driver
# if it has been broken by a software upgrade.

# Update: 08/08/2012 - Updated to be able to use the script to add/update the wifi driver on XBian

# Update: 13/08/2012 - Added test to ensure script run by root. Added test to collect list of nearby
# wireless networks to check network has visible SSID available.

# Update: 19/08/2012 - Update for new wheezy version. Fixed bugs that put driver in wrong directory.

# Update: 25/08/2012 - Update for new driver for 3.2.27+ #66 PREEMPT

# Update: 30/08/2012 - Update for new driver for 3.2.27+ #90 PREEMPT

# Update: 31/08/2012 - Update to script and file downloads to ensure old version is overwritten correctly
# update for 3.2.27+ #96

# Update: 01/09/2012 - Update for new driver for 3.2.27+ #102 PREEMPT

# Update: 03/09/2012 - Update to check wifi adapter compatible with RTL8188CUS driver

# Update: 04/09/2012 - Update to enable built in driver to replace the previous drivers

# Update: 10/09/2012 - Updated the script to avoid having to hot-plug the wifi adapter
# to avoid kernel crashes when plugging the wifi adapter while the Pi is powere on.

# Update: 14/09/2012 - Updated the script to avoid conflicts when using apt-get upgrade and rpi-update
# Running rpi-update before apt-get upgrade can result in apt-get upgrade loading an older kernel version
# which has caused problems restoring a working driver.

# Update: 17/09/2012 - Update the script to avoid an issue where the driver may not be installed or a
# wrong version could be installed due to the driver not being untared from the tar.gz file correctly.
# Removed references to XBian. It has it's own version of script included in the XBian image.

# Update: 20/09/2012 - Disable the script from running on the new 2012-09-18-wheezy-raspbian.

if [[ ${EUID} -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

# Check for new wifi setup with built in driver. Don't run script if it is.

if [ -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko ] && grep -q "iface wlan0 inet manual" /etc/network/interfaces > /dev/null 2>&1; then
	echo
	echo "Looks like you're using the new 2012-09-18-wheezy-raspbian image."
	echo
	echo "Sorry but the script will not currently set up the wifi on this image."
	echo "You need to start the GUI using command startx and set it up using WiFi Config."
	echo
	read -p "The script will now terminate. Press any key to continue ... " -n1 -s
	echo
	exit
fi


# Check if rtlwifi/rtl8192cu is blacklisted. If not blacklist the file and restart the Pi

if [ -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rtlwifi/rtl8192cu/rtl8192cu.ko ] && ! grep -q "blacklist rtl8192cu" /etc/modprobe.d/blacklist.conf > /dev/null 2>&1; then
	echo >> /etc/modprobe.d/blacklist.conf
	echo "blacklist rtl8192cu" >> /etc/modprobe.d/blacklist.conf
	echo
	echo "To avoid problems with hot-plugging the wifi adapter the Raspberry Pi has been"
	echo "configured to allow it to boot with the rtl8188cus based wifi adapter plugged in."
	echo
	echo "The Raspberry Pi will now shutdown. After the Pi has shutdown power off and plug"
	echo "in the wifi adapter. Restart the Pi and then run the script again."
	echo
	read -p "Press any key to continue ... " -n1 -s
	echo
	shutdown -h now
	exit
fi

clear

echo
echo "IMPORTANT UPDATE: The RTL8188CUS driver is now included in the latest updates"
echo "for the RPi. The script has been updated to hopefully make the transition as"
echo "easy as possible. To update to the new driver run the script and it will end"
echo "by running rpi-update which should load the latest kernel version with the"
echo "new driver included. The script will then reconfigure the image to use the"
echo "new driver."
echo
echo "This script will install the driver for Realtek RTL8188CUS based wifi adapters."
echo
echo "To see a list of wifi adapters using this driver take a look at the document at"
echo "http://dl.dropbox.com/u/80256631/install-rtl8188cus.txt"
echo
echo "1. It can install a new driver if you do not already have the rtl8188cus driver"
echo "   installed and have no other wifi adapter installed."
echo "2. It can install a wifi adapter using the rtl8188cus driver if you have a wifi"
echo "   adapter using a different driver already installed."
echo "3. If the driver is already installed it will update the driver and software, or"
echo "   allow you to add an different wifi adapter using the rtl8188cus driver so you"
echo "   can switch between them if you want to, e.g. unplug one and plug in another,"
echo "   or even connect two wifi adapters at the same time."
echo "4. It can repair a broken driver. e.g. if you have updated the software and the"
echo "   wifi has stopped working it will update the driver to a working version if"
echo "   one is available."
echo
echo "The script will also give you the option to update the software and firmware to"
echo "the latest versions using apt-get update, apt-get upgrade and rpi-update."
echo
read -p "Press any key to continue... " -n1 -s
echo
echo

# First check current wifi configuration

DRIVER_INSTALLED=1
ADAPTER_NUMBER=0
INTERNET_CONNECTED=1

# check the rtl8188cus driver is installed

if [ -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko ] || [ -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8192cu.ko ]; then
	DRIVER_INSTALLED=0
	echo -n "An RTL8188CUS driver module is installed"
	lsmod > temp.tmp 2> /dev/null
	if grep -q "8192cu" temp.tmp ; then
		echo " and loaded."
	else
		echo " but is not loaded."
	fi
else
	echo "The RTL8188CUS driver module is not installed."
	DRIVER_INSTALLED=1
fi

# check the /etc/network/interfaces file for configured wifi adapters

TOTAL_COUNT=$(grep -c "wlan" /etc/network/interfaces)

while true; do

# check number of lines with wlanX
	CONFIG=0
	CONFIG1=0
	COUNT=$(grep -c "wlan$ADAPTER_NUMBER" /etc/network/interfaces)
	if [ ${COUNT} != 0 ]; then

# check for line with "iface wlanX" at start. If it exists there must be a line with "auto wlanX"
# and/or "allow-hotplug wlanX".  if the line doesn't exist other lines shouldn't exist and any lines
# with wlanX should be commented out.

		if grep -q "^iface wlan$ADAPTER_NUMBER" /etc/network/interfaces ; then
			let CONFIG=1
			if grep -q -x "auto wlan$ADAPTER_NUMBER" /etc/network/interfaces ; then
				let CONFIG=CONFIG+1
			fi
			if grep -q -x "allow-hotplug wlan$ADAPTER_NUMBER" /etc/network/interfaces ; then
				let CONFIG=CONFIG+1
			fi
		fi

# check for lines commented out that including wlanX

		let CONFIG1=$(grep "^#" /etc/network/interfaces | grep -c "wlan${ADAPTER_NUMBER}")  2> /dev/null
		let CONFIG1=CONFIG1+CONFIG
	fi

	if [ ${CONFIG} == 2 ] || [ ${CONFIG} == 3 ]; then
		echo -n "wlan$ADAPTER_NUMBER is configured" >> installed_wifi1.txt
		ifconfig wlan$ADAPTER_NUMBER > temp.tmp 2> /dev/null
		if grep -q "wlan$ADAPTER_NUMBER" temp.tmp ; then
			if grep -q "inet addr:" temp.tmp ; then
				echo ", installed, and has a network connection." >> installed_wifi1.txt
			else
				echo " and installed, but has no network connection." >> installed_wifi1.txt
			fi
		else
			echo " but is not installed." >> installed_wifi1.txt
		fi
		let ADAPTER_NUMBER=ADAPTER_NUMBER+1
	else
		if grep -q "wlan$ADAPTER_NUMBER" /etc/network/interfaces ; then
			echo
			echo "The file /etc/network/interfaces appears to have been edited. The script will"
			echo "abort to avoid any problems that may occur if the installation continues."
			echo
			echo "Please check the file /etc/network/interfaces. A very basic setup for wlan$ADAPTER_NUMBER"
			echo "should look something like:-"
			echo
			echo "allow-hotplug wlan$ADAPTER_NUMBER             <--this line is optional"
			echo
			echo "auto wlan$ADAPTER_NUMBER                                         unsecured network-----\\"
			echo "                           /--WPA/WPA2 network     WEP network------\\     |"
			echo "iface wlan$ADAPTER_NUMBER inet dhcp     |                                          |    |"
			echo "wpa-ssid \"SSID\"        <-/|     <--may be 'wireless-essid SSID'   <-/| <-/|"
			echo "wpa-psk \"PASSWORD\"     <-/      <--may be 'wireless-key PASSWORD' <-/     |"
			echo "                                           or blank.                   <-/"
			echo
			echo "wpa-config /etc/wpa_supplicant/wpa_supplicant.conf  <-may replace the two 'wpa'"
			echo "                                                        lines."
			echo
			echo "Aborting the installation script."
			echo
			exit
		else
			if [ ${ADAPTER_NUMBER} == 1 ]; then
				echo "You have $ADAPTER_NUMBER wifi adapter configured." >> installed_wifi.txt
			else
				echo "You have $ADAPTER_NUMBER wifi adapters configured." >> installed_wifi.txt
			fi
		fi
	echo >> installed_wifi1.txt
	break
	fi
done

echo
cat  installed_wifi.txt 2> /dev/null
cat  installed_wifi1.txt 2> /dev/null

rm  installed_wifi.txt 2> /dev/null
rm  installed_wifi1.txt 2> /dev/null

# check file /etc/udev/rules.d/70-persistent-net.rules for the number of wifi adapters installed, if any

COUNT=$(grep -c "wlan" /etc/udev/rules.d/70-persistent-net.rules)
if [ ${COUNT} != ${ADAPTER_NUMBER} ] ; then
	echo -n "The file /etc/udev/rules.d/70-persistent-net.rules has $COUNT "
	if [ ${COUNT} == 1 ] ; then
		echo "entry for a wifi"
		echo -n "adapter and you have $ADAPTER_NUMBER "
	else
		echo "entries for wifi"
		echo -n "adapters and you have $ADAPTER_NUMBER "
	fi
	if [ ${ADAPTER_NUMBER} == 1 ] ; then
		echo "wifi adapter configured."
	else
		echo "wifi adapters configured."
	fi
	echo
	echo "There may be a problem with the file /etc/udev/rules.d/70-persistent-net.rules"
	echo "It may have an invalid entry for a wifi adapter that has not been installed."
	echo
	echo "However, if you have previously run the script and it aborted after the driver"
	echo "was installed but before configuring the SSID and PASSWORD it may be valid."
	echo "Entries refering to wifi adapters will have a name wlan0, wlan1 etc."
	echo
	echo "The file /etc/udev/rules.d/70-persistent-net.rules will now be displayed. The"
	echo "value ATTR[address]==\"00:e0:4c:xx:yy:zz\" is likely to indicate an invalid"
	echo "entry. Other values will probably be valid. If you have not installed a wifi"
	echo "adapter before it should only have one line at the most referencing wlan0 and no"
	echo "other entries for wlan1 etc., but if it contains the value above it should be"
	echo "deleted along with the line immediately above it which includes value rtl8192cu."
	echo "--------------------------------------------------------------------------------"
	cat /etc/udev/rules.d/70-persistent-net.rules
	echo "--------------------------------------------------------------------------------"
	echo
	echo "You now have the option to edit /etc/udev/rules.d/70-persistent-net.rules using"
	echo "the nano text editor to remove any invalid lines if any exist. After opening the"
	echo "editor place the cursor on the lines in question using the arrow keys and delete"
	echo "with ctrl-k. Save the file and exit nano using the key sequence ctrl-x, y and"
	echo "enter. If you do not change the file ctrl-x alone will terminate and close nano."
	echo
	echo "Press Y/y to edit the file /etc/udev/rules.d/70-persistent-net.rules."
	read -p "Press any other key to continue... " -n1 RESPONSE
	echo
	if [ "$RESPONSE" == "Y" ] || [ "$RESPONSE" == "y" ]; then
		nano /etc/udev/rules.d/70-persistent-net.rules
	fi
	echo
	echo
fi

# check if there is an internet connection

COUNT=0
while [ $COUNT -lt 5 ] && [ ${INTERNET_CONNECTED} != 0 ]; do
#	ping -c 1 pool.ntp.org >/dev/null 2>&1
	ping -c 1 ntp0.zen.co.uk >/dev/null 2>&1
	INTERNET_CONNECTED=$?
	if [ ${INTERNET_CONNECTED} != 0 ]; then
		let COUNT=COUNT+1
	fi
done

if [ ${INTERNET_CONNECTED} == 0 ]; 	then
	echo "The Pi has an internet connection."
	echo
	echo "Any files needed for the installation/upgrade will be downloaded from the"
	echo "Internet unless they have already been copied to the SD card /boot directory."
	echo
else
	echo "The Pi has no Internet connection."
	echo
	echo "A basic installation will be made to enable an internet connection using the"
	echo "wifi. This will then allow the remaining files required to be downloaded from"
	echo "the internet. Any files needed for the basic wifi installation need to be in"
	echo "the /boot directory of the SD card for the installation to complete."
	echo
	echo "If you are unsure of the files required for the installation the script will"
	echo "notify you of any files it cannot find that are needed then the script will"
	echo "abort. You must then copy the files to the SD card /boot directory and re-run"
	echo "the script. If you're using a Windows system to generate the SD card the /boot"
	echo "directory is the one you see when viewing the SD card with Windows Explorer."
	echo
	echo "To copy the files you can either shut down the Pi, remove the SD card and copy"
	echo "the files needed to the SD card using the system you used to copy the image to"
	echo "the SD card, or you can copy the files to a usb stick or similar and then mount"
	echo "the usb stick on the Pi and copy the files from the USB stick to the /boot"
	echo "directory of the Pi."
	echo
	read -p "Press any key to continue... " -n1 -s
	echo
	echo
fi

# check the image has the wpa_supplicant and wireless-tools packages installed

rm driver_file.txt 2> /dev/null
uname -v > linux_version.txt

EXITSTATUS=0
if [ ! -f /sbin/wpa_supplicant ] || [ ! -f /sbin/iwconfig ] || [ ! -f /usr/bin/unzip ]; then
	echo
	echo "The image you are using needs wpa_supplicant and wireless-tools installing."
	echo
	if [ ${INTERNET_CONNECTED} == 0 ]; then
		echo
		echo "Updating the software packages list."
		echo
		EXITSTATUS=-1
		until [ ${EXITSTATUS} == 0 ]; do
			apt-get update
			EXITSTATUS=$?
		done
		echo
		echo "Installing the wireless-tools and wpasupplicant packages required for the wifi to"
		echo "operate."
		echo
		EXITSTATUS=-1
		until [ ${EXITSTATUS} == 0 ]; do
			apt-get install -y unzip wireless-tools wpasupplicant 2> /dev/null
			EXITSTATUS=$?
		done
	else
		echo
		echo "Installing the wireless-tools and wpasupplicant packages required for the wifi to"
		echo "operate."
		echo

# check packages needed are on the SD card in the /bootdirectory and copy to the home directory

		if ! grep -q "#107 PREEMPT Sun Jun 10 15:57:56 BST 2012" linux_version.txt ; then

# install the unzip package if needed for the wifi installation
			EXITSTATUS=0
			if [ ! -f /usr/bin/unzip ]; then
				if [ -f /boot/unzip_6.0-7_armhf.deb ]; then
					cp /boot/unzip_6.0-7_armhf.deb ./

					dpkg -i unzip_6.0-7_armhf.deb
				else
					EXITSTATUS=1
				fi
			fi

# install the wireless-tools package if needed for the wifi installation

			if [ ${EXITSTATUS} == 0 ] && [ ! -f /sbin/iwconfig ]; then
				if [ -f /boot/libiw30_30~pre9-8_armhf.deb ] && [ -f /boot/wireless-tools_30~pre9-8_armhf.deb ]; then
					cp /boot/libiw30_30~pre9-8_armhf.deb ./
					cp /boot/wireless-tools_30~pre9-8_armhf.deb ./

					dpkg -i libiw30_30~pre9-8_armhf.deb wireless-tools_30~pre9-8_armhf.deb
				else
					EXITSTATUS=1
				fi
			fi

# install the wpasupplicant package if needed for the wifi installation
#echo "test0a"
			if [ ${EXITSTATUS} == 0 ] && [ ! -f /sbin/wpa_supplicant ]; then
#echo "test0b"
				if [ -f /boot/libnl-3-200_3.2.7-4_armhf.deb ] && [ -f /boot/libnl-genl-3-200_3.2.7-4_armhf.deb ] && [ -f /boot/libpcsclite1_1.8.4-1_armhf.deb ] && [ -f /boot/wpasupplicant_1.0-2_armhf.deb ]; then
#echo "test0c"
					cp /boot/libnl-3-200_3.2.7-4_armhf.deb ./
					cp /boot/libnl-genl-3-200_3.2.7-4_armhf.deb ./
					cp /boot/libpcsclite1_1.8.4-1_armhf.deb ./
					cp /boot/wpasupplicant_1.0-2_armhf.deb ./

					if ! grep -q "#1 PREEMPT Wed Jun 6 16:26:14 CEST 2012" linux_version.txt ; then
#echo "test0d"
						dpkg -i libnl-3-200_3.2.7-4_armhf.deb libnl-genl-3-200_3.2.7-4_armhf.deb libpcsclite1_1.8.4-1_armhf.deb wpasupplicant_1.0-2_armhf.deb
					else
#echo "test0e"

						if [ -f /boot/dbus_1.6.0-1_armhf.deb ] && [ -f /boot/libdbus-1-3_1.6.0-1_armhf.deb ] && [ -f /boot/libexpat1_2.1.0-1_armhf.deb ] && [ -f /boot/libsystemd-login0_44-3_armhf.deb ]; then
#echo "test0f"
							cp /boot/dbus_1.6.0-1_armhf.deb ./
							cp /boot/libdbus-1-3_1.6.0-1_armhf.deb ./
							cp /boot/libexpat1_2.1.0-1_armhf.deb ./
							cp /boot/libsystemd-login0_44-3_armhf.deb ./

							dpkg -i libnl-3-200_3.2.7-4_armhf.deb libnl-genl-3-200_3.2.7-4_armhf.deb libpcsclite1_1.8.4-1_armhf.deb wpasupplicant_1.0-2_armhf.deb dbus_1.6.0-1_armhf.deb libdbus-1-3_1.6.0-1_armhf.deb libexpat1_2.1.0-1_armhf.deb libsystemd-login0_44-3_armhf.deb
						else
#echo "test0g"
							EXITSTATUS=1
						fi
					fi
				else
#echo "test0h"
					EXITSTATUS=1
				fi
			fi

# if any files are not in the /boot directory of the SD card generate a list to display to the user
#echo "test0i"

			if [ ${EXITSTATUS} != 0 ]; then
#echo "test0j"
				if [ ! -f /usr/bin/unzip ] && [ ! -f /boot/unzip_6.0-7_armhf.deb ]; then
					echo "unzip_6.0-7_armhf.deb" >> driver_file.txt
				fi
				if [ ! -f /sbin/iwconfig ] && [ ! -f /boot/libiw30_30~pre9-8_armhf.deb ]; then
					echo "libiw30_30~pre9-8_armhf.deb" >> driver_file.txt
				fi
				if [ ! -f /sbin/iwconfig ] && [ ! -f /boot/wireless-tools_30~pre9-8_armhf.deb ]; then
					echo "wireless-tools_30~pre9-8_armhf.deb" >> driver_file.txt
				fi
				if grep -q "#1 PREEMPT Wed Jun 6 16:26:14 CEST 2012" linux_version.txt ; then
#echo "test0k"
					if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/dbus_1.6.0-1_armhf.deb ]; then
						echo "dbus_1.6.0-1_armhf.deb" >> driver_file.txt
					fi
					if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libdbus-1-3_1.6.0-1_armhf.deb ]; then
						echo "libdbus-1-3_1.6.0-1_armhf.deb" >> driver_file.txt
					fi
					if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libexpat1_2.1.0-1_armhf.deb ]; then
						echo "libexpat1_2.1.0-1_armhf.deb" >> driver_file.txt
					fi
					if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libsystemd-login0_44-3_armhf.deb ]; then
						echo "libsystemd-login0_44-3_armhf.deb" >> driver_file.txt
					fi
				fi
				if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libnl-3-200_3.2.7-4_armhf.deb ]; then
					echo "libnl-3-200_3.2.7-4_armhf.deb" >> driver_file.txt
				fi
				if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libnl-genl-3-200_3.2.7-4_armhf.deb ]; then
					echo "libnl-genl-3-200_3.2.7-4_armhf.deb" >> driver_file.txt
				fi
				if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/libpcsclite1_1.8.4-1_armhf.deb ]; then
					echo "libpcsclite1_1.8.4-1_armhf.deb" >> driver_file.txt
				fi
				if [ ! -f /sbin/wpa_supplicant ] && [ ! -f /boot/wpasupplicant_1.0-2_armhf.deb ]; then
					echo "wpasupplicant_1.0-2_armhf.deb" >> driver_file.txt
				fi
				rm *.deb 2> /dev/null

			else

				rm *.deb 2> /dev/null
				rm /boot/*.deb 2> /dev/null

				echo
			fi

		else

# install wpasupplicant on wheezy alpha

#echo "test0l"
			if [ -f /boot/libnl-3-200_3.2.7-4_armel.deb ] && [ -f /boot/libnl-genl-3-200_3.2.7-4_armel.deb ] && [ -f /boot/libpcsclite1_1.8.4-1_armel.deb ] && [ -f /boot/wpasupplicant_1.0-2_armel.deb ]; then
#echo "test0m"
				cp /boot/libnl-3-200_3.2.7-4_armel.deb ./
				cp /boot/libnl-genl-3-200_3.2.7-4_armel.deb ./
				cp /boot/libpcsclite1_1.8.4-1_armel.deb ./
				cp /boot/wpasupplicant_1.0-2_armel.deb ./

				dpkg -i libnl-3-200_3.2.7-4_armel.deb libnl-genl-3-200_3.2.7-4_armel.deb libpcsclite1_1.8.4-1_armel.deb wpasupplicant_1.0-2_armel.deb

				rm *.deb 2> /dev/null
				rm /boot/*.deb 2> /dev/null

				EXITSTATUS=0
			else
				if [ ! -f /boot/libnl-3-200_3.2.7-4_armel.deb ]; then
					echo "libnl-3-200_3.2.7-4_armel.deb" >> driver_file.txt
				fi
				if [ ! -f /boot/libnl-genl-3-200_3.2.7-4_armel.deb ]; then
					echo "libnl-genl-3-200_3.2.7-4_armel.deb" >> driver_file.txt
				fi
				if [ ! -f /boot/libpcsclite1_1.8.4-1_armel.deb ]; then
					echo "libpcsclite1_1.8.4-1_armel.deb" >> driver_file.txt
				fi
				if [ ! -f /boot/wpasupplicant_1.0-2_armel.deb ]; then
					echo "wpasupplicant_1.0-2_armel.deb" >> driver_file.txt
				fi
				rm *.deb 2> /dev/null
				EXITSTATUS=1
			fi
		fi
	fi
fi

# copy or download the basic driver files compatible with the installed Linux version
# for newer kernel versions the driver is included so no need to download a new driver version

BUILTIN_DRIVER=1

if grep -q "#52 Tue May 8 23:49:32 BST 2012\|#66 Thu May 17 16:56:20 BST 2012\|#90 Wed Apr 18 18:23:05 BST 2012" linux_version.txt ; then
	DRIVER_FILE=8192cu.tar.gz
else
	if grep -q "#1 PREEMPT Wed Jun 6 16:26:14 CEST 2012\|#101 PREEMPT Mon Jun 4 17:19:44 BST 2012" linux_version.txt ; then
		DRIVER_FILE=8192cu-20120607.tar.gz
	else
		if grep -q "#107 PREEMPT Sun Jun 10 15:57:56 BST 2012\|#110 PREEMPT Wed Jun 13 11:41:58 BST 2012" linux_version.txt ; then
			DRIVER_FILE=8192cu-20120611.tar.gz
		else
			if grep -q "#122 PREEMPT Sun Jun 17 00:30:41 BST 2012\|#125 PREEMPT Sun Jun 17 16:09:36 BST 2012\|#128 PREEMPT Thu Jun 21 01:59:01 BST 2012\|#135 PREEMPT Fri Jun 22 20:39:30 BST 2012\|#138 PREEMPT Tue Jun 26 16:27:52 BST 2012" linux_version.txt ; then
				DRIVER_FILE=8192cu-20120629.tar.gz
			else
				if grep -q "#144 PREEMPT Sun Jul 1 12:37:10 BST 2012\|#149 PREEMPT Thu Jul 5 01:33:01 BST 2012\|#152 PREEMPT Fri Jul 6 18:47:16 BST 2012\|#155 PREEMPT Mon Jul 9 12:49:19 BST 2012\|#159 PREEMPT Wed Jul 11 19:54:53 BST 2012\|#162 PREEMPT Thu Jul 12 12:01:22 BST 2012\|#165 PREEMPT Fri Jul 13 18:54:13 BST 2012\|#168 PREEMPT Sat Jul 14 18:56:31 BST 2012\|#171 PREEMPT Tue Jul 17 01:08:22 BST 2012\|#174 PREEMPT Sun Jul 22 19:04:28 BST 2012" linux_version.txt ; then
					DRIVER_FILE=8192cu-20120701.tar.gz
				else
					if grep -q "#202 PREEMPT Wed Jul 25 22:11:06 BST 2012\|#242 PREEMPT Wed Aug 1 19:47:22 BST 2012\|#272 PREEMPT Tue Aug 7 22:51:44 BST 2012\|#278 PREEMPT Wed Aug 15 20:59:07 BST 2012" linux_version.txt ; then
						DRIVER_FILE=8192cu-20120726.tar.gz
					else
						if grep -q "#6 PREEMPT Sat Aug 18 15:05:48 BST 2012\|#12 PREEMPT Sun Aug 19 12:28:17 BST 2012\|#24 PREEMPT Sun Aug 19 21:28:36 BST 2012\|#41 PREEMPT Tue Aug 21 15:51:24 BST 2012\|#54 PREEMPT Wed Aug 22 13:22:32 BST\|#60 PREEMPT Thu Aug 23 15:33:51 BST 2012" linux_version.txt ; then
							DRIVER_FILE=8192cu-20120819.tar.gz
						else
							if grep -q "#66 PREEMPT Fri Aug 24 23:52:42 BST 2012\|#84 PREEMPT Tue Aug 28 18:11:56 BST 2012" linux_version.txt ; then
								DRIVER_FILE=8192cu-20120819.tar.gz
							else
								if grep -q "#90 PREEMPT Wed Aug 29 22:58:42 BST 2012\|#96 PREEMPT Fri Aug 31 13:34:04 BST 2012\|#102 PREEMPT Sat Sep 1 01:00:50 BST 2012" linux_version.txt ; then
									DRIVER_FILE=8192cu-20120830.tar.gz
								else
									if grep -q "#108 PREEMPT Mon Sep 3 17:42:39 BST 2012\|#114 PREEMPT Tue Sep 4 00:15:33 BST 2012\|#138 PREEMPT Mon Sep 10 01:04:03 BST 2012\|#143 PREEMPT Tue Sep 11 02:02:37 BST 2012\|#148 PREEMPT Thu Sep 13 21:36:23 BST 2012\|#151 PREEMPT Fri Sep 14 17:00:51 BST 2012\|#157 PREEMPT Mon Sep 17 21:08:07 BST 2012\|#160 PREEMPT Mon Sep 17 23:18:42 BST 2012\|#165 PREEMPT Thu Sep 20 22:28:17 BST 2012\|#168 PREEMPT Sat Sep 22 19:26:13 BST 2012\|#171 PREEMPT Tue Sep 25 00:08:57 BST 2012\|#174 PREEMPT Wed Sep 26 14:09:47 BST 2012" linux_version.txt ; then
										DRIVER_FILE=Built-in
										BUILTIN_DRIVER=0
										EXITSTATUS=0
									else
										DRIVER_FILE=Unknown
										echo
										echo -n "Unrecognised software version: "
										uname -a
										echo
										if [ ${INTERNET_CONNECTED} != 0 ]; then
											echo "The script may be out of date. Download the latest version of the script from"
											echo "\"http://dl.dropbox.com/u/80256631/install-rtl8188cus-latest.sh\""
											echo
											echo "Compare the new script with the one you already have. If they are different"
											echo "replace the script in the /boot directory of the SD card with the new one and"
											echo "then re-run the script."
										else
											echo "Downloading the latest script."
											echo
											EXITSTATUS=1
											until [ ${EXITSTATUS} == 0 ]; do
												wget http://dl.dropbox.com/u/80256631/install-rtl8188cus-latest.sh -O install-rtl8188cus-latest.sh 2> /dev/null
												EXITSTATUS=$?
												if [ ${EXITSTATUS} != 0 ]; then
													sleep 4
												fi
											done
											if cmp -s ./install-rtl8188cus-latest.sh /boot/install-rtl8188cus-latest.sh 2> /dev/null ; then
												rm install-rtl8188cus-latest.sh
												echo "The script you're using is the latest version."
											else
												mv install-rtl8188cus-latest.sh /boot
												chmod +x /boot/install-rtl8188cus-latest.sh
												echo "The script has changed. The new script has been copied to the /boot directory"
												echo "of the SD card and will now be run."
												echo
												read -p "Press any key to continue... " -n1 -s
												/boot/install-rtl8188cus-latest.sh
												exit
											fi
										fi
										echo
										echo "Aborting the rtl8188cus installation script."
										echo
										echo
										exit
									fi
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	fi
fi

echo "A check will now be done to see if your wifi adapter is compatible with the"
echo "rtl8188cus wifi driver."
echo

COMPATIBLE_WIFI=1
EXITSTATUS=1
while [ ${EXITSTATUS} != 0 ]; do
	if lsusb | grep "04f2:aff7\|0846:9041\|0bda:8186\|2001:3309\|04f2:aff8\|0b05:17ab\|0bda:818a\|2001:330a\|04f2:aff9\|0bda:018a\|0bda:8191\|2019:1201\|04f2:affa\|0bda:317f\|0bda:8754\|2019:4902\|04f2:affb\|0bda:5088\|0df6:0052\|2019:ab2a\|04f2:affc\|0bda:8170\|0df6:005c\|2019:ab2b\|050d:1102\|0bda:8176\|0df6:0061\|2019:ab2e\|050d:2102\|0bda:8177\|0e66:0019\|2019:ed17\|050d:2103\|0bda:8178\|0eb0:9071\|20f4:624d\|0586:341f\|0bda:817a\|103c:1629\|20f4:648b\|06f8:e033\|0bda:817b\|13d3:3357\|4855:0090\|07aa:0056\|0bda:817c\|13d3:3358\|4855:0091\|07b8:8178\|0bda:817d\|13d3:3359\|4856:0091\|07b8:8189\|0bda:817e\|2001:3307\|7392:7811\|0846:9021\|0bda:817f\|2001:3308\|7392:7822" ; then
		echo
		echo "The wifi adapter has been detected and is compatible with the RTL8188CUS driver."
		echo "The script will now continue and install the driver and configure the wifi."
		echo
		COMPATIBLE_WIFI=0
		EXITSTATUS=0
	else
		if lsusb | grep "N 150\|N150\|N 300\|N300\|Wireless\|WLAN\|802.11" ; then
			echo
			echo "Your wifi adapter appears to have been detected but it is NOT compatible with"
			echo "the Realtek RTL8188CUS driver installed by the script."
			echo
			echo "You may continue and use the script to configure the /etc/network/interfaces"
			echo "file with the wifi settings, network name and password needed to get your wifi"
			echo "working but unless the driver for your device is already included in the kernel"
			echo "image it is unlikely to work."
		else
			echo
			echo "Your wifi adapter has NOT been detected. The full list of USB devices detected"
			echo "will now be displayed."
			echo
			lsusb
			echo
			echo "If your device is not displayed was it plugged in properly? You can try the USB"
			echo "scan again but first unplug it, wait a second or two, plug it back in and press"
			echo "a key to retry the USB scan to see if your device is now detected."
			echo
			echo "If your device is displayed it is NOT compatible with the RTL8188CUS driver"
			echo "installed by the script. You may continue and use the script to configure the"
			echo "/etc/network/interfaces file with the wifi settings, network name and password"
			echo "needed to get your wifi working but unless the driver for your device is already"
			echo "installed in the kernel image it is unlikely to work."
			echo
		fi
		echo
		echo "Press C/c to continue and setup the file /etc/network/interfaces with your network"
		read -p "settings, press A/a to abort the script, any other key to repeat the USB scan..." -n1 RESPONSE
		echo
		echo
		if [ "$RESPONSE" == "A" ] || [ "$RESPONSE" == "a" ]; then
			exit
		fi
		if [ "$RESPONSE" == "C" ] || [ "$RESPONSE" == "c" ]; then
			EXITSTATUS=0
		fi
	fi
done

if [ ${COMPATIBLE_WIFI} == 0 ]; then
	if [ ${BUILTIN_DRIVER} != 0 ]; then

# if the file doesn't exist and there is an internet connection then try and download the file

		WGET_FAILED=1
		while [ ! -f /boot/$DRIVER_FILE ] && [ ${INTERNET_CONNECTED} == 0 ] && [ ${WGET_FAILED} == 1 ] ; do
			if [ "$DRIVER_FILE" != "8192cu.tar.gz" ] ; then
				wget -q http://dl.dropbox.com/u/80256631/$DRIVER_FILE -O /boot/$DRIVER_FILE
			else
				wget -q http://www.electrictea.co.uk/rpi/$DRIVER_FILE -O /boot/$DRIVER_FILE
			fi

# if wget fails then an invalid 0 byte file will be generated so delete it

			if [ ! -s /boot/$DRIVER_FILE ] ; then
				rm /boot/$DRIVER_FILE
				echo "The driver download failed. Do you want to try again?"
				echo
				read -p "Press Y/y to try again. Press any other key to abort... " -n1 RESPONSE
				echo
				echo
				if [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "y" ]; then
					WGET_FAILED=0
				fi
			fi
		done

# if the file exists untar it otherwise flag the file needs copying to the SD card
# remove any 8192cu.ko files in ./ so we can check if tar is OK

		rm 8192cu.ko > /dev/null 2>&1

		TAR_FAILED=1
		if [ -f /boot/$DRIVER_FILE ]; then
			tar -zxf /boot/$DRIVER_FILE -C ./ > /dev/null 2>&1
			if [ ! -f ./8192cu.ko ] ; then
				TAR_FAILED=0
				echo "$DRIVER_FILE" >> driver_file.txt
			fi
		else
			echo "$DRIVER_FILE" >> driver_file.txt
		fi

# if driver_file.txt exists some files need downloading so flag to user

		if [ -f driver_file.txt ]; then
			if [ ${WGET_FAILED} == 0 ]; then
				echo
				echo "The file download failed to fetch the file $DRIVER_FILE. The download web site"
				echo "may be offline or your internet connection may have a problem."
				echo
			fi
			if [ ${TAR_FAILED} == 0 ]; then
				echo
				echo "There is a problem with the driver file /boot/$DRIVER_FILE. File details:"
				echo
				ls -l /boot/$DRIVER_FILE
				echo
				echo "The file is invalid and the tar command failed to untar it correctly. If you are"
				echo "using a wired internet connection to the Pi the file downloaded incorrectly. If"
				echo "you downloaded the file on a different system and copied it to the PI either the"
				echo "file was downloaded incorrectly on the other system or the copy failed."
				echo
				echo "Delete the file /boot/$DRIVER_FILE before running the script again."
				echo
			fi
			echo
			echo  "The file(s) "
			cat driver_file.txt
			echo "must be in the /boot directory of the SD card, or a wired internet connection"
			echo "must be made to the Pi for the installation to continue."
			echo
			echo "Copy the file(s) to the /boot directory of the SD card or connect to a wired"
			echo "internet connection and then run the script again."
			echo
			echo "Aborting the rtl8188cus installation script."
			echo

			rm driver_file.txt
			rm linux_version.txt

			exit 1
		fi

		echo
		echo "The wifi driver for your current Linux version will now be installed/re-installed"
		echo "and the necessary files will be configured as required."
		echo

# if the the kernel version has been downgraded by apt-get upgrade remove built in driver

		rm /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko > /dev/null 2>&1

# check if a driver is installed, uninstall if yes and install new one
		if [ -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8192cu.ko ] ; then
			echo "Replacing previous version of driver."
			rmmod 8192cu > /dev/null 2>&1
		else
			echo "Installing new driver."
		fi

		install -p -m 644 8192cu.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/ > /dev/null 2>&1
		insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8192cu.ko > /dev/null 2>&1
		depmod -a
	else
		echo "The kernel version you are now using has the RTL8188CUS driver built in so now"
		echo "there is no need to download and install a driver. The script will however"
		echo "continue to clean up the old, now unused, driver and module directories and"
		echo "you can configure the files if necessary to ensure the wifi is operational or"
		echo "install a different wifi adaptor."

# if the driver is built in the old version should be removed if it exists

		rmmod 8192cu > /dev/null 2>&1
		sed -i '/8192cu/d' /etc/modules
		sed -i '/blacklist rtl8192cu/d' /etc/modprobe.d/blacklist.conf
		rm -r /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtlwifi > /dev/null 2>&1
		rm /lib/modules/3.2.27+/kernel/drivers/net/wireless/8192cu.ko > /dev/null 2>&1
		rm -r /lib/modules/3.1.9+ > /dev/null 2>&1
		rm -r /lib/modules/3.1.9-cutdown+ > /dev/null 2>&1
		rm -r /lib/modules.bak/3.1.9+ > /dev/null 2>&1
		rm -r /lib/modules.bak/3.1.9-cutdown+ > /dev/null 2>&1
		insmod /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko > /dev/null 2>&1
		depmod -a > /dev/null 2>&1
	fi

# wifi driver should be installed - bring up adapter to allow scan

	echo
	echo "Bringing up wifi adapter."
	echo

	COUNT=0
	EXITSTATUS=1
	while [ ${EXITSTATUS} != 0 ]; do
		echo -n "Bringing up wlan$COUNT"
		ifup --force wlan$COUNT > temp.tmp 2>&1
		if grep -q "Failed to bring up wlan$COUNT" temp.tmp ; then
			echo
			let COUNT=COUNT+1
		else
			echo " - OK."
			EXITSTATUS=0
		fi
	done

# check wifi adapter is compatible with driver and check list of available networks

	echo
	echo "The script will now attempt to find a list of available wifi networks."
	read -p "Press any key to continue... " -n1 -s
	echo
	echo

	ADAPTER_COUNTER=0
	EXITSTATUS=1

	while [ ${ADAPTER_COUNTER} -le ${ADAPTER_NUMBER} ] && [ ${EXITSTATUS} != 0 ] ; do
		echo -n "Scanning networks using wlan$ADAPTER_COUNTER"
		iwlist wlan$ADAPTER_COUNTER scanning > network-list.txt 2>&1
		if grep -q "ESSID" network-list.txt ; then
			echo " - Scanned OK!"
			EXITSTATUS=0
		else
			echo
			let ADAPTER_COUNTER=ADAPTER_COUNTER+1
		fi

		if [ ${ADAPTER_COUNTER} -gt ${ADAPTER_NUMBER} ] && [ ${EXITSTATUS} != 0 ]; then
			echo "The scan for wifi networks failed to find any networks."
			echo
			read -p "Press any key to continue... " -n1 -s
			echo
			echo
			let ADAPTER_COUNTER=0
		fi
	done
else
	echo "Wifi not scanned because the wifi is incompatible with the rtl8188cus driver."
fi

# delete the driver files in the home directory - the driver has been installed so they're no longer needed.

rm 8192cu.ko > /dev/null 2>&1
rm linux_version.txt > /dev/null 2>&1

# now update some files to configure the driver - first /etc/network/interfaces.

# if wlan0 or another wifi is already configured in these files:
# 1 - ignore the file edits if doing a update of the currently installed driver.
# 2 - add a new device using wlanx if installing another wifi adapter
#

ADAPTER_INSTALL=N

if [ ${ADAPTER_NUMBER} != 0 ]; then
	echo
	echo "Your Pi is already configured to use a wifi adapter."
	echo
	echo "The script will allow you to add an additional wifi adapter if it uses the"
	echo "rtl8188cus driver. The wifi adapter already installed does not need to be using"
	echo "the rtl8188cus driver and may use a different driver. Use the Add option in this"
	echo "case"
	echo
	echo "If the installed wifi adapter uses the rtl8188cus driver and is not working"
	echo "because you have done a recent software update/upgrade or you want to alter the"
	echo "SSID or PASSWORD select the Upgrade option."
	echo
	echo "Are you upgrading or re-installing the driver for a device already installed or"
	echo "do you want to install a new adapter that uses the rtl8188cus driver?"
	while true; 	do
		echo
		read -p "Press U/u if Upgrading/re-installing a driver, press A/a if Adding a new adapter. " -n1 ADAPTER_INSTALL
		if [ "$ADAPTER_INSTALL" != "U" ] && [ "$ADAPTER_INSTALL" != "A" ] && [ "$ADAPTER_INSTALL" != "u" ] && [ "$ADAPTER_INSTALL" != "a" ]; then
			echo " - Invalid response, enter U or A "
			echo
		else
			echo
			break
		fi
	done
fi

if [ "$ADAPTER_INSTALL" == "U" ] || [ "$ADAPTER_INSTALL" == "u" ]; then
	echo
	echo "As you are upgrading you have the option to change the network ssid or password."
	echo
	echo "If you want to change either of them the script can open the file"
	echo "/etc/network/interfaces with the nano text editor so you can edit the network"
	echo "name and the password as required."
	echo
	echo "If you use the option to use nano you can save the file and exit nano by using"
	echo "the key sequence cntl-x, y and enter."
	echo
	read -p "Press Y/y to edit the sidd or password. Press any other key to continue... " -n1 RESPONSE
	echo
	if [ "$RESPONSE" == "Y" ] || [ "$RESPONSE" == "y" ]; then
		nano /etc/network/interfaces
	fi
fi

if [ "$ADAPTER_INSTALL" == "A" ] || [ "$ADAPTER_INSTALL" == "a" ] ||  [ "$ADAPTER_INSTALL" == "N" ]; then

	echo
	echo "Be careful typing in the network name, SSID, and the network key/password,"
	echo "PASSWORD, if your network uses WEP or WPA/WPA2. If either are incorrect the wifi"
	echo "will not connect to the network and you may need to re-write the SD card and"
	echo "repeat the installation. If the network name or network key/password use any"
	echo "non-alphanumeric characters these can also cause problems connecting. The"
	echo "following characters can cause problems. ! \" # $ ( ) . / : < > ? [ \\ ] _ { | } "
	echo
	echo "Is your network unsecured so does NOT need a password or is it secured and needs"
	echo "a password to connect to the wireless network."
	while true; do
		echo
		read -p "Press U/u if the network is unsecured, E/e if WEP, or A/a if WPA/WPA2. " -n1 SECURITY
		if [ "$SECURITY" != "U" ] && [ "$SECURITY" != "E" ] && [ "$SECURITY" != "A" ] && [ "$SECURITY" != "u" ] && [ "$SECURITY" != "e" ] && [ "$SECURITY" != "a" ]; then
			echo " - Invalid response, enter U, E or A "
			echo
		else
			echo
			break
		fi
	done

	EXITSTATUS=1
	until [ ${EXITSTATUS} == 0 ]; do
		while true; do
			echo
			read -p "Please enter the Network SSID - " SSID
			echo
			echo "Your network SSID is \"$SSID\", is that correct?"
			read -p "press Y to continue, any other key to re-enter the SSID. " -n1 RESPONSE
			if [ "$RESPONSE" == "Y" ] || [ "$RESPONSE" == "y" ]; then
				echo
				break
			fi
			echo
		done

# check we can see the network you want to connect to
		if [ -f network-list.txt ]; then
			if grep -q "ESSID:\"$SSID\"" network-list.txt ; then
				EXITSTATUS=$?
			else
				echo
				echo "That network is not visible. Does your wireless access point or router transmit"
				echo "it's SSID (network name)? If not you need to configure your access point to"
				echo "transmit the ssid."
				echo
				echo "The list of available networks will now be displayed. You can scroll through the"
				echo "list using the up and down arrow keys. To quit viewing the list use the q key."
				read -p "Press any key to continue... " -n1 -s
				echo
				cat network-list.txt | less
				echo
				echo "Do you want to continue the installation? You will need to enter a valid SSID."
				read -p "To terminate the script press N/n, any other key to re-enter the SSID. " -n1 RESPONSE
				if [ "$RESPONSE" == "N" ] || [ "$RESPONSE" == "n" ]; then
					echo
					echo
					rm network-list.txt > /dev/null 2>&1
					exit 1
				fi
				echo
			fi
		else
			EXITSTATUS=0
		fi
	done

	if [ "$SECURITY" != "U" ] && [ "$SECURITY" != "u" ]; then
		while true; do
			echo
			read -p "Please enter the Network PASSWORD - " PASSWORD
			echo
			echo "Your network PASSWORD is \"$PASSWORD\", is that correct?"
			read -p "press Y to continue, any other key to re-enter the PASSWORD. " -n1 RESPONSE
			if [ "$RESPONSE" == "Y" ] || [ "$RESPONSE" == "y" ]; then
				echo
				break
			fi
			echo
		done
	fi

# add line "allow-hotplug wlan0" to file /etc/network/interfaces

	echo
	echo "modifying file /etc/network/interfaces to add an rtl8188cus wifi adapter wlan$ADAPTER_NUMBER "

	echo >> /etc/network/interfaces
	echo "allow-hotplug wlan$ADAPTER_NUMBER" >> /etc/network/interfaces

# add line "auto wlan0" to file /etc/network/interfaces

	echo >> /etc/network/interfaces
	echo "auto wlan$ADAPTER_NUMBER" >> /etc/network/interfaces

# add line "iface wlan0 inet dhcp" to file /etc/network/interfaces

	echo >> /etc/network/interfaces
	echo "iface wlan$ADAPTER_NUMBER inet dhcp" >> /etc/network/interfaces

# if unsecured or using WEP add line "wireless-essid $SSID" to file /etc/network/interfaces
# if using WPA/WPA add line "wpa-ssid \"$SSID\"" to file /etc/network/interfaces

	if [ "$SECURITY" != "A" ] && [ "$SECURITY" != "a" ]; then
		echo "wireless-essid $SSID" >> /etc/network/interfaces
	else
		echo "wpa-ssid \"$SSID\"" >> /etc/network/interfaces
	fi

# if using WEP add line "wireless-key $PASSWORD" to file /etc/network/interfaces

	if [ "$SECURITY" = "E" ] || [ "$SECURITY" = "e" ]; then
		echo "wireless-key $PASSWORD" >> /etc/network/interfaces
	fi

# if using WPA/WPA2 add line "wpa-psk \"$PASSWORD\"" to file /etc/network/interfaces

	if [ "$SECURITY" = "A" ] || [ "$SECURITY" = "a" ]; then
		echo "wpa-psk \"$PASSWORD\"" >> /etc/network/interfaces
	fi

# now update module blacklist.conf file to disable any old rtl8192cu driver file

	if [ ! -f /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko ]; then
		if [ ${COMPATIBLE_WIFI} == 0 ]; then
			if ! grep -q "blacklist rtl8192cu" /etc/modprobe.d/blacklist.conf 2> /dev/null ; then

				echo
				echo "modifying /etc/modprobe.d/blacklist.conf to blacklist the old rtl8192cu driver"

# add line "blacklist rtl8192cu" to file /etc/modprobe.d/blacklist.conf

				echo >> /etc/modprobe.d/blacklist.conf
				echo "blacklist rtl8192cu" >> /etc/modprobe.d/blacklist.conf
			fi
		fi
	fi
fi

rm network-list.txt > /dev/null 2>&1

# now update the module dependencies

echo
echo "updating system module dependencies - I know, I don't know what this is as well"
echo

depmod -a

# Terminate if incompatible wifi adapter is being used

if [ ${COMPATIBLE_WIFI} != 0 ]; then
	echo "The file /etc/network/interfaces is now setup to connect your wifi to the"
	echo "network you selected. As the wifi adapter you are using is NOT compatible with"
	echo "the RTL8188CUS driver the script will now terminate. If your wifi driver is"
	echo "included in the Linux image, after rebooting you may find your wifi will be"
	echo "working. If not you will need to determine the correct driver and install it."
	echo
	read -p "The script will now terminate and the Pi will reboot. Press any key to continue... " -n1 -s
	echo
	reboot
	exit
fi

# check if we are already using a wifi adapter when we are adding a new one

let ADAPTER_COUNTER=ADAPTER_NUMBER
if [ "$ADAPTER_INSTALL" == "A" ] || [ "$ADAPTER_INSTALL" == "a" ] ; then
	ADAPTER_COUNTER=0
	while [ ${ADAPTER_COUNTER} != ${ADAPTER_NUMBER} ]; do
		ifconfig wlan$ADAPTER_COUNTER > temp.tmp 2>/dev/null
		if grep -q "wlan$ADAPTER_COUNTER" temp.tmp ; then
			ifdown wlan$ADAPTER_COUNTER 2> /dev/null
			echo
			echo "Unplug the wifi adapter you are using and plug in the new adapter. It should"
			echo "start automatically. Just wait a while for the wifi adapter LED to start"
			read -p "flashing then press any key to continue... " -n1 -s
			echo
			echo
			break
		else
			let ADAPTER_COUNTER=ADAPTER_COUNTER+1
		fi
	done
fi

if [ ${ADAPTER_COUNTER} == ${ADAPTER_NUMBER} ]; then

	echo "The wifi is now configured and should start when you continue the script. If the"
	echo "LED is not flashing now it should start to when you continue. This may take a"
	echo "little time so be patient."
	echo
	read -p "Press any key to continue... " -n1 -s
	echo
	echo
fi

#
# check if the wifi has started.
#

ADAPTER_COUNTER=0

while true; do
	if grep -q -x "iface wlan$ADAPTER_COUNTER inet dhcp" /etc/network/interfaces ; then
		let ADAPTER_COUNTER=ADAPTER_COUNTER+1
	else
		if [ ${ADAPTER_COUNTER} == 1 ]; then
			echo "You now have $ADAPTER_COUNTER wifi adapter configured"
		else
			echo "You now have $ADAPTER_COUNTER wifi adapters configured"
		fi
	echo
	break
	fi
done

# Look for a wifi adapter to come ready

EXITSTATUS=1
until [ ${EXITSTATUS} == 0 ]; do
	ADAPTER_NUMBER=0
	while [ ${ADAPTER_NUMBER} != ${ADAPTER_COUNTER} ]; do
		ifconfig wlan$ADAPTER_NUMBER > temp.tmp 2>/dev/null
		if grep -q "wlan$ADAPTER_NUMBER" temp.tmp ; then
			EXITSTATUS=$?
			echo "The wifi adapter is installed. Waiting for the wifi adapter to connect."
			echo "This could take a minute or two so be patient."
			break
		else
			let ADAPTER_NUMBER=ADAPTER_NUMBER+1
		fi
	done
done

sleep 5

EXITSTATUS=1
COUNTER=0
until [ ${EXITSTATUS} == 0 ]; do
	ifconfig wlan$ADAPTER_NUMBER > temp.tmp 2>/dev/null
	grep -q "inet addr:" temp.tmp
	EXITSTATUS=$?
	if [ ${EXITSTATUS} != 0 ]; then
		if [ ${COUNTER} == 0 ]; then
			ifup --force wlan$ADAPTER_NUMBER  >/dev/null 2>&1
		fi
		if [ ${COUNTER} == 4 ]; then
			COUNTER=0
		fi
	let COUNTER=COUNTER+1
	sleep 10
	fi
rm temp.tmp
done

echo
echo "The wifi adapter wlan$ADAPTER_NUMBER is now connected."
echo
echo "Check the wlan$ADAPTER_NUMBER settings. This will show the network IP address assigned to the"
echo "wifi adapter and other parameters for the wifi adapter."
echo

ifconfig wlan$ADAPTER_NUMBER

uname -a > linux_version.txt
if grep -q "Linux raspberry-pi 3.2.21+\|Linux raspberry-pi 3.1.9-test-12-06+\|Linux XBian 3.1.9+" linux_version.txt ; then
	rm linux_version.txt
	echo
	echo "The basic wifi driver is now loaded and operating. The script will now terminate"
	echo
	echo "Have fun with your Raspberry Pi."
	echo
	exit
fi
rm linux_version.txt
echo
echo "The wifi driver is now loaded and operating. The script will now terminate unless"
echo "you want to continue and upgrade to update the packages list and update any out of"
echo "date software packages. The script will run apt-get update and apt-get upgrade. You"
echo "may need to rerun the script after the upgrade has finished to update the driver."
echo
echo "The script can also run rpi-update if you want to. This will load the latest version"
echo "of firmware and software for the Pi including the new rtl8188cus drivers which are"
echo "included in the latest kernel versions, from kernel version 3.2.27+ #108 and newer."
echo
echo "If you decide not to continue the script but then later update the firmware and"
echo "software the wifi may stop working. You can run the script again to upgrade the wifi"
echo "driver to a newer version compatible with the updated kernel version."
echo
echo "Do you want to continue and update the software packages list, kernel software"
echo "packages and upgrade the Pi's firmware and software or do you want to terminate"
echo "the script?"
echo
read -p "Press Y/y to continue, any other key to exit the script. " -n1 RESPONSE
echo
if [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "y" ]; then
	echo
	exit
fi

# now we have an internet connection the Pi can grab a few updates. first update the list
# of available packages to bring it upto date

# update sources list if debian6-19-04-2012 release

uname -a > linux_version.txt
if grep -q "Linux raspberrypi 3.1.9+ #90 Wed Apr 18 18:23:05 BST 2012 armv6l GNU/Linux" linux_version.txt ; then
	if grep -q "deb http://ftp.uk.debian.org/debian/ squeeze main non-free" /etc/apt/sources.list ; then

		echo
		echo "Updating the apt-get sources.list file. There is an issue with the sources.list"
		echo "file which may generate an error when using apt-get to install/update software."
		echo
		sleep 3

		echo 'deb http://ftp.uk.debian.org/debian/ squeeze main contrib non-free' > /etc/apt/sources.list
		echo >> /etc/apt/sources.list
		echo >> /etc/apt/sources.list
		echo '# Nokia Qt5 development' >> /etc/apt/sources.list
		echo 'deb http://archive.qmh-project.org/rpi/debian/ unstable main' >> /etc/apt/sources.list
		echo >> /etc/apt/sources.list
	fi
fi

echo
echo "Updating the Debian sofware packages list to bring it up to date."
echo

EXITSTATUS=-1
until [ ${EXITSTATUS} == 0 ]; do
	apt-get update
	EXITSTATUS=$?
	if [ ${EXITSTATUS} != 0 ]; then
		sleep 4
	fi
done

# save a copy of arm224_start.elf to check if apt-get upgrade updates the firmware

cp /boot/arm224_start.elf ./ > /dev/null 2>&1

echo
echo "Upgrading the loaded Debian software packages to the latest version."
echo

EXITSTATUS=-1
until [ ${EXITSTATUS} == 0 ]; do
	apt-get -y --force-yes upgrade
	EXITSTATUS=$?
	if [ ${EXITSTATUS} != 0 ]; then
		sleep 4
	fi
done

#check if apt-get upgrade has loaded new firmware - reboot if it has

if ! cmp /boot/arm224_start.elf ./arm224_start.elf ; then
	echo
	echo "apt-get upgrade has installed a new revision of Raspberry Pi firmware."
	echo "The Raspberry Pi must reboot and you must run the script again to complete"
	echo "the wifi installation and install the correct revision wifi driver. When"
	echo "running the script again, when it asks if you want to upgrade the current"
	echo "driver or add a new adapter, select the upgrade option, use the U/u key."
	echo
	read -p "Press any key to continue and reboot... " -n1 -s
	echo
	rm /boot/.firmware_revision > /dev/null 2>&1
	rm ./arm224_start.elf > /dev/null 2>&1
	reboot
	exit
fi

rm ./arm224_start.elf > /dev/null 2>&1

# If Raspbian Hexxeh get ntp and fake-hwclock packages to set the time before running rpi-update

if grep -q "#52 Tue May 8 23:49:32 BST 2012" linux_version.txt ; then
	EXITSTATUS=-1
	until [ ${EXITSTATUS} == 0 ]; do
		apt-get -y install ntp fake-hwclock
		EXITSTATUS=$?
		if [ ${EXITSTATUS} != 0 ]; then
			sleep 4
		fi
	done
fi

rm linux_version.txt

# now update dhcp. the current dhcp may only allow you to access the Pi using it's ip address.
# the update should allow accessing the Pi using it's host name.

EXITSTATUS=-1
until [ ${EXITSTATUS} == 0 ]; do
	apt-get install -y isc-dhcp-client
	EXITSTATUS=$?
	if [ ${EXITSTATUS} != 0 ]; then
		sleep 4
	fi
done

echo
echo "Do you want to continue and run rpi-update? This will update the kernel to the"
echo "latest version."
echo
read -p "Press Y/y to continue, any other key to exit the script. " -n1 RESPONSE
echo
if [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "y" ]; then
	echo
	exit
fi

if [ ! -f /usr/bin/rpi-update ]; then

	echo
	echo
	echo "rpi-update is not installed. Installing rpi-update - automatic rpi software and"
	echo "firmware updater."
	echo
	sleep 1

	EXITSTATUS=-1
	until [ ${EXITSTATUS} == 0 ]; do
		apt-get -y install git-core ca-certificates binutils
		EXITSTATUS=$?
		if [ ${EXITSTATUS} != 0 ]; then
			sleep 4
		fi
	done

	EXITSTATUS=-1
	until [ ${EXITSTATUS} == 0 ]; do
		wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update 2> /dev/null
		EXITSTATUS=$?
		if [ ${EXITSTATUS} != 0 ]; then
			sleep 4
		fi
	done
else
	echo
	echo "rpi-update is already installed."
fi

if [ ! -f /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko ]; then

	echo
	echo "Downloading the latest wifi driver. This will be installed after rpi-update"
	echo "has run."
	echo

	EXITSTATUS=-1
	until [ ${EXITSTATUS} == 0 ]; do
		wget http://dl.dropbox.com/u/80256631/8192cu-latest.tar.gz -O /boot/8192cu-latest.tar.gz 2> /dev/null
		EXITSTATUS=$?
		if [ ${EXITSTATUS} != 0 ]; then
			sleep 4
		fi
	done

# extract driver file from tar.gz

	tar -zxf /boot/8192cu-latest.tar.gz -C ./ > /dev/null 2>&1

fi

# As the driver is now included in the linux image running rpi-update should be fine

	echo
	echo "rpi-update will now run to update the Pi's firmware and software"
	echo
	sleep 1

#	rm /boot/.firmware_revision > /dev/null 2>&1

	rpi-update
	EXITSTATUS=$?

	echo
	echo

# running rpi-update from the command line will allow you to load any new updates when they become available
# so don't forget to run it occasionally especially if you think you may have a software issue.

# install the new driver software and update the module dependencies if not already included
# but only if the update does not inlude driver.

if [ ! -f /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtl8192cu/8192cu.ko ] ; then
	if [ ${EXITSTATUS} == 0 ]; then
		echo
		echo "Installing the new wifi driver. "
		echo

		if [ -e "/lib/modules/3.2.27+" ] && [ "$(uname -r)" != "3.2.27+" ] ; then
			install -p -m 644 8192cu.ko /lib/modules/3.2.27+/kernel/drivers/net/wireless/
			depmod -a 3.2.27+
			echo
			echo "rpi-update has installed a new revision of Linux - 3.2.27+."
			echo
			echo "The Raspberry Pi must reboot and you must run the script again to complete"
			echo "the wifi installation. When running the script again, when it asks if you"
			echo "want to upgrade the current driver or add a new adapter, select the upgrade"
			echo "option, use the U/u key."
			echo
		else
			install -p -m 644 8192cu.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/
			insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8192cu.ko
			depmod -a

			echo
			echo "Plug in the wifi adapter if not already plugged in and unplug the wired"
			echo "connection. The wifi should start when the RPi restarts."
			echo
			echo "It is possible the RPi may not reboot correctly but get stuck trying to reboot."
			echo "If it doesn't reboot correctly turn of the power to the RPi, wait for all LEDS "
			echo "to turn off, wait a few seconds and then turn the power back on. It should boot"
			echo "up and the wireless should connect. I have never seen it fail to boot after "
			echo "switching the power off and then on again after failing to reboot correctly "
			echo "while testing this script."
			echo
		fi
	else

		echo
		echo "rpi-update returned an error"
		echo
		echo "As the latest version of the driver expects rpi-update to have run the driver"
		echo "has not been installed - the script will now terminate."
		echo
		echo "I would suggest running the script again."
		echo
	fi

else

# the new driver is installed so remove the old one and delete /lib/modules/3.1.9+ and all stuff in those directories
# as apt-get update, #114, fails to do this. the new module should then come up OK

	if [ "$(uname -r)" != "3.2.27+" ] ; then

# remove the faulty rtlwifi/rtl8192cu driver and the old 3.1.9+ and 3.2.27+ drivers if they exist

		rm /lib/modules/3.2.27+/kernel/drivers/net/wireless/8192cu.ko > /dev/null 2>&1
		rm /lib/modules/3.1.9+/kernel/drivers/net/wireless/8192cu.ko > /dev/null 2>&1
		rm -r /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtlwifi > /dev/null 2>&1
		depmod -a

# update files /etc/modules and /etc/modprobe.d/blacklist.conf

		sed -i '/blacklist rtl8192cu/d' /etc/modprobe.d/blacklist.conf
		sed -i '/8192cu/d' /etc/modules

		echo
		echo "rpi-update has installed a new revision of Linux - 3.2.27+."
		echo
		echo "The Raspberry Pi must reboot and you must run the script again to complete"
		echo "the wifi installation. When running the script again, when it asks if you"
		echo "want to upgrade the current driver or add a new adapter, select the upgrade"
		echo "option, use the U/u key."
		echo

	else
		if [ -f /lib/modules/3.2.27+/kernel/drivers/net/wireless/8192cu.ko ] ; then

# remove the old 3.1.9+ and 3.2.27+ drivers if they exist

			rmmod 8192cu > /dev/null 2>&1
			rm /lib/modules/3.2.27+/kernel/drivers/net/wireless/8192cu.ko > /dev/null 2>&1
			rm -r /lib/modules/3.1.9+ > /dev/null 2>&1
			rm -r /lib/modules.bak/3.1.9+ > /dev/null 2>&1
			rm -r /lib/modules.bak/3.1.9-cutdown+ > /dev/null 2>&1

# remove the faulty rtlwifi/rtl8192cu driver

			rm -r /lib/modules/3.2.27+/kernel/drivers/net/wireless/rtlwifi > /dev/null 2>&1

# update files /etc/modules and /etc/modprobe.d/blacklist.conf

			sed -i '/8192cu/d' /etc/modules
			sed -i '/blacklist rtl8192cu/d' /etc/modprobe.d/blacklist.conf
		fi

# register, install and bring up wifi with new driver

		depmod -a
		echo
		echo "Reboot the Pi to ensure the driver is installed."
		echo
		echo "The RTL8188CUS driver is now included in the kernel image so you should no"
		echo "longer have problems with the driver breaking when you do an update and so you"
		echo "will probably not need to use the script again to keep this image maintained"
		echo "unless you want to add a new wifi adapter."
		echo
		echo "Thank you for using the script. The kind remarks from so many of you has made"
		echo "all the effort in maintaining it worth while."
		echo
		echo "Thank you, MrEngman."
		echo
		echo "Have fun with your Raspberry Pi."
		echo
	fi
fi

# time to finish!

echo
read -p "The Pi will now reboot. Press any key to continue... " -n1 -s
echo
rm 8192cu.ko > /dev/null 2>&1
reboot
exit
