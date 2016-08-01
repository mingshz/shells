#!/bin/bash
# Authored By Cai Jiang
# 在开放环境中自动部署cms的脚本，通常由CI调用，调用该脚本需在cms项目主目录中
# CI必须拥有wildfly安装目录
#
#
# 环境中应当已经配置有WILDFLY_HOME_MANAGEMENT_USER WILDFLY_HOME_MANAGEMENT_PASSWORD

#
PWD=`pwd`
LSTargetWar=`ls web/target/*.war`
war=$PWD"/"$LSTargetWar
echo "[CISHELL] deploying $war"
if [ ! -e $war -o ! -f $war -o ! -r $war ]
then
  echo "no $war found!"
  exit 1
fi

# 需要信任
sftp deploy@120.25.96.16 <<EOF
cd /home/cmstest/tomcat/webapps
put $war ROOT.war
exit
EOF
