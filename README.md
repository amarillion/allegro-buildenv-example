Very simple example to demonstrate how to build an allegro game using docker.

## Prerequisites

Prerequisites: you must have docker installed on your system.

## Compiling the example for linux

To build this example for linux, use:

```
docker run \
	-v $(pwd):/data \
	amarillion/alleg5-buildenv:latest \
	make BUILD=RELEASE
```

This command will:
* Download the latest docker image containing pre-built allegro and its dependencies from docker hub.
* Map the current directory (`pwd`) to `/data` inside the container. That way your project files
are available inside the container. Any files created in this direcory will be availble from the host as well.
* Invoke `make BUILD=RELEASE` inside this container
* The resulting binary will be `build/release/example`

## Compiling the example for windows

To build this example for windows, use:
```
docker run \
	-v $(pwd):/data \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	make BUILD=RELEASE TOOLCHAIN=i686-w64-mingw32- WINDOWS=1
```

This time, we use a different docker image, one that contains a mingw-w64 cross-compilation toolchain. 
We again invoke make, but supply a few different flags to our makefile. The resulting binary will be created in build/release_win/example.exe

This .exe won't run without a few dlls. These DLLs are present inside the docker image, to get them out we can run the collect-dlls.sh script.

```
docker run \
	-v $(pwd):/data \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	./collect-dlls.sh build/release_win/example.exe
```

This will run the `./collect-dlls.sh build/release_win/example.exe` inside the docker container, which will copy the DLLs to build/release_win.


## Troubleshooting

If you ever need to inspect a docker image, for example to troubleshoot a makefile, you can run:

```
docker run \
 	-ti \
 	-v $(pwd):/data \
 	amarillion/alleg5-buildenv:latest-mingw-w64-i686
```

Where you specify the docker image you want to inspect in the last line. This will give you a bash shell inside the docker container, and you can examine the filesystem, try commands, even install new tools with `apt` (make sure to run `apt update` first). The container is ephemeral: once you close it, all your changes outside the volume-mapped directory are gone.