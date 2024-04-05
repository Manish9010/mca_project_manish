#!/bin/bash

# Replace these variables with your values
KEY_PAIR_FILE="/home/ec2-user/keys.pem"
EMAIL="manish.ambekar63@gmail.com"

# List EC2 instances
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text)

# Iterate through instances
for instance_id in $instances; do
    # Retrieve password data
    password_data=$(aws ec2 get-password-data --instance-id $instance_id --priv-launch-key $KEY_PAIR_FILE)

    # Extract password from JSON response
    password=$(echo $password_data | jq -r '.PasswordData')

    # Securely share password via email
    echo "Instance ID: $instance_id, RDP password is: $password" | mail -s "RDP Password for Instance $instance_id" $EMAIL
done
