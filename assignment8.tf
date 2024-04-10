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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzBaFk81xSjotcrjmTvaWY4AFZ54zdd4pZtrNU1fhxQGosWkx22EjVfRQM0UabjNvf+6M8v5Vfq9+o1jYv2wlQ+M8AoYn+nFFxZ505FV0/3z71nNG4Hj52auI2BHdRnshV4hKxxGbSe/QbnYcfRU3Gt8ugB8424a1ybrGl8nslt9gRNlAxS2v0s4KIObI0+TwuTwMtWDlOIXdcnr92F20XYo4H3HYIYoOS2YLmUMyL4rIbSDfvdMzvp6+FTEhkF3AadKzDX/eH8Nfj38FygorxBxT/71xu3XOoXnXKIKoJQ+/jT6rlA7fJqttU7O0AknVqYogJGJ+kSmZKuhR36paVhmUeDB5mkok/VcuZNPay719refOGeEWOGy9L4PQ8SfrlDcooyYFvK5B4zXgs8HSulk1473A3pVZSsc+luaVZ1tiMX4eexEpyvYn0G5A2lYwydAWmh37cfmhziHWsduR3AXvYFkjmq1WC7bv0tdxorCLB7jU8WE/AasYslfzM9K8= dhougaard@DESKTOP-ELTS15O"
}

# Create EC2 instances
resource "aws_instance" "dev" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "dev"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_instance" "test" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "test"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_instance" "prod" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "prod"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_ebs_volume" "extra_storage" {
  availability_zone = aws_instance.dev.availability_zone
  size              = 5
  tags = {
    Name = "week10storage"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdv"
  volume_id   = aws_ebs_volume.extra_storage.id
  instance_id = aws_instance.dev.id
}

output "ip_of_dev" {
  value         = aws_instance.dev.public_ip
  description   = "Public IP of dev instance"
}
