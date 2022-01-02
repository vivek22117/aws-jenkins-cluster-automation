#!/bin/bash

sleep 5
chown jenkins:jenkins /var/lib/jenkins/

echo "Edit fstab, so EFS automatically loads on reboot"
echo "${efs_id}:/ /var/lib/jenkins nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab

# Mount EFS
mount -a -t nfs4

sleep 10

echo "Configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/basic-security.groovy /var/lib/jenkins/init.groovy.d/basic-security.groovy
mv /tmp/disable-cli.groovy /var/lib/jenkins/init.groovy.d/disable-cli.groovy
mv /tmp/csrf-protection.groovy /var/lib/jenkins/init.groovy.d/csrf-protection.groovy
mv /tmp/disable-jnlp.groovy /var/lib/jenkins/init.groovy.d/disable-jnlp.groovy
mv /tmp/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.UpgradeWizard.state
mv /tmp/node-agent.groovy /var/lib/jenkins/init.groovy.d/node-agent.groovy
chown -R jenkins:jenkins /var/lib/jenkins/jenkins.install.UpgradeWizard.state
mv /tmp/jenkins /etc/sysconfig/jenkins
chmod +x /tmp/install-plugins.sh
bash /tmp/install-plugins.sh

chown -R jenkins:jenkins /var/lib/jenkins
chmod -R 777 /var/lib/jenkins
service jenkins restart