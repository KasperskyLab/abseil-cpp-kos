#!/usr/bin/env bash
#
# © 2025 AO Kaspersky Lab
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

EXAMPLE_DIR="$(dirname "$(realpath "${0}")")"
EXAMPLE_BUILD_DIR="${EXAMPLE_DIR}/build"
KOS_DIR="$(dirname ${EXAMPLE_DIR})"
ABSEIL_BUILD_DIR="${KOS_DIR}/build"
ABSEIL_INSTALL_DIR="${KOS_DIR}/../install/kos"
BUILD_TARGET=

function PrintHelp () {
    cat<<HELP

Script to build and run an example of using Abseil library for KasperskyOS.

USAGE:
    ${0} <BUILD_TARGET> [-h | --help]

BUILD_TARGET:
    qemu - to build and run the example on QEMU.
    hw   - to create a file system image bootable device for hardware.

OPTIONS:
    -h, --help
        Help text.
HELP
}

# Parse arguments.
while [ -n "${1}" ]; do
    case "${1}" in
    -h | --help) PrintHelp
        exit 0;;
    qemu) BUILD_TARGET=sim;;
    hw) BUILD_TARGET=sd-image;;
    *) echo "Unknown option -'${1}'."
        PrintHelp
        exit 1;;
    esac
    shift
done

if [ -z "${BUILD_TARGET}" ]; then
    echo "BUILD_TARGET is not specified. Specify the value: 'qemu' or 'hw'."
    PrintHelp
    exit 1
fi

# Prepare environment.
if [ -z "${SDK_PREFIX}" ]; then
    echo "Can't get path to the installed KasperskyOS SDK."
    echo "Please specify it via the SDK_PREFIX environment variable."
    exit 1
fi

if [ -z "${SDK_PREFIX}" ]; then
    echo "Can't get path to installed KasperskyOS SDK."
    echo "Please specify it via SDK_PREFIX environment variable."
    exit 1
fi

if [ -z "${TARGET}" ]; then
    echo "Target platform is not specified. Try to autodetect..."
    TARGETS=($(ls -d "${SDK_PREFIX}"/sysroot-* | sed 's|.*sysroot-\(.*\)|\1|'))
    if [ ${#TARGETS[@]} -gt 1 ]; then
        echo More than one target platform found: ${TARGETS[*]}.
        echo Use the TARGET environment variable to specify exact platform.
        exit 1
    fi

    export TARGET=${TARGETS[0]}
    echo "Platform ${TARGET} will be used."
fi

export LANG=C
export PKG_CONFIG=""
export PATH="${SDK_PREFIX}/toolchain/bin:${PATH}"

export BUILD_WITH_CLANG=
export BUILD_WITH_GCC=

TOOLCHAIN_SUFFIX=""

if [ "${BUILD_WITH_CLANG}" == "y" ]; then
    TOOLCHAIN_SUFFIX="-clang"
fi

if [ "${BUILD_WITH_GCC}" == "y" ]; then
    TOOLCHAIN_SUFFIX="-gcc"
fi

# Build and install Abseil library
# if it is not installed previously.
if [ ! -d "${ABSEIL_INSTALL_DIR}" ]; then
    export INSTALL_PREFIX="${ABSEIL_INSTALL_DIR}"
    ${KOS_DIR}/cross-build.sh && rm -rf "${ABSEIL_BUILD_DIR}"
fi

# Build example.
"${SDK_PREFIX}/toolchain/bin/cmake" -G "Unix Makefiles" -B "${EXAMPLE_BUILD_DIR}" \
      -D CMAKE_BUILD_TYPE:STRING=Debug \
      -D CMAKE_TOOLCHAIN_FILE="${SDK_PREFIX}/toolchain/share/toolchain-${TARGET}${TOOLCHAIN_SUFFIX}.cmake" \
      -D CMAKE_FIND_ROOT_PATH="${ABSEIL_INSTALL_DIR};${PREFIX_DIR}/sysroot-${TARGET}" \
      "${EXAMPLE_DIR}" && "${SDK_PREFIX}/toolchain/bin/cmake" --build "${EXAMPLE_BUILD_DIR}" -j`nproc` --target ${BUILD_TARGET}
