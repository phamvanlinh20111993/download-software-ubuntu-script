#!/usr/bin/env bash

##################################### install softwares in ubuntu 18.04 #########################################
# 1, java jdk 13.02
# 2, maven 3.6.3
# 3, docker 
# 4, git 
# 5, node 16.19.0
# 6, npm 
# 7, nginx 
# 8, microk8s 
# 9, tomcat 10.0.11
# 10, mysql
# 11, postgres  
#################################################################################################################



sudo apt update

################################################################################################################################## install java 13
# url https://www.digitalocean.com/community/tutorials/install-maven-linux-ubuntu
# check in terminal: grep -q "jdk" /etc/profile; [ $? -eq 0 ] && echo "yes" || echo "no"
if ! grep -q  'jdk' /etc/profile; then
  echo "################################### installing java 13 #################################################################"
  sudo wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz
  tar -xvf openjdk-13.0.1_linux-x64_bin.tar.gz
  sudo mv jdk-13.0.1 /opt/
fi

################################################################################################################################## install maven
#grep -q "maven" /etc/profile; [ $? -eq 0 ] && echo "yes" || echo "no"
if ! grep -q  'maven' /etc/profile; then
  echo "################################### installing maven #################################################################"
  sudo wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
  tar -xvf apache-maven-3.6.3-bin.tar.gz
  sudo mv apache-maven-3.6.3 /opt/
fi

################################################################################################################################## setting enviroment for java and maven
#url https://stackoverflow.com/questions/33860560/how-to-set-java-environment-variables-using-shell-script
# https://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-a-text-file
# https://askubuntu.com/questions/175514/how-to-set-java-home-for-java
#sudo echo "export JAVA_HOME=/opt/jdk-13.0.1" >>~/.bashrc
#sudo echo "export M2_HOME=/opt/apache-maven-3.6.3" >>~/.bashrc
#sudo echo "export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >>~/.bashrc

if ! (grep -q  'jdk' /etc/profile || grep -q  'maven' /etc/profile ); then
	echo "################################### setting java and maven path in enviroment file #################################################################"
	# https://stackoverflow.com/questions/13702425/source-command-not-found-in-sh-shell
	sudo echo 'export JAVA_HOME=/opt/jdk-13.0.1' | sudo tee -a /etc/enviroment > /dev/null
	source /etc/environment
	echo $JAVA_HOME
	sudo echo 'export M2_HOME=/opt/apache-maven-3.6.3' | sudo tee -a /etc/enviroment > /dev/null
	source /etc/environment
	echo $M2_HOME
	sudo echo 'export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH' | sudo tee -a /etc/enviroment > /dev/null
	source /etc/environment
	sudo -s source /etc/environment
fi


if ! (grep -q  'jdk' /etc/profile || grep -q  'maven' /etc/profile ); then
	# if enviroment file is not work: https://askubuntu.com/questions/747745/maven-environment-variable-not-working-on-other-terminal
	echo "################################### setting java and maven path in profile file #################################################################"
	# https://stackoverflow.com/questions/13702425/source-command-not-found-in-sh-shell
	sudo echo 'export JAVA_HOME=/opt/jdk-13.0.1' | sudo tee -a /etc/profile > /dev/null
	echo $JAVA_HOME
	source /etc/profile

	sudo echo "export M2_HOME=/opt/apache-maven-3.6.3" | sudo tee -a /etc/profile > /dev/null
	echo $M2_HOME
	source /etc/profile

	sudo echo "export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" | sudo tee -a /etc/profile > /dev/null
	source /etc/profile 
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
    git --version
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


################################################################################################################################## install nodejs
# https://www.stewright.me/2022/01/tutorial-install-nodejs-16-on-ubuntu-20-04/
#sudo apt-get remove nodejs
#sudo apt-get remove npm
if type node > /dev/null 2>&1 && which node > /dev/null 2>&1 ;then
    echo "node is installed, skipping..."
    node -v
else
    echo "################################### installing nodejs #################################################################"
	curl -s https://deb.nodesource.com/setup_16.x | sudo bash
    sudo apt install nodejs -y
	node -v
fi


################################################################################################################################## install npm
if type npm > /dev/null 2>&1 && which npm > /dev/null 2>&1 ;then
    echo "npm is installed, skipping..."
	npm -v
else
	echo "################################### installing nodejs #################################################################"
	sudo apt install npm
	npm -v
fi

if ! which nginx > /dev/null 2>&1; then
    echo "Nginx not installed"
	sudo apt update
	sudo apt install nginx
	service nginx status
else
	echo "nginx is installed, skipping..."
	service nginx status
fi


################################################################################################################################## install apache tomcat

