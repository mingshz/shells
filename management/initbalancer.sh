#!/bin/bash
# 初始化平衡器

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

# 获取目录
wget -O /root/balancer1.tar.gz http://resali.huobanplus.com/balancer1.tar.gz
tar -C /var -xzf /root/balancer1.tar.gz
ln -fs /var/balancer1/jk.conf /etc/httpd/conf.modules.d/jk.conf
