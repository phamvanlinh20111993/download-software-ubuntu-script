#!/usr/bin/env bash

# ref: https://www.hostinger.com/tutorials/how-to-install-tomcat-on-ubuntu/
#      https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-10-on-ubuntu-20-04
#      https://phoenixnap.com/kb/install-tomcat-ubuntu
# check file is in system: https://stackoverflow.com/questions/5905054/how-can-i-recursively-find-all-files-in-current-and-subfolders-based-on-wildcard
if ! sudo grep -q  'Apache Tomcat Web Application Container' /etc/systemd/system/tomcat.service; then
	echo "####################################################################### install apache tomcat"
	sudo apt update
	sudo groupadd tomcat
	sudo mkdir /opt/tomcat
	sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
	cd /tmp
	curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.63/bin/apache-tomcat-9.0.63.tar.gz
	#sudo apt install wget
	TOMCAT_VER="10.1.1"
	sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz
	#sudo tar xzvf /tmp/apache-tomcat-9.0.*tar.gz -C /opt/tomcat --strip-components=1
	sudo tar xzvf apache-tomcat-10*.tar.gz -C /opt/tomcat --strip-components=1

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
	sudo echo 'Environment="CATALINA_BASE=/opt/tomcat"' | sudo tee -a /etc/systemd/system/tomcat.service > /dev/null
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
	sudo mysql_secure_installation
	mysql -V
	mysql --version
}


# https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-20-04
################################################################################################################################## install git
if type docker > /dev/null 2>&1 && which docker > /dev/null 2>&1 ;then
  echo "################################# git was install ##############################"
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

if type microk8s > /dev/null 2>&1 && which microk8s > /dev/null 2>&1 ;then
	echo "microk8s is installed, skipping..."
	microk8s version
else 
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