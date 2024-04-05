#!/bin/bash

# Extract arguments
instance_ip=$1
instance_id=$2
recipient_email=$3

# Retrieve instance password from Systems Manager Parameter Store
instance_password=$(aws ssm get-parameter --name "/instance_passwords/$instance_id" --query "Parameter.Value" --output text)

# Email subject and content
subject="EC2 Instance Information"
content="Instance IP: $instance_ip\nInstance Password: $instance_password"

# Send email using mail command (ensure mailutils package is installed)
echo -e "$content" | mail -s "$subject" "$recipient_email"
