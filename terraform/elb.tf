variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "elb_subnet_ids" {
  type = "list"
}

variable "cluster_name" {
  type = "string"
}

variable "instance_ids" {
  default = []
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_elb" "k8s_master" {
  name            = "k8s-master-${var.cluster_name}"
  subnets         = "${var.elb_subnet_ids}"
  security_groups = ["${aws_security_group.k8s_master.id}"]

  listener {
    instance_port     = "8443"
    instance_protocol = "tcp"
    lb_port           = "8443"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    target              = "TCP:8443"
    interval            = 5
  }

  instances             = "${var.instance_ids}"

  tags {
    Name = "k8s-master-${var.cluster_name}"
  }
}

resource "aws_security_group" "k8s_master" {
  name   = "k8s-master-${var.cluster_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master" {
  type        = "ingress"
  from_port   = "8443"
  to_port     = "8443"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "k8s_master_lb_name" {
  value = "${aws_elb.k8s_master.name}"
}

output "k8s_master_lb_dns_name" {
  value = "${aws_elb.k8s_master.dns_name}"
}

output "k8s_master_security_group" {
  value = "${aws_security_group.k8s_master.id}"
}
