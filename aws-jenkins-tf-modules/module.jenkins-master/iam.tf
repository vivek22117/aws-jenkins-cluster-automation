resource "aws_iam_role" "jenkins_access_role" {
  name = "JenkinsSlavesRole"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            }
        }
    ]
}
EOF

}

resource "aws_iam_policy" "jenkins_access_policy" {
  name        = "JenkinsAWSResourcePolicy"
  description = "Policy to access AWS Resources"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession",
                "ssm:SendCommand"
            ],
            "Resource": [
                "arn:aws:ec2:${var.default_region}:${data.aws_caller_identity.current.account_id}:instance/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetConnectionStatus",
                "ssm:DescribeInstanceInformation",
                "ssm:DescribeSessions"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:TerminateSession",
                "ssm:ResumeSession"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "policy_role_attach" {
  policy_arn = aws_iam_policy.jenkins_access_policy.arn
  role       = aws_iam_role.jenkins_access_role.name
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "JenkinsSlavesAccessProfile"
  role = aws_iam_role.jenkins_access_role.name
}

