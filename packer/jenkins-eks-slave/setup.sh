#!/usr/bin/env bash



sudo yum update -y
sudo yum install wget unzip -y
sleep 5


echo "Install Java8"
sudo yum remove -y java
sudo amazon-linux-extras install epel -y
sudo yum-config-manager --enable epel
sudo yum install -y java-1.8.0-openjdk


echo "Install AWS Cli & kubectl & eks & docker"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo  ./aws/install -i /usr/local/aws-cli -b /usr/local/bin


echo "Install Terraform"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip
mv terraform /usr/local/bin/
terraform version


echo "Installing Kubectl"
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/${KUBECTL_VER}/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

kubectl version --short --client


curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
yum install docker -y
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user


echo "Install Helm"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
sudo ./get_helm.sh
helm version

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update


echo "Install git"
sudo yum install -y git


echo "Install Telegraf"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start


echo "Install SSM-Agent"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent


echo "Install NodeExporter"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar -xf node_exporter-0.18.1.linux-amd64.tar.gz
sudo mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf /tmp/node_exporter-0.18.1.linux-amd64*

sudo cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "SUCCESS! Installation succeeded!"
