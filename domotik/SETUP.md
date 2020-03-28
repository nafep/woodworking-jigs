# Setting-up Domotik





## Raspberry



### Install & configure Raspbian


* Download the Raspbian image from http://downloads.raspberrypi.org/raspbian_latest


* Write the image to the SD card with (following the on-line guide http://www.raspberrypi.org/ documentation/installation/installing-images/README.md)


* Create a new user and give that account sudo privileges by adding it to the "sudo" group

		~$ sudo adduser *LOGIN*
		~$ sudo adduser *LOGIN* sudo
		

* Logout and login with the newly created power user


* Update/upgrade the system:

		~$ sudo apt-get update 
		~$ sudo apt-get upgrade


* Remove default **pi** account from sudoers group

		~$ sudo deluser pi sudo
		

* Set the hostname by updating following files:

		/etc/hostname
		/etc/hosts
		

* Install Bonjour Support (mDNS) support:

		~$ sudo apt-get install avahi-daemon


* Install "unattended-upgrades" to make the rpi automatically update/upgrade

		~$ sudo apt-get install unattended-upgrades
		

* Optionally install "samba" server, following the instructions found at https://www.raspberrypi.org/documentation/remote-access/samba.md
Make sure to add the user(s) as samba user


		~$ sudo smbpasswd -a <username>
		
	and also to modify the config (/etc/samba/smb.conf) file to make the "homes" share writeable (set "read only = **no**")






		
### MQTT


#### On the Raspberry Pi


* Install Mosquitto

		~$ sudo apt install -y mosquitto mosquitto-clients
		

* To make Mosquitto auto start on boot up enter

		~$ sudo systemctl enable mosquitto.service
		

* 