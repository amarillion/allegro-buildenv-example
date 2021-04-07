#!/bin/bash -e

BINARY=$1
if [ -z $BINARY ]
then
	echo "Expected argument: path to .exe"
	exit 1
fi
DEST=$(dirname $BINARY)

arr=("/usr/i686-w64-mingw32/lib" "/usr/i686-w64-mingw32/bin" "/usr/lib/gcc/i686-w64-mingw32/9.3-posix")
find_dll() {
	find "${arr[@]}" -maxdepth 1 -type f -name $1 | head -n 1
}

copy_dll() {
	local DLL=$(find_dll $1)
	local DEST=$2
	if [ -z $DLL ] 
	then
		echo "Could not find $1"
		return
	fi
	cp $DLL $DEST
}

#copy_dll allegro_image-5.2.dll $DEST
#copy_dll allegro-5.2.dll $DEST

# copy_dll libpng16-16.dll $DEST
# copy_dll libwinpthread-1.dll $DEST

# copy_dll libgcc_s_sjlj-1.dll $DEST
# copy_dll libstdc++-6.dll $DEST
# copy_dll libbz2-1.dll $DEST
# copy_dll libharfbuzz-0.dll $DEST
# copy_dll libglib-2.0-0.dll $DEST
# copy_dll libjpeg-8.dll $DEST
# copy_dll libphysfs.dll $DEST
# copy_dll libintl-8.dll $DEST
# copy_dll libtheoradec-1.dll $DEST
# copy_dll libdumb.dll $DEST
# copy_dll zlib1.dll $DEST
# copy_dll libiconv-2.dll $DEST
# copy_dll libidn2-0.dll $DEST
# copy_dll libgraphite2.dll $DEST
# copy_dll libpcre-1.dll $DEST
# copy_dll libunistring-2.dll $DEST
# copy_dll libbrotlidec.dll $DEST
# copy_dll libbrotlicommon.dll $DEST
# cp $WINDOWS_BASE/xinput1_3.dll $DEST
# cp $WINDOWS_BASE/dsound.dll $DEST
# cp $WINDOWS_BASE/msvcrt.dll $DEST

echo Checking $DEST/*.exe
cd $DEST
for i in $(objdump -p *.exe *.dll | grep 'DLL Name:' | sort | uniq | sed "s/\s*DLL Name: //")
do
	if [ -e $i ]
	then
		echo "FOUND: $i"
	else
		echo "MISSING: $i"
	fi
done
cd -

