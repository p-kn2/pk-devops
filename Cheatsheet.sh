cat << 'EOF' >> ~/.bashrc

# ====================================================================
# 🔥 DEV-OPS ALL-IN-ONE MASTER ALIASES & LIVE CHEATBOOK
# ====================================================================

# --- 1. EC2 ALIASES ---
alias le='aws ec2 describe-instances --query "Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], InstanceId: InstanceId, State: State.Name, PublicIP: PublicIpAddress, PrivateIP: PrivateIpAddress}" --output table'
alias lerun='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], InstanceId: InstanceId, PublicIP: PublicIpAddress}" --output table'

# --- 2. S3 BUCKET ALIASES ---
alias ls3='aws s3 ls'              # List all buckets
alias ls3f='aws s3 ls s3://'       # List files inside a bucket (Usage: ls3f bucket-name)

# --- 3. EKS CLUSTER ALIASES ---
alias leks='aws eks list-clusters --output table'
alias leksnode='kubectl get nodes -o wide'
alias lekspod='kubectl get pods -A'

# --- 4. VPC & NETWORKING ALIASES ---
alias lvpc='aws ec2 describe-vpcs --query "Vpcs[].{Name: Tags[?Key==\`Name\`].Value | [0], VpcId: VpcId, CidrBlock: CidrBlock, IsDefault: IsDefault}" --output table'
alias lsub='aws ec2 describe-subnets --query "Subnets[].{Name: Tags[?Key==\`Name\`].Value | [0], SubnetId: SubnetId, VpcId: VpcId, CidrBlock: CidrBlock, AZ: AvailabilityZone}" --output table'

# --- 5. IAM ALIASES ---
alias luser='aws iam list-users --query "Users[].[UserName,UserId,CreateDate]" --output table'
alias lrole='aws iam list-roles --query "Roles[].[RoleName,CreateDate]" --output table'

# --- 🚀 THE ULTIMATE CHEATBOOK COMMAND ---
alias dops='cat << "DEVOP"

alias k='kubectl'
========================================================================================
                      🚀 DEV-OPS MASTER CHEATBOOK (ALL-IN-ONE) 🚀
========================================================================================

  💻 EC2 COMMANDS:
  👉 le         : List ALL EC2 instances (Name, ID, State, IPs)
  👉 lerun      : List ONLY Running EC2 instances
  
  🪣 S3 BUCKET COMMANDS:
  👉 ls3        : List ALL S3 Buckets in your account
  👉 ls3f <name>: List ALL files inside a specific bucket

  ☸️ EKS & KUBERNETES COMMANDS:
  👉 leks       : List ALL active EKS Clusters in the region
  👉 leksnode   : Live Kubernetes Nodes status (kubectl get nodes)
  👉 lekspod    : Live Kubernetes Pods status across ALL namespaces

  🌐 VPC & NETWORK COMMANDS:
  👉 lvpc       : List ALL VPCs (Name, ID, CIDR block, Default check)
  👉 lsub       : List ALL Subnets (Name, ID, connected VPC, CIDR, Zone)

  🔑 IAM & ACCESS COMMANDS:
  👉 luser      : List ALL IAM Users in the AWS Account
  👉 lrole      : List ALL IAM Roles

  💡 Tip: Just type any 2-4 letter command from above and get your infrastructure details!
========================================================================================
DEVOP'

EOF
source ~/.bashrc
