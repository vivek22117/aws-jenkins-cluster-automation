#!/usr/bin/env bash


echo ====================================== Info =======================================================
echo "The below script will first create terraform backend resources that is S3 bucket and DynamoDB table.
They will be used in other modules to store the TF state file"
echo -e "===============================================================================================\n\n"


echo ============================== Reading AWS Default Profile ====================================
aws configure list --profile default >/dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 256 ]; then
    echo "'default' aws profile does not exit, please create!"
    exit 1
else
  echo "'default' aws profile exists! Let's provision some AWS resources."
fi


echo -e "\n\n =========================== Fetch AWS Account Id ======================================"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text --profile default)
if [ -z $AWS_ACCOUNT_ID  ]; then
    echo "Credentials are not valid!"
    exit 1
else
  echo $AWS_ACCOUNT_ID
fi


echo -e "\n\n =========================== Choose Terraform Execution Type ==========================="

PS3="Select the terraform execution type: "

select EXEC_TYPE in apply destroy
do
    echo "You have decided to $EXEC_TYPE the AWS resources!"
    break
done


echo -e "\n\n ============================= Choose AWS Region ======================================="

PS3="Select aws region to deploy the resources: "

select AWS_REGION in us-east-1 us-east-2 eu-central-1 eu-west-1 eu-west-2 ap-south-1
do
    echo "You have selected $AWS_REGION to deploy the resources!"
    break
done


echo -e "\n\n ======================= Choose Environment To Deploy =================================="

PS3="Select environment to deploy: "

select ENV in qa test prod
do
    echo "You have selected $ENV environment for deployment"
    break
done


echo -e "\n\n ======================= Choose AMI Filter Type To Create EC2 =================================="

PS3="Select ami filter type. Select 'self_owned' option, only if the default VPC is available within the AWS account: "

AMI_FILTER_TYPE="amazon"

select AMI_FILTER in self_owned amazon_owned
do
    echo "You have selected $AMI_FILTER ami filter type."

    if [ $AMI_FILTER == 'self_owned' ]; then
      AMI_FILTER_TYPE='self'
    fi

    break
done


function terraform_backend_deployment() {
    echo -e "\n\n==================== Starting Terraform Backend Deployment ========================="

    cd aws-terraform-backend

    sed -i '/profile/s/^#//g' providers.tf
    sed -i '/backend/,+4d' providers.tf

    terraform init -reconfigure
    terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION"
    terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

    cd ..

    echo -e "========================= Completed ================================================ \n\n"
}




if [ $EXEC_TYPE == 'apply' ]; then

  terraform_backend_deployment

fi



if [ $EXEC_TYPE == 'destroy' ]; then

  PS3="Do you want to destroy TF backend resources? "

  select DESTROY_BACKEND in Yes No
  do
      echo "Your input is $DESTROY_BACKEND"
      break
  done

  if [ $DESTROY_BACKEND == 'Yes' ]; then
    echo -e "\n\n ========================= Destroying Backend TF Resources =============================="
    cd aws-jenkins-tf-backend
    terraform init -reconfigure
    terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
    cd ..
  fi
  
  
  echo -e "\n\n ========================= =============================== =============================="
  PS3="Do you want to deregister & delete Jenkins AMIs? Select by inserting the number: "

  select AMI_DELETE_FLAG in Yes No
  do
      echo "Your input is $AMI_DELETE_FLAG"
      break
  done
  
  if [ $AMI_DELETE_FLAG=='Yes' ] && [ $AMI_FILTER_TYPE=='self' ]; then

      BASTION_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=Jenkins-Master-2.x" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

      if [ ! -z $BASTION_AMI_ID ]; then
          aws ec2 deregister-image --image-id $BASTION_AMI_ID --region $AWS_REGION

          BASTION_SNAPSHOT=$(aws ec2 describe-snapshots --owner-ids self --filters Name=tag:Name,Values=Bastion-AMI --query "Snapshots[*].SnapshotId" --output text --region $AWS_REGION)
          for ID in $BASTION_SNAPSHOT;
          do
            aws ec2 delete-snapshot --snapshot-id $ID --region $AWS_REGION
            echo ====================== Bastion Host AMI Delete Successfully =============================
          done
      fi



      ECS_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=Jenkins-Slave-AMI" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

      if [ ! -z $ECS_AMI_ID ]; then
        aws ec2 deregister-image --image-id $ECS_AMI_ID --region $AWS_REGION

        ECS_SNAPSHOT=$(aws ec2 describe-snapshots --owner-ids self --filters Name=tag:Name,Values=ECS-AMI --query "Snapshots[*].SnapshotId" --output text --region $AWS_REGION)

        for ID in $ECS_SNAPSHOT;
        do
          aws ec2 delete-snapshot --snapshot-id $ID --region $AWS_REGION
          echo ======================== ECS AMI Deleted Successfully ======================================
        done
      fi

  else
    echo "No activity to perform!"
  fi

fi