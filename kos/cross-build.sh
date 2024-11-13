#!/usr/bin/env bash
#
# © 2024 AO Kaspersky Lab
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

set -e

PROJECT_NAME=Abseil
KOS_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${KOS_DIR}")"
BUILD="${KOS_DIR}/build"
DEFAULT_INSTALL_PREFIX="${KOS_DIR}/install"

function PrintHelp() {
cat<<HELP

Build and install ${PROJECT_NAME} for KasperskyOS.

USAGE:

    ${0} [OPTIONS]

OPTIONS:

    -h, --help
        Help text.

    -s, --sdk PATH
        Path to the installed version of the KasperskyOS Community Edition SDK.
        The path must be set using either the value of the SDK_PREFIX environment variable or the -s option.
        The value specified in the -s option takes precedence over the value of the SDK_PREFIX environment variable.

    -i, --install PATH
        Path to directory where ${PROJECT_NAME} for KasperskyOS will be installed.
        If not specified, the default path ${DEFAULT_INSTALL_PREFIX} will be used.
        The value specified in the -i option takes precedence over the value of the INSTALL_PREFIX environment variable.
HELP
}

# Parse command line options.
while [ -n "${1}" ]; do
    case "${1}" in
    -h | --help) PrintHelp
        exit 0;;
    -s | --sdk) SDK_PREFIX="${2}"
        shift;;
    -i | --install) INSTALL_PREFIX="${2}"
        shift;;
    *) echo "Unknown option -'${1}'."
        PrintHelp
        exit 1;;
    esac
    shift
done

if [ -z "${SDK_PREFIX}" ]; then
    echo "Can't get path to the installed KasperskyOS SDK."
    PrintHelp
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

if [ -z "${INSTALL_PREFIX}" ]; then
    export INSTALL_PREFIX="${DEFAULT_INSTALL_PREFIX}"
    echo "Use default install path - ${INSTALL_PREFIX}"
fi

export LANG=C
export PKG_CONFIG=""
export PATH="${SDK_PREFIX}/toolchain/bin:${PATH}"

export BUILD_WITH_CLANG=
export BUILD_WITH_GCC=

TOOLCHAIN_SUFFIX=""

if [ "${BUILD_WITH_CLANG}" == "y" ];then
    TOOLCHAIN_SUFFIX="-clang"
fi

if [ "${BUILD_WITH_GCC}" == "y" ];then
    TOOLCHAIN_SUFFIX="-gcc"
fi

cmake -G "Unix Makefiles" -B "${BUILD}" \
      -D ABSL_ENABLE_INSTALL=ON \
      -D BUILD_TESTING=OFF \
      -D CMAKE_INSTALL_PREFIX:STRING="$INSTALL_PREFIX" \
      -D CMAKE_FIND_ROOT_PATH="${PREFIX_DIR}/sysroot-${TARGET}" \
      -D CMAKE_TOOLCHAIN_FILE="${SDK_PREFIX}/toolchain/share/toolchain-${TARGET}${TOOLCHAIN_SUFFIX}.cmake" \
      "${ROOT_DIR}" && \
cmake --build "${BUILD}" -j`nproc` --target install
