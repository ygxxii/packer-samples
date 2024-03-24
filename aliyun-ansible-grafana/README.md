
# Packer 阿里云 `alicloud-ecs` 示例

使用以下工具构建 阿里云自定义镜像：

- Packer
    - Packer Builder Plugin [`alicloud-ecs`](https://github.com/hashicorp/packer-plugin-alicloud)
    - Packer Provisioner Plugin [`ansible`](https://github.com/hashicorp/packer-plugin-ansible)
- Ansible
    - Ansible Role [`grafana.grafana.grafana`](https://github.com/grafana/grafana-ansible-collection)

在镜像中使用 Ansible Playbook 安装 Grafana 。

## 部署步骤

1. 安装 Ansible；

2. 安装依赖的 Ansible Collections 和 Roles：

```bash
ansible-galaxy install -r requirements.yml
```

3. 安装 Packer：
   - [Install | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/install)
   - [Install Packer | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

4. 安装依赖的 Packer Plugins：

```bash
packer init
```

5. 开始 Packer 构建：

```bash
packer build .
```
