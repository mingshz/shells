#!/bin/bash
# 安装wildfly到当前目录

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

wget http://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.zip
# 获取当前目录
unzip wildfly-10.0.0.Final.zip
rm wildfly-10.0.0.Final.zip

PWD=`pwd`
HOME=${PWD}/wildfly-10.0.0.Final

# 添加用户
useradd -c "Wildfly Daemon User" -r -d "${HOME}" wildfly

echo "export WILDFLY_USER=wildfly" >> /etc/environment
echo "export WILDFLY_HOME=$HOME" >> /etc/environment

echo "it's very importment to true resolve-parameter-values in ${HOME}/bin/jboss-cli.xml"
