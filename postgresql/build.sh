#!/bin/bash

# --- 脚本配置 ---
# 如果任何命令失败，脚本将立即退出
set -e
# 定义镜像名称，方便后续修改
IMAGE_NAME="hlw-postgres:16-full"

# --- 步骤 1: 清理悬空 (Orphan) 镜像 ---
echo "--> STEP 1: Pruning dangling (orphan) images..."
# podman image prune 会删除所有没有标签的镜像
# --force 选项可以在非交互式环境（如脚本）中自动回答 "yes"
podman image prune --force
echo "--> Pruning complete."
echo # 打印一个空行，方便阅读

# --- 步骤 2: 检查并删除已存在的旧镜像 ---
echo "--> STEP 2: Checking for and removing existing image: ${IMAGE_NAME}"
# 'podman image exists' 命令如果找到镜像则返回 0 (true)，否则返回非 0 (false)
if podman image exists "${IMAGE_NAME}"; then
    echo "Image found. Removing it now..."
    podman rmi "${IMAGE_NAME}"
    echo "Successfully removed '${IMAGE_NAME}'."
else
    echo "Image not found. Proceeding directly to build."
fi
echo # 打印一个空行

# --- 步骤 3: 构建新镜像 ---
echo "--> STEP 3: Building the new image: ${IMAGE_NAME}"
# 执行构建命令，并将 UID/GID 传递给 Dockerfile
#podman build \
#    --build-arg CTNG_UID=$(id -u) \
#    --build-arg CTNG_GID=$(id -g) \
#    -t "${IMAGE_NAME}" .


podman build -t "${IMAGE_NAME}" .

echo # 打印一个空行
echo "--> BUILD COMPLETE! Image '${IMAGE_NAME}' is now ready to use."
