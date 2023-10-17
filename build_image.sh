#!/usr/bin/env bash

SFLAG=
AFLAG=
BFLAG=

APP="base_rak_rak7268v2"
IMAGE_SUFFIX=
BUILD_TIME=`date +%s`

REPO_PATH=$(pwd)
VERSION="23.05"
OPENWRT_PATH="openwrt"

while getopts 'a:seh' OPTION
do
	case $OPTION in
	a)	
		AFLAG=1
		APP="$OPTARG"
		;;
	e)	
		EFLAG=1
		;;
	s)	
		SFLAG=1
		;;
	h|?)	printf "Build Image for Caipirinha\n\n"
		printf "Usage: %s [-p <openwrt_source_path>] [-a <application>] [-s] \n" $(basename $0) >&2
		printf "	-a: application file to build\n"
		printf "	-s: build in singe thread\n"
		printf "	-e: set config only\n"
		printf "\n"
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

BUILD=$APP-$VERSION
BUILD_TIME="`date`"

echo "Rollback previously applied patches"
cd $OPENWRT_PATH && quilt pop -a
cd $REPO_PATH
echo "Switching configuration"
rm -f conf/files conf/patches conf/.config
ln -s $APP/files conf/files
ln -s $APP/patches conf/patches
ln -s $APP/.config conf/.config

echo "***Entering build directory***"
cd $OPENWRT_PATH
echo "Applying patches"
quilt push -a
make defconfig

if [ ! -z $EFLAG ];then
	echo "***Only updated config***"
	exit
fi

echo ""
echo "***Update build version and build date***"
echo "Build: $BUILD"
echo "Build time: $BUILD_TIME"
echo ""

echo ""
if [ ! -z $SFLAG ];then
	echo "***Run make for single thread ***"
	make -s V=99
else
	echo "***Run make"
	make -j $(($(nproc)+1)) download world
fi

