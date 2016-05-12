#!/bin/bash
# 执行初始化服务器的脚本

# TODO 用户
# TODO jdbc

# 获取当前文件夹
SCRIPTPATH=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

. $SCRIPTPATH/core.sh
. $SCRIPTPATH/jdbcmodule.sh
# NAME=$1
# if [[ ! $NAME ]]; then
#   echo "$0 --dev [name] [port] or $0 [name] [port]"
#   exit 1
# fi

execCLI initmaster.cli
