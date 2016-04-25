#!/bin/bash
# Authored By Cai Jiang
# 初始化一个CentOS 服务器
# 该脚本负责初始化 一些常用服务
# 缺 禁止root远程登录
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

# 安装一些必要的软件
yum -y install net-tools ntp redis memcached httpd

systemctl enable ntpd
systemctl enable redis
systemctl enable memcached
systemctl enable httpd
systemctl enable firewalld

# 将http端口开放
firewall-cmd --add-service=http --permanent

# 获取我们精心准备的发布包
if [[ ! -e /root/setup.tar.gz ]]; then
  wget -O /root/setup.tar.gz http://resali.huobanplus.com/huobanplus/setup.tar.gz
fi

tar -C /root -xzf /root/setup.tar.gz
# install

# rpm -ivh /root/setup/install/*.rpm
# 安装完毕提取Java目录到环境中
RPMJDK=`rpm -qa | grep jdk`
if [[ ! $RPMJDK ]]; then
  echo "Failed to install jdk."
  exit 1
fi
JavaHome=`rpm -ql $RPMJDK | grep jdk | head -n1`
if [[ ! $JavaHome ]]; then
  echo "Failed to get install dir of JDK."
  exit 1
fi
echo "export JAVA_HOME=$JavaHome" >> /etc/environment
# apache tomcat 寻找tomcat安装包
GZTomcat=`ls /root/setup/install/apache-tomcat*`
tar -C /usr -xzf $GZTomcat

CATALINA_HOME=`ls /usr/apache-tomcat* -d`
echo "export HB_CATALINA_HOME=${CATALINA_HOME}" >> /etc/environment

# tomcat base 空压缩包
cp /root/setup/install/tomcat_base.tar.gz ${CATALINA_HOME}/
echo "export HB_CATALINA_BASE_TAR=${CATALINA_HOME}/tomcat_base.tar.gz" >> /etc/environment

# jdbc
cp /root/setup/jdbc/*.jar ${CATALINA_HOME}/lib

# httpd
cp /root/setup/httpd/*.so /etc/httpd/modules/
cp /root/setup/httpd/*.conf /etc/httpd/conf.modules.d/
cp /root/setup/httpd/*.properties /etc/httpd/conf/
service httpd configtest
