#!/bin/bash

# Retrieve instance IP from Terraform output
instance_ip=$(terraform output instance_ips | sed -n ${count.index+1}p)

# Send instance IP via SNS
aws sns publish \
  --topic-arn "arn:aws:sns:ap-south-2:747132195357:InstanceEmailTopic" \
  --subject "Instance IP" \
  --message "Instance IP: $instance_ip" \
  --region "ap-south-2" \
  --message-attributes "{\"email\": {\"DataType\": \"String\", \"StringValue\": \"manish.ambekar63@gmail.com\"}}"
