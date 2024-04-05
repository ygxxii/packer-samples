packer {
  required_plugins {
    alicloud = {
      source  = "github.com/hashicorp/alicloud"
      version = "1.1.1"
    }
  }
}

variable "access_key" {
  type      = string
  default   = "${env("ALICLOUD_ACCESS_KEY_ID")}"
}

variable "secret_key" {
  type      = string
  default   = "${env("ALICLOUD_ACCESS_KEY_SECRET")}"
  sensitive = true
}

variable "region" {
  type    = string
  # default = "${env("ALICLOUD_REGION_ID")}"
  default = "cn-hongkong"
}

local "timestamp" {
   expression = formatdate("YYYY.MMDD.hh:mm:ss", timestamp())
}

source "alicloud-ecs" "packer_aliyun_ecs" {
  access_key                   = var.access_key
  secret_key                   = var.secret_key
  region                       = var.region
  instance_type                = "ecs.u1-c1m2.large"
  image_family                 = "acs:almalinux_8_9_x64"
  image_name                   = "packer_alma8_builder"

  skip_image_validation        = false
  system_disk_mapping {
    disk_category              = "cloud_essd"
    disk_size                  = 20
  }
  associate_public_ip_address  = true
  instance_name                = "Packer构建_临时实例_按量付费"
  internet_charge_type         = "PayByTraffic"
  image_description            = "Custom image created by Packer. Installed Packages: Ansible, Packer"
  image_copy_regions           = ["cn-hangzhou"]
  image_copy_names             = ["packer_alma8_builder"]
  image_force_delete           = true
  image_force_delete_snapshots = true
  ssh_username                 = "root"
  tags                         = {
    Environment  = "DEV"
    Release-date = local.timestamp
    Created-by   = "Packer"
  }
}

build {
  sources = ["source.alicloud-ecs.packer_aliyun_ecs"]

  provisioner "shell" {
    inline = [ <<EOF
    sleep 10

    echo " ====== DNF: Enable Extras REPO (to install epel-release) ====> "
    dnf config-manager --enable extras

    echo " ====== DNF: Install EPEL REPO ====> "
    dnf -y install epel-release
    
    echo " ====== DNF: Config EPEL REPO Mirror ====> "
    sed -e 's|^metalink=|#metalink=|g' \
      -e 's|^#baseurl=https\?://download.*/pub/epel/|baseurl=http://mirrors.cloud.aliyuncs.com/epel/|g' \
      -i.default \
      /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
    dnf config-manager --set-disabled "epel-modular*"
    dnf config-manager --set-disabled "epel-testing-modular*"
    dnf -y makecache

    echo " ====== DNF: Install Hashicorp REPO ====> "
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    dnf -y makecache

    echo " ====== DNF: Install required packages ====> "
    dnf -y install \
        jq \
        ansible \
        python3-argcomplete \
        packer

    echo " ====== DNF: Install / Upgrade Aliyun Assist (云助手Agent) ====> "
    dnf -y install \
        https://aliyun-client-assist-${var.region}.oss-${var.region}-internal.aliyuncs.com/linux/aliyun_assist_latest.rpm

    echo " ====== Manual: Install Aliyun CLI ====> "
    curl -SL https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz -o /tmp/aliyun-cli-linux-latest-amd64.tgz
    tar xzf /tmp/aliyun-cli-linux-latest-amd64.tgz  -C /tmp
    install /tmp/aliyun /usr/local/bin

    echo " ====== Linux: Create Linux user ecs-user ====> "
    useradd ecs-user
    id ecs-user

    echo " ====== Alias: Create Packer alias ====> "
    echo 'alias "packer=/usr/bin/packer"' >> /root/.bashrc
    echo 'alias "packer=/usr/bin/packer"' >> /home/ecs-user/.bashrc

    echo " ====== Packer: Install Plugins ====> "
    sudo -u ecs-user sh -c "cd /home/ecs-user; PACKER_LOG=1 /usr/bin/packer plugins install github.com/hashicorp/alicloud"
    sudo -u ecs-user sh -c "cd /home/ecs-user; PACKER_LOG=1 /usr/bin/packer plugins install github.com/hashicorp/ansible"
    EOF
    ]
  }

  post-processor "manifest" {}
}