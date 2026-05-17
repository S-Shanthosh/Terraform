#!/bin/bash
echo "🔄 Restoring Terraform environment from S3..."

# Restore Terraform binary
aws s3 cp s3://mountstorages/terraform-env.tar.gz /tmp/
tar -xzf /tmp/terraform-env.tar.gz -C /

# Add binary to PATH
export PATH=$PATH:~/bin
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc

# Set provider plugin directory
export TF_DATA_DIR=/tmp/.terraform
echo 'export TF_DATA_DIR=/tmp/.terraform' >> ~/.bashrc

# Restore provider plugins
aws s3 cp s3://mountstorages/terraform-providers.tar.gz /tmp/ && \
tar -xzf /tmp/terraform-providers.tar.gz -C / && \
echo "✅ Providers restored — no terraform init needed!"

# Restore SSH keys
aws s3 cp s3://mountstorages/ssh-keys.tar.gz /tmp/ && \
tar -xzf /tmp/ssh-keys.tar.gz -C / && \
chmod 600 ~/.ssh/shanthosh-key && \
chmod 644 ~/.ssh/shanthosh-key.pub
echo "✅ SSH keys restored"

# Terraform auto-destroy wrapper
terraform() {
  if [[ "$*" == *"apply"* ]]; then
    command terraform "$@"
    echo "⏰ Auto-destroy scheduled in 1 hour..."
    nohup bash -c "sleep 3600 && cd $(pwd) && command terraform destroy -auto-approve" > ~/terraform-demo/Terraform/destroy.log 2>&1 &
    echo "✅ Background job started. Check destroy.log to confirm."
  else
    command terraform "$@"
  fi
}
export -f terraform
echo "✅ Terraform wrapper loaded — auto-destroy enabled!"
echo "✅ Restore complete! Terraform is ready."
