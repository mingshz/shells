#!/bin/bash
# Authored By Cai Jiang
# 添加并且启动一个http代理服务器
# addtinyproxy.sh [port 默认55555] [Allow List;如果没有则允许所有]

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

yum install -y tinyproxy
# 更改配置文件
ConfigFile=/etc/tinyproxy/tinyproxy.conf
# ConfigFile=~/tinyproxy.conf
Port=$1
if [[ ! $Port ]]; then
  Port='55555'
fi
AllowList=$2

# https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html

sed -i -e "s@^Port [0-9]*@Port ${Port}@g" $ConfigFile
if [[ ! $AllowList ]]; then
  # 允许所有
  sed -i -e "s@^Allow .*@#Allow 127.0.0.1@g" $ConfigFile
else
  # 更改Allow
  sed -i -e "s@^Allow .*@Allow ${AllowList}@g"\
-e "s@^#Allow .*@Allow ${AllowList}@g" $ConfigFile
fi

# cat $ConfigFile
systemctl enable tinyproxy
systemctl start tinyproxy
# 同时应当信任 所有的访问
# firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.46.121.157" accept'
# firewall-cmd --add-rich-rule='rule family="ipv4" source address="120.76.42.134" accept'
