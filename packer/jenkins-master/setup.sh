#!/bin/bash

echo "Configure EFS for storage"
yum update -y
sudo yum install wget unzip git -y
sudo amazon-linux-extras install epel -y
sudo yum-config-manager --enable epel
yum install nfs-utils

sleep 5
cd ..
cd ..
cd var
cd lib
sudo mkdir -p jenkins

echo "Mounting volume..."
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0318d2da7b751e4fa.efs.us-east-1.amazonaws.com:/ jenkins

sleep 10

echo "Install Jenkins stable release"
sudo yum install java-1.8.0-openjdk-devel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins-ci.org/redhat-stable/jenkins.repo --no-check-certificate
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

yum --showduplicates list jenkins | expand
sudo yum install -y jenkins-2.319.1-1.1
chkconfig jenkins on


sleep 5
echo "Install Telegraph"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start

sleep 10

echo "Install git"
yum install -y git

echo "Install SSM-Agent"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent


