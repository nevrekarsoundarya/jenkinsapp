resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Ensure this is a valid Ubuntu AMI in your region
  instance_type = "t2.micro"

  # 1. This script runs automatically when the instance boots up
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              
              # This creates the directory and the index file
              sudo mkdir -p /var/www/html
              echo "<h1>Hello World from Jenkins</h1>" | sudo tee /var/www/html/index.html
              EOF

  # 2. Ensure you attach a security group that opens Port 80
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "My-Deployed-App"
  }
}

# Security group to allow you to see the web page
resource "aws_security_group" "app_sg" {
  name        = "app_web_sg"
  description = "Allow HTTP inbound traffic"

  ingress {
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
