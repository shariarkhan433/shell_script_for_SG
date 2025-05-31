#!/bin/bash
# Copyright (C) Shariar Khan - All Rights Reserved
# Unauthorized copying, modification, or reuse is prohibited.
# Contact: kshariare@gmail.com for licensing inquiries.

# Configuration
SOURCE_REGION="eu-central-1"      # Frankfurt
TARGET_REGION="ap-southeast-2"        # Sydney
SOURCE_SG_ID="sg-0e9448c4e35d38e00"
TARGET_VPC_ID="vpc-02816664"

SG_JSON="sg-details.json"

echo "Fetching security group $SOURCE_SG_ID from $SOURCE_REGION..."
aws ec2 describe-security-groups \
  --region "$SOURCE_REGION" \
  --group-ids "$SOURCE_SG_ID" > "$SG_JSON"

SG_NAME=$(jq -r '.SecurityGroups[0].GroupName' "$SG_JSON")
SG_DESC=$(jq -r '.SecurityGroups[0].Description' "$SG_JSON")

echo "Creating security group '${SG_NAME}-copy' in $TARGET_REGION (VPC: $TARGET_VPC_ID)..."
NEW_SG_ID=$(aws ec2 create-security-group \
  --region "$TARGET_REGION" \
  --group-name "${SG_NAME}" \
  --description "$SG_DESC - copied from $SOURCE_REGION" \
  --vpc-id "$TARGET_VPC_ID" \
  --query 'GroupId' \
  --output text)

echo "New security group ID: $NEW_SG_ID"

echo "Copying inbound rules..."
INGRESS_RULES=$(jq -c '.SecurityGroups[0].IpPermissions[]' "$SG_JSON")
for rule in $INGRESS_RULES; do
  aws ec2 authorize-security-group-ingress \
    --region "$TARGET_REGION" \
    --group-id "$NEW_SG_ID" \
    --ip-permissions "$rule" >/dev/null
done

echo "Copying outbound rules..."
EGRESS_RULES=$(jq -c '.SecurityGroups[0].IpPermissionsEgress[]' "$SG_JSON")
for rule in $EGRESS_RULES; do
  aws ec2 authorize-security-group-egress \
    --region "$TARGET_REGION" \
    --group-id "$NEW_SG_ID" \
    --ip-permissions "$rule" >/dev/null
done

echo "Security group copied successfully!"
