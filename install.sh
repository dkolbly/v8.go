#!/bin/bash

# make sure go is installed
hash go 2>/dev/null || { echo "You need to install go." >&2 ; exit 1; }

# make sure subversion is installed
hash svn 2>/dev/null || { echo >&2 "You need to install Subversion client."; exit 1; }

# find download tool
download=''
if hash curl 2>/dev/null; then
	download='curl -o'
elif hash wget 2>/dev/null; then
	download='wget -O'
else
	echo >&2 "You need to install 'curl' or 'wget'."
	exit 1
fi

v8_version="3.25.28.12"
v8_path="v8-$v8_version"

# check v8 installation
need_v8='false'
if [ ! -d $v8_path ] || [ ! -d $v8_path/out/native/ ]; then
	need_v8='true'
else
	libv8_base="`find $v8_path/out/native/ -name 'libv8_base.*.a' | head -1`"
	libv8_snapshot="`find $v8_path/out/native/ -name 'libv8_snapshot.a' | head -1`"

	if [ libv8_base == '' ] || [ libv8_snapshot == '' ]; then
		need_v8='true'
	fi
fi

# download and build v8
if [ $need_v8 == 'true' ]; then
	# download
	if [ ! -f $v8_path.tar.gz ]; then
		$download $v8_path.tar.gz https://codeload.github.com/v8/v8/tar.gz/$v8_version
	fi
	tar -xzvf $v8_path.tar.gz

	# begin
	cd $v8_path

	# we don't need ICU library
	svn checkout --force http://gyp.googlecode.com/svn/trunk build/gyp --revision 1685

	# fix gcc 4.8 compile error
	gcc48=`gcc -v 2>&1 | tail -1 | grep "gcc [^0-9 ]\+ 4.8"`
	if [ ! "$gcc48" == ""  ]; then
		cp build/standalone.gypi build/standalone.gypi.bk
		patch build/standalone.gypi ../v8-for-go/gcc48.patch
	fi

	# build
	make ${MAKE_OPTIONS} i18nsupport=off native

	# end
	cd ..
fi

# check again
libv8_base="`find $v8_path/out/native/ -name 'libv8_base.*.a' | head -1`"
libv8_snapshot="`find $v8_path/out/native/ -name 'libv8_snapshot.a' | head -1`"
if [ libv8_base == '' ] || [ libv8_snapshot == '' ]; then
	echo >&2 "V8 build failed?"
	exit
fi

# for Linux
librt=''
if [ `go env | grep GOHOSTOS` == 'GOHOSTOS="linux"' ]; then
	librt='-lrt'
fi

# for Mac
libstdcpp=''
if  [ `go env | grep GOHOSTOS` == 'GOHOSTOS="darwin"' ]; then
	libstdcpp='-stdlib=libstdc++'
fi

echo "Name: v8
Description: v8 javascript engine
Version: $v8_version
Cflags: $libstdcpp -I`pwd` -I`pwd`/$v8_path/include
Libs: $libstdcpp `pwd`/$libv8_base `pwd`/$libv8_snapshot $librt" > v8.pc

go install

go test -bench="."
