data "aws_ami" "jenkins-slave-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Jenkins-Slave-AMI"]
  }
}
