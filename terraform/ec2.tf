# key pair (login)
resource "aws_key_pair" "my_key_new" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}

# VPC & Security Group
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "this will add a TF generated Security group"
  vpc_id      = aws_default_vpc.default.id # interpolation

  # inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  # outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access open outbound"
  }

  tags = {
    Name = "automate-sg"
  }
}

# ec2 instance

resource "aws_instance" "my_instance" {
  for_each = tomap({
    Control-node-ubuntu  = "ami-07a00cf47dbbc844c", # ubuntu
    Worker-node-ubuntu-1 = "ami-07a00cf47dbbc844c", #ubuntu
    Worker-node-redhat-2 = "ami-00a3ff43223e36738", #RedHat
    Worker-node-Amazon-3 = "ami-0db56f446d44f2f09"  # CentOs / Amazon Linux 2
  })                                                # meta argument

  depends_on = [aws_security_group.my_security_group, aws_key_pair.my_key_new]

  key_name        = aws_key_pair.my_key_new.key_name
  security_groups = [aws_security_group.my_security_group.name]
  instance_type   = "t3.micro"
  ami             = each.value
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  tags = {
    Name = each.key
  }
}