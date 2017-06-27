#!/bin/bash
# Authored By Cai Jiang
# 移除一个项目 包括这个组 以及相关的一些文件
# ./removeproject.sh [name] 只是预览即将执行的指令
# 只有
# ./removeproject.sh --do [name] 才会真的删除项目

# 从用户组中移除一个组
# RemoveGroupFromUser [GROUP] [LOGIN]

DOIT=false

function RemoveGroupFromUser(){
  # echo $1 $2
  unset GroupNames
  GroupName=`groups $2 | cut -f2 -d':' | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | cut -s -f1 -d' '`
  if [[ -n $GroupName ]]; then
    # 进入循环
    VAR=1

    while [[ -n $GroupName ]]; do
      if [[ $? != 0 ]]; then
        echo "failed."
        exit $?
      fi
      GroupNames[$[ VAR - 1 ]]=$GroupName
      VAR=$[ VAR + 1 ]
      # echo ${GroupNames[@]}
      GroupName=`groups $2 | cut -f2 -d':' | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | cut -s -f$VAR -d' '`
    done
  else
    GroupNames[0]=`groups $2 | cut -f2 -d':' | sed 's/[ \t]*$//' | sed 's/^[ \t]*//'`
  fi


  # 组织命令
  TCMD="usermod -G "
  COMMAED=false
  for GroupName in ${GroupNames[@]}
  do
      if [[ $GroupName != $2 && $GroupName != $1 ]]; then
        if [[ $COMMAED == false ]]; then
          COMMAED=true
        else
          TCMD=$TCMD","
        fi
        TCMD=$TCMD$GroupName
      fi
  done
  if [[ $TCMD = "usermod -G " ]]; then
    TCMD=$TCMD'""'
  fi
  TCMD=$TCMD" $2"
  if [[ $DOIT == true ]]; then
    `$TCMD`
  else
    echo $TCMD
  fi
}

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi


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
NEWHOME=`cat /etc/passwd | grep "^$NAME:" | cut -f6 -d':'`
if [[ -z $NEWHOME || ! -e $NEWHOME ]]; then
  echo "no project $NAME existing."
  exit 1
fi

# 获取该组的所有成员 到 UserNames
# 如果只有一个呢？
unset UserNames
VAR=1
UserName=`cat /etc/group | grep "^$NAME:" | cut -f4 -d':' | cut -s -f$VAR -d','`
if [[ -n $UserName ]]; then
  # 说明存在分组 进入循环
  # echo "start" $UserName
  while [[ -n $UserName ]]; do
    if [[ $? != 0 ]]; then
      echo "failed."
      exit $?
    fi
    UserNames[$[ VAR - 1 ]]=$UserName
    VAR=$[ VAR + 1 ]
    UserName=`cat /etc/group | grep "^$NAME:" | cut -f4 -d':' | cut -s -f$VAR -d','`
    # echo "start2" $UserName $VAR
  done
else
  UserNames[0]=`cat /etc/group | grep "^$NAME:" | cut -f4 -d':'`
fi

# echo ${#UserNames[@]} ${UserNames[*]}

for UserName in ${UserNames[@]}
do
    RemoveGroupFromUser $NAME $UserName
done

ResourceHome="/var/www/html/resources/"$NAME
if [[ -e $ResourceHome && -d $ResourceHome ]]; then
  TCMD="rm -rf $ResourceHome"
  if [[ $DOIT == true ]]; then
    `$TCMD`
  else
    echo $TCMD
  fi
fi

TCMD="userdel -r $NAME"
if [[ $DOIT == true ]]; then
  `$TCMD`
else
  echo $TCMD
fi

TCMD="systemctl disable tomcat_$NAME"
if [[ $DOIT == true ]]; then
  `$TCMD`
else
  echo $TCMD
fi

TCMD="systemctl stop tomcat_$NAME"
if [[ $DOIT == true ]]; then
  `$TCMD`
else
  echo $TCMD
fi

TCMD="rm /etc/systemd/system/tomcat_$NAME.service"
if [[ $DOIT == true ]]; then
  `$TCMD`
else
  echo $TCMD
fi

TCMD="rm /etc/sudoers.d/${NAME}"
if [[ $DOIT == true ]]; then
  `$TCMD`
else
  echo $TCMD
fi
