#!/bin/bash
# 增加数据源
# addds.sh XA|NOXA mysql|jtds|sqlserver host port databaseName user password [profile|S for Standlone mode] [driver]
# driver for install driver
XA=false

if [[ $1 = "XA" ]]; then
  XA=true
fi
jdbc=$2
host=$3
port=$4
databaseName=$5
user=$6
password=$7
profileName=$8
installDriver=$9
if [[ ! $jdbc || ! $host || ! $port || ! $databaseName || ! $user || ! $password ]]; then
  echo "$0 XA|NOXA mysql|jtds|sqlserver host port databaseName user password [profile|S for Standlone mode] [driver]"
  exit 1
fi

if [[ ! $profileName ]]; then
  echo "input profile name to add Datasource:(Keep empty for Standlone mode)"
  read profileName
  echo $profileName
fi
if [[ ! $profileName || $profileName = "" || $profileName = "S" ]]; then
  WD="/"
else
  WD="/profile="$profileName
fi

toAddJdbc=false
if [[ ! $installDriver = "driver" ]]; then
  echo "add driver first?(y/n):"
  read toAddJdbcYN
  if [[ $toAddJdbcYN = "y" ]]; then
    toAddJdbc=true
  else
    toAddJdbc=false
  fi
else
  toAddJdbc=true
fi

# 获取当前文件夹
SCRIPTPATH=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

. $SCRIPTPATH/core.sh

if [[ $toAddJdbc = true ]]; then
  case $jdbc in
    mysql )
      execCLI adddriver.cli WD $WD name $jdbc module com.mysql.jdbc driverClassName com.mysql.jdbc.Driver xadsClassName com.mysql.jdbc.jdbc2.optional.MysqlXADataSource
      ;;
    jtds )
      execCLI adddriver.cli WD $WD name $jdbc module net.sourceforge.jtds.jdbc driverClassName net.sourceforge.jtds.jdbc.Driver xadsClassName net.sourceforge.jtds.jdbcx.JtdsDataSource
      ;;
    sqlserver )
      execCLI adddriver.cli WD $WD name $jdbc module com.microsoft.sqlserver.jdbc driverClassName com.microsoft.sqlserver.jdbc.SQLServerDriver xadsClassName com.microsoft.sqlserver.jdbc.SQLServerXADataSource
      ;;
    * )
    echo "$jdbc not support yet."
    exit 1
    ;;
  esac

  # execCLI initmaster.cli
fi
