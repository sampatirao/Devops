provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "allow_ssh_nexus" {
  name        = "allow_ssh_nexus"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your specific IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nexus" {
  ami             = "ami-097c5c21a18dc59ea" # Replace with your AMI ID
  instance_type   = "c5.large"
  key_name        = "stockholm"
  security_groups = [aws_security_group.allow_ssh_nexus.name]
  availability_zone = "eu-north-1b"  # Specify the availability zone

  tags = {
    Name = "Nexus-Repo"
  }

  user_data = <<-EOF
              #!/bin/bash
              {
                  echo "Starting user data script"
                  sudo dnf install java-17-amazon-corretto -y
                  cd /opt/
                  sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
                  sudo tar -xvf latest-unix.tar.gz
                  sudo mv nexus-* nexus3
                  sudo chown -R ec2-user:ec2-user nexus3 sonatype-work
                  echo 'run_as_user="ec2-user"' > /opt/nexus3/bin/nexus.rc
                  sudo ln -s /opt/nexus3/bin/nexus /etc/init.d/nexus
                  cd /etc/init.d/
                  sudo chkconfig --add nexus
                  sudo chkconfig nexus on
                  sudo service nexus start
                  echo "User data script finished"
              } >> /var/log/user_data.log 2>&1
              EOF
}
output "instance_ip" {
  value = aws_instance.nexus.public_ip
}

output "instance_dns" {
  value = aws_instance.nexus.public_dns
}
