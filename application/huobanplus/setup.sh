#!/usr/bin/env bash

# 安装huobanplus
# 指令 ./setup.sh tomcat_home domain
# 默认会装到 localhost 中

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

if [[ ! $1 ]]; then
  echo "$0 <tomcat_home> <domain>"
  exit 1
fi
if [[ ! $2 ]]; then
  echo "$0 <tomcat_home> <domain>"
  exit 1
fi

ScriptPath=`pwd`/$0
_ScriptIndex=${#ScriptPath}-8-1
ScriptHome=${ScriptPath:0:${_ScriptIndex}}

Tomcat_home=$1
Domain=$2

cp ${ScriptHome}/httpd-resource.conf /etc/httpd/conf.d/0-resource.conf

sed -i -e "s@#{domain}@"${Domain}"@g"\
 /etc/httpd/conf.d/0-resource.conf

chmod +r /etc/httpd/conf.d/0-resource.conf
chown CJ:CJ /etc/httpd/conf.d/0-resource.conf
apachectl configtest

# 开始处理 tomcat
cp ${ScriptHome}/context.xml ${Tomcat_home}/conf/Catalina/localhost/context.xml.default
sed -i -e "s@#{domain}@"${Domain}"@g"\
 ${Tomcat_home}/conf/Catalina/localhost/context.xml.default
chmod +r ${Tomcat_home}/conf/Catalina/localhost/context.xml.default
chown CJ:CJ ${Tomcat_home}/conf/Catalina/localhost/context.xml.default
echo "${ScriptHome}/../gethuobanplus.sh <version>"
echo '可以获取最新版本WAR'
