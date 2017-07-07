#!/usr/bin/env bash

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

ScriptPath=`pwd`/$0
_ScriptIndex=${#ScriptPath}-18-1
ScriptHome=${ScriptPath:0:${_ScriptIndex}}

# 解压到 /var/apache-activemq-5.14.4
tar -C /var -xzf ${ScriptHome}/apache-activemq-5.14.4-bin.tar.gz
# 建立用户
useradd -r activemq
chown -R activemq:activemq /var/apache-activemq-5.14.4
# ln -s /var/apache-activemq-5.14.4 /var/activemq
usermod -d /var/apache-activemq-5.14.4 activemq

# 修改运行配置
cp /var/apache-activemq-5.14.4/bin/env /etc/default/activemq
sed -i '~s/^ACTIVEMQ_USER=""/ACTIVEMQ_USER="activemq"/' /etc/default/activemq
chmod 644 /etc/default/activemq

#
ln -snf  /var/apache-activemq-5.14.4/bin/activemq /etc/init.d/activemq

chkconfig --add activemq
chkconfig activemq on

service activemq start

