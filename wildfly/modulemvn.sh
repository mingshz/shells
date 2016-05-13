#!/bin/bash

SCRIPTPATH=`dirname "$0"`
SCRIPTPATH=`exec 2>/dev/null;(cd -- "$mypath") && cd -- "$mypath"|| cd "$mypath"; unset PWD; /usr/bin/pwd || /bin/pwd || pwd`

. $SCRIPTPATH/modulemvncore.sh

UpgradeModule $*
