# group: eagle system

echo "Creating tags for instances..."
aws ec2 create-tags \
    --resources \
    --tags Key=cost_group,Value="client"
echo "Tags created for instances Oregon's client"
