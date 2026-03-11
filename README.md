# KasperskyOS adaptation patch for Abseil (C++ Common Libraries)

This project provides an adaptation patch for the
[Abseil C++ library](https://github.com/abseil/abseil-cpp), enabling its use in KasperskyOS-based
solutions. The project is based on the
[20250512.0](https://github.com/abseil/abseil-cpp/tree/20250512.0) version.

For more information about the original Abseil C++ library, see its
[README.md](https://github.com/abseil/abseil-cpp/blob/master/README.md) file or
[Abseil website](https://abseil.io/).

For additional details on KasperskyOS, including its limitations and known issues, please refer to
the [KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=community_edition).

## Table of contents
- [KasperskyOS adaptation patch for Abseil (C++ Common Libraries)](#kasperskyos-adaptation-patch-for-abseil-c-common-libraries)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and installing](#building-and-installing)
  - [Usage](#usage)
  - [Trademarks](#trademarks)
  - [Contributing](#contributing)
  - [Licensing](#licensing)

## Getting started

### Prerequisites

1. Confirm that your host system meets all the
[System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=system_requirements)
listed in the KasperskyOS Community Edition Developer's Guide.
1. [Install](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=sdk_install_and_remove)
the KasperskyOS Community Edition SDK version 1.4. You can download it for free from
[os.kaspersky.com](https://os.kaspersky.com/development/).
1. Copy the source files of this adaptation patch to your local project directory.
1. Source the SDK setup script to configure the build environment. This exports the `KOSCEDIR`
  environment variable, which points to the SDK installation directory:
   ```sh
   source /opt/KasperskyOS-Community-Edition-<platform>-<version>/common/set_env.sh
   ```

### Building and installing

The KasperskyOS-adapted version of the Abseil C++ library is built using the CMake build system,
which is provided in the KasperskyOS Community Edition SDK. When you develop a KasperskyOS-based
solution, use the
[recommended structure of project directories](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=cmake_using_sdk_cmake)
to simplify the use of CMake scripts.

Suppose to install the library into a user directory `~/.local/share/kos/`. This path is
passed to CMake using the `CMAKE_INSTALL_PREFIX` option.

To build and install the library, choose the command block corresponding to your desired library
type:

* Static Library
   ```sh
   $ cmake -B build \
           -D CMAKE_INSTALL_PREFIX=~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos \
           -D CMAKE_TOOLCHAIN_FILE="${KOSCEDIR}/toolchain/share/toolchain-aarch64-kos.cmake"
   $ cmake --build build -j`nproc` --target all install
   ```

* Dynamic (Shared) Library
   ```sh
   $ cmake -B build \
           -D BUILD_SHARED_LIBS=ON \
           -D CMAKE_INSTALL_PREFIX=~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos \
           -D CMAKE_TOOLCHAIN_FILE="${KOSCEDIR}/toolchain/share/toolchain-aarch64-kos.cmake"
   $ cmake --build build -j`nproc` --target all install
   ```

* Monolithic Shared Library (single `.so` file)
   ```sh
   $ cmake -B build \
           -D BUILD_SHARED_LIBS=ON \
           -D ABSL_BUILD_MONOLITHIC_SHARED_LIBS=ON \
           -D CMAKE_INSTALL_PREFIX=~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos \
           -D CMAKE_TOOLCHAIN_FILE="${KOSCEDIR}/toolchain/share/toolchain-aarch64-kos.cmake"
   $ cmake --build build -j`nproc` --target all install
   ```

After a successful build, the library is installed in the
`~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos` directory.

> [!NOTE]
> This adaptation patch does not include the adaptation of unit tests.
>
> Running the original Abseil unit tests on KasperskyOS requires significant additional adaptation,
> including but not limited to:
>
>* Adapting the test source code for the KasperskyOS.
>* Resolving external dependencies.
>* Adapting the CMake build scripts, including writing wrappers that create appropriate solutions
>  for KasperskyOS for each test.

[⬆ Back to Top](#table-of-contents)

## Usage

To integrate the KasperskyOS-adapted Abseil C++ library into your solution, first build and install
it into the `~/.local/share/kos/` directory. For a practical implementation, refer to the
[abseil example](https://github.com/KasperskyLab/kos-ce-extra/tree/master/examples/abseil) in the
`KasperskyLab/kos-ce-extra` repository, which demonstrates this exact workflow.

## Trademarks

Registered trademarks and endpoint marks are the property of their respective owners.

AIX is a trademark of International Business Machines Corporation, registered in many jurisdictions
worldwide.

Apache is either a registered trademark or a trademark of the Apache Software Foundation in the
United States and/or other countries.

Apple, macOS are trademarks of Apple Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United
States and/or other countries. Docker, Inc. and other parties may also have trademark rights in
other terms used herein.

FreeBSD is a registered trademark of The FreeBSD Foundation.

GITHUB is a trademark of GitHub, Inc., registered in the United States and other countries.

iOS is a registered trademark or trademark of Cisco Systems, Inc. and/or its affiliates in the
United States and certain other countries.

Linux is the registered trademark of Linus Torvalds in the U.S. and other countries.

LTS is a registered trademark of Canonical Ltd.

VxWorks is a registered trademark (®) or service mark (SM) of Wind River Systems, Inc. This product
is not affiliated with, endorsed, sponsored, supported by the owners of the third-party trademark
mentioned herein.

Win32 is a trademark of the Microsoft group of companies.

## Contributing

Only KasperskyOS-specific changes can be approved. See [CONTRIBUTING.md](CONTRIBUTING.md) for
detailed instructions on code contribution.

## Licensing

This project is licensed under the terms of the MIT license. See [LICENSE](LICENSE) for more information.

This project comprises publication(s) intended to be used with [Abseil C++ library](https://github.com/abseil/abseil-cpp/tree/20250512.0) ( “Upstream Project”).
The Upstream Project is licensed and distributed under its own license terms, which are separate from the terms of this project.
Nothing in this repository is intended to modify, replace, supersede, or relicense the Upstream Project or any of its components.

[⬆ Back to Top](#table-of-contents)

© 2026 AO Kaspersky Lab
