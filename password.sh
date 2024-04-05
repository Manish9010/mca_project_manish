#!/bin/bash

instance_ids=("i-090d1cc887c8a5c9b" "i-0dcb9eabdaa19169d" "i-041912a89df35baaf")

# Path to the private key file
private_key="keys.pem"

# Loop through each instance ID
for instance_id in "${instance_ids[@]}"; do
    # Retrieve the password data for the instance
    password_data=$(aws ec2 get-password-data --instance-id "$instance_id" --priv-launch-key "$private_key")

    # Extract the password from the JSON output
    password=$(echo "$password_data" | jq -r '.PasswordData')
    public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

    # Print the instance ID and password
    echo "Instance ID: $instance_id"
    echo "Password: $password"
    echo "Public IP: $public_ip"
    echo "------------------------------------------"
done
