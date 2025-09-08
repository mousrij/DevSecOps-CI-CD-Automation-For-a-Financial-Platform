#!/bin/bash

# Install AWS CLI
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Docker
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
# timeout 60 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu
sudo chmod 777 /var/run/docker.sock
# sudo newgrp docker
docker --version

# Install Sonarqube (as image)
# Create a docker-compose.yml file with the required configuration
cat <<EOF > docker-compose.yml
version: "3"

services:
  sonarqube:
    image: sonarqube:lts-community
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs

  db:
    image: postgres:13
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - postgresql:/var/lib/postgresql

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:
EOF

# Before Linux controls how many "virtual memory map areas" a process can have with the kernel parameter:
# vm.max_map_count = Your system currently has: 65530
# Elasticsearch (inside SonarQube) requires at least: 262144
# so run this command 
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


# Run docker compose up in detached mode
docker compose up -d

# Install Trivy
sudo apt-get install -y wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# Install Java 17
# REF: https://www.rosehosting.com/blog/how-to-install-java-17-lts-on-ubuntu-20-04/
sudo apt update -y
sudo apt install openjdk-17-jdk openjdk-17-jre -y
java -version

# Install Jenkins
# REF: https://www.jenkins.io/doc/book/installing/linux/#debianubuntu

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y                                   # to update package
sudo apt install jenkins -y                          # to install jenkins

sudo systemctl start jenkins                         # to start jenkins service
# sudo systemctl status jenkins                        # to check the status if jenkins is running or not

# Get Jenkins_Public_IP
ip=$(curl ifconfig.me)
port1=8080
port2=9000

# Generate Jenkins initial login password
pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Access Jenkins Server here --> http://$ip:$port1"
echo "Jenkins Initial Password: $pass"
echo
echo "Access SonarQube Server here --> http://$ip:$port2"
echo "SonarQube Username & Password: admin"
