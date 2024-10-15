provider "aws" {
    region = "eu-north-1"
}

resource "aws_security_group" "allow_ssh1" {
    name        = "allow_ssh1"
    description = "Allow SSH access"

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your specific IP for better security
    }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this
    }

    ingress {
    from_port   = 9000
    to_port     = 9000
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

resource "aws_instance" "SonarQube" {
    ami                 = "ami-097c5c21a18dc59ea"  # Ensure this AMI is valid
    instance_type       = "t3.medium"
    key_name            = "stockholm"
    security_groups     = [aws_security_group.allow_ssh1.name]
    availability_zone   = "eu-north-1b"  # Specify the availability zone

    tags = {
    Name = "SonarQube"
    }

    user_data = <<-EOF
                #!/bin/bash
                set -e  # Exit on error
                echo "Starting user data script"
                sudo yum install java-1.8.0 -y
                sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip
                sudo unzip sonarqube-7.6.zip -d /opt/sonar76
                sudo groupadd sonar
                sudo useradd -c "Sonar System User" -d /opt/sonar76 -g sonar -s /bin/bash sonar
                sudo chown -R sonar:sonar /opt/sonar76
                sudo cd /opt/sonar76/sonarqube-7.6/bin/linux-x86-64
                sudo -u sonar /opt/sonar76/sonarqube-7.6/bin/linux-x86-64/sonar.sh start
                sudo -u sonar /opt/sonar76/sonarqube-7.6/bin/linux-x86-64/sonar.sh status
                EOF

}

output "instance_ip" {
    value = aws_instance.SonarQube.public_ip
}

output "instance_dns" {
    value = aws_instance.SonarQube.public_dns
}
