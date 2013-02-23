#!/bin/bash

BASEDIR="/home/cocafe/Android/CoCore-P/"

OUTDIR="$BASEDIR/out"

INITRAMFSDIR="$BASEDIR/ramdisk-twrp2.2"

CONFIG="u8500_CoCore-P_defconfig"

TOOLCHAIN="/home/cocafe/Android/toolchains/arm-eabi-4.4.3/bin/arm-eabi-"

#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-eabi-linaro-4.4.5/bin/arm-eabi-"
#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-eabi-linaro-4.5.4/bin/arm-eabi-"
#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-"

#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-2009q3/bin/arm-none-eabi-"
#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-2010q1/bin/arm-none-eabi-"
#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-2010.09/bin/arm-none-eabi-"
#TOOLCHAIN="/home/cocafe/Android/toolchains/arm-2012.09/bin/arm-none-eabi-"

STARTTIME=$SECONDS

cd kernel

case "$1" in

	clean)
		echo -e "\n\n Cleaning Kernel Sources... \n\n"
		make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		rm -rf ${INITRAMFSDIR}/lib
		rm -rf ${OUTDIR}
		ENDTIME=$SECONDS
		echo -e "\n\n Finished in $((ENDTIME-STARTTIME)) Seconds\n\n"
		;;

	modules)
		echo -e "\n\n Compiling Kernel Modules... \n\n"
		make $CONFIG ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		make modules ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR
		;;

	makeconfig)
		echo -e "\n\n Generating .config ... \n\n"
		make $CONFIG ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		;;

	*)
		echo -e "\n\n Configuring I9070 Kernel... \n\n"
		make $CONFIG ARCH=arm CROSS_COMPILE=$TOOLCHAIN

		echo -e "\n\n Compiling I9070 Kernel and Modules... \n\n"
		make -j3 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR

		echo -e "\n\n Copying Modules to InitRamFS Folder...\n\n"
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/bluetooth/bthid
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/net/wireless/bcm4330
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/j4fs
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/param
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/scsi

		cp drivers/bluetooth/bthid/bthid.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/bluetooth/bthid/bthid.ko
		cp drivers/net/wireless/bcm4330/dhd.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/net/wireless/bcm4330/dhd.ko
		cp drivers/samsung/param/param.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/param/param.ko
		cp drivers/scsi/scsi_wait_scan.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/scsi/scsi_wait_scan.ko
		cp drivers/samsung/j4fs/j4fs.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/j4fs/j4fs.ko
		cp drivers/staging/android/logger.ko $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/logger.ko

#		echo -e "\n Changing Modules Modes... \n"
#		chmod 0644 $INITRAMFSDIR/lib/modules/*
#		ls -l $INITRAMFSDIR/lib/modules

		echo -e "\n\n Creating zImage... \n\n"
		make ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR zImage

		mkdir -p ${OUTDIR}
		cp arch/arm/boot/zImage ${OUTDIR}/kernel.bin
		cp fs/cifs/cifs.ko ${OUTDIR}/cifs.ko

		echo -e "\n\n Pushing Kernel to OUT folder... \n\n"
		pushd ${OUTDIR}
		md5sum -t kernel.bin >> kernel.bin
		mv kernel.bin kernel.bin.md5

		md5sum -t kernel.bin.md5 >> md5.txt

		popd

                ENDTIME=$SECONDS
                echo -e "\n\n = Finished in $((ENDTIME-STARTTIME)) Seconds =\n\n"
		;;

esac
