#!/usr/bin/env sh

##################################### ubuntu 18.04 ########################################

sudo apt update

##### install java 13
# url https://www.digitalocean.com/community/tutorials/install-maven-linux-ubuntu
sudo wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz
tar -xvf openjdk-13.0.1_linux-x64_bin.tar.gz
mv jdk-13.0.1 /opt/

##### install maven
sudo wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 /opt/

#url https://stackoverflow.com/questions/33860560/how-to-set-java-environment-variables-using-shell-script
# https://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-a-text-file
# https://askubuntu.com/questions/175514/how-to-set-java-home-for-java
#sudo echo "export JAVA_HOME=/opt/jdk-13.0.1" >>~/.bashrc
#sudo echo "export M2_HOME=/opt/apache-maven-3.6.3" >>~/.bashrc
#sudo echo "export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >>~/.bashrc

sudo echo "export JAVA_HOME=/opt/jdk-13.0.1" >>~/etc/enviroment
sudo echo "export M2_HOME=/opt/apache-maven-3.6.3" >>~/etc/enviroment
sudo echo "export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >>~/etc/enviroment
sudo source ~/etc/environment

echo $JAVA_HOME
echo $M2_HOME
sudo java -version
sudo mvn --version

# url https://docs.docker.com/engine/install/ubuntu/
##### install docker
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
sudo docker run hello-world


# https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-20-04
##### install git
sudo apt update
sudo apt install git
git --version
# https://www.cyberciti.biz/faq/how-to-change-directory-in-linux-terminal/
# https://superuser.com/questions/1004254/how-can-i-change-the-directory-that-ssh-keygen-outputs-to
cd ~
cd ~/.ssh
mkdir linhpv-ssh-k8s-example
ssh-keygen -o -t rsa -b 4096 -C "linhpv@vmodev.com" -f $HOME/.ssh/linhpv-ssh-k8s-example/id_rsa
ssh-add ~/.ssh/linhpv-ssh-k8s-example/id_rsa
cat ~/.ssh/linhpv-ssh-k8s-example/id_rsa.pub
eval "$(ssh-agent -s)"

echo # # github.com >> ~/.ssh/config
echo Host github.com >> ~/.ssh/config
echo  HostName github.com >> ~/.ssh/config
echo  PreferredAuthentications publickey >> ~/.ssh/config
echo  PasswordAuthentication no >> ~/.ssh/config
echo  UserKnownHostsFile ~/.ssh/known_hosts >> ~/.ssh/config
echo  IdentityFile ~/linhpv-ssh-k8s-example/id_rsa >> ~/.ssh/config
echo  User github.com >> ~/.ssh/config
echo  IdentitiesOnly yes >> ~/.ssh/config

cd ~/home/$USER
mkdir micro-service-linhpv-vmo
git clone git@github.com:phamvanlinh20111993/k8s-example.git


##### install microk8s

sudo snap install microk8s --classic
sudo ufw allow in on cni0 && sudo ufw allow out on cni0
sudo ufw default allow routed

sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
sudo microk8s kubectl -n kube-system describe secret $token

sudo microk8s enable dashboard dns registry storage ingress

cd ~/home/$USER/micro-service-linhpv-vmo/k8s-example
# run script build k8s
chmod +x ./microk8s_kubernetes_build_script.sh
./microk8s_kubernetes_build_script.sh