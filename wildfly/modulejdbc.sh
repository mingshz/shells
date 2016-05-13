#!/bin/bash
# 这个脚本 会将jdbc加入到现有wildfly目录

if [[ ! ${WILDFLY_HOME} ]]; then
  # echo "${WILDFLY_HOME} do not exist."
  echo "echo 'export WILDFLY_HOME=' >> /etc/environment"
  echo "to set environment well."
  exit 1
fi


if [[ ! ${HB_CATALINA_HOME} ]]; then
  # echo "${WILDFLY_HOME} do not exist."
  echo "echo 'export HB_CATALINA_HOME=' >> /etc/environment"
  echo "to set environment well."
  exit 1
fi

# 1 jarFile mysql-connector-java-5.1.32.jar
# 2.. packages..
function SetupJdbc(){
  if [[ ! -e ${HB_CATALINA_HOME}/lib/$1 ]]; then
    echo "${HB_CATALINA_HOME}/lib/$1 is not exsting."
    exit 1
  fi
  JarName=$1
  PackagePath=$2/
  PackageName=$2
  while [[ $3 ]]; do
    # echo $PackageName $PackagePath
    PackagePath=$PackagePath$3/
    PackageName=${PackageName}.$3
    shift
  done

  # echo $PackageName $PackagePath
  ModulePath=${WILDFLY_HOME}/modules/system/layers/base/${PackagePath}main

  if [[ -e $ModulePath ]]; then
    echo "$ModulePath existing. skipping."
    return
  fi

  PRE=""
  if [[ $WILDFLY_USER ]]; then
    PRE="sudo runuser -u $WILDFLY_USER "
  fi
  $PRE mkdir -p $ModulePath
  $PRE cp ${HB_CATALINA_HOME}/lib/$JarName $ModulePath/

  $PRE echo -e "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<module xmlns=\"urn:jboss:module:1.3\" name=\"$PackageName\">\n\
  <resources>\n\
    <resource-root path=\"$JarName\"/>\n\
  </resources>\n\
  <dependencies>\n\
    <module name=\"javax.api\"/>\n\
    <module name=\"javax.transaction.api\"/>\n\
    <module name=\"javax.servlet.api\" optional=\"true\"/>\n\
  </dependencies>\n\
</module>\n\
\n\
"\
  > $ModulePath/module.xml
  echo "setup into $ModulePath"
}

# 只有不存在才会干
SetupJdbc mysql-connector-java-5.1.32.jar com mysql jdbc
SetupJdbc jtds-1.3.1.jar net sourceforge jtds jdbc
SetupJdbc sqljdbc4.jar com microsoft sqlserver jdbc

# https://repo1.maven.org/maven2/
