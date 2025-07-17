# Abseil adaptation for KasperskyOS (C++ Common Libraries)

This project is an adaptation of the [Abseil library](https://github.com/abseil/abseil-cpp) for
KasperskyOS. The project is based on the [20220623.1](https://github.com/abseil/abseil-cpp/tree/20220623.1)
version and includes an example that demonstrates the use of the previously built and installed
Abseil library in KasperskyOS.

The Abseil library for KasperskyOS is an open source collection of C++ libraries designed to augment
the C++ standard library. For more information about the original abseil-cpp library, see its
[README.md](https://github.com/abseil/abseil-cpp/blob/master/README.md) file or
[Abseil website](https://abseil.io/).

For additional details on KasperskyOS, including its limitations and known issues, please refer to the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=community_edition).

## Table of contents
- [Abseil adaptation for KasperskyOS (C++ Common Libraries)](#abseil-adaptation-for-kasperskyos-c-common-libraries)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and installing](#building-and-installing)
      - [Abseil library for KasperskyOS](#abseil-library-for-kasperskyos)
      - [Tests](#tests)
  - [Usage](#usage)
    - [Example](#example)
    - [Tests](#tests-1)
  - [Trademarks](#trademarks)
  - [Contributing](#contributing)
  - [Licensing](#licensing)

## Getting started

### Prerequisites

1. [Install](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=sdk_install_and_remove)
KasperskyOS Community Edition SDK. You can download the latest version of the KasperskyOS Community
Edition for free from [os.kaspersky.com](https://os.kaspersky.com/development/). The minimum required
version of KasperskyOS Community Edition SDK is 1.3. For more information, see
[System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=system_requirements).
1. Copy source files to your project directory. The example of KasperskyOS-based solution are located
in the [`./kos`](kos) directory.

### Building and installing
#### Abseil library for KasperskyOS

The Abseil library for KasperskyOS is built using the CMake build system, which is provided in the
KasperskyOS Community Edition SDK.

To build and install the Abseil library for KasperskyOS, execute the `cross-build.sh` script located
in the `./kos` directory. There are environment variables that affect the build and installation
of the library:

* `SDK_PREFIX` specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `INSTALL_PREFIX` specifies the installation path of the library. If not specified, the library will
be installed in the `./kos/install` directory.
* `TARGET` specifies the target platform. (Currently only the `aarch64-kos` platform is supported.)

For example, review the following command:
```sh
$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> INSTALL_PREFIX=/home/libs/Abseil-kos ./cross-build.sh
```
The Abseil library is built and installed in the `/home/libs/Abseil-kos/` directory using the SDK
toolchain found in the `/opt/KasperskyOS-Community-Edition-<version>` path, where `version` is the
latest version number of the KasperskyOS Community Edition SDK.

You can also use the following options:

* `-h, --help`

  Help text.
* `-s, --sdk SDK_PREFIX`

  Path to the installed version of the KasperskyOS Community Edition SDK. The value specified in the `-s`
option takes precedence over the value of the `SDK_PREFIX` environment variable.
* `-i, --install INSTALL_PREFIX`

  Directory where Abseil for KasperskyOS binary files are installed. If not specified, the library
will be installed in the `./kos/install` directory. The value specified in the `-i` option takes
precedence over the value of the `INSTALL_PREFIX` environment variable.

For example:
```sh
$ ./cross-build.sh -s /opt/KasperskyOS-Community-Edition-<version> -i /opt/libs
```
[⬆ Back to Top](#table-of-contents)

#### Tests

The Abseil library's [tests](absl) have been adapted to run on KasperskyOS.
The tests have the following limitations:

* Unit tests for KasperskyOS are currently available only for QEMU.
* Death tests are not supported by KasperskyOS.
* Tests such as `symbolize_test`, `demangle_test` and `stack_consumption_test` cannot be compiled
due to the absence of POSIX `sigaltstack()` implementation in KasperskyOS.
* Some tests are skipped:
  * Tests with excessive memory allocation.
  * Tests converting `float` and `double` types to the `string` type and vice versa.
  * `Uint128.ConversionTests` case for the `highest_precision_in_long_double` test, where the precision
is not as high as expected.
  * `Int128FloatConversionTest.ConstructAndCastTest` cases for large values.

Tests use an out-of-source build. The build tree is situated in the generated `build_tests`
subdirectory of the `./kos` directory. For each test suite, a separate image will be created.
As it can be taxing on disk space, the tests will run sequentially.

There are environment variables that affect the build and installation of the tests:

* `SDK_PREFIX` specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `TARGET` specifies the target platform. (Currently only the `aarch64-kos` platform is supported.)

To build and run the tests, go to the `./kos` directory and run the command:

`$ [TARGET="aarch64-kos"] ./run-tests.sh [-s SDK_PREFIX] [--help] [--list] [-t TIMEOUT] [-n TEST_NAME_1] ... [-n TEST_NAME_N] [-t TIMEOUT] [-o OUT_PATH] [-j N_JOBS]`,

where:

* `-s, --sdk SDK_PREFIX`

  Path to the installed version of the KasperskyOS Community Edition SDK. The value specified in the `-s`
option takes precedence over the value of the `SDK_PREFIX` environment variable.
* `-h, --help`

  Help text.
* `-l, --list`

  List of tests that can be run.
* `-n, --name TEST_NAME`

  Test name to execute. The parameter can be repeated multiple times. If not specified, all tests
will be executed.
* `-t, --timeout TIMEOUT`

  Time, in seconds, allotted to start and execute a single test case. Default value is 300 seconds.
* `-o, --out OUT_PATH`

  Path where the results of the test run will be stored. If not specified, the results will be stored
in the `./kos/build_tests/logs` directory.
* `-j, --jobs N_JOBS`

  Number of jobs for parallel build. If not specified, the default value obtained from the `nproc`
command is used.

For example, to start executing all tests, use the following command:
```
$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> ./run-tests.sh
```
[⬆ Back to Top](#table-of-contents)

## Usage

When you develop a KasperskyOS-based solution, use the
[recommended structure of project directories](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.3&customization=KCE&helpid=cmake_using_sdk_cmake)
to simplify usage of CMake scripts.

To include the Abseil library in a KasperskyOS-based solution, it is recommended to use a previously
built and installed Abseil library in KasperskyOS. The project's example demonstrates this methods.

### Example

[`./kos/example`](kos/example)—Example of using the previously installed Abseil library.

### Tests

[`./kos/run-tests.sh`](kos/run-tests.sh)—Script downloads the GoogleTest framework and then runs unit
tests using that framework.

## Trademarks

Registered trademarks and endpoint marks are the property of their respective owners.

AIX, s3, POWER, POWER8, PowerPC are trademarks of International Business Machines Corporation, registered in many jurisdictions worldwide.

AMD, AMD64 are trademarks or a registered trademarks of Advanced Micro Devices, Inc.

Android, Closure, Google, GoogleTest are trademarks of Google LLC.

Apple, macOS, Mac OS, Xcode are trademarks of Apple Inc.

Arm is a registered trademark of Arm Limited (or its subsidiaries) in the US and/or elsewhere.

Core, Intel, Itanium, XMM are trademarks of Intel Corporation or its subsidiaries.

Linux is the registered trademark of Linus Torvalds in the U.S. and other countries.

Microsoft, Visual C++, Visual Studio, Win32, Windows are trademarks of the Microsoft group of companies.

Python is a trademark or registered trademark of the Python Software Foundation.

IOS is a registered trademark of Cisco Systems, Inc. and/or its affiliates in the United States and certain other countries.

Raspberry Pi is a trademark of the Raspberry Pi Foundation.

## Contributing

Only KasperskyOS-specific changes can be approved. See [CONTRIBUTING.md](CONTRIBUTING.md) for
detailed instructions on code contribution.

## Licensing

This project is licensed under the terms of the Apache License. See [LICENSE](LICENSE) for
more information.

[⬆ Back to Top](#table-of-contents)

© 2025 AO Kaspersky Lab
