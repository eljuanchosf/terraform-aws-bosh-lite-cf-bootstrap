provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

output "aws_key_path" {
	value = "${var.aws_key_path}"
}

resource "aws_security_group" "ssh_only" {
  name = "${var.prefix}-ssh-only"
  description = "Allow SSH only inbound traffic"

  ingress {
			from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}-ssh-only"
  }
}

resource "aws_security_group" "allow_bosh_lite_and_cf" {
  name = "${var.prefix}-bosh-lite-and-cf"
  description = "Allow BOSH and SSH only inbound traffic"

  ingress {
      self = true
			from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      self = true
			from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      self = true
			from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 25555
      to_port = 25555
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}-bosh-lite-and-cf"
  }
}

resource "aws_instance" "bosh-lite" {
    ami = "${var.aws_bosh_lite_ami}"
    instance_type = "${var.aws_bosh_lite_instance_type}"
    key_name = "${var.aws_key_name}"
    associate_public_ip_address = true
    security_groups = ["${var.prefix}bosh_lite_and_cf"]
    root_block_device {
        volume_type = "standard"
        volume_size = 80
    }
    tags {
      Name = "${var.prefix}-${var.bosh_lite_box_name}"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.aws_key_path}"
    }

    provisioner "file" {
      source = "${path.module}/set_routing_cf.sh"
      destination = "/home/ubuntu/set_routing_cf.sh"
    }

    provisioner "remote-exec" {
      inline = [
          "chmod +x /home/ubuntu/set_routing_cf.sh",
          "sudo /home/ubuntu/set_routing_cf.sh"
      ]
    }
}

resource "aws_instance" "jumpbox" {
    ami = "${var.aws_jumpbox_ami}"
    instance_type = "${var.aws_jumpbox_instance_type}"
    key_name = "${var.aws_key_name}"
    associate_public_ip_address = true
    security_groups = ["${var.prefix}-ssh-only"]
    root_block_device {
        volume_type = "standard"
        volume_size = 40
    }
    tags {
      Name = "${var.prefix}-${var.jumpbox_name}"
    }

    connection {
      user = "ubuntu"
      key_file = "${var.aws_key_path}"
    }

    provisioner "file" {
      source = "${path.module}/provision_cf.sh"
      destination = "/home/ubuntu/provision_cf.sh"
    }

    provisioner "remote-exec" {
      inline = [
          "chmod +x /home/ubuntu/provision_cf.sh",
          "/home/ubuntu/provision_cf.sh ${aws_instance.bosh-lite.public_ip} ${var.bosh_lite_stemcell}"
      ]
    }
}

output "jumpbox-ip" {
  value = "${aws_instance.jumpbox.public_ip}"
}


output "boshlite-ip" {
  value = "${aws_instance.bosh-lite.public_ip}"
}
