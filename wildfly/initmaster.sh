#!/bin/bash
# 执行初始化服务器的脚本

# TODO 用户
# TODO jdbc

# 获取当前文件夹
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. $SCRIPTPATH/core.sh

# NAME=$1
# if [[ ! $NAME ]]; then
#   echo "$0 --dev [name] [port] or $0 [name] [port]"
#   exit 1
# fi

execCLI initmaster.cli
