Very simple example to demonstrate how to build an allegro game using docker.

## Prerequisites

Prerequisites: you must have docker installed on your system.

Then, check-out a working copy of this git repository on your PC. 

```
git clone https://github.com/amarillion/allegro-buildenv-example.git
```

Change your current directory to this working copy before you run the commands below.

## Compiling the example for linux from linux hosts.

To build the linux version of this example, use the command below.
Note that the process will be very similar for Windows or Mac - if you have docker working. The way you invoke docker may be slightly different but the make command should work the same and produce the same results.

```
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest \
	make BUILD=RELEASE
```

This command will:
* Download the latest docker image `amarillion/alleg5-buildenv:latest` containing pre-built allegro and its dependencies from docker hub.
* Map the current directory (`pwd`) to `/data` inside the container. That way your project files
are available inside the container. Any files created in this direcory will be availble from the host as well.
* The line `-u $(id -u):$(id -g)` will make docker assume your current user/group, so that files written to the current directory have the right permissions.
* Invoke `make BUILD=RELEASE` inside this container
* The resulting binary will be `build/release/example`

## Compiling the example for windows

To build this example for windows, use the command below.
Again, this should work regardless of the OS of your host machine.

```
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	make BUILD=RELEASE TOOLCHAIN=i686-w64-mingw32- WINDOWS=1
```

This time, we use a different docker image: `amarillion/alleg5-buildenv:latest-mingw-w64-i686`. This one that contains a mingw-w64 cross-compilation toolchain. We again invoke make, but supply a few different flags to our makefile. The flag `WINDOWS=1` will do extra windows-specific things like adding the icon to our .exe. The flag `TOOLCHAIN=i686-w64-mingw32-` tells the makefile which prefix to use for commands like `gcc` and `windres`. The resulting binary will be created in build/release_win/example.exe

This .exe won't run without a few dlls. These DLLs are present inside the docker image, to get them out we can run the collect-dlls.sh script.

```
docker run \
	-v $(pwd):/data \
	-u $(id -u):$(id -g) \
	amarillion/alleg5-buildenv:latest-mingw-w64-i686 \
	./collect-dlls.sh build/release_win/example.exe
```

This will run the `./collect-dlls.sh build/release_win/example.exe` inside the docker container, which will copy the DLLs to build/release_win.


## Troubleshooting

If you ever need to inspect a docker image, for example to troubleshoot a makefile, you can run:

```
docker run \
 	-ti \
	-u $(id -u):$(id -g) \
 	-v $(pwd):/data \
 	amarillion/alleg5-buildenv:latest-mingw-w64-i686
```

Where you specify the docker image you want to inspect in the last line. This will give you a bash shell inside the docker container, and you can examine the filesystem, try commands, even install new tools with `apt` (make sure to run `apt update` first). The container is ephemeral: once you close it, all your changes outside the volume-mapped directory are gone.