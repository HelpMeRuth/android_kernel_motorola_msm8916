### HelpMeRuth (jukeboxruthger1@gmail.com)

### Made universal for everyone.

set -e


KERNEL_DIR=$PWD
TOOLCHAINDIR=../Toolchain
## Place your toolchain in ../Toolchain dir.
if [ ! -d $TOOLCHAINDIR ]
then
echo "**** Making /Toolchain directory ****"
echo "**** Place your toolchain in it! ****"
echo "##STOPPED COMPILING"
mkdir $TOOLCHAINDIR
exit
else
echo "**** /Toolchain present ****"
echo " "
fi
TC=$(ls ../Toolchain/)
echo $TOOLCHAINDIR
DEVICE=osprey
KERNEL_TOOLCHAIN=/home/ruthger/raid/Toolchaind/toolchain/bin/arm-eabi-
KERNEL_DEFCONFIG="$DEVICE"_defconfig
BUILDS=../Builds
JOBS=8
VERSION=0


# The MAIN Part
echo "**** Toolchain set to $TC ****"
echo " "
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
export ARCH=arm
export SUBARCH=arm

echo "**** clean af ****"
#make mrproper
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f cwm_flash_zip/boot.img
rm -f cwm_flash_zip/*.zip

echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
make $KERNEL_DEFCONFIG

# Time for dtb
echo "**** Building Everything ****"
make -j$JOBS CONFIG_NO_ERROR_ON_MISMATCH=y zImage
make -j$JOBS CONFIG_NO_ERROR_ON_MISMATCH=y dtimage
make -j$JOBS modules

echo "**** Verify zImage,dtb & wlan ****"
ls $KERNEL_DIR/arch/arm/boot/zImage
ls $KERNEL_DIR/arch/arm/boot/dt.img
ls $KERNEL_DIR/drivers/staging/prima/wlan.ko

echo "**** Making kernel_install ****"
rm -rf kernel_install
mkdir -p kernel_install

echo "**** Making final wlan.ko ****"
make -j$JOBS modules_install INSTALL_MOD_PATH=kernel_install INSTALL_MOD_STRIP=1
mkdir -p cwm_flash_zip/system/lib/modules/pronto
find kernel_install/ -name '*.ko' -type f -exec cp '{}' cwm_flash_zip/system/lib/modules/ \;

echo "**** Moving modules ****"
mv cwm_flash_zip/system/lib/modules/wlan.ko cwm_flash_zip/system/lib/modules/pronto/pronto_wlan.ko
echo "**** Copying zImage ****"
cp arch/arm/boot/zImage cwm_flash_zip/tools/
echo "**** Copying dtb ****"
cp arch/arm/boot/dt.img cwm_flash_zip/tools/

## Set build number
echo "**** Setting Build Number ****"
NUMBER=$(cat number)
INCREMENT=$(expr $NUMBER + 1)
echo $INCREMENT > tmp
cat tmp > number
rm tmp
FINAL_KERNEL_ZIP=SomeFeak-$DEVICE-build$INCREMENT-R$VERSION-$DATE.zip

## Make sure we have a map for output zip
if [ ! -d "$BUILDS" ]
then
echo "**** Making /Builds directory ****"
  mkdir $BUILDS

chmod 777 $BUILDS
else
echo "**** Build directory is present ****"
fi

echo "**** Time to zip up! ****"
cd cwm_flash_zip
zip -r ./$FINAL_KERNEL_ZIP ./
cd ..
cd ..
echo $FINAL_KERNEL_ZIP
cp $KERNEL_DIR/cwm_flash_zip/$FINAL_KERNEL_ZIP Builds/$FINAL_KERNEL_ZIP

echo "**** Good Bye!! ****"
cd $KERNEL_DIR
