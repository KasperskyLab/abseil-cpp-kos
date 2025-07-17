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

export LANG=C
export PKG_CONFIG=""

export BUILD_WITH_CLANG=
export BUILD_WITH_GCC=

TOOLCHAIN_SUFFIX=""

if [ "${BUILD_WITH_CLANG}" == "y" ]; then
    TOOLCHAIN_SUFFIX="-clang"
fi

if [ "${BUILD_WITH_GCC}" == "y" ]; then
    TOOLCHAIN_SUFFIX="-gcc"
fi

PROJECT_NAME=Abseil
KOS_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${KOS_DIR}")"
BUILD=${KOS_DIR}/build_tests
TARGET=${TARGET:-"aarch64-kos"}


export GENERATED_DIR="${BUILD}/generated"
export TEST_LOGS_DIR="${BUILD}/logs"
export FAILED_TESTS="${TEST_LOGS_DIR}/failed_tests"
export TEST_TARGET_PREFIX="kos-qemu-image-"
export TEST_TARGET_SUFFIX="-sim"
export TEST_TIMEOUT=3000
export JOBS=`nproc`
export CMAKE_PID=
export ALL_TESTS=
export TESTS=

function KillQemu() {
    PID_TO_KILL=$(pgrep qemu-system.*)
    kill $PID_TO_KILL 2>/dev/null
}

function PrintHelp() {
cat<<HELP

Run ${PROJECT_NAME} unit tests in QEMU.

USAGE:

    ${0} [OPTIONS]

OPTIONS:

    -h, --help
        Help text.

    -s, --sdk PATH
        Path to the installed version of the KasperskyOS Community Edition SDK.
        The value specified in the -s options takes precedence over
        the value of the SDK_PREFIX environment variable.

    -l, --list
        List of tests that can be run.

    -n, --name TEST
        Test name to execute. The parameter can be repeated multiple times.
        If not specified, all tests will be executed.

    -t, --timeout SEC
        Time, in seconds, allotted to start and execute a single test case.
        Default value is ${TEST_TIMEOUT} seconds.

    -o, --out PATH
        Path where the results of the test run will be stored.
        If not specified, the results will be stored in the ${TEST_LOGS_DIR} directory.

    -j, --jobs N
        Number of jobs for parallel build.
        If not specified, the default value obtained from the nproc command is used.

HELP
}

function ParsArguments() {
    local LIST_TESTS=""

    while [ -n "${1}" ]; do
        case "${1}" in
        -h | --help) PrintHelp
            exit 0;;
        -l | --list) LIST_TESTS=YES;;
        -s | --sdk) SDK_PREFIX="${2}"
            shift;;
        -n | --name) TESTS="${TESTS} ${2}"
            shift ;;
        -t | --timeout) TEST_TIMEOUT="${2}"
            shift ;;
        -o | --out) TEST_LOGS_DIR="${2}";
            shift ;;
        -j | --jobs) JOBS="${2}";
            shift ;;
        *) echo "Unknown option - '${1}'"
            exit 1;;
        esac
        shift
    done

    if [ -z "${SDK_PREFIX}" ];then
        echo "Can't get path to the installed KasperskyOS SDK."
        PrintHelp
        exit 1
    fi

    export PATH="${SDK_PREFIX}/toolchain/bin:${PATH}"

    if [ ! -z "${LIST_TESTS}" ]; then
        PrintTestNames
        exit 0
    fi
}

function Generate() {
    cmake -G "Unix Makefiles" -B "${BUILD}" \
             -D ABSL_BUILD_TESTING=ON \
             -D ABSL_USE_EXTERNAL_GOOGLETEST=OFF \
             -D ABSL_USE_GOOGLETEST_HEAD=ON \
             -D ABSL_PROPAGATE_CXX_STD=ON \
             -D KOS_DIR="${KOS_DIR}" \
             -D CMAKE_BUILD_TYPE:STRING=Debug \
             -D CMAKE_TOOLCHAIN_FILE="${SDK_PREFIX}/toolchain/share/toolchain-${TARGET}${TOOLCHAIN_SUFFIX}.cmake" \
             "${ROOT_DIR}/"
     if [ $? -ne 0 ]; then
         echo "Can't generate make files.";
         rm -rf "${BUILD}"
         exit 1
     fi
}

