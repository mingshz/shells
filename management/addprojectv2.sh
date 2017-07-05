#!/bin/bash
# Authored By Cai Jiang
# 添加一个项目，该项目同名也会添加一个无法直接登录的系统用户
# 目标
# 然后会把相关tomcat实例复制一份到run目录,还会将rw权限开放给group
# 接着会修改配置文件中的端口号，使其匹配到参数指定的端口号
# addproject --dev <name> <port>
# 所有环境中应该指定一个值  指向一个压缩好的 tomcat 实例
# 以及一个tomcat home
# HB_CATALINA_HOME
# HB_CATALINA_BASE_TAR
# 环境检查gcc make autoconf


if [[ ! ${HB_CATALINA_HOME} ]]; then
  HB_CATALINA_HOME=/usr/share/apache-tomcat-8.0.23
fi

if [[ ! ${HB_CATALINA_BASE_TAR} ]]; then
  HB_CATALINA_BASE_TAR=/usr/share/tomcat_base.tar.gz
fi

if [[ ! ${JAVA_HOME} ]]; then
    JAVA_HOME=/usr/lib/jvm/java-1.8.0
fi

# 准备一个脚本文件
function MakeTomcatScript(){
  # $1 用户 $2 home
  T_Base=$2/tomcat
  # s/要替换的字符串/新的字符串/g
  #  / 可以用其他字符代替 比如# @
  # https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html
  # +好像用得不是太利索 用\+代替, 抓取数据应该用\(\)  代替数据应该用\1
  # ""
  # "s/\(address=\).*/\1$1/"
  # "s/\(JAVA_HOME=\"\).*\"/\1/g"
  cp ${HB_CATALINA_HOME}/bin/tomcat.service /etc/systemd/system/tomcat_$1.service

  sed -i -e "s@#{JAVA_HOME}@"${JAVA_HOME}"@g"\
 -e "s@#{CATALINA_BASE}@"${T_Base}"@g"\
 -e "s@#{CATALINA_HOME}@"${HB_CATALINA_HOME}"@g"\
 -e "s@#{TOMCAT_USER}@"$1"@g"\
 -e "s@#{CWD}@"$2"@g"\
 /etc/systemd/system/tomcat_$1.service

 systemctl daemon-reload
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


NEWHOME=/run/${NAME}

# test script
# MakeTomcatScript
# exit 0

if [[ ! $NAME ]]; then
  echo "$0 --dev [name] [port] or $0 [name] [port]"
  exit 1
fi

if [[ ! $PORT ]]; then
  echo "$0 --dev [name] [port] or $0 [name] [port]"
  exit 1
fi

if [ $DEV == 1 -a $PORT -lt 10000 ]
then
  echo "the port($PORT) must great than 10000";
  exit 1;
fi

# echo $NAME $PORT $DEV ${HB_CATALINA_HOME} ${HB_CATALINA_BASE_TAR} ${NEWHOME}

# 检查tomcat服务器以及实例压缩包
if [ ! -e $HB_CATALINA_HOME -o ! -d $HB_CATALINA_HOME ]
then
  echo "${HB_CATALINA_HOME} do not exist."
  echo "echo 'export HB_CATALINA_HOME=' >> /etc/environment"
  echo "to set environment well."
  exit 1
fi

if [[ -z $JAVA_HOME || ! -e $JAVA_HOME || ! -d $JAVA_HOME ]]; then
  echo "${JAVA_HOME} do not exist."
  echo "echo 'export JAVA_HOME=' >> /etc/environment"
  echo "to set environment well."
  exit 1
fi

if [ ! -e ${HB_CATALINA_BASE_TAR} ]
then
  echo "${HB_CATALINA_BASE_TAR} do not exist."
  echo "echo 'export HB_CATALINA_BASE_TAR=' >> /etc/environment"
  echo "to set environment well."
  exit 1
fi

# 检查用户名是否可用
if [ -e ${NEWHOME} ]
then
  echo "${NEWHOME} already existing."
  exit 1
fi

# 如果存在/data1/projects 则创建在 /data1/projects/name_home
# 并且ln -s /data1/projects/name_home/tomcat ./tomcat
# 还有就是关于连接的。。
# 建立服务

# 新增用户
useradd -mr -d ${NEWHOME} -s /sbin/nologin -c "Project ${NAME} Account" ${NAME}
chmod -R g+rw ${NEWHOME}

# 解压缩 并且更名
tar zxvf ${HB_CATALINA_BASE_TAR} -C ${NEWHOME}
mv ${NEWHOME}/tomcat_home_template ${NEWHOME}/tomcat

# 默认关闭ajp，并且修改http port为指定值
sed -i -e "s@<Connector[ ]\+port=\"[0-9]\+\"[ ]\+protocol=\"AJP.*@"'<!-- Disable AJP port -->'"@g" ${NEWHOME}/tomcat/conf/server.xml
sed -i -e "s@\(port=\"\)[0-9]\+\(\"[ ]\+protocol=\"HTTP\)@\1$PORT\2@g" ${NEWHOME}/tomcat/conf/server.xml
# port="8006" shutdown="SHUTDOWN  这个有必要改么？

# 制作启动脚本 和后台运行脚本 需要了解如何将伪装一个其他用户的权限
# http://unix.stackexchange.com/questions/364/allow-setuid-on-shell-scripts
# 制作服务单元 /etc/systemd/system/tomcat_${NAME}.service
MakeTomcatScript ${NAME} ${NEWHOME}

# 给予组管理权
echo "" > /etc/sudoers.d/${NAME}
echo "%${NAME} ALL= NOPASSWD: /bin/systemctl start tomcat_${NAME}" >> /etc/sudoers.d/${NAME}
echo "%${NAME} ALL= NOPASSWD: /bin/systemctl stop tomcat_${NAME}" >> /etc/sudoers.d/${NAME}
echo "%${NAME} ALL= NOPASSWD: /bin/systemctl enable tomcat_${NAME}" >> /etc/sudoers.d/${NAME}
echo "%${NAME} ALL= NOPASSWD: /bin/systemctl disable tomcat_${NAME}" >> /etc/sudoers.d/${NAME}
echo "%${NAME} ALL= NOPASSWD: /usr/bin/cp ROOT.war ${NEWHOME}/tomcat/webapps/ROOT.war" >> /etc/sudoers.d/${NAME}

chown -R ${NAME}:${NAME} ${NEWHOME}
# ACL控制
setfacl -m group:${NAME}:rwx ${NEWHOME}
# if [[ ${DEV} -eq 1 ]]; then
# fi

# 将需要管理这个开发程序的人 加入到该组
AddProjectManager $NAME CJ
if [[ ${DEV} -eq 1 ]]; then
  AddProjectManager $NAME jenkins
fi

# 是否有必要创建资源文件夹
ResourceHome="/var/www/html/resources/"
unset ResourceCreated
if [[ -e $ResourceHome && -d $ResourceHome ]]; then
  mkdir ${ResourceHome}${NAME}
  ResourceCreated=true
  chown -R ${NAME}:${NAME} ${ResourceHome}${NAME}
fi

if [[ $DEV == 0 ]]; then
  echo "        Deploy Summary" > ${NEWHOME}/README
else
  echo "        Development Deploy Summary" > ${NEWHOME}/README
fi
echo "" >> ${NEWHOME}/README
echo "  Project Name:$NAME" >> ${NEWHOME}/README
echo "  Project Home:$NEWHOME" >> ${NEWHOME}/README
echo "  Tomcat Home:$NEWHOME/tomcat" >> ${NEWHOME}/README
IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
echo "  Project URL:http://$IP:$PORT/" >> ${NEWHOME}/README
if [[ $ResourceCreated == true ]]; then
  echo "  Resource URL:http://$IP/resources/$NAME" >> ${NEWHOME}/README
  echo "  Resource HOME:${ResourceHome}${NAME}" >> ${NEWHOME}/README
fi
echo "" >> ${NEWHOME}/README
echo "sudo systemctl start tomcat_${NAME} ; to start instance" >> ${NEWHOME}/README
echo "sudo systemctl stop tomcat_${NAME} ; to stop instance" >> ${NEWHOME}/README
echo "man systemctl for more." >> ${NEWHOME}/README

cat ${NEWHOME}/README
