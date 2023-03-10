#!/bin/bash

sudo apt-get update
sudo apt-get upgrade

##########################
SSH_TYPE=$(dpkg --list | grep ssh)
if [[ "$SSH_TYPE" == *"openssh-server"* ]]; then
	echo "################################# ssh server was installed ##############################"
    ssh -V
else 	
    echo "################################### installing ssh-server #################################################################"
	sudo apt-get install openssh-server
	# https://www.cyberciti.biz/faq/ubuntu-linux-install-openssh-server/
	sudo systemctl enable ssh --now
	sudo systemctl start ssh
	
	sudo ufw allow ssh
	sudo ufw enable
	sudo ufw status
fi
unset SSH_TYPE

############################

MY_NAME=$(whoami)
sudo touch storageName.txt
sudo echo "$MY_NAME" | sudo tee -a storageName.txt > /dev/null
unset MY_NAME

if [ -e /root/sudoers.bak ]; then
    echo "file is existed"
else
	sudo su
	cp /etc/sudoers /root/sudoers.bak
    
	userName=`cat storageName.txt`
	sudo rm storageName.txt
	# https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/
	File=/etc/sudoers
	if ! grep -q "$userName ALL=(ALL)" "$File" ;then
	  # sudo echo $MY_NAME ALL = NOPASSWD: /bin/systemctl restart httpd.service, /bin/kill >> /etc/sudoers
	  # careful with that command
	  sudo echo "$userName ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
	fi
	unset File
	unset userName
	exit;
fi


if [ ! -d $HOME/.ssh ]; then
  echo "$HOME/.ssh does not exist."
  mkdir $HOME/.ssh
fi

if [ ! -e $HOME/.ssh/config ]; then
	 echo "$HOME/.ssh/config does not exist."
	 sudo touch $HOME/.ssh/config
	 sudo chown -R $USER:$USER /home/vienlv/.ssh/config 
	 sudo chmod 600 $HOME/.ssh/config
fi

if [ ! -e $HOME/.ssh/known_hosts ]; then
	 echo "$HOME/.ssh/known_hosts does not exist."
	 sudo touch $HOME/.ssh/known_hosts
	 sudo chown -v $USER $HOME/.ssh/known_hosts
fi

##############################
if [ -e $HOME/.ssh/authorized_keys ]; then
	echo "authorized_keys is existed";
else
	#sudo cat id_rsa.pub>>/home/$USER/.ssh/authorized_keys
	touch authorized_keys
	chmod 700 $HOME/.ssh && chmod 600 $HOME/.ssh/authorized_keys
	chown -R $USER:$USER $HOME/.ssh
fi

sudo sed -i -E "s|#?PasswordAuthentication no.+|PasswordAuthentication no|g" /etc/ssh/sshd_config
sudo sed -i -E "s|#?PubkeyAuthentication yes.+|PubkeyAuthentication yes|g" /etc/ssh/sshd_config
sudo systemctl restart sshd