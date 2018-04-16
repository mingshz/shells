#!/usr/bin/env bash

#安装docker CE

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi
#https://docs.docker.com/install/linux/docker-ce/centos/#uninstall-old-versions
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce

#调整/usr/lib/systemd/system/docker.service 添加MountFlags=private
sudo sed -i -e "s@^\[Service\]@[Service]\\nMountFlags=private@g" /usr/lib/systemd/system/docker.service
#检查docker 版本
sudo docker -v
#开启docker
sudo systemctl enable docker
sudo systemctl start docker

sudo docker run hello-world

# 设置主机名称
#hostnamectl --static --transient --pretty set-hostname $1
