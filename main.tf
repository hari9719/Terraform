provider "aws" {
    region = "ap-south-1"
    access_key = "Access key"
    secret_key = "secret_key"
}

resource "aws_vpc" "vpc_1" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "vpc-1"
    }
}
 
 resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "igw_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "igw-1"
  }
}

resource "aws_default_route_table" "rt_1" {
  default_route_table_id = aws_vpc.vpc_1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_1.id
  }

}

resource "aws_route_table_association" "rt_ass" {
  subnet_id      =  aws_subnet.subnet_1.id   
  route_table_id = aws_default_route_table.rt_1.id
}

resource "aws_security_group" "sg_1" {
  name        = "sg_1"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg-1"
  }
}

resource "aws_key_pair" "terraform_1" {
  key_name   = "terraform-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzpb7kADZwkRVGmzr/X+49qUY060+m5YJ5fzX50HNPMWE5+Q6pLrfgMTBGeMSon6sepO9WMYOqSKnKq1M7p/V0zKIxW1YMq6dowdgoXrakyxMO9lSc32dY43Nxc1OkYe2mlCi68M2ASa7AsEdg9rSPy3lsNNhxuEjlLxxoTTg8+suCNuqhnflFZ34n96mnszEgmX26PEo3Dwzb+BspyysIyg0jq/um6RdptbMLscyEJaR7Y06xhwaMtsMWlACA1k30tWHlNRth3MgvyfHIEJ/rOMGsqwt1Vf/rSGskm6u+oMTM4bLNL788sJb2k89sUznm/dWnzx/lCe1BUaeajwVKzBPbJYi2gZrxDCxEDy9d7C6gqQwqDFNiGYX75h9UcXCbwbRUOlTO9TuerpmFLnbbMxBgWRXfU1Eug1/YbK0yJ5cLDCAGlZn3ud2J4dwMZ3BGNZlCbJuJN95rfgHqpanGrMv7u/z5gii2z0rJ0Pu43QoPNfPeY5qZ0tFYe6p/Auk= hari.hariharan753@gmail.com"
}


data "aws_ami" "aws_os" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240429.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "demo-ec2" {
  ami           = data.aws_ami.aws_os.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet_1.id
  key_name = "terraform-1"
  vpc_security_group_ids = [aws_security_group.sg_1.id]

  availability_zone = "ap-south-1a"

  associate_public_ip_address = true

  tags = {
    Name = "demo-ec2"
  }
}

resource "aws_instance" "demo-ec2-2" {
  ami           = data.aws_ami.aws_os.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet_2.id
  key_name = "terraform-1"
  vpc_security_group_ids = [aws_security_group.sg_1.id]

  availability_zone = "ap-south-1a"

  associate_public_ip_address = true

  tags = {
    Name = "demo-ec2-2"
  }
}

 