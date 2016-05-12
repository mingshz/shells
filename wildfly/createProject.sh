#!/bin/bash
# 创建项目
# createProject.sh --do {name} [port-offset] [domain] [default-web-module]

DRYRUN=true

if [[ $1 = "--do" ]]; then
  DRYRUN=false;
  shift
fi

NAME=$1
if [[ ! $NAME ]]; then
  echo "$0 --do {name} [port-offset] [domain] [default-web-module]"
  exit 1
fi
OFFSET=$2

MCPM=6666
JGROUPS=7600

if [[ $OFFSET && $OFFSET -ge 0 ]]; then
  let MCPM=${MCPM}+${OFFSET}
  let JGROUPS=${JGROUPS}+${OFFSET}
fi

# 内网网卡
IP=`ip addr | grep 'state UP' -A2 | head -n3 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

DOMAIN=$3
if [[ ! $DOMAIN ]]; then
  DOMAIN=localhost
fi

Content=$4
if [[ ! $Content ]]; then
  Content=ROOT.war
fi

if [[ ${DRYRUN} == true ]]; then
  echo "name=${NAME}"
  # echo "port.MCPM=${MCPM}"
  echo "port.jgroups-tcp=${JGROUPS}"
  echo "iaddress=${IP}"
  echo "domain.web=${DOMAIN}"
  echo "content.web=${Content}"
else
  # 获取当前文件夹
  SCRIPTPATH=`dirname "$0"`
  SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

  . $SCRIPTPATH/core.sh

  # port.MCPM $MCPM
  execCLI createProject.cli name $NAME iaddress $IP port.offset $OFFSET port.jgroups-tcp $JGROUPS domain.web ${DOMAIN} content.web ${Content}
  echo "$NAME-profile , $NAME-sockets, $NAME-group created. exec cli:"
  echo "/host=master/server-config=${NAME}xxx:add(group=${NAME}-group, auto-start=true, socket-binding-port-offset=$OFFSET)"
  echo "to create server at master; exec cli:"
  echo "/server-group=$NAME-group/system-property=[property-name]:add(value=\"[property-value]\")"
  echo "to add system property"
fi
