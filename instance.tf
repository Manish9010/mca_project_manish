/*
# Define the provider and region
provider "aws" {
  region = "ap-south-2"
}
*/
# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My VPC"
  }
}
# aws
# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My IGW"
  }
}

# Create a custom route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "My Route Table"
  }
}

# Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "My Subnet"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "my_security_group" {
  name        = "My Security Group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnfvYW3Ce90dxCVKRG+v7psprtDYVm/CvZ1Lv9kQxJQbCJBV6kq8tO3Joagaeb6f5BVJyW0AYZzplUpNnjJNjkrv24HzIoI9VktgoNXTxLXmI86yzhd9S/q9AG1xb73yoWmUDDLEnqnABqPJShPtoK6RLDhvFUE+p0IOL/mOOI5nHvFNpcI/cMkybShoFIW2luI7uFH73QwT2GpcMJoQS8639wVG2VsCUfkx8UhClgqyE7yvmqtgSWnWkLMaFM+WpZpz94sjSEhw/NX4oVmR3BRF4GZJcM1qwpv3BWDcSnP8OZ1L1HiJEggSC8Fa5MWwQbxoWJoaFbIRi5R0VW14qPYdpjNIYlukyaZKqjf+Wg+i1L9SQo5nULwQCxdVRZgwuXZ18LBlDBpGDMQrYmHWNnIvdlUySUosQGRUzDc9iOQ1+XwUiUJhJI1JDrHdZffs+XkwfrzigyBZMl9/Wxec9nIl91d00LnW+vY366gCh38LAtenk4Bp2ZQa/08/GxYts= manish@Manish"
}
# Create an EC2 instance
resource "aws_instance" "my_ec2_instance" {
  count = 3
  ami           = "ami-0bd7b4edb1385fd36" # This is an example AMI ID, replace it with the AMI ID for your region
  instance_type = "t3.micro"
  key_name      = "keys" # Replace this with your key pair name
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true # Ensure automatic public IP assignment
/*
user_data = <<-EOF
              <powershell>
              Rename-LocalUser -Name "Administrator" -NewName "Manish"
              </powershell>
              EOF
*/
  tags = {
    //  Name = "Mca_Project_Windows_Server"
    Name = "Mca_Project_Windows_Server-${count.index + 1}"
  }
}
#-------------------------------------------------------------------
# Create SNS topics
resource "aws_sns_topic" "email_topic" {
  name = "InstanceEmailTopic"
}

resource "aws_sns_topic" "sms_topic" {
  name = "InstanceSMSTopic"
}

# Create email subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = "manishgroup.link@gmail.com"
}

# Create SMS subscription
resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.sms_topic.arn
  protocol  = "sms"
  endpoint  = "+918247359977" # Phone number to receive SMS notifications
}

# Output SNS topics ARNs
output "email_topic_arn" {
  value = aws_sns_topic.email_topic.arn
}

output "sms_topic_arn" {
  value = aws_sns_topic.sms_topic.arn
}

#---------------------------------------------------------------------------------------

resource "null_resource" "send_instance_info" {
  count = length(aws_instance.my_ec2_instance)

  triggers = {
    instance_id = aws_instance.my_ec2_instance[count.index].id
  }

  provisioner "local-exec" {
    command = <<-EOT
      instance_id=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[${count.index}].Instances[0].InstanceId" --output text)
      instance_ip=$(aws ec2 describe-instances --instance-id "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

      # Send instance IP via email
      aws_cli_args_email_1 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceEmailTopic",
        "--subject", "Instance IP",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"email\": {\"DataType\": \"String\", \"StringValue\": \"manish.ambekar63@gmail.com\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_email_1[*]}"

      aws_cli_args_email_2 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceEmailTopic",
        "--subject", "Instance IP",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"email\": {\"DataType\": \"String\", \"StringValue\": \"manjusha.ambekar36@gmail.com\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_email_2[*]}"

      aws_cli_args_email_3 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceEmailTopic",
        "--subject", "Instance IP",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"email\": {\"DataType\": \"String\", \"StringValue\": \"ananth.ambekar@gmail.com\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_email_3[*]}"

      # Send instance IP via SMS
      aws_cli_args_sms_1 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceSMSTopic",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"sms\": {\"DataType\": \"String\", \"StringValue\": \"+919010548051\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_sms_1[*]}"

      aws_cli_args_sms_2 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceSMSTopic",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"sms\": {\"DataType\": \"String\", \"StringValue\": \"+919059117245\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_sms_2[*]}"

      aws_cli_args_sms_3 = [
        "sns", "publish",
        "--topic-arn", "arn:aws:sns:ap-south-2:747132195357:InstanceSMSTopic",
        "--message", "Instance IP: $instance_ip",
        "--region", "ap-south-2",
        "--message-attributes", "{\"sms\": {\"DataType\": \"String\", \"StringValue\": \"+916305314023\"}}"
      ]
      ${data.external.default.command} "${aws_cli_args_sms_3[*]}"
    EOT
  }
}

data "external" "default" {
  depends_on = [aws_instance.my_ec2_instance]
}
