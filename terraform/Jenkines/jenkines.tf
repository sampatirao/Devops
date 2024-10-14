provider "aws" {
  region = "eu-north-1"
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (use with caution)
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed for security
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (use with caution)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "sampatirao" {
  ami           = "ami-097c5c21a18dc59ea"  
  instance_type = "t3.micro"
  key_name      = "stockholm"               
  security_groups = [aws_security_group.allow_ssh.name]  # Associate the security group

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo dnf install java-17-amazon-corretto -y
              sudo yum install -y git
              sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
              sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
              sudo yum install -y apache-maven
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum install jenkins -y
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              sudo systemctl status jenkins
              EOF

  tags = {
    Name = "Jenkines"
  }
}

output "instance_ip" {
  value = aws_instance.sampatirao.public_ip
}
output "instance_availability_zone" {
  value = aws_instance.sampatirao.availability_zone
  
}
output "instance_key_pair_nam" {
  value = aws_instance.sampatirao.key_name
}
#sudo alternatives --config java change to java 17