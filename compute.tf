# Get Ubuntu AMI 16.04data "aws_ami" "ubuntu" {
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

# Create EIP for the App servers.
resource "aws_eip" "Servers" {
  count    = var.sub_count
  vpc      = true
  instance = element(aws_instance.server.*.id, count.index)
}

# Create userdata template
data "template_file" "userdata" {
  template = file("${path.module}/bootstrap-web.tpl")
}

# Create Instances
resource "aws_instance" "server" {
  count                       = var.sub_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  user_data                   = data.template_file.userdata.rendered
  associate_public_ip_address = false

  tags = {
    Name = "${var.env_name}0${count.index + 1}a"
  }

  key_name        = var.key_name
  subnet_id       = element(var.public_subnets, count.index)
  security_groups = [aws_security_group.Server_SG.id]
}

# Create Security Group
resource "aws_security_group" "Server_SG" {
  name        = "${var.env_name}_Security_SG"
  description = "Used for access the instances"
  vpc_id      = var.vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}