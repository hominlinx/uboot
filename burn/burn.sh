#!/bin/bash
set -e
if [ -z $1 ]
then
   echo "You should specify the device and kernel !"
   echo "Usage: sudo ./setup.sh device kernel"
   echo "Example: sudo ./setup.sh /dev/sdb HD-Elastos"
   exit 0
fi

#make uboot
make -C ../ CROSS_COMPILE=arm-linux-gnueabi-
#if make has error, exit
echo "=====>>>> make complite "$?

#convert the boot.txt to boot.scr
#mkimage -A arm -O linux -T script -C none -n "U-Boot commands" -d boot.txt boot.scr

#create a file named disk.img
dd if=/dev/zero of=disk.img bs=1M count=60

#repartition the file disk.img
sfdisk -uS --force disk.img << EOF
2048,,b,*
EOF

#copy the spl file into disk.img
dd if=u-boot-sunxi-with-spl.bin of=disk.img bs=1024 seek=8
#dd if=u-boot-sunxi-with-spl.bin of=$1 bs=1024 seek=8


#copy the image into the device
echo "wirting the img to the device, Please wait... "
dd if=disk.img of=$1 bs=1M
rm -r disk.img u-boot-sunxi-with-spl.bin
