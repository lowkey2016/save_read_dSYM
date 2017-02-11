#!/bin/sh

toHex()
{
	str=$1
	# 取开头2个字符
	sub_str=`echo ${str}|awk '{print substr($0,1,2)}'`
	# 如果不是16进制数就将其转换
	if [ "$sub_str"x != "0x"x ]; then
		# 去掉字符串中的'0x'
		str=`echo ${str}|sed s/0x//g`
		echo "ibase=10;obase=16;$str"|bc
		return
	fi
	echo ${str}|sed s/0x//g
}

hexAdd()
{
	str1=$1
	str2=$2
	str1=`echo ${str1}|sed s/0x//g|tr '[a-z]' '[A-Z]'`
	str2=`echo ${str2}|sed s/0x//g|tr '[a-z]' '[A-Z]'`
	
	ret=`echo "ibase=obase=16;${str1} + ${str2}"|bc`
	echo "0x"${ret}
}

help()
{
	echo "in your dsym directory,and press under it:"
	echo "usage:read.sh [arch] [stack address]"
	echo "sample:read.sh armv7 19352"
	exit
}

# 如果传入的参数不是2个，就显示帮助菜单
if [ $# != 2 ]; then
	help
fi
if [ $1 == "--help" ]; then
	help
fi

ARCH=$1
CODE=$2

# 判断输入的架构是否正确
if [ $ARCH != "armv7" -a $ARCH != "armv7s" -a $ARCH != "armv6" -a $ARCH != "arm64" ]; then
	echo "arch is error,must be armv7s/armv7/armv6/arm64"
	help
	exit
fi

# 结果例如：./H5GameCenter.app
APPPATH=`find . -name "*.app" -maxdepth 1`
# awk -F'/' 表示以'/'为分隔符
# 下面的语句把 H5GameCenter 提取出来
APPNAME=`echo $APPPATH|awk -F'/' '{print $2}'|sed s/\.app//g`
# dSYM的文件名可以通配（因为 auto_save_dsym.sh 脚本保存的文件名如：H5GameCenter2015xxxx.app.dSYM）
DSYMNAME="${APPNAME}*.app.dSYM"

# 判断 dSYM 文件和 .app 文件的 uuid 是否对应
APP_MACH_O_UUID=`dwarfdump --uuid ${APPNAME}.app/${APPNAME} | awk '{print $2}'`
APP_DSYM_UUID=`dwarfdump --uuid ${DSYMNAME} | awk '{print $2}'`
if [ "${APP_MACH_O_UUID}" != "${APP_DSYM_UUID}" ]; then
    echo "UUIDs of Mach-O and dSYM not match"
    exit
fi
echo "UUIDs matched: "
dwarfdump --uuid ${APPNAME}.app/${APPNAME}

CODE=`toHex $CODE`
cd $APPPATH
SLIDE=`otool -arch ${ARCH} -l ./"$APPNAME"| grep -B 3 -A 8 -m 2 "__TEXT"|grep vmaddr|awk '{print $2}'`
SLIDE=`toHex $SLIDE`
SYMBOLADDR=`hexAdd $CODE $SLIDE`

cd -
echo "dwarfdump --lookup ${SYMBOLADDR} --arch ${ARCH} ${DSYMNAME}"|sh
