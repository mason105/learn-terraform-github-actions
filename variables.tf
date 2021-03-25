variable "number" {
  default = "1"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "count_format" {
  default = "%02d"
}

#variable "image_id" {
#  default = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
#}

variable "instance_type" {
  default = "ecs.c5.3xlarge"
  #default = "ecs.n4.small"
  #default = "ecs.sn2ne.large"
}

variable "role" {
  default = "work"
}

variable "datacenter" {
  default = "hongkong"
}

variable "short_name" {
  default = "alicloud"
}

variable "ecs_type" {
  default = "ecs.n4.small"
}

variable "ecs_password" {
  default = "Mason1987"
}

variable "internet_charge_type" {
  default = "PayByTraffic"
}

variable "internet_max_bandwidth_out" {
  default = 5
}

variable "disk_category" {
  default = "cloud_efficiency"
}

variable "disk_size" {
  default = "40"
}

variable "nic_type" {
  default = "intranet"
}

