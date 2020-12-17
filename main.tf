terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}
variable "region" {
default = "ap-south-1"
}
variable "web_ports" {
default = ["22","80","443","3306"]
}
variable "images" {
default = "ami-08f63db601b82ff5f"
}
provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  }

  resource "aws_security_group_rule" "web_ingress"{
    description = "inbound rules"
	type        ="ingress"
	count       = length(var.web_ports)
    from_port   = element(var.web_ports,count.index)
    to_port     = element(var.web_ports,count.index)
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	security_group_id = aws_security_group.allow_web.id
  }

  resource "aws_security_group_rule" "web_egress" {
    description = "outbound rules"
	type        = "egress"
    count       = length(var.web_ports)
    from_port   = element(var.web_ports,count.index)
    to_port     = element(var.web_ports,count.index)
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	security_group_id = aws_security_group.allow_web.id
  }



resource "aws_instance" "my_web_instance" {
ami = var.images
instance_type = "t2.micro"
user_data = file("user_data.sh")
vpc_security_group_ids = [aws_security_group.allow_web.id]
}