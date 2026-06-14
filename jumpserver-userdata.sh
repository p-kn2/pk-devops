#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

echo "=========================================="
echo " Starting jumphost app Installation"
echo " Target Environment: Ubuntu 26.04"
echo "=========================================="

# 0. Initial System Updates & Dependencies
echo "--> Updating package indexes..."
sudo apt-get update -y
sudo apt-get install -y wget curl gnupg apt-transport-https fontconfig unzip lsb-release


# --------------------------------------------------------
# 5. Installing AWS CLI
# --------------------------------------------------------
echo "--> Installing AWS CLI v2..."
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip
cd - > /dev/null

# --------------------------------------------------------
# 6. Installing Kubectl (Latest Stable release)
# --------------------------------------------------------
echo "--> Installing Kubectl..."
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
sudo curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "--> Verifying Kubectl Installation:"
kubectl version --client

# --------------------------------------------------------
# 7. Installing eksctl
# --------------------------------------------------------
echo "--> Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo "--> Verifying eksctl Installation:"
eksctl version

# --------------------------------------------------------
# 10. Installing Helm
# --------------------------------------------------------
echo "--> Installing Helm via Snap..."
sudo snap install helm --classic

# --------------------------------------------------------
# Final Verification Check
# --------------------------------------------------------
echo "=========================================="
echo " Post-Installation Checks"
echo "=========================================="
echo "Java:      $(java --version | head -n 1)"
echo "Jenkins:   $(sudo systemctl is-active jenkins)"
echo "Docker:    $(docker --version)"
echo "AWS CLI:   $(aws --version)"
echo "Kubectl:   $(kubectl version --client --output=yaml | grep gitVersion || echo 'Installed')"
echo "Terraform: $(terraform --version | head -n 1)"
echo "Trivy:     $(trivy --version | head -n 1)"
echo "Helm:      $(helm version --short)"
echo "=========================================="
echo " Complete Setup Successful!"
echo "=========================================="
