#!/bin/bash
# Authored By Cai Jiang
# 初始化一个CentOS 服务器
# 该脚本负责初始化 一些常用服务
# 缺 禁止root远程登录
# 还缺少给httpd服务增加一个默认的虚拟服务器
# 缺少自动配置jk
# 缺少自动配置资源目录
# 自动的addproject还不成熟 比如自动service
# 参考 https://scottlinux.com/2014/12/08/how-to-create-a-systemd-service-in-linux-centos-7/
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

if [[ ! $1 ]]; then
  echo "$0 hostname"
  exit 1
fi

# 设置主机名称
hostnamectl --static --transient --pretty set-hostname $1

# 安装一些必要的软件
# 移除  gcc autoconf  httpd 暂时还支持，可以手动切换为nginx
yum -y install net-tools ntp redis memcached httpd lvm2 firewalld wget device-mapper java-1.8.0-openjdk

systemctl enable ntpd
systemctl enable redis
systemctl enable memcached
systemctl enable httpd
systemctl enable firewalld
systemctl start firewalld

# 将http端口开放
firewall-cmd --add-service=http --permanent

# 获取我们精心准备的发布包 2.0的版本了
if [[ ! -e /root/setup.tar.gz ]]; then
  wget -O /root/setup.tar.gz http://resali.huobanplus.com/setup.4.tar.gz
fi

tar -C /root -xzf /root/setup.tar.gz
# install

# 不再使用甲骨文的
#rpm -ivh /root/setup/install/*.rpm
## 安装完毕提取Java目录到环境中
#RPMJDK=`rpm -qa | grep jdk`
#if [[ ! $RPMJDK ]]; then
#  echo "Failed to install jdk."
#  exit 1
#fi
#JavaHome=`rpm -ql $RPMJDK | grep jdk | head -n1`
#if [[ ! $JavaHome ]]; then
#  echo "Failed to get install dir of JDK."
#  exit 1
#fi
echo "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk" >> /etc/environment
# apache tomcat 寻找tomcat安装包
GZTomcat=`ls /root/setup/install/apache-tomcat*`
tar -C /usr -xzf $GZTomcat

CATALINA_HOME=`ls /usr/apache-tomcat* -d`
echo "export HB_CATALINA_HOME=${CATALINA_HOME}" >> /etc/environment

chown -R root:root ${CATALINA_HOME}
chmod +x ${CATALINA_HOME}/bin/*.sh

# tomcat base 空压缩包
cp /root/setup/install/tomcat_base.tar.gz ${CATALINA_HOME}/
echo "export HB_CATALINA_BASE_TAR=${CATALINA_HOME}/tomcat_base.tar.gz" >> /etc/environment

# jdbc
cp /root/setup/jdbc/*.jar ${CATALINA_HOME}/lib

# httpd
cp /root/setup/httpd/*.so /etc/httpd/modules/
cp /root/setup/httpd/*.conf /etc/httpd/conf.modules.d/
cp /root/setup/httpd/*.properties /etc/httpd/conf/
# . addprojectmanager.sh
service httpd configtest
