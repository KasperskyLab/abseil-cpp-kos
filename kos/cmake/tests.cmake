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

# Initialize CMake library for the KasperskyOS SDK.
include(platform)
initialize_platform(FORCE_STATIC)

# Include the CMake library named nk for working with the NK compiler (nk-gen-c).
include(platform/nk)

# Include the CMake library named test-generator to write and build unit tests
# using the specialized program named test_generator provided in the KasperskyOS SDK.
include(test-generator/test_generator)

# Add a package with the VFS program implementations.
find_package(vfs REQUIRED)
include_directories(${vfs_INCLUDE})

# Add a package with prebuilt VFS program implementations.
find_package(precompiled_vfs REQUIRED)

# Add a package with the Dhcpcd program implementation.
find_package(rump REQUIRED COMPONENTS DHCPCD_ENTITY)
include_directories(${rump_INCLUDE})

# Set additional properties for the VfsSdCardFs program.
set_target_properties(${precompiled_vfsVfsSdCardFs} PROPERTIES
  EXTRA_ENV "
    VFS_FILESYSTEM_BACKEND: server:kl.VfsSdCardFs"
  EXTRA_ARGS "
    - -l
    - devfs /dev devfs 0
    - -l
    - romfs /etc romfs ro"
)

# Set additional properties for the Dhcpcd program.
set_target_properties(${rump_DHCPCD_ENTITY} PROPERTIES
  ${vfs_ENTITY}_REPLACEMENT ""
  DEPENDS_ON_ENTITY "${precompiled_vfsVfsSdCardFs};${precompiled_vfsVfsNet}"
  EXTRA_ENV "
    VFS_FILESYSTEM_BACKEND: client{fs->net}:kl.VfsSdCardFs
    VFS_NETWORK_BACKEND: client:kl.VfsNet"
  EXTRA_ARGS "
    - '-4'
    - '-f'
    - /etc/dhcpcd.conf"
)

#Filtered tests:
#   FromChars.NaNFloats, FromChars.NaNDoubles, FormatConvertTest.Float,
#   FormatConvertTest.Double FormatConvertTest.LongDouble : not all converted as expected NaN;
#   HugeStringView.TwoPointTwoGB: allocates too much memory (much than 2 GB)
#                                 for emulator configuration KasperskyOS runs on.
string(JOIN : FILTERED_TESTS
  HugeStringView.TwoPointTwoGB
  FromChars.NaNFloats
  FromChars.NaNDoubles
  FormatConvertTest.Float
  FormatConvertTest.Double
  FormatConvertTest.LongDouble
)

###
# Helper function to create GTest unit test with test generator.
# Arguments:
#   TEST_TARGET   - executable target that represents test.
#   WITH_NETWORK  - add network support to test.
#   ARGS          - tests command line arguments.
#   ENV_VARIABLES - environment variables that will be set while test runs.
#   FILES         - files that will be added to test kos-image.
#   FILES_TO_COPY - list of strings with format "path_to_files_need_by_test:path_where_it_should_be_placed".
#   DEPENDS_ON    - extra programs that test depends on.
function(kos_gtest TEST_TARGET)
  set(OPTIONS WITH_NETWORK)
  set(MULTI_VAL_ARGS FILES FILES_TO_COPY ENV_VARIABLES ARGS DEPENDS_ON)
  cmake_parse_arguments(TEST "${OPTIONS}" "" "${MULTI_VAL_ARGS}" ${ARGN})

  # Add programs to support disk storage.
  set(TEST_DEPENDS_ON ${precompiled_vfsVfsSdCardFs})
  # Set environment variables to select disk storage backend.
  set(TEST_ENV_VARIABLES VFS_FILESYSTEM_BACKEND=client:kl.VfsSdCardFs)

  if(TEST_WITH_NETWORK)
    # Add programs to support network.
    list(APPEND TEST_DEPENDS_ON ${precompiled_vfsVfsNet})
    # Set environment variables to select network backend.
    list(APPEND TEST_ENV_VARIABLES VFS_NETWORK_BACKEND=client:kl.VfsNet)
    set(WITH_NETWORK_OPTION WITH_NETWORK)
  endif(TEST_WITH_NETWORK)

  get_entity_name(${TEST_TARGET} TEST_ENTITY_NAME)
  generate_edl_file(${TEST_ENTITY_NAME})
  nk_build_edl_files(${TEST_TARGET}_edl_files EDL ${EDL_FILE})
  add_dependencies(${TEST_TARGET} ${TEST_TARGET}_edl_files)

  target_link_libraries(${TEST_TARGET} PUBLIC ${vfs_CLIENT_LIB})
  target_compile_definitions(${TEST_TARGET} PUBLIC GTEST_HAS_PTHREAD=1)

  set_target_properties(${TEST_TARGET} PROPERTIES
    ${vfs_ENTITY}_REPLACEMENT ""
    DEPENDS_ON_ENTITY "${TEST_DEPENDS_ON}"
  )

  unset(vfs_ENTITY)
  generate_kos_test(
    ${WITH_NETWORK_OPTION}
    ENTITY_NAME ${TEST_ENTITY_NAME}
    TARGET_NAME ${TEST_TARGET}
    TEST_TYPE gtest
    ARGUMENTS ${TEST_ARGS} --gtest_filter=-${FILTERED_TESTS}
    VARIABLES ${TEST_ENV_VARIABLES}
    ENTITY_HAS_VFS YES
    FILES ${TEST_FILES}
    FILES_TO_COPY ${TEST_FILES_TO_COPY}
  )
endfunction(kos_gtest)
