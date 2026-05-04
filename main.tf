# 1. Terraform Settings & Required Providers
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. AWS Provider Configuration
provider "aws" {
  region = "us-east-1" 
}

# 3. Security Group for the Application
# This opens Port 80 so you can actually view your index.html file.
resource "aws_security_group" "app_sg" {
  name        = "jenkins-app-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world for testing
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open SSH for troubleshooting
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instance for the Application
resource "aws_instance" "app_server" {
  ami                    = "ami-0e2c8ca38b5913345" # Ubuntu 24.04 LTS AMI in us-east-1 (Updates regularly)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # This script automatically runs when the instance boots up.
  # It installs Apache and creates your index.html file.
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              
              # Create the index file
              echo "<h1>Hello World from Jenkins</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform-Deployed-App"
  }
}

# 5. Output the Public IP
output "application_url" {
  description = "Access your application at this URL"
  value       = "http://${aws_instance.app_server.public_ip}"
}
