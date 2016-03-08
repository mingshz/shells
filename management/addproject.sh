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

# 准备一个脚本文件
function MakeTomcatScript(){
  # $0 文件名 $1 指令
  echo "#!/bin/sh" > $1
  echo "export JAVA_HOME=${JAVA_HOME}" >> $1
  echo "export CATALINA_HOME=${HB_CATALINA_HOME}" >> $1
  echo "export CATALINA_BASE=${NEWHOME}/tomcat" >> $1
  echo "export TOMCAT_USER=${NAME}" >> $1
  echo "export JSVC_OPTS=\"-cwd ${NEWHOME}/tomcat\"" >> $1
  echo "${HB_CATALINA_HOME}/bin/daemon.sh $2" >> $1
  chmod +x $1
  chmod o-x $1
  chmod u+s $1
  # chmod u+s
}

. addprojectmanager.sh

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

if [[ ! ${JAVA_HOME} ]]; then
  JAVA_HOME=/usr/java/jdk1.8.0_66
fi

NEWHOME=/home/${NAME}
# echo $NAME $PORT $DEV ${HB_CATALINA_HOME} ${HB_CATALINA_BASE_TAR} ${NEWHOME}

# 检查tomcat服务器以及实例压缩包
if [ ! -e $HB_CATALINA_HOME -o ! -d $HB_CATALINA_HOME ]
then
  echo "${HB_CATALINA_HOME} do not exist."
  exit 1
fi

if [ ! -e $JAVA_HOME -o ! -d $JAVA_HOME ]
then
  echo "${JAVA_HOME} do not exist."
  exit 1
fi

if [ ! -e ${HB_CATALINA_BASE_TAR} ]
then
  echo "${HB_CATALINA_BASE_TAR} do not exist."
  exit 1
fi

# 检查用户名是否可用
if [ -e ${NEWHOME} ]
then
  echo "${NEWHOME} already existing."
  exit 1
fi

# 新增用户
useradd -mr -d ${NEWHOME} -s /sbin/nologin -c "Project ${NEWHOME} Account" ${NAME}
# 在开发模式中 给予组权限
if [[ ${DEV} -eq 1 ]]; then
  chmod g+rw ${NEWHOME}
fi

# 解压缩 并且更名
tar zxvf ${HB_CATALINA_BASE_TAR} -C ${NEWHOME}
mv ${NEWHOME}/tomcat_home_template ${NEWHOME}/tomcat


# 默认关闭ajp，并且修改http port为指定值

# 制作启动脚本 和后台运行脚本 需要了解如何将伪装一个其他用户的权限
# http://unix.stackexchange.com/questions/364/allow-setuid-on-shell-scripts
MakeTomcatScript ${NEWHOME}/startTomcat start
MakeTomcatScript ${NEWHOME}/stopTomcat stop
MakeTomcatScript ${NEWHOME}/runTomcat run
MakeTomcatScript ${NEWHOME}/versionTomcat version

chown -R ${NAME}:${NAME} ${NEWHOME}
if [[ ${DEV} -eq 1 ]]; then
  chmod -R g+rw ${NEWHOME}/tomcat
  # ACL控制
  setfacl -m group:${NAME}:rwx ${NEWHOME}
fi

# 将需要管理这个开发程序的人 加入到该组
AddProjectManager $NAME CJ
if [[ ${DEV} -eq 1 ]]; then
  AddProjectManager $NAME jenkins
fi
