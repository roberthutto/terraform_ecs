provider "aws" {
  region = "us-east-1"
  profile = "devops"
}
#vpc vpc-f551ac8c
#Container name simple-app , httpd:2.4
##need application loadbalancer
#role ecsInstanceRole
#key rhutto-devops
#ami ami-04351e12
#!Ref "AWS::NoValue"


### Compute

variable "asg_min" {
  default = "2"
}
variable "asg_max" {
  default = ""
}
variable "asg_desired" {
  default = ""
}
variable "availability_zones" {
  default = ""
}
resource "aws_autoscaling_group" "app" {
  name                 = "ecs-sample-asg"
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  availability_zones   = "${var.availability_zones}"
  launch_configuration = "${aws_launch_configuration.app.name}"
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    ecs_cluster_name   = "${aws_ecs_cluster.main.name}"
  }
}



resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.ecs_cluster_name}"
}


resource "aws_security_group" "ecs-security-group" {
  description = "ECS sg"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##Lanunch configuration
resource "aws_launch_configuration" "ecs-launch-config" {
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  iam_instance_profile = "${var.iam_instance_profile}"
  key_name = "${var.key_name}"


  ebs_block_device {
    device_name = "${var.device_name}"
    volume_size = "${var.volume_size}"
  }

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
}

## Auto scaling group


## Application LoadBalancer