# ref: https://www.hostinger.com/tutorials/how-to-install-tomcat-on-ubuntu/
#      https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-10-on-ubuntu-20-04
#      https://phoenixnap.com/kb/install-tomcat-ubuntu
# check file is in system: https://stackoverflow.com/questions/5905054/how-can-i-recursively-find-all-files-in-current-and-subfolders-based-on-wildcard
if ! sudo grep -q  'Apache Tomcat Web Application Container' /etc/systemd/system/tomcat.service; then
	echo "####################################################################### install apache tomcat"
	sudo apt update
	sudo groupadd tomcat
	sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
	cd /tmp
	curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.63/bin/apache-tomcat-9.0.63.tar.gz
	#sudo apt install wget
	TOMCAT_VER="10.1.1"
	sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz
	#sudo tar xzvf /tmp/apache-tomcat-9.0.*tar.gz -C /opt/tomcat --strip-components=1
	sudo tar xzvf apache-tomcat-10*.tar.gz -C /opt/tomcat --strip-components=1

	sudo mkdir /opt/tomcat
	cd /opt/tomcat
	sudo chgrp -R tomcat /opt/tomcat
	sudo chmod -R g+r conf
	sudo chmod g+x conf
	sudo chown -R tomcat webapps/ work/ temp/ logs/
	sudo touch /etc/systemd/system/tomcat.service

	sudo echo '[Unit]' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Description=Apache Tomcat Web Application Container' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'After=network.target' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '[Service]' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Type=forking' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="JAVA_HOME=/opt/jdk-13.0.1"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="CATALINA_Home=/opt/tomcat"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="CATALINA_BASE=/opt/tomcat' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	#sudo echo 'Environment="JAVA_OPTS.awt.headless=true -Djava.security.egd=file:/dev/v/urandom"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'ExecStart=/opt/tomcat/bin/startup.sh' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'ExecStop=/opt/tomcat/bin/shutdown.sh' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'User=tomcat' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Group=tomcat' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'UMask=0007' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'RestartSec=20' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'Restart=always' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '[Install]' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo '' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
	sudo echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null

	#cd /opt/tomcat/bin
	#sudo ./startup.sh run

	sudo systemctl daemon-reload

	sudo systemctl start tomcat
	#sudo systemctl status tomcat

	#sudo ufw allow 8080/tcp
	sudo ufw allow 8080
else 
	echo "apache tomcat is installed, skipping..."
	sudo systemctl start tomcat
	#sudo systemctl status tomcat
fi


################################################################################################################################## install microk8s
if [ -x "$(command -v microk8s)" ]; then
	echo "################################### installing microk8s #################################################################"
	sudo snap install microk8s --classic
	sudo ufw allow in on cni0 && sudo ufw allow out on cni0
	sudo ufw default allow routed

	sudo usermod -a -G microk8s $USER
	sudo chown -f -R $USER ~/.kube

	token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
	sudo microk8s kubectl -n kube-system describe secret $token

	sudo microk8s enable dashboard dns registry storage ingress
fi


################################################################################################################################## install mysql
# https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04
# https://phoenixnap.com/kb/install-mysql-ubuntu-20-04
# https://hevodata.com/learn/installing-mysql-on-ubuntu-20-04/

#type mysql >/dev/null 2>&1 && echo "MySQL present." || echo "MySQL not present."
type mysql >/dev/null 2>&1 && {
	echo "mysql is installed, skipping..."
	mysql -V
	mysql --version
} || { 
	echo "################################### installing mysql #################################################################"
	sudo apt update
	sudo apt upgrade
	sudo apt install mysql-server
	sudo systemctl start mysql.service
	#sudo mysql 
	#ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
	#exit;
	#mysql -u root -p
	#ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;
	# sudo mysql_secure_installation
	mysql -V
	mysql --version
}

#####################################################################################################################################################################
# https://www.cyberciti.biz/faq/how-to-change-directory-in-linux-terminal/
# https://superuser.com/questions/1004254/how-can-i-change-the-directory-that-ssh-keygen-outputs-to
echo "################################### setting ssh key git #################################################################"
cd ~
cd ~/.ssh
mkdir linhpv-ssh-k8s-example
#ssh-keygen -o -t rsa -b 4096 -C "linhpv@vmodev.com" -f $HOME/.ssh/linhpv-ssh-k8s-example/id_rsa
#ssh-add ~/.ssh/linhpv-ssh-k8s-example/id_rsa
#cat ~/.ssh/linhpv-ssh-k8s-example/id_rsa.pub
#eval "$(ssh-agent -s)"

#echo # # github.com >> ~/.ssh/config
#echo Host github.com >> ~/.ssh/config
#echo  HostName github.com >> ~/.ssh/config
#echo  PreferredAuthentications publickey >> ~/.ssh/config
#echo  PasswordAuthentication no >> ~/.ssh/config
#echo  UserKnownHostsFile ~/.ssh/known_hosts >> ~/.ssh/config
#echo  IdentityFile ~/linhpv-ssh-k8s-example/id_rsa >> ~/.ssh/config
#echo  User github.com >> ~/.ssh/config
#echo  IdentitiesOnly yes >> ~/.ssh/config

cd ~/home/$USER
mkdir micro-service-linhpv-vmo
#git clone git@github.com:phamvanlinh20111993/k8s-example.git

#cd ~/home/$USER/micro-service-linhpv-vmo/k8s-example
# run script build k8s
#chmod +x ./microk8s_kubernetes_build_script.sh
#./microk8s_kubernetes_build_script.sh

# need to restart system and login again to apply all setting to current system.
sudo reboot;
exit;