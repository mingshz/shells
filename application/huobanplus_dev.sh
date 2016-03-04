#!/bin/bash
# Authored By Cai Jiang
# 在开放环境中自动部署huobanplus的脚本，通常由CI调用
#
# 将webservice.war 复制到api.open.fancat.cn/JavaDevelopmentEnvironment/tomcat_dev/huobanplusapps/ROOT.war
#
# 环境中应当已经配置有ApiOpenFancatCnAccount 以及ApiOpenFancatCnPassword

#
PWD=`pwd`
war=$PWD"/webservice/target/ROOT.war"
if [ ! -e $war -o ! -f $war -o ! -r $war ]
then
  echo "no $war found!"
  exit 0
fi

# 如何输入密码？ 参考 http://www.stratigery.com/scripting.ftp.html
ftp -n api.open.fancat.cn <<EOF
quote USER $ApiOpenFancatCnAccount
quote PASS $ApiOpenFancatCnPassword
cd /JavaDevelopmentEnvironment/tomcat_dev/huobanplusapps/
bin
put $war ROOT.war
exit
EOF
