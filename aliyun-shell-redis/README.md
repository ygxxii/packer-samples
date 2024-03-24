
# Packer 阿里云 `alicloud-ecs` 示例

使用以下工具构建 阿里云自定义镜像：

- Packer
    - Packer Builder Plugin [`alicloud-ecs`](https://github.com/hashicorp/packer-plugin-alicloud)

在镜像中使用 Shell 命令安装 Redis 。

### 部署步骤

1. 安装 Packer：
   - [Install | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/install)
   - [Install Packer | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

2. 安装依赖的 Packer Plugins：

```bash
packer init
```

3. 开始 Packer 构建：

```bash
packer build .
```
