#!/bin/bash
# Authored By Cai Jiang
# 增加指定项目的管理员

function AddProjectManager(){
# 第一个参数项目名称  第二个参数LOGIN
  if [[ ! $1 ]]; then
    echo "which project want be manage? "
    echo "$0 [project] [LOGIN]"
    exit 1
  fi
  if [[ ! $2 ]]; then
    echo 'which LOGIN want be manage?'
    echo "$0 [project] [LOGIN]"
    exit 1
  fi
  # 移除组请使用 usermod -G group1,group2 LOGIN
  # 比如 sudo usermod -G CJ,wheel,apache CJ
  # sudo usermod -G jenkins,root jenkins
  usermod -aG $1 $2
}

if [[ $0 == *"addprojectmanager.sh" ]]
then
  if [ $UID -ne 0 ]; then
      echo "Superuser privileges are required to run this script."
      echo "e.g. \"sudo $0\""
      exit 1
  fi
  AddProjectManager $1 $2
fi
