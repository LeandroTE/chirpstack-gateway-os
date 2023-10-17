#!/usr/bin/env bash
#Set up build environment for Dragino v2. Only need to run once on first compile. 

OPENWRT_PATH=openwrt

while getopts 'p:v:sh' OPTION
do
	case $OPTION in
	p)	OPENWRT_PATH="$OPTARG"
		;;
	h|?)	printf "Set Up OpenWrt environment \n\n"
		printf "Usage: %s [-p <openwrt_source_path>]\n" $(basename $0) >&2
		printf "	-p: set up build path, default path = openwrt\n"
		printf "\n"
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

REPO_PATH=$(pwd)

echo "*** Copy feeds to openwrt ***"
cp feeds.conf.default $OPENWRT_PATH/feeds.conf.default

echo "*** Create symbolic links ***"
rm -r openwrt/.config
rm -r openwrt/files
ln -s ../conf/.config openwrt/.config
ln -s ../conf/files openwrt/files

echo " "
echo "*** Update/Install the feeds"
sleep 2
$OPENWRT_PATH/scripts/feeds update -a
$OPENWRT_PATH/scripts/feeds install -a
sleep 2
echo " "

echo "*** start patches"
quilt init
echo "End of script"
