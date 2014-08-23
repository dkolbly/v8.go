#! /bin/bash

v8_version="3.25.28.12"
v8_path="v8-$v8_version"

echo "** Downloading v8 ${v8_version}"

curl -o $v8_path.tar.gz https://codeload.github.com/v8/v8/tar.gz/$v8_version
tar -xzvf $v8_path.tar.gz
cd $v8_path

# we don't need ICU library
echo "** Checking out gyp"
svn checkout -q --force http://gyp.googlecode.com/svn/trunk build/gyp --revision 1685

# fix gcc 4.8 compile error
gcc48=`gcc -v 2>&1 | tail -1 | grep "gcc [^0-9 ]\+ 4.8"`
if [ ! "$gcc48" == ""  ]; then
    cp build/standalone.gypi build/standalone.gypi.bk
    patch build/standalone.gypi ../gcc48.patch
fi

# build
echo "** Compiling v8"
make ${MAKE_OPTIONS} i18nsupport=off native