function ListTests() {
    [ ! -e ${BUILD} ] && Generate
    ALL_TESTS=$("cmake" --build ${BUILD} --target help | \
                grep -wo ${TEST_TARGET_PREFIX}.*${TEST_TARGET_SUFFIX} | \
                sed "s|${TEST_TARGET_PREFIX}\(.*\)${TEST_TARGET_SUFFIX}|\1|")
    if [ -z "${ALL_TESTS}" ]; then
        echo "No test targets found - nothing to do."
        exit 0
    fi
}

function PrintTestNames() {
    ListTests
    echo "Tests available:"
    echo "${ALL_TESTS}" | sed 's/\s\+/\n/g' | sort | sed 's/^/  /'
}

function GetTests() {
    ListTests
    if [ -z "${TESTS}" ]; then
        TESTS="${ALL_TESTS}"
    else
        TESTS=$(echo "${TESTS}" | sed 's/ /\n/g' | sort | uniq)
        for TEST in ${TESTS}; do
            if ! echo "${ALL_TESTS}" | grep -q "${TEST}"; then
                echo "Unknown test: ${TEST}."
                exit 1;
            fi
        done
    fi
}

function SetupEnvironment() {
    # TEST_LOGS_DIR should be a full path, no matter relative or absolute.
    if [[ "${TEST_LOGS_DIR}" != /* ]]; then
        TEST_LOGS_DIR="${PWD}/${TEST_LOGS_DIR}"
    fi

    if [ -e "${TEST_LOGS_DIR}" ]; then
        rm -rf "${TEST_LOGS_DIR}"
    fi

    mkdir -p ${TEST_LOGS_DIR} &> /dev/null

    if [ -e "${FAILED_TESTS}" ]; then
        rm -rf "${FAILED_TESTS}"
    fi
}

function RunTests() {
    # Run all specified tests.
    for TEST in ${TESTS}; do

        TEST_LOG="${TEST_LOGS_DIR}/${TEST}.result"
        TEST_TARGET=${TEST_TARGET_PREFIX}${TEST}${TEST_TARGET_SUFFIX}

        # Build test.
        "cmake" --build ${BUILD} --target ${TEST_TARGET} -j ${JOBS} &> ${TEST_LOG} &
        CMAKE_PID=`echo $!`

        FAILED=YES
        tail -F -n +1 --pid="${CMAKE_PID}" "${TEST_LOG}" 2>/dev/null \
        | while IFS= read -t ${TEST_TIMEOUT} -r STR; do
            echo ${STR}
            if [[ ${STR} == *"ALL-KTEST-FINISHED"* ]]; then
                FAILED=NO
                break;
            elif [[ ${STR} == *"FAILED TEST"* ]]; then
                echo "  ${TEST}" >> "${FAILED_TESTS}"
                break;
            fi
        done;
        KillQemu

        # Cleanup.
        if [[ "${FAILED}" == NO ]]; then
           rm -rf "${GENERATED_DIR}/*_${TEST}" "${BUILD}/${TEST}*"
        fi
    done
}

function PrintResult() {
    if [[ -e "${FAILED_TESTS}" ]]; then
        echo "Some tests have failed. See the logs for more details."
        echo "List of failed tests can be found at ${FAILED_TESTS}."
        echo "Failed tests:"
        cat "${FAILED_TESTS}"
    else
        echo "All tests are passed."
    fi
}

# Main.
trap KillQemu EXIT HUP INT QUIT PIPE TERM
ParsArguments $@
GetTests
SetupEnvironment
RunTests
PrintResult
