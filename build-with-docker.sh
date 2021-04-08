#!/bin/bash -e

# For troubleshooting, run the following command to inspect a container:
# docker run \
# 	-ti \
#   -u $(id -u):$(id -g) \
# 	-v $(pwd):/data \
# 	amarillion/alleg5-buildenv:latest-mingw-w64-i686


# Build for linux. Will create a binary in build/release/example
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest \
	make BUILD=RELEASE

# Build for windows. Will create build/release_win/example.exe
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	make BUILD=RELEASE TOOLCHAIN=i686-w64-mingw32- WINDOWS=1

# Copy DLL dependencies of build/release_win/example.exe
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	./collect-dlls.sh build/release_win/example.exe


