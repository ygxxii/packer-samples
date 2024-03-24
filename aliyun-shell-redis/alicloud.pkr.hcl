packer {
  required_plugins {
    alicloud = {
      source  = "github.com/hashicorp/alicloud"
      version = "1.1.1"
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
  region                      = "cn-hangzhou"                 # 临时ECS实例、自定义镜像 的 地域
  instance_type               = "ecs.e-c1m1.large"
  image_family                = "acs:almalinux_8_9_x64"
  image_name                  = "packer_alma8_redis"
  
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
  provisioner "shell" {
    inline = ["sleep 10", "yum install redis.x86_64 -y"]
  }
}