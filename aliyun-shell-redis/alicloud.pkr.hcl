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
  sensitive = true
}

source "alicloud-ecs" "packer_aliyun_ecs" {
  access_key                  = var.access_key                              # Access key. 默认读取环境变量 ALICLOUD_ACCESS_KEY
  secret_key                  = var.secret_key                              # Secret key. 默认读取环境变量 ALICLOUD_SECRET_KEY
  region                      = "cn-hangzhou"                               # 临时ECS实例、自定义镜像 的 地域。默认读取环境变量 ALICLOUD_REGION
  instance_type               = "ecs.e-c1m1.large"                          # 临时ECS实例 的 实例规格。需确保在该地域可购买
  image_family                = "acs:almalinux_8_9_x64"                     # 临时ECS实例 的 镜像族系
  image_name                  = "packer_alma8_redis"                        # 自定义镜像 的 名称
  
  skip_image_validation       = false
  system_disk_mapping {
    disk_category             = "cloud_essd"                                # 临时ECS实例 的 云盘规格
    disk_size                 = 20                                          # 临时ECS实例、自定义镜像 的 云盘大小
  }
  associate_public_ip_address = true                                        # 临时ECS实例 是否分配 EIP
  instance_name               = "Packer构建_临时实例_按量付费"              # 临时ECS实例 的 名称
  internet_charge_type        = "PayByTraffic"                              # 临时ECS实例 EIP 公网带宽 的 计费方式。阿里云 目前仅支持 PayByTraffic(按流量计费)
  ssh_username                = "root"                                      # 临时ECS实例 的 SSH 登录账户。临时SSH密钥对 会写入到 root 账户；不要指定 源镜像 中没有/无法登录的账户
}

build {
  sources = ["source.alicloud-ecs.packer_aliyun_ecs"]
  
  provisioner "shell" {
    inline = ["sleep 10", "yum install redis -y"]
  }

  post-processor "manifest" {}
}