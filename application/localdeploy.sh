#!/bin/bash
# Authored By Cai Jiang
# 本地部署到 某文件
# usage: ./localdeploy file toFile

if [[ $1 == "/"* ]]; then
  war=$1
else
  PWD=`pwd`
  war=$PWD"/"$1
fi

echo "[CISHELL] deploying $war"
if [ ! -e $war -o ! -f $war -o ! -r $war ]
then
  echo "no $war found!"
  exit 0
fi

cp $war $2
return $?
