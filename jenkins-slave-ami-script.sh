#!/usr/bin/env bash


echo ================================== Info =====================================================
echo "The below script will create Jenkins Slave AMI with Jenkins Installed"
echo -e "===============================================================================================\n\n"


echo ============================== Reading AWS Default Profile ========================================
aws configure list --profile default >/dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 256 ]; then
    echo "'default' aws profile does not exit, please create!"
    exit 1
else
  echo "'default' aws profile exists! Let's create AMI for CI/CD instances."
fi


echo -e "\n\n =========================== Fetch AWS Account Id ======================================"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text --profile default)
if [ -z $AWS_ACCOUNT_ID  ]; then
    echo "Credentials are not valid!"
    exit 1
else
  echo $AWS_ACCOUNT_ID
fi


echo -e "\n\n =========================== Choose Packer Execution Type ==========================="
PS3="Select the packer execution type by inserting number: "

select EXEC_TYPE in create_ami destroy_ami
do
    echo "You have decided to $EXEC_TYPE!"
    break
done


echo -e "\n\n ============================= Choose AWS Region ======================================="

PS3="Select aws region to deploy the AMI by inserting number: "

select AWS_REGION in us-east-1 us-east-2 eu-central-1 eu-west-1 eu-west-2 ap-south-1
do
    echo "You have selected $AWS_REGION to deploy the AMI!"
    break
done


function create_jenkins_slave_ami() {

    echo -e "You have decided to create AMI for Jenkins slave AMI."

    echo -e "\n\n ====================== Creating Jenkins slave Node AMI using Packer ========================="
    echo "Checking whether AMI exists"
    CI_CD_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=Jenkins-Slave-AMI" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

    if [ -z $CI_CD_AMI_ID ]; then
      echo "Creating AMI named jenkins-node-YYYY-MM-DD using packer as it is being used for CI/CD Node"

      cd packer/jenkins-slave
      packer validate jenkins-ami-template.json
      packer build -var "aws_profile=default" -var "default_region=$AWS_REGION" server-template.json
      cd ../..
    else
      echo "AMI exits with id $CI_CD_AMI_ID"
    fi


  echo -e "============================== Completed ================================================ \n\n"
}


if [ $EXEC_TYPE == 'create_ami' ]; then

  create_jenkins_slave_ami

fi



if [ $EXEC_TYPE == 'destroy_ami' ]; then

  echo -e "\n\n ========================= =============================== =============================="
      CI_CD_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=Jenkins-Slave-AMI" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

      if [ ! -z $CI_CD_AMI_ID ]; then
          aws ec2 deregister-image --image-id $CI_CD_AMI_ID --region $AWS_REGION

          CI_CD_SNAPSHOT=$(aws ec2 describe-snapshots --owner-ids self --filters Name=tag:Name,Values=CI-CD-Server --query "Snapshots[*].SnapshotId" --output text --region $AWS_REGION)
          for ID in $CI_CD_SNAPSHOT;
          do
            aws ec2 delete-snapshot --snapshot-id $ID --region $AWS_REGION
            echo ====================== CI/CD Node AMI Delete Successfully =============================
          done
      fi

fi
