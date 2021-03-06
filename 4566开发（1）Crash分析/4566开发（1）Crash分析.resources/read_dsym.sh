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
# 拼凑路径：APPPATH/APPNAME
# APP=`echo $APPPATH|awk '{print $0"/"app_name}' app_name=${APPNAME}`

CODE=`toHex $CODE`
cd $APPPATH
SLIDE=`otool -arch ${ARCH} -l ./"$APPNAME"| grep -B 3 -A 8 -m 2 "__TEXT"|grep vmaddr|awk '{print $2}'`
SLIDE=`toHex $SLIDE`
SYMBOLADDR=`hexAdd $CODE $SLIDE`

cd -
echo "dwarfdump --lookup ${SYMBOLADDR} --arch ${ARCH} ${APPNAME}.app.dSYM"|sh

