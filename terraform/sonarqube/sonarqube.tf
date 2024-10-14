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
    security_groups     = [aws_security_group.allow_ssh.name]
    availability_zone   = "eu-north-1b"  # Specify the availability zone

    tags = {
    Name = "SonarQube"
    }

    user_data = <<-EOF
                #!/bin/bash
                set -e  # Exit on error
                echo "Starting user data script"

                # Install necessary packages
                yum install -y java-1.8.0 unzip wget || exit 1

                # Download and unzip SonarQube
                wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.59859.zip || exit 1
                unzip sonarqube-9.9.0.59859.zip -d /opt/sonar76 || exit 1

                # Create sonar group and user if they don't exist
                groupadd sonar || echo "Group 'sonar' already exists"
                useradd -c "Sonar System User" -d /opt/sonar76 -g sonar -s /bin/bash sonar || echo "User 'sonar' already exists"
                chown -R sonar:sonar /opt/sonar76

                # Start SonarQube
                cd /opt/sonar76/sonarqube-9.9.0.59859/bin/linux-x86-64/ || exit 1
                su - sonar -c './sonar.sh start' || exit 1
                su - sonar -c './sonar.sh status' || exit 1
                EOF

}

output "instance_ip" {
    value = aws_instance.SonarQube.public_ip
}

output "instance_dns" {
    value = aws_instance.SonarQube.public_dns
}
