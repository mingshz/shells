#!/bin/bash
# 从maven中更新一个库到module
# 不支持添加！ 只支持更新

# 1 version
# packages...
function UpgradeModule(){
  if [[ ! ${WILDFLY_HOME} ]]; then
    # echo "${WILDFLY_HOME} do not exist."
    echo "echo 'export WILDFLY_HOME=' >> /etc/environment"
    echo "to set environment well."
    exit 1
  fi
  Version=$1
  PackagePath=$2/
  PackageName=$2
  artifactId=$2
  while [[ $3 ]]; do
    # echo $PackageName $PackagePath
    PackagePath=$PackagePath$3/
    PackageName=${PackageName}.$3
    artifactId=$3
    shift
  done

  if [[ ! $Version || ! $PackageName || ! $PackagePath ]]; then
    echo "not enough arguments."
    echo "UpgradeModule version packages...."
    exit 1
  fi

  ModulePath=${WILDFLY_HOME}/modules/system/layers/base/${PackagePath}main
  if [[ ! $MavenRepoURL ]]; then
    MavenRepoURL=https://repo1.maven.org/maven2/
  fi

  if [[ ! -e $ModulePath ]]; then
    echo "upgrade support only!"
    return
  fi

  MVNURL=$MavenRepoURL${PackagePath}$Version/$artifactId-$Version.jar
  JarPath=$ModulePath/$artifactId-$Version.jar

  if [[ -e $JarPath ]]; then
    echo "$JarPath is existing, skipping upgrade."
    return
  fi

  wget -O $JarPath $MVNURL

  if [[ $? != 0 ]]; then
    echo "failed download $MVNURL"
    rm -f $JarPath
    return
  fi

  sed -i -e "s/$artifactId.*.jar/$artifactId-$Version.jar/g" $ModulePath/module.xml
  echo "Upgraded! check $ModulePath/module.xml"
}
