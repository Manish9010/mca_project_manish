#!/bin/bash

# Extract arguments
instance_ip=$1
instance_password=$2
recipient_email=$3

# Email subject and content
subject="EC2 Instance Information"
content="Instance IP: $instance_ip\nInstance Password: $instance_password"

# Send email using mail command (ensure mailutils package is installed)
echo -e "$content" | mail -s "$subject" "$recipient_email"
