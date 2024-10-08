#!/bin/bash

##################################### install softwares in ubuntu 18.04 #########################################
# 1, java jdk 13.02
# 2, maven 3.9.9
# 3, docker 
# 4, git 
# 5, jenkins (include jdk-11) 
# 6, vim 
#################################################################################################################

sudo apt update

################################################################################################################################## install java 13
# url https://www.digitalocean.com/community/tutorials/install-maven-linux-ubuntu
# check in terminal: grep -q "jdk" /etc/profile; [ $? -eq 0 ] && echo "yes" || echo "no"
if ! grep -q 'jdk' /etc/profile; then
  echo "################################### installing java 13 #################################################################"
  sudo wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz
  sudo tar -xvf openjdk-13.0.1_linux-x64_bin.tar.gz
  sudo mv jdk-13.0.1 /opt/
  rm openjdk-13.0.1_linux-x64_bin.tar.gz
fi

################################################################################################################################## install maven
#grep -q "maven" /etc/profile; [ $? -eq 0 ] && echo "yes" || echo "no"
if ! grep -q 'maven' /etc/profile; then
  echo "################################### installing maven #################################################################"
  sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
  sudo tar -xvf apache-maven-3.9.9-bin.tar.gz
  sudo mv apache-maven-3.9.9 /opt/
  rm apache-maven-3.9.9-bin.tar.gz
fi

################################################################################################################################## setting environment for java and maven
#url https://stackoverflow.com/questions/33860560/how-to-set-java-environment-variables-using-shell-script
# https://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-a-text-file
# https://askubuntu.com/questions/175514/how-to-set-java-home-for-java
#sudo echo "export JAVA_HOME=/opt/jdk-13.0.1" >>~/.bashrc
#sudo echo "export M2_HOME=/opt/apache-maven-3.9.9" >>~/.bashrc
#sudo echo "export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >>~/.bashrc

if ! ( grep -q 'jdk' /etc/environment && grep -q 'maven' /etc/environment ); then
	echo "################################### setting java and maven path in environment file #################################################################"
	# https://stackoverflow.com/questions/13702425/source-command-not-found-in-sh-shell
	
	if ! grep -q 'jdk' /etc/environment; then
		sudo echo 'export JAVA_HOME=/opt/jdk-13.0.1' | sudo tee -a /etc/environment > /dev/null
		echo $JAVA_HOME
		
		sudo echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/environment > /dev/null
		source /etc/environment
	fi
	
	if ! grep -q 'maven' /etc/environment; then
		sudo echo 'export M2_HOME=/opt/apache-maven-3.9.9' | sudo tee -a /etc/environment > /dev/null
		echo $M2_HOME
		
		sudo echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/environment > /dev/null
		source /etc/environment
	fi
	
	sudo -s source /etc/environment
fi


if ! ( grep -q 'jdk' /etc/profile && grep -q 'maven' /etc/profile ); then
	# if environment file is not work: https://askubuntu.com/questions/747745/maven-environment-variable-not-working-on-other-terminal
	echo "################################### setting java and maven path in profile file #################################################################"
	# https://stackoverflow.com/questions/13702425/source-command-not-found-in-sh-shell
	
	if ! grep -q  'jdk' /etc/profile; then
		sudo echo 'export JAVA_HOME=/opt/jdk-13.0.1' | sudo tee -a /etc/profile > /dev/null
		echo $JAVA_HOME
		
		sudo echo "export PATH=$JAVA_HOME/bin:$PATH" | sudo tee -a /etc/profile > /dev/null
		source /etc/profile
	fi	
	
	if ! grep -q  'maven' /etc/profile; then
		sudo echo "export M2_HOME=/opt/apache-maven-3.9.9" | sudo tee -a /etc/profile > /dev/null
		echo $M2_HOME
		
		sudo echo "export PATH=$M2_HOME/bin:$PATH" | sudo tee -a /etc/profile > /dev/null
		source /etc/profile
	fi

	sudo -s source /etc/profile
fi

echo '######################## java version #################################################'
java -version

echo '######################## mvn version #################################################'
mvn --version


# url https://docs.docker.com/engine/install/ubuntu/
################################################################################################################################## install docker
if type docker > /dev/null 2>&1 && which docker > /dev/null 2>&1 ;then
	echo "################################# docker was installed ##############################"
    docker --version
else 
	echo "################################### installing docker #################################################################"
	sudo apt-get remove docker docker-engine docker.io containerd runc

	sudo apt-get update
	sudo apt-get install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
		
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
	
	################################ run docker without sudo ############################################
	# https://phoenixnap.com/kb/docker-permission-denied
	sudo groupadd -f docker
	sudo usermod -aG docker $USER
	#sudo newgrp docker
	#groups
fi
sudo docker run hello-world

# https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-20-04
################################################################################################################################## install git
if type git > /dev/null 2>&1 && which git > /dev/null 2>&1 ;then
  echo "################################# git was installed ##############################"
  git --version
else
  echo "################################### installing git #################################################################"
  sudo apt update
  sudo apt install git
fi
git config --global user.email "phamvanlinh20111993@gmail.com"
git config --global user.name "phamvanlinh20111993"

#update init-system-helpers for ubutu 18, check: https://github.com/odoo/odoo/issues/60574
# error with jenkins 9/12/2024:
# re-depends on init-system-helpers (>= 1.54~)
# init-system-helpers is installed, but is version 1.51.
# 
# or http://ftp.us.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb
# or http://ftp.de.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb

# Check if init-system-helpers is installed

required_version="1.60"
if dpkg -l | grep -q init-system-helpers; then
    echo "init-system-helpers is installed."
	installed_version=$(dpkg -l | grep init-system-helpers | awk '{print $3}')
    echo "Version: $installed_version"
	# Compare versions
    if dpkg --compare-versions "$installed_version" lt "$required_version"; then
        echo "Version is less than $required_version. Installing the latest version..."
		wget http://ftp.kr.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb
		sudo dpkg -i init-system-helpers_1.60_all.deb
    else
        echo "Version is up to date."
    fi
else
    echo "init-system-helpers is not installed."
	wget http://ftp.kr.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb
	sudo dpkg -i init-system-helpers_1.60_all.deb
fi


################################################################################################################################## install jenkins
# https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
# https://www.jenkins.io/doc/book/system-administration/systemd-services/
# https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-18-04

if test -d /lib/systemd/system/ && test -e /lib/systemd/system/jenkins.service && grep -q 'jenkins' /lib/systemd/system/jenkins.service ;then
	echo "################################# jenkins was installed ##############################"
	sudo systemctl status jenkins
else
	echo "################################### installing jenkins #################################################################"
	# this is command for jenkins old version before 04/2023
	#curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
	#  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
	#echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
	#  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
	#  /etc/apt/sources.list.d/jenkins.list > /dev/null
	
	sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
	  https://pkg.jenkins.io/debian/jenkins.io-2023.key
	  
	echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
	  https://pkg.jenkins.io/debian binary/ | sudo tee \
	  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
	sudo apt-get update
	sudo apt-get install jenkins
	
	echo "########### update java version to 17 ############"
	#install java 17 to enable jenkins
	sudo apt update
    sudo apt install fontconfig openjdk-17-jre #openjdk-17-jdk
	java -version
	#JAVA_LOCATION =$(readlink -f $(which java))
	JAVA_HOME_LOCATION=$(update-alternatives --list java)
	echo "JAVA_HOME_LOCATION before update: $JAVA_HOME_LOCATION"
	splitStrPath=(${JAVA_HOME_LOCATION//\// })
	length=${#splitStrPath[@]}
	#init empty
	JAVA_HOME_LOCATION=
	for (( j=0; j < $length; j++ ));
	do
	   if [[ "${splitStrPath[j]}" == *"bin"* ]] 
       then
            break
       fi
	   JAVA_HOME_LOCATION+=/${splitStrPath[j]}
	done
	JAVA_HOME_LOCATION+=/
	echo "JAVA_HOME_LOCATION after update: $JAVA_HOME_LOCATION"
	 
	 #https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
	 #https://unix.stackexchange.com/questions/78625/using-sed-to-find-and-replace-complex-string-preferrably-with-regex
	 #https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
	 #https://askubuntu.com/questions/76808/how-do-i-use-variables-in-a-sed-command 
	 sudo sed -i -E "s|#?Environment=\"JAVA_HOME=.+|Environment=\"JAVA_HOME=$JAVA_HOME_LOCATION\"|g" /lib/systemd/system/jenkins.service
	 
	 unset splitStrPath
	 unset JAVA_HOME_LOCATION
	 unset length
	 
	 sudo systemctl daemon-reload
	 #
	 sudo systemctl enable jenkins
	 #
	 sudo systemctl start jenkins
	 #
	 #sudo systemctl status jenkins
	 
	 # config jenkins user without promt any password
	 if [ -e /root/sudoers.bak ]
	 then
		echo 'already backup sudoers file'
	 else
		sudo cp /etc/sudoers /root/sudoers.bak
		echo 'create backup sudoers file with name sudoers.bak'
	 fi
	 # https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/
	 File=/etc/sudoers
	 if ! sudo grep -q "jenkins ALL=(ALL)" "$File" ;then
	    sudo echo "#config allow for jenkins user" | sudo tee -a /etc/sudoers > /dev/null
		sudo echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
	 fi
	 unset File
fi

# install vim
if command -v vim &>/dev/null; then
    echo "#################################  Vim have already installed. #################################  "
else
    echo "#################################  Vim is not installed. Installing Vim...################################# "
    sudo apt update
    sudo apt install vim
fi


# need to restart system and login again to apply all setting to current system.
echo "################################### sleeling 40, preparing for reboot #################################################################"
sleep 15
sudo reboot;


