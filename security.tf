# create iam role to allow systems manager
resource "aws_iam_role" "ssm_instance_role" {
  name = "SSMInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach policies to ssm role
resource "aws_iam_role_policy_attachment" "AmazonEC2ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.ssm_instance_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_instance_role.name
}

resource "aws_iam_instance_profile" "ssm" {
  name = "SSMInstanceRole"
  role = aws_iam_role.ssm_instance_role.name
}
