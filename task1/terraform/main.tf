# =========================
# UBUNTU AMI
# =========================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# =========================
# VPC
# =========================

resource "aws_vpc" "mlops" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}


# =========================
# PUBLIC SUBNET
# =========================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.mlops.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}


# =========================
# INTERNET GATEWAY
# =========================

resource "aws_internet_gateway" "mlops" {
  vpc_id = aws_vpc.mlops.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}


# =========================
# ROUTE TABLE
# =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mlops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlops.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}


# =========================
# ROUTE TABLE ASSOCIATION
# =========================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# =========================
# SECURITY GROUP
# =========================

resource "aws_security_group" "mlops" {
  name        = "${var.project_name}-sg"
  description = "Security group for MLOps Foundations VM"
  vpc_id      = aws_vpc.mlops.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # Лучше потом заменить на YOUR_IP/32
    cidr_blocks = ["178.235.193.38/32"]
  }

  # MLflow
  ingress {
    description = "MLflow"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Airflow
  ingress {
    description = "Airflow"
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Web / API
  ingress {
    description = "Web API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Internet access
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}


# =========================
# EC2 INSTANCE
# =========================

resource "aws_instance" "mlops" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Existing AWS EC2 Key Pair
  key_name = "mlops-key"

  # Put EC2 into our public subnet
  subnet_id = aws_subnet.public.id

  # Attach Security Group
  vpc_security_group_ids = [
    aws_security_group.mlops.id
  ]

  # Vagrant provision equivalent
  user_data = file("${path.module}/user_data.sh")


  # =========================
  # ROOT DISK
  # =========================

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
    encrypted   = true
  }


  # =========================
  # TAGS
  # =========================

  tags = {
    Name    = "${var.project_name}-vm"
    Project = var.project_name
  }
}
