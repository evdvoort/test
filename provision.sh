#!/bin/bash
#########################################################################################
#
# Usage:
#
#   provision.sh
#
# Description
#
#   Create data disks
#   yum update
#   
#
# When        Who        What
# 15-11-2018  EvdV,AMIS  - Create
#
#########################################################################################
# set -vx
#
# Variables

# Functions
#
#
# Main

# FDisk /dev/sdc
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdc
n
p
1


w
q
EOF

# FDisk /dev/sdc
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdd
n
p
1


w
q
EOF

# FDisk /dev/sdc
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sde
n
p
1


w
q
EOF

# Create PVs
pvcreate /dev/sdc1
pvcreate /dev/sdd1
pvcreate /dev/sde1

# Create VGs
vgcreate vol_data /dev/sdc1
vgcreate vol_wal /dev/sdd1
vgcreate vol_backup /dev/sde1

# Create LVs
lvcreate -l 100%FREE -n dat01 vol_data
lvcreate -l 100%FREE -n wal01 vol_wal
lvcreate -l 100%FREE -n bck01 vol_backup

# Create filesystems
mkfs.xfs /dev/vol_data/dat01
mkfs.xfs /dev/vol_wal/wal01
mkfs.xfs /dev/vol_backup/bck01

# Add to fstab
echo "/dev/mapper/vol_data-data01              /mnt/data              xfs     defaults       0 0" >> /etc/fstab
echo "/dev/mapper/vol_wal-wal01                /mnt/wal               xfs     defaults       0 0" >> /etc/fstab
echo "/dev/mapper/vol_backup-bck01             /mnt/backup            xfs     defaults       0 0" >> /etc/fstab

# Update OS
yum update -y

# Add alias
echo "alias influx=\"sudo docker exec -it influx influx\"" >> /etc/bashrc
