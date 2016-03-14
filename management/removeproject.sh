#!/bin/bash
# Authored By Cai Jiang
# 移除一个项目 包括这个组 以及相关的一些文件
# ./removeproject.sh [name] 只是预览即将执行的指令
# 只有
# ./removeproject.sh --do [name] 才会真的删除项目

# 从用户组中移除一个组
# RemoveGroupFromUser [GROUP] [LOGIN]
function RemoveGroupFromUser(){
  echo $1 $2
  GroupName=`groups $2|cut -f2 -d':'|sed 's/[ \t]*$//'|sed 's/^[ \t]*//'|cut -f1 -d' '`
  VAR=1
  while [[ -n $GroupName ]]; do
    if [[ $? != 0 ]]; then
      echo "failed."
      exit $?
    fi
    GroupNames[$[ VAR - 1 ]]=$GroupName
    VAR=$[ VAR + 1 ]
    echo ${GroupNames[@]}
    GroupName=`groups $2|cut -f2 -d':'|sed 's/[ \t]*$//'|sed 's/^[ \t]*//'|cut -f$VAR -d' '`
  done
}

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

DOIT=false
# 参数处理
if [[ $1 = '--do' ]]; then
  shift
  DOIT=true
fi
NAME=$1

if [[ -z $NAME  ]]; then
  echo "Bad command."
  echo "use $0 [name]; to preview commands, or "
  echo "use $0 --do [name]; to remove project."
  exit 1
fi

# echo "checking $NAME"
# 校验项目是否存在

# 获取该组的所有成员 到 UserNames
VAR=1
UserName=`cat /etc/group | grep "^$NAME:" | cut -f4 -d':' | cut -f$VAR -d','`
while [[ -n $UserName ]]; do
  if [[ $? != 0 ]]; then
    echo "failed."
    exit $?
  fi
  UserNames[$[ VAR - 1 ]]=$UserName
  VAR=$[ VAR + 1 ]
  UserName=`cat /etc/group | grep "^$NAME:" | cut -f4 -d':' | cut -f$VAR -d','`
done

# echo ${#UserNames[@]} ${UserNames[*]}

for UserName in ${UserNames[@]}
do
    RemoveGroupFromUser $NAME $UserName
done
