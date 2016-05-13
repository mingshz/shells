#!/bin/bash
# 执行初始化服务器的脚本

# TODO 用户

LBHost=$1
LBPort=$2

if [[ ! $LBHost || ! LBPort ]]; then
  echo "$0 LoadBalancerHost LoadBalancerPort";
  exit 1;
fi

# 获取当前文件夹
SCRIPTPATH=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

. $SCRIPTPATH/core.sh
. $SCRIPTPATH/modulemvncore.sh

. $SCRIPTPATH/jdbcmodule.sh

UpgradeModule 2.7.4 com fasterxml jackson core jackson-databind
UpgradeModule 2.7.4 com fasterxml jackson core jackson-core
UpgradeModule 2.7.4 com fasterxml jackson core jackson-annotations
UpgradeModule 1.3.1 com fasterxml classmate
# NAME=$1
# if [[ ! $NAME ]]; then
#   echo "$0 --dev [name] [port] or $0 [name] [port]"
#   exit 1
# fi

execCLI initmaster.cli LBHost $1 LBPort $2
