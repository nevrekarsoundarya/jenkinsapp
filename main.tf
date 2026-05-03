# 1. Define the AWS Provider
provider "aws" {
  region = "us-east-1" 
}

# 2. Network Infrastructure
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "jenkins-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "jenkins-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = { Name = "jenkins-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 3. Security Group (Firewall)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH, Jenkins, and Web traffic"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web App"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instance with User Data Bootstrap
resource "aws_instance" "jenkins_server" {
  ami           = "ami-0e001c9271cf7f3b9" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # This script runs on the first boot to install Jenkins automatically
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt install fontconfig openjdk-21-jre
              sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
              echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update
              sudo apt install jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = { Name = "Jenkins-Server" }
}

# 5. Output the Public IP for easy access
output "jenkins_ip" {
  value = aws_instance.jenkins_server.public_ip
}
