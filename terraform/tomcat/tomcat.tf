provider "aws" {
    region = "eu-north-1"
}
resource "aws_security_group" "allow_ssh_tomcat" {
    name        = "allow_ssh_tomcat"
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
    instance_type = "t3.medium"
    key_name      = "stockholm"               
    security_groups = [aws_security_group.allow_ssh_tomcat.name]  # Associate the security group
    availability_zone   = "eu-north-1b"
    user_data = file("/Users/sampatirao/Documents/work/terraform/tomcat/user_data.sh")
    tags = {
    Name = "tomcat"
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

