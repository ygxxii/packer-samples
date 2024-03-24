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
}

source "alicloud-ecs" "packer_aliyun_ecs" {
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  region                      = "cn-hangzhou"
  instance_type               = "ecs.e-c1m2.large"
  image_family                = "acs:almalinux_8_9_x64"
  image_name                  = "packer_alma8_grafana"
  
  skip_image_validation       = false
  system_disk_mapping {
    disk_category             = "cloud_essd"
    disk_size                 = 20
  }
  associate_public_ip_address = true
  instance_name               = "Packer构建_临时实例_按量付费"
  internet_charge_type        = "PayByTraffic"
  ssh_username                = "root"
}

build {
  sources = ["source.alicloud-ecs.packer_aliyun_ecs"]
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
  }
}