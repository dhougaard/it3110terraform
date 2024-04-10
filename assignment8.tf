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
  public_key = "-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEAqcphvzgCgV/J/P+PMA5n61UVSoM1k0TLmT6zHusLv31rgWKt2inJeZdKtxuVyS27TTq17E2fEH1N9a3buxY5ar2QA9I9InATmihJaE8OCCkAZTLQVzEFJFjS/sYTGyte3Z1i+Rlmf6efY/9Z026KD+NjD1uf/yuXcos0ENtTy/2b97WDTqLKTrXNbcJSvfW2JPVOmnrYhaTDYvPHEBOa/UP5Q92+N7WovXgH1KuXgvk+ceaWvBr+NM8lOw7h6grmjVPG9bMVnODQROYUjqf3EDBCXDx7Hi/aWRH5PcI8/HEsCq7/2DRZqMUvuR0Eer6Fx+HmvvIY04kvTqgPt9vwmwIDAQABAoIBAG2LiHMhxOQJlD1p+M0NjliUBW+Upf1FFoLhpBlflq3OUo0gyIAIE9giF296GbK5ka2rInK6RdUSszi+GhVjqlnGweLlQtI0M0FzmqD02F3Fbl7cYPTQSLwBnugHjY4q9kLPZ2rFy46y7DBNMHwsRmEn2OKwv9KXIlghnc7+Ytspz5a33vkIAbFElJ5Jx0Qm+nL430kB0xEMkQ9y0BIgaORCJzHjMvNKJNz79/AN06dSvZxR3G5s5supCvxrCEtAafvPDmLhsGAig/G+izQsp8SFUD2gnDyTFb+bf+8/gYGI8nYEDKjBpVygSfXH2GA0bu/E2MNID0+Z4zxxwMR2rdECgYEA5mwdFcAXlbXcnVj1a7uGGk2tVsNAYnMrjX9dDQqynfPCx0Y4ZVx+4ifZzPTwKhZO3iaVDG5sgQz9Awb59G8NL/mquT3g7fdV1GyUrBbZqETHyfXrnvKAYjZ2Hw0yjxkW5BVfFrsE1Jt1ZNOLaagGdZVpObI55eq8X95GUvi6e3kCgYEAvKNNRR0dKV1KB/1RoW0dIBzWszbgM34CN0BNHRP/V56hodo5mmxHILpvqOCCLzhggZyHqyD/b3mkPK0+PrL1yVge6H7nE9TfA01wMG4F089CGtEGvH+tQFuDVBp9eZuUnykd7uKTp0g8UvCNfixWiAmeCOOFJng0UWt4wUeys7MCgYEAhJP4OCeKam11PmOM8iu3gTLoZV96kCrMCGIb3AEnvJIgpB/XGxsZNm7PdooIFW84ecGhSMHQVIBwo2lEMEwlPlFc1bCw1rrU+6Bt+oY7PgI1IhMJOy80h03msP8a9BLvhNR3HdEFen7oENdXA7fV35nULYpKnett74so01yhj6ECgYEAn3l7QLu9RJQOmzSIh21EmzpmNDpnToDwBJ/C0ZtvWjbMtJVV73wsobmb3mx3As6pn8miVIVgDXEL7RQVNFJ9QgvSjYGDf5uOMi+MchUBrjBg1WTzSfaylF8JZtfCTkW+XtQW7zbz1w9VmFSvegSn3vgqd59JmN00dcTi4JvpsssCgYEAqaVbw6NMdZVxJ2ZzKwqsvt9fUqFyk85Ra4aRsFjozLyQcOYr9MwpmM0CzAilKFYsoRG4VEIS0pxFwDmH/zzQcm06OQRhrBPUxxsdPiNU3MygpoJKpSkBYv2UztsxOxPLJ5b9p1ZUHmengosYVE4/h1d2pyL0sISsNGak+qBxpfI=-----END RSA PRIVATE KEY-----"
}

# Create EC2 instances
resource "aws_instance" "instance" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids        = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tf-key.key_name

  tags = {
    Name = "Instance"
  }

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_ebs_volume" "extra_storage" {
  availability_zone = aws_instance.instance.availability_zone
  size              = 5
  tags = {
    Name = "week10storage"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdv"
  volume_id   = aws_ebs_volume.extra_storage.id
  instance_id = aws_instance.instance.id
}

output "ip_of_instance" {
  value         = aws_instance.instance.public_ip
  description   = "Public IP of github created instance"
}
