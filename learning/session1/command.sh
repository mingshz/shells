#!/bin/bash
DATE=`date`
echo "Date is $DATE"
USERS=`who | wc -l`
echo "Logged in user are $USERS"
UP=`date ; uptime`
echo "Uptime is $UP"

PWD=`pwd`
echo "current working: $PWD"

# 命令替换是指Shell可以先执行命令，将输出结果暂时保存，在适当的地方输出。
