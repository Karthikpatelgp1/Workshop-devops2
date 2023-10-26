provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "demo-server" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name      = "CI-CD"
  //security_groups = ["demo-sg"]
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id              = aws_subnet.Nam-public-subnet-01.id
  for_each               = toset(["jenkins-master", "jenkins-slave", "Ansible"])
  tags = {
    Name = "${each.key}"
  }
}
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.Nam-vpc.id
  ingress {
    description = "Shh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins-port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "ssh-port"
  }
}
resource "aws_vpc" "Nam-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Nam-vpc"
  }
}
resource "aws_subnet" "Nam-public-subnet-01" {
  vpc_id                  = aws_vpc.Nam-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "Nam-public-subent-01a"
  }
}
# CICD Project Workshop 8
resource "aws_subnet" "Nam-public-subnet-02" {
  vpc_id                  = aws_vpc.Nam-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "Nam-public-subent-02"
  }
}
resource "aws_internet_gateway" "Nam-igw" {
  vpc_id = aws_vpc.Nam-vpc.id
  tags = {
    Name = "Nam-igw"
  }
}
resource "aws_route_table" "Nam-public-rt" {
  vpc_id = aws_vpc.Nam-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Nam-igw.id
  }
}
resource "aws_route_table_association" "Nam-rta-public-subnet-01" {
  subnet_id      = aws_subnet.Nam-public-subnet-01.id
  route_table_id = aws_route_table.Nam-public-rt.id
}
resource "aws_route_table_association" "Nam-rta-public-subnet-02" {
  subnet_id      = aws_subnet.Nam-public-subnet-02.id
  route_table_id = aws_route_table.Nam-public-rt.id
}
