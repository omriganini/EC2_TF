##_________________VPC Creation____________________##

resource "aws_vpc" "tf_vpc" {
cidr_block = "10.0.0.0/16"
tags = {
Name = "tf_vpc"
    }
}

resource "aws_subnet" "tf_public_subnet" {
vpc_id = aws_vpc.tf_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-west-1a"
map_public_ip_on_launch = true
tags = {
Name = "tf_public_subnet"
    }
}

resource "aws_subnet" "tf_private_subnet" {
vpc_id = aws_vpc.tf_vpc.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-west-1a"
tags = {
Name = "private_subnet"
    }
}

resource "aws_internet_gateway" "tf_igw" {
vpc_id = aws_vpc.tf_vpc.id
tags = {
Name = "tf_main_igw"
    }
}

resource "aws_route_table" "tf_public_route_table" {
vpc_id = aws_vpc.tf_vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.tf_igw.id
}
tags = {
Name = "tf-public_route_table"
    }
}


resource "aws_route_table_association" "public_subnet_association" {
subnet_id = aws_subnet.tf_public_subnet.id
route_table_id = aws_route_table.tf_public_route_table.id
}



##__________________________Security Group#___________________________#

resource "aws_security_group" "tf_ec2_sg" {
vpc_id = aws_vpc.tf_vpc.id
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["31.210.177.3/32"] # Allow SSH from anywhere; adjust as needed
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "ec2_sg"

}
}
resource "aws_security_group" "tf_rds_sg" {
vpc_id = aws_vpc.tf_vpc.id
ingress {
from_port = 3306 # Default MySQL port; adjust for your DB engine
to_port = 3306
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"] # Allow access from within the VPC
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "rds_sg"
    }
}


##________________EC2 INSTANCE&KEY PAIR____________##


resource "aws_key_pair" "tf_key" {
  key_name   = "tf_key_pair"
  public_key = file("C:/Users/omrig/.ssh/id_rsa.pub")

}


resource "aws_instance" "tf_web_server" {
ami = "ami-07d2649d67dbe8900"
instance_type = "t3.micro"
availability_zone = "us-west-1a"
subnet_id = aws_subnet.tf_public_subnet.id
security_groups = [aws_security_group.tf_ec2_sg.id]
key_name = aws_key_pair.tf_key.key_name
user_data = <<-EOF
    #!/bin/bash
    set -e  # Stop script on error

    sudo apt update -y
    sudo apt install -y nginx unzip curl wget fontconfig openjdk-17-jre

    # Install AWS CLI (latest version)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip

    # Install Jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y
    sudo apt install -y jenkins

    # Enable and start services
    sudo systemctl enable nginx
    sudo systemctl start nginx
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
EOF
tags = {
Name = "tf_web_server"
}
}