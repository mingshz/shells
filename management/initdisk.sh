#!/bin/bash
# Authored By Cai Jiang
# 初始化一个CentOS 服务器
# 该脚本负责初始化 硬盘以及虚拟内存
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

DISKFILE=$1

if [[ ! $DISKFILE ]]; then
  echo "$0 [Device]"
  exit 1
fi

# DISKFILE必须是一个设备
if [[ ! -b $DISKFILE ]]; then
  echo "$0 [Device]"
  echo "Device must be a disk file. check ls /dev for details."
  exit 1
fi

fdisk $DISKFILE<<EOF
n
p
1


t
8e
w
EOF

VOLUME=`lvm lvmdiskscan | grep $DISKFILE | awk '{print $1}'`
# 获得这个新硬盘的大小，以GIB为单位
BIG=`lvm lvmdiskscan | grep $VOLUME | grep -oP "\d+(.\d+)?[[:space:]]+GiB" | cut -f1 -d' ' | cut -f1 -d'.'`
if [[ ! $BIG ]]; then
  echo "failed to know length of ${VOLUME}"
  exit 1
fi

# free to get total memory
Memory=`free -g | grep Mem | awk '{print $2}'`

# 计划设置一块跟物理内存一样的虚拟内存
echo ${VOLUME}
echo ${BIG}
if [[ ${BIG} -le ${Memory} ]]; then
  echo "length of ${DISKFILE} is too small to use."
  exit 1
fi

lvm pvcreate ${VOLUME}

LastVGIndex=`lvm vgs | tail -n1 | grep found`

if [[ ! $LastVGIndex ]]; then
  NewlyVGName="VG0"
else
  LastVGIndex=`lvm vgs | tail -n1 | awk '{print $1}' | grep -oP "\d+"`
  NewlyVGName="VG${LastVGIndex+1}"
fi

# Now, another LVM command to create a LVM volume group (VG) called vg0 with a
# physical extent size (PE size) of 16MB:
lvm vgcreate -s 16M $NewlyVGName ${VOLUME}

# Create a 10GB logical volume (LV)
lvm lvcreate -L ${Memory}G -n ${NewlyVGName}SWAP $NewlyVGName
# 检查剩余空间
OTHER=`lvm vgs | tail -n1 | awk '{print $7}'`

lvm lvcreate -L $OTHER -n ${NewlyVGName}DATA $NewlyVGName

SWAPPATH=`lvm lvdisplay | grep Path.*${NewlyVGName}SWAP | awk '{print $3}'`
DATAPATH=`lvm lvdisplay | grep Path.*${NewlyVGName}DATA | awk '{print $3}'`

# data
# 建立data文件夹 从索引1开始
for dataIndex in 1 2 3 4 5 6 7 8 9
do
  if [[ ! -d /data${dataIndex} ]]; then
    NewlyData=/data${dataIndex}
    break
  fi
done

if [[ ! $NewlyData ]]; then
  echo "failed to create new data folder."
  exit 1
fi

mkfs.ext3 $DATAPATH
mkdir $NewlyData
mount $DATAPATH $NewlyData
echo "$DATAPATH $NewlyData    ext3    defaults     0 0" >> /etc/fstab

# swap
mkswap $SWAPPATH
echo "$SWAPPATH      swap     swap    defaults     0 0" >> /etc/fstab
swapon -va
