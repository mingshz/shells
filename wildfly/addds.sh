#!/bin/bash
# 增加数据源
# addds.sh XA|NOXA mysql|jtds|sqlserver name jndi host port databaseName user password [profile|S for Standlone mode] [driver]
# driver for install driver
XA=false

if [[ $1 = "XA" ]]; then
  XA=true
fi
jdbc=$2
dsName=$3
jndi=$4
host=$5
port=$6
databaseName=$7
user=$8
password=$9
profileName=${10}
installDriver=${11}
if [[ ! $jdbc || ! $host || ! $port || ! $databaseName || ! $user || ! $password || ! $dsName || ! $jndi ]]; then
  echo "$0 XA|NOXA mysql|jtds|sqlserver name jndi host port databaseName user password [profile|S for Standlone mode] [driver]"
  exit 1
fi

if [[  ${jndi:0:6} != 'java:/' ]]; then
  echo "JNDI-name should begin as java:/. $jndi is bad jndi."
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
mypath=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

if [[ ! -e $SCRIPTPATH/$jdbc ]]; then
  echo "$jdbc not support yet."
  exit 1
fi

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

fi

if [[ $XA = true ]]; then
  cliFile=$jdbc/XA.cli
else
  cliFile=$jdbc/NOXA.cli
fi

# java:/
# echo WD $WD name $dsName jndi $jndi jdbc $jdbc host $host port $port databaseName $databaseName username $user password $password

execCLI $cliFile WD $WD name $dsName jndi $jndi jdbc $jdbc host $host port $port databaseName $databaseName username $user password $password
