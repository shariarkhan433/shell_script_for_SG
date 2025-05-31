aws ec2 describe-instances \
  --region us-west-2 \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text > instance_ids.txt
echo "Instance IDs saved to instance_ids.txt"
# This script retrieves the instance IDs of all EC2 instances in the us-west-2 region
# and saves them to a file named instance_ids.txt.
# Make sure to run this script in the same directory where you want the instance_ids.txt file to be created.
# You can run this script using the command:
# bash get_id.sh
