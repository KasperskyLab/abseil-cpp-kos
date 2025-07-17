# Abseil library for KasperskyOS usage example

This solution is based on an example from [Abseil C++ Quickstart With CMake](https://abseil.io/docs/cpp/quickstart-cmake.html#c-quickstart-with-cmake).
It prints the message `Joined string: foo-bar-baz` to the standard output. The difference between
this solution and the base example is that it uses the previously built and installed Abseil library.
It is assumed that the Abseil library is installed in the default installation directory
`<project_directory>/kos/install`, where `project_directory` is the directory with the source files.
If the Abseil library is not found in the default installation path, it will be built and installed
in this directory. More usage examples can be found in the [Abseil C++ Programming Guides](https://abseil.io/docs/cpp/guides/).

This solution uses the dynamic variant of the Abseil library. To build a static variant of the library,
use the `initialize_platform` command with the `FORCE_STATIC` parameter. For additional details
regarding this command, please refer to the
[platform library](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=cmake_platform_lib).

## Table of contents
- [Abseil library for KasperskyOS usage example](#abseil-library-for-kasperskyos-usage-example)
  - [Table of contents](#table-of-contents)
  - [Solution overview](#solution-overview)
    - [List of programs](#list-of-programs)
    - [Initialization description](#initialization-description)
    - [Security policy description](#security-policy-description)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and running the example](#building-and-running-the-example)
      - [QEMU](#qemu)
      - [Hardware](#hardware)
      - [CMake input files](#cmake-input-files)
  - [Usage](#usage)

## Solution overview

### List of programs

* `Hello`—Program that joins the strings `foo`, `bar`, `baz` and prints the resulting string to
the standard output
* `BlobContainer`—Program that loads dynamic libraries used by other programs into shared memory
* `EntropyEntity`—Random number generator
* `VfsSdCardFs`—Program that supports the SD Card file system
* `SDCard`—SD Card driver
* `BSP`—Driver for configuring pin multiplexing parameters (pinmux)

### Initialization description

 <details><summary>Statically created IPC channels</summary>

* `example.Hello` → `kl.BlobContainer`
* `kl.BlobContainer` → `kl.VfsSdCardFs`
* `kl.VfsSdCardFs` → `kl.drivers.SDCard`
* `kl.VfsSdCardFs` → `kl.bc.BlobContainer`
* `kl.VfsSdCardFs` → `kl.EntropyEntity`
* `kl.EntropyEntity` → `kl.bc.BlobContainer`
* `kl.drivers.SDCard` → `kl.drivers.BSP`
* `kl.drivers.SDCard` → `kl.bc.BlobContainer`
* `kl.drivers.BSP` → `kl.BlobContainer`

</details>

The [`./einit/src/init.yaml.in`](einit/src/init.yaml.in) template is used to automatically generate
part of the solution initialization description file `init.yaml`. For more information about the
`init.yaml.in` template file, see the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=cmake_yaml_templates).

### Security policy description

The [`./einit/src/security.psl.in`](einit/src/security.psl.in) template is used to automatically
generate part of the `security.psl` file using CMake tools. The `security.psl` file contains part
of a solution security policy description. For more information about the `security.psl` file, see
[Describing a security policy for a KasperskyOS-based solution](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=ssp_descr).

[⬆ Back to Top](#table-of-contents)

## Getting started

### Prerequisites

To install [KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/) and run examples
on QEMU or a hardware platform, make sure you meet all the
[System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=system_requirements)
listed in the KasperskyOS Community Edition Developer's Guide.

### Building and running the example

The example is built using the CMake build system, which is provided in the KasperskyOS Community
Edition SDK.

There are environment variables that affect the build of the example:

* `SDK_PREFIX` specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `TARGET` specifies the target platform. (Currently only the `aarch64-kos` platform is supported.)

Run the following command:

`$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> [TARGET="aarch64-kos"] ./cross-build.sh <platform>`,

where:

* `version` specifies the latest version number of the [KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/).
* `platform` can take one of the following values: `qemu` for QEMU or `hw` for Raspberry Pi 4 B or Radxa ROCK 3A.

For example, review the following command:
```sh
$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> ./cross-build.sh qemu
```
The command builds the example and runs the KasperskyOS-based solution image on QEMU. The solution
image is based on the SDK found in the `/opt/KasperskyOS-Community-Edition-<version>` path, where
`version` is the latest version number of the KasperskyOS Community Edition SDK.

#### QEMU

Running `cross-build.sh` creates a KasperskyOS-based solution image that includes the example.
The `kos-qemu-image` solution image is located in the `./build/einit` directory.

The `cross-build.sh` script both builds the example on QEMU and runs it.

[⬆ Back to Top](#table-of-contents)

#### Hardware

Running `cross-build.sh` creates a KasperskyOS-based solution image that includes the example
and a bootable SD card image for a hardware platform. The `kos-image` solution image is located
in the `./build/einit` directory. The `hdd.img` bootable SD card image is located in the
`./build` directory.

1. To copy the bootable SD card image to the SD card, connect the SD card to the computer and
run the following command:

  `$ sudo dd bs=64k if=build/hdd.img of=/dev/sd[X] conv=fsync`,

  where `[X]` is the final character in the name of the SD card block device.

1. Connect the bootable SD card to the hardware.
1. Supply power to the hardware and wait for the example to run.

You can also use an alternative option to prepare and run the example:

1. Prepare the required hardware platform and bootable SD card by following the instructions in the KasperskyOS Community Edition Online Help:
    * [Raspberry Pi 4 B](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=preparing_sd_card_rpi)
    * [Radxa ROCK 3A](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=preparing_sd_card_radxa)
1. Run the example by following the instructions in the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=running_sample_programs_rpi)

#### CMake input files

[./hello/CMakeLists.txt](hello/CMakeLists.txt)—CMake commands for building the `Hello` program.

[./einit/CMakeLists.txt](einit/CMakeLists.txt)—CMake commands for building the `Einit` program
and the solution image.

[./CMakeLists.txt](CMakeLists.txt)—CMake commands for building the solution.

## Usage

After running the example, the message `Joined string: foo-bar-baz` should be displayed in the
standard output.

[⬆ Back to Top](#table-of-contents)

© 2025 AO Kaspersky Lab
