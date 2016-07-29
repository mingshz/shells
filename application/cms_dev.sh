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

# 找wildfly目录
# 获取当前文件夹
mypath=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

echo $SCRIPTPATH
. $SCRIPTPATH/../wildfly/core.sh

TMP="$(mktemp -q -t "$(basename "$0").XXXXXXXX" 2>/dev/null || mktemp -q)"
# 现在我们把脚本写到里面去
echo "deploy $war --name=web.war --runtime-name=web.war  --force" > $TMP
# cat $TMP
execCLI $TMP "10.24.145.73:9990"
rm $TMP

#
# if [[ ! $ApiOpenFancatCnAccount ]]; then
#   echo "set ApiOpenFancatCnAccount first"
#   exit 1
# fi
# if [[ ! $ApiOpenFancatCnPassword ]]; then
#   echo "set ApiOpenFancatCnPassword first"
#   exit 1
# fi
# # 如何输入密码？ 参考 http://www.stratigery.com/scripting.ftp.html
# ftp -n api.open.fancat.cn <<EOF
# quote USER $ApiOpenFancatCnAccount
# quote PASS $ApiOpenFancatCnPassword
# cd /JavaDevelopmentEnvironment/tomcat_dev/huobanplusapps/
# bin
# put $war ROOT.war
# exit
# EOF
