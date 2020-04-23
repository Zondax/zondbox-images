# zondboxes-images
![CI](https://github.com/Zondax/ARM-TEE-Image/workflows/CI/badge.svg?branch=master)

## Preconditions

- Install [Docker](https://docs.docker.com/engine/install/)
- We assume you are using Linux. While possible to use other OS (MacOS /
  Windows), this has not been tested.

## Build or pull the container with the build environment
- `make docker` to retrieve the latest published container image

## Pull latest repo manifest
- `make manifest` to retrieve the latest published container image

This command wraps `repo` tool and fetches the latest changes and updates of
the working files in your local environment, essentially accomplishing git fetch
across all Git repositories listed in [default.xml](https://github.com/Zondax/zondbox-manifest)
manifest.

## QEMU ARM v7/v8 image

- Run `make build <target>`. Current supported QEMU targets are: `qemu`, `qemu8`
- After build is finished, you can run QEMU emulator with this image:
```
zondbox-images.git $ make run qemu
...
Please use telnet to receive console output:
      NW output $ telnet 127.0.0.1 54320
      SW output $ telnet 127.0.0.1 54321
To mount host 'shared' directory run:
      $ mount -t 9p -o trans=virtio host <mount_point>
QEMU 4.1.0 monitor - type 'help' for more information
(qemu)
```

- To obtain both Normal World (port** 54320**)/Secure World (port** 54321**)
consoles use telnet client:

```
$ telnet 127.0.0.1 54320
$ telnet 127.0.0.1 54321
```

- When connections are established, you can resume execution of QEMU emulator
by entering `c` command:

```
...
QEMU 4.1.0 monitor - type 'help' for more information
(qemu) c
```

- You can also use `run-term` target, where terminals with connected telnet
will be forked automatically:
```
zondbox-images.git $ make run-term qemu
```

- When Linux inside QEMU is booted, login with `root` without password.

## STM32MP1 DK2 image

- Run `make build <target>`. Current supported real hw targets are: `dk2`;
- After build is finished, you can run find the raw image ready for flashing
to the SD card in `shared/images/`
- Flash raw image to your SD card:

```
zondbox-images.git $ sudo dd if=shared/images/dk2/flashlayout_core-image-minimal_FlashLayout_sdcard_stm32mp157c-dk2-optee.raw of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress
```

- Insert SD to your DK2 board and boot it
- When Linux is booted, login with root without password.


## Running tests

When your target is booted you can verify that everything works as expected
by using OP-TEE sanity test suit.
```
$ xtest
...
regression_8001 OK
regression_8002 OK
regression_8101 OK
regression_8102 OK
regression_8103 OK
+-----------------------------------------------------
24603 subtests of which 0 failed
99 test cases of which 0 failed
0 test cases were skipped
TEE test application done!
```

Also you can invoke minimal Rust TEE "hello world" application:
```
 root@qemu-optee32:~# hello_rustee
    [RUSTEE] <= 12345
    [RUSTEE] => 12387
```

## Development

### Adjusting existing recipe

- If you're familiar with Yocto build system and want to run all Yocto-specific
commands manually, you can login into the docker container using this command:
```
zondbox-images.git $ make shell <target> # target: qemu, qemu8, dk2
```

Then follow steps described in this [manual](https://wiki.yoctoproject.org/wiki/TipsAndTricks/Patching_the_source_for_a_recipe)

- If you're not familiar with Yocto, you can use existing wrappers which
is supposed to make simplify things:
```
zondbox-images.git $ make workspace <target> <recipe-name>
```

This will fetch the sources for the recipe and unpack them to a
`shared/zondbox-distro/build/workspace/sources/<recipename>` directory and
initialise it as a git repository if it isn't already one. You can make any
changes to the sources, make new commits, switch branches/remotes etc.
- When you want rebuild the images, the sources from your workspace will be
used instead the` SRC_URI` value specified in recipe.

### Creating new recipe

- For creating a new example recipe you could:
```
zondbox-images.git $ cd shared/zondbox-distro/meta-zondax
meta-zondax $ mkdir recipes-example
meta-zondax $ cd recipes-example
recipes-example $ mkdir bbexample
recipes-example $ cd bbexample
bbexample $ wget https://raw.githubusercontent.com/DynamicDevices/meta-example/master/recipes-example/bbexample/bbexample_1.0.bb
```

- The recipe will then be picked up by bitbake and you can build the recipe.
Login into docker container using `make shell <target>` command, then:

```
 $ bitbake bbexample
```

### OP-TEE updates deployment

- To avoid restarting QEMU for testing updates of userspace binaries, you
can mount `shared` directory using this command inside QEMU terminal:
```
root@qemu-optee32:~# mount -t 9p -o trans=virtio host /mnt
```

- Then you can check example script, prepared for `hello_rustee` application,
stored in `shared/qemu-scripts` dir on the host. To invoke it from QEMU run:
```
root@qemu-optee32:/mnt# ./qemu-scripts/run_app.sh
Copying TAs...
-rw-r--r--    1 1000     1000       65.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/528938ce-fc59-11e8-8eb2-f2801f1b9fd1.ta
-rw-r--r--    1 1000     1000      106.8K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/5b9e0e40-2636-11e1-ad9e-0002a5d5c51b.ta
-rw-r--r--    1 1000     1000       85.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/5ce0c432-0ab0-40e5-a056-782ca0e6aba2.ta
-rw-r--r--    1 1000     1000       85.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/614789f2-39c0-4ebf-b235-92b32ac107ed.ta
-rw-r--r--    1 1000     1000       89.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/731e279e-aafb-4575-a771-38caa6f0cca6.ta
-rw-r--r--    1 1000     1000       70.1K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/873bcd08-c2c3-11e6-a937-d0bf9c45c61c.ta
-rw-r--r--    1 1000     1000       66.0K Apr 23 16:55 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/8d22f026-eb0a-4401-b575-5cf59327119b.ta
-rw-r--r--    1 1000     1000       65.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/a4c04d50-f180-11e8-8eb2-f2801f1b9fd1.ta
-rw-r--r--    1 1000     1000       17.3K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/b3091a65-9751-4784-abf7-0298a7cc35ba.ta
-rw-r--r--    1 1000     1000       89.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/b689f2a7-8adf-477a-9f99-32e90c0ad0a2.ta
-rw-r--r--    1 1000     1000       65.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/c3f6e2c0-3548-11e1-b86c-0800200c9a66.ta
-rw-r--r--    1 1000     1000      340.4K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/cb3e5ba0-adf1-11e0-998b-0002a5d5c51b.ta
-rw-r--r--    1 1000     1000       65.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/d17f73a0-36ef-11e1-984a-0002a5d5c51b.ta
-rw-r--r--    1 1000     1000       85.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/e13010e0-2ae1-11e5-896a-0002a5d5c51b.ta
-rw-r--r--    1 1000     1000       86.0K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/e626662e-c0e2-485c-b8c8-09fbce6edf3d.ta
-rw-r--r--    1 1000     1000       65.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/e6a33ed4-562b-463a-bb7e-ff5e15a493c8.ta
-rw-r--r--    1 1000     1000       73.9K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/f157cda0-550c-11e5-a6fa-0002a5d5c51b.ta
-rw-r--r--    1 1000     1000       17.3K Apr 20 15:30 ./qemu-scripts/../zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs//lib/optee_armtz/ffd2bded-ab7d-4988-95ee-e4962fff7154.ta

------------------------ LAUNCHING HOST -------------------------------

[RUSTEE] <= 12345
[RUSTEE] => 12387
[RUSTEE] Supertest
INIT: Id "AMA1" respawning too fast: disabled for 5 minutes
```
