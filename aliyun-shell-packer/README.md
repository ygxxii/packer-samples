
# Packer 阿里云 `alicloud-ecs` 示例

使用以下工具构建 阿里云自定义镜像：

- Packer
    - Packer Builder [`alicloud-ecs`](https://github.com/hashicorp/packer-plugin-alicloud)

在镜像中使用 Shell 命令安装 Packer 和 Ansible 。

## 准备工作

1. 创建 权限策略：[Alicloud Builder | Integrations | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/integrations/hashicorp/alicloud/latest/components/builder/alicloud-ecs#alicloud-ram-permission)

2. 创建 RAM 账户，为该 RAM 账户 授权 上面创建的 权限策略；

3. 为 阿里云 CLI (`aliyun-cli`) 设置环境变量：

```bash
export ALICLOUD_ACCESS_KEY_ID=...
export ALICLOUD_ACCESS_KEY_SECRET=...
```

4. 安装 阿里云 CLI (`aliyun-cli`)：
    - [安装指南_阿里云CLI(CLI)-阿里云帮助中心](https://help.aliyun.com/zh/cli/installation-guide/)

5. 【可选】查询指定 镜像族系(ImageFamily) 的最新镜像：

```bash
ALICLOUD_REGION_ID="cn-hongkong"

aliyun ecs DescribeImages \
    --region "$ALICLOUD_REGION_ID" \
    --RegionId "$ALICLOUD_REGION_ID" \
    --Status Available \
    --ImageFamily 'acs:almalinux_8_9_x64'
```

6. 【可选】查询指定 实例规格(InstanceType) 是否有库存：

```bash
ALICLOUD_REGION_ID="cn-hongkong"

aliyun ecs DescribeAvailableResource \
    --region "$ALICLOUD_REGION_ID" \
    --RegionId "$ALICLOUD_REGION_ID" \
    --DestinationResource InstanceType \
    --InstanceType 'ecs.u1-c1m2.large' \
    | jq -c '.AvailableZones.AvailableZone[].AvailableResources.AvailableResource[].SupportedResources'
```

## 部署步骤

1. 安装 Packer：
   - [Install | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/install)
   - [Install Packer | Packer | HashiCorp Developer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

2. `cd` 到当前目录；

3. 安装依赖的 Packer Plugins：

```bash
packer init .
```

4. 校验 Packer Template `.pkr.hcl`：

```bash
packer validate .
```

5. 开始 Packer 构建：

```bash
packer build .
```

6. 查询 自定义镜像：

```bash
ALICLOUD_REGION_ID="cn-hangzhou"

aliyun ecs DescribeImages \
    --region "$ALICLOUD_REGION_ID" \
    --RegionId "$ALICLOUD_REGION_ID" \
    --ImageOwnerAlias self
```
