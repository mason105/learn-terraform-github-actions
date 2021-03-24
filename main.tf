terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = "~> 0.14"

  backend "remote" {
    organization = "mason105"

    workspaces {
      name = "github-test"
    }
  }
}


data "alicloud_images" "default" {
  most_recent = true
  owners      = "system"
  name_regex  = "^ubuntu.*18.*64"
  os_type = "linux"
  output_file = "images.json"
}

data "alicloud_regions" "current_region_ds" {
 output_file = "regions.json"
}

data "alicloud_zones" "zones_ds" {
  available_resource_creation = "VSwitch" 
  output_file = "zones.json"
}

resource "alicloud_vpc" "hkgw" {
  name       = "HKGW"
  cidr_block = "192.168.1.0/24"
}

resource "alicloud_vswitch" "hkgwsw" {
  vpc_id            = alicloud_vpc.hkgw.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "${data.alicloud_zones.zones_ds.zones.0.id}"
}

resource "alicloud_security_group" "hkgw_sg" {
  name = "hkgw_sg"
  vpc_id = alicloud_vpc.hkgw.id
}

resource "alicloud_key_pair" "publickey" {
  key_name   = "my_public_key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "all"
  policy            = "accept"
  port_range        = "1/65535"
  nic_type          = "intranet"
  priority          = 1
  security_group_id = alicloud_security_group.hkgw_sg.id
  cidr_ip           = "0.0.0.0/0"
}

data "template_file" "user_data" {
  template = file("./software/install.yaml")
}


data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  part{
   filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.user_data.rendered}"
  }
  part {
    content_type = "text/x-shellscript"
    content      = "#!/bin/bash\n /bin/mkdir /tmp/lalal"
  }
}

resource "alicloud_instance" "instance" {
   count 		= var.number
   instance_name	= "${var.short_name}-${var.role}-${format(var.count_format, count.index + 1)}"
   host_name	 	= "${var.short_name}-${var.role}-${format(var.count_format, count.index + 1)}"
   image_id		= data.alicloud_images.default.images.0.id
   instance_type	= var.instance_type
   security_groups      = alicloud_security_group.hkgw_sg.*.id
   vswitch_id           = alicloud_vswitch.hkgwsw.id

   internet_charge_type       = var.internet_charge_type
   internet_max_bandwidth_out = var.internet_max_bandwidth_out

   spot_strategy 	= "SpotAsPriceGo"
   password = var.ecs_password
   key_name = alicloud_key_pair.publickey.key_name
   instance_charge_type          = "PostPaid"
   system_disk_category          = "cloud_efficiency"
   system_disk_size              = 400
   security_enhancement_strategy = "Deactive"
   tags = {
      create = "terraform",
      role   = "k8s-worker"
    }
   user_data                   = data.template_file.user_data.rendered
}


output "ip" {
  value = alicloud_instance.instance.*.public_ip
}



