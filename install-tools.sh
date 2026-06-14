#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

echo "=========================================="
echo " Starting DevOps Tools Stack Installation"
echo " Target Environment: Ubuntu 26.04"
echo "=========================================="

# 0. Initial System Updates & Dependencies
echo "--> Updating package indexes..."
sudo apt-get update -y
sudo apt-get install -y wget curl gnupg apt-transport-https fontconfig unzip lsb-release

# Ensure standard keyring directory exists
sudo mkdir -p /etc/apt/keyrings

# --------------------------------------------------------
# 1. Installing Java (OpenJDK 21)
# --------------------------------------------------------
echo "--> Installing OpenJDK 21..."
sudo apt-get install -y openjdk-21-jre openjdk-21-jdk

echo "--> Verifying Java Installation:"
java -version

# --------------------------------------------------------
# 2. Installing Jenkins (Using Modern 2026 Repository Keys)
# --------------------------------------------------------
echo "--> Adding Jenkins 2026 Repository Keys..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2026.key | sudo tee \
  /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "--> Installing Jenkins..."
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# --------------------------------------------------------
# 3. Installing Docker
# --------------------------------------------------------
echo "--> Installing Docker..."
sudo apt-get install -y docker.io

# Grant permissions (adds users to group)
sudo usermod -aG docker jenkins || echo "Jenkins user assignment skipped (if user setup isn't complete)"
sudo usermod -aG docker ubuntu

# Restart service to apply group updates
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock

# --------------------------------------------------------
# 4. Run Sonarqube Container
# --------------------------------------------------------
echo "--> Deploying Sonarqube Community LTS container..."
# Check if container already exists to avoid conflict errors
if [ ! "$(docker ps -a -q -f name=sonar)" ]; then
    docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
else
    echo "Sonarqube container already exists, skipping creation."
fi

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
# 8. Installing Terraform
# --------------------------------------------------------
echo "--> Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform

# --------------------------------------------------------
# 9. Installing Trivy (Aqua Security Scanner Fixed)
# --------------------------------------------------------
echo "--> Installing Trivy..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/trivy.gpg
echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

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
