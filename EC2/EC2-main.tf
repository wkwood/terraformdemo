# EC2 Instance Setup for Windows Server
# input variables

variable "app_name" {}
variable "app_environment" {}
variable "windows_instance_name" {}
variable "windows_instance_class" {}
variable "windows_associate_public_ip_address" {}
variable "windows_volume_type" {}
variable "security_group_id" {}
variable "public_subnet_id" {}
variable "key_pair_id" {}
variable "windows_root_volume_size" {}
variable "windows_data_volume_size" {}
variable "timezone" {}
variable "transit_role_name" {}


# Bootstrapping PowerShell Script
data "template_file" "windows-userdata" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "${var.windows_instance_name}" -Force;

# Set the Timezone

Set-Timezone -Name "${var.timezone}"

# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools;

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install PSWindowsUpdate

choco install pswindowsupdate -y -f

# Install CURL. This will allow us to query metadata, i.e., http://169.254.169.254/latest/meta-data

choco install curl -y -f

# Install .NET 4.8

choco install dotnetfx -y -f

# Install AWS CLI

choco install awscli -y -f

# modify the System PATH to include AWS CLI
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;C:\program files\Amazon\AWSCLIV2"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

# Install SSMS

choco install sql-server-management-studio -y -f

# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

# Get AMIs for the Windows Server editions that we support 

# Get latest Windows Server 2016 AMI
data "aws_ami" "windows-2016" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }
}

# Get latest Windows Server 2019 AMI
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

# Get latest Windows Server 2022 AMI
data "aws_ami" "windows-2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

# create a profile for EC2 based on the transit role

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "transit-ec2-profile"
  role = var.transit_role_name
}


# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                         = data.aws_ami.windows-2022.id
  instance_type               = var.windows_instance_class
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = var.windows_associate_public_ip_address
  source_dest_check           = false
  key_name                    = var.key_pair_id
  user_data                   = data.template_file.windows-userdata.rendered
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.id

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.windows_data_volume_size
    volume_type           = var.windows_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-windows-server"
    Environment = var.app_environment
  }
}

# Create Elastic IP for the EC2 instance
resource "aws_eip" "windows-eip" {
  vpc = true
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-windows-eip"
    Environment = var.app_environment
  }
}

# Associate Elastic IP to Windows Server
resource "aws_eip_association" "windows-eip-association" {
  instance_id   = aws_instance.windows-server.id
  allocation_id = aws_eip.windows-eip.id
}

