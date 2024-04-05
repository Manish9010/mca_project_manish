#!/bin/bash

# Array containing the instance IDs
instance_ids=("i-090d1cc887c8a5c9b" "i-090d1cc887c8a5c9b" "i-041912a89df35baaf")

# Path to the private key file
private_key="keys.pem"

# Loop through each instance ID
for instance_id in "${instance_ids[@]}"; do
    # Retrieve the password data for the instance
    password_data=$(aws ec2 get-password-data --instance-id "$instance_id" --priv-launch-key "$private_key")

    # Extract the password from the JSON output
    password=$(echo "$password_data" | jq -r '.PasswordData')

    # Print the instance ID and password
    echo "Instance ID: $instance_id"
    echo "Password: $password"
    echo "------------------------------------------"
done