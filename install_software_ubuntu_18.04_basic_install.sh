#!/usr/bin/env bash

##################################### install softwares in ubuntu 18.04 #########################################
# 1, java jdk 13.02
# 2, maven 3.6.3
# 3, docker 
# 4, git 
# 5, microk8s 
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



################################################################################################################################## install microk8s
#if [ -x "$(command -v microk8s)" ]; then
if type microk8s > /dev/null 2>&1 && which microk8s > /dev/null 2>&1 ;then
	echo "microk8s is installed, skipping..."
	sudo microk8s version
	sudo microk8s about
else 
	echo "################################### installing microk8s #################################################################"
	sudo snap install microk8s --classic
	
	sudo usermod -a -G microk8s $USER
	sudo chown -f -R $USER ~/.kube
	
	sudo ufw allow in on cni0 && sudo ufw allow out on cni0
	
	sudo ufw default allow routed
	
	sudo microk8s enable dashboard dns registry storage ingress metallb
	sudo microk8s kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml

	token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
	sudo microk8s kubectl -n kube-system describe secret $token

	# sudo microk8s enable metallb
fi

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
#cd /
#cd ~/home/$USER
cd ~
mkdir micro-service-linhpv-vmo
#git clone git@github.com:phamvanlinh20111993/k8s-example.git

#cd ~/home/$USER/micro-service-linhpv-vmo/k8s-example
# run script build k8s
#chmod +x ./microk8s_kubernetes_build_script.sh
#./microk8s_kubernetes_build_script.sh

# need to restart system and login again to apply all setting to current system.
sudo reboot;
#exit;
