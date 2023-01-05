#!/bin/sh
sudo apt update
sudo apt upgrade
# Clone courses repository
git clone https://github.com/jacintogl82/courses.git

# Install VSFTP
sudo apt install -y vsftpd
sudo cp courses/linux/ftp/vsftpd.conf /etc/vsftpd.conf
sudo ufw allow 20,21,990/tcp
sudo systemctl restart vsftpd
sudo systemctl status vsftpd

# Install Docker
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
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world
sudo usermod -aG docker $USER && newgrp docker

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --apiserver-ips=192.168.1.193
minikube docker-env && eval $(minikube -p minikube docker-env)
minikube kubectl proxy -- --address='0.0.0.0' &
minikube tunnel -c --bind-address='0.0.0.0' &
minikube dashboard
minikube addons enable ingress
minikube addons enable istio
minikube addons enable istio-provisioner

# Install Kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install Java JDK
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install -y openjdk-11-jdk
sudo apt install -y default-jdk
java -version
# To seletc an specific java version execute
# sudo update-alternatives --set java path

# Install Maven
sudo apt install -y maven	
mvn -version

# Install NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install v18.12.1

# Install Nginx
sudo apt install -y nginx
mkdir /etc/nginx/conf.d/ && mkdir /etc/nginx/conf.d/certs/
cp ./nginx/nginx.conf /etc/nginx/nginx.conf
cp ./nginx/conf.d/minikube.conf /etc/nginx/conf.d/minikube.conf
cp ~/.minikube/profiles/minikube/client.crt /etc/nginx/conf.d/certs/minikube-client.crt
cp ~/.minikube/profiles/minikube/client.key /etc/nginx/conf.d/certs/minikube-client.key
sudo systemctl restart nginx