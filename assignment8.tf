# Define provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

# Create subnet
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "tf-subnet"
  }
}

# Create security group
resource "aws_security_group" "tf-sg" {
  name   = "tf-sg"
  vpc_id = aws_vpc.tf-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-sg"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "tf-ig"
  }
}

# Create route table
resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
    Name = "tf-r"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "tf-r-assoc" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

# Create key pair
resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/6CSHEnFrO3QnfMsLgeWf3JjIMj6Xg+KWPq6bguTCP9kR2gUFxRunuL9BSQCL529c3BW2Q35kL7RSidrwA7I0IbiNAaxswP/JUjuIbCdFdQvWl/SoMg1FNVnAMbO4qkrLcn7ib3WbfQvRnEExuexWmWtrN25CJvsmIxPgvV30/v4uFQgUNMTStqNKHpTM3m+3TsXM2nMaXSz54oR6DIH/rLrzzpUrV25QlvtWV/Q+qUiChxLt0brqU26bzs/KzcCN96Qn5LCtp27ZUTh63NHG+dEXbEkPFLq24pg4QFz1tm2DdC3VBI9lXxXu68G45zk55PzMGxeGU3pQLZ+d/+UQb1GkY6rHdUIZTn7bT/jocXkraziDdAgrvQTlW6zPR87TxxIlYAuQNZePzqp7LhuLcl5lvRgBUvi/e/wSnl32nEE9AMObe7zhB3A36mzqr9tmekVs+pC7qXts7G8zSY2G4t298oiqnyRyFuj1bL3SAZE736r3Wkl8lxYAbAqneVM= dhougaard@dhcp"
}

# Create EC2 instances
resource "aws_instance" "php" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "php"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_instance" "python" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "python"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

output "ip_of_php" {
  value         = aws_instance.php.public_ip
  description   = "Public IP of php instance"
}

output "ip_of_python" {
  value         = aws_instance.python.public_ip
  description   = "Public IP of python instance"
}
