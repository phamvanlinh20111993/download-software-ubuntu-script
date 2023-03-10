#!/bin/bash

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install openssh-client


############
SSH_TYPE=$(dpkg --list | grep ssh)
if [[ "$SSH_TYPE" == *"openssh-client"* ]]; then
	echo "################################# ssh client was installed ##############################"
    ssh -V
else 	
    echo "################################### installing ssh-client #################################################################"
	sudo apt-get install openssh-client
	sudo systemctl enable ssh --now
	sudo systemctl start ssh
	
	sudo ufw allow ssh
	sudo ufw enable
	sudo ufw status
fi
unset SSH_TYPE


if [ ! -d $HOME/.ssh ]; then
  echo "$HOME/.ssh does not exist."
  mkdir $HOME/.ssh
fi

if [ ! -e $HOME/.ssh/config ]; then
	 echo "$HOME/.ssh/config does not exist."
	 sudo touch $HOME/.ssh/config
	 sudo chown -R $USER:$USER $HOME/.ssh/config 
	 sudo chmod 600 $HOME/.ssh/config
fi

if [ ! -e $HOME/.ssh/known_hosts ]; then
	 echo "$HOME/.ssh/known_hosts does not exist."
	 sudo touch $HOME/.ssh/known_hosts
	 sudo chown -v $USER $HOME/.ssh/known_hosts
fi

REMOTE_HOST_NAME=34.126.75.224
REMOTE_USER=vienlv

FOLDER_STORE_SSH_KEY="$HOME/.ssh/remote-host-key"
FILE_NAME="gcp_remote_host_key"
PATH_KEY=$FOLDER_STORE_SSH_KEY/$FILE_NAME
if [ ! -d $FOLDER_STORE_SSH_KEY ]; then
  echo "$FOLDER_STORE_SSH_KEY does not exist."
  mkdir $FOLDER_STORE_SSH_KEY
  sudo ssh-keygen -f $PATH_KEY  -t ed25519 -b 4096 -N ''
fi

if ! sudo grep -q "$REMOTE_HOST_NAME" $HOME/.ssh/config; then 
	sudo echo "# ####zenkins server###" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "# ssh vienlv@$REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "Host $REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     HostName $REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     User $REMOTE_USER" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     PreferredAuthentications publickey" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     IdentitiesOnly yes" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     IdentityFile $PATH_KEY" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     UserKnownHostsFile $HOME/.ssh/known_hosts" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     Port 22" | sudo tee -a $HOME/.ssh/config > /dev/null
	eval $(ssh-agent -s)
	sudo ssh-keyscan -H $REMOTE_HOST_NAME >> $HOME/.ssh/known_hosts

fi

unset MY_NAME
unset REMOTE_HOST_NAME
unset REMOTE_USER
unset FOLDER_STORE_SSH_KEY
unset FILE_NAME
unset PATH_KEY