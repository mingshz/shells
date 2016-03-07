#!/bin/bash
# 添加一个项目，该项目同名也会添加一个无法直接登录的系统用户
# 目标
# 然后会把相关tomcat实例复制一份到home目录,如果是测试范畴还会将rw权限开放给group
# 接着会修改配置文件中的端口号，使其匹配到参数指定的端口号
# addproject --dev <name> <port>
# 所有环境中应该指定一个值  指向一个压缩好的 tomcat 实例
# 以及一个tomcat home
# HB_CATALINA_HOME
# HB_CATALINA_BASE_TAR
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

DEV=0
if [[ $1 = '--dev' ]]; then
  # 检查是否在开发模式
  DEV=1
  shift
fi

NAME=$1
shift
PORT=$1

if [[ ! $NAME ]]; then
  echo "$0 --dev [name] [port] or $0 [name] [port]"
  exit 1
fi

if [[ ! $PORT ]]; then
  echo "$0 --dev [name] [port] or $0 [name] [port]"
  exit 1
fi

if [[ ! ${HB_CATALINA_HOME} ]]; then
  HB_CATALINA_HOME=/usr/share/apache-tomcat-8.0.23
fi

if [[ ! ${HB_CATALINA_BASE_TAR} ]]; then
  HB_CATALINA_BASE_TAR=/usr/share/tomcat_base.tar.gz
fi

NEWHOME=/home/${NAME}
# echo $NAME $PORT $DEV ${HB_CATALINA_HOME} ${HB_CATALINA_BASE_TAR} ${NEWHOME}

if [ ! -e $HB_CATALINA_HOME -o ! -d $HB_CATALINA_HOME ]
then
  echo "${HB_CATALINA_HOME} do not exist."
  exit 1
fi

if [ ! -e ${HB_CATALINA_BASE_TAR} ]
then
  echo "${HB_CATALINA_BASE_TAR} do not exist."
  exit 1
fi

if [ -e ${NEWHOME} ]
then
  echo "${NEWHOME} already existing."
  exit 1
fi

useradd -mr -d ${NEWHOME} -s /sbin/nologin -c "Project ${NEWHOME} Account" ${NAME}
if [[ ${DEV} -eq 1 ]]; then
  chmod g+rw ${NEWHOME}
fi
