packer {
  required_plugins {
    alicloud = {
      source  = "github.com/hashicorp/alicloud"
      version = "1.1.1"
    }
    ansible = {
      source = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "access_key" {
  type    = string
  default = "${env("ALICLOUD_ACCESS_KEY_ID")}"
}

variable "secret_key" {
  type    = string
  default = "${env("ALICLOUD_ACCESS_KEY_SECRET")}"
  sensitive = true
}

variable "region" {
  type    = string
  # default = "${env("ALICLOUD_REGION_ID")}"
  default = "cn-hangzhou"
}

local "timestamp" {
   expression = formatdate("YYYY.MMDD.hh:mm:ss", timestamp())
}

source "alicloud-ecs" "packer_aliyun_ecs" {
  access_key                   = var.access_key
  secret_key                   = var.secret_key
  region                       = var.region
  instance_type                = "ecs.e-c1m2.large"
  image_family                 = "acs:almalinux_8_9_x64"
  image_name                   = "packer_alma8_grafana"
  
  skip_image_validation        = false
  system_disk_mapping {
    disk_category              = "cloud_essd"
    disk_size                  = 20
  }
  associate_public_ip_address  = true
  instance_name                = "Packer构建_临时实例_按量付费"
  internet_charge_type         = "PayByTraffic"
  image_description            = "Custom image created by Packer."
  image_force_delete           = false
  image_force_delete_snapshots = false
  ssh_username                 = "root"
  tags                         = {
    Environment  = "DEV"
    Release-date = local.timestamp
    Created-by   = "Packer"
  }
}

build {
  sources = ["source.alicloud-ecs.packer_aliyun_ecs"]
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
  }

  post-processor "manifest" {}
}