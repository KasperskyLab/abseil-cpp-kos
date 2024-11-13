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

project(einit)

# Include the CMake library named image
# containing the solution image build scripts.
include(platform/image)
include(${KL_SDK_ROOT_PATH}/common/build-sd-image.cmake)

# Set the linker and compiler flags.
project_header_default("STANDARD_GNU_11:YES" "STRICT_WARNINGS:NO")

# Set the values of the variables.
set(ENTITIES Hello)
set(SECURITY_PSL_FILE "src/security.psl.in")
set(CONNECTIONS_CFG_FILE "src/init.yaml.in")
set(IMAGE_FS "${CMAKE_BINARY_DIR}/hdd")
set(LIBS_PATH "${IMAGE_FS}/lib")
set(QEMU_DISK_IMAGE sdcard0.img)
set(QEMU_FLAGS "-nic none")

if(PLATFORM_SUPPORTS_DYNAMIC_LINKING)
  find_package(precompiled_vfs REQUIRED)
  list(APPEND ENTITIES ${precomiled_vfsVfsSdCardFs})
  set_target_properties(${blob_container_ENTITY} PROPERTIES
    DEPENDS_ON_ENTITY ${precompiled_vfsVfsSdCardFs}
    EXTRA_ENV "    VFS_FILESYSTEM_BACKEND: client:kl.VfsSdCardFs"
  )
  set(QEMU_FLAGS "${QEMU_FLAGS} -drive file=${QEMU_DISK_IMAGE},if=sd,format=raw")
  set(QEMU_DEPENDENCIES ${QEMU_DISK_IMAGE})
endif()

# Create a top-level CMake target named kos-image which can be used
# when building a solution image to be started on the hardware platform.
build_kos_hw_image(kos-image
  EINIT_ENTITY EinitHw
  CONNECTIONS_CFG ${CONNECTIONS_CFG_FILE}
  SECURITY_PSL ${SECURITY_PSL_FILE}
  PACK_DEPS_COPY_ONLY ON
  PACK_DEPS_LIBS_PATH ${LIBS_PATH}
  PACK_DEPS_COPY_TARGET copylibs_hw
  IMAGE_FILES ${ENTITIES}
)

add_dependencies(kos-image copylibs_hw)

# Create a top-level CMake target named sd-image which can be used
# when building an SD card image to be started on the hardware platform.
build_sd_image(sd-image
  KOS_IMAGE_TARGET kos-image
  IMAGE_FS ${IMAGE_FS}
)

add_custom_target(${QEMU_DISK_IMAGE}
  DEPENDS copylibs_qemu
  COMMAND ${KL_SDK_ROOT_PATH}/common/prepare_hdd_img.sh
          -d ${IMAGE_FS} -s 64 -f fat32 -img ${QEMU_DISK_IMAGE}
)

# Create a top-level CMake target named kos-qemu-image which
# can be used when building a solution image to be started in QEMU.
build_kos_qemu_image(kos-qemu-image
  EINIT_ENTITY EinitQemu
  QEMU_FLAGS "${QEMU_FLAGS}"
  CONNECTIONS_CFG ${CONNECTIONS_CFG_FILE}
  SECURITY_PSL ${SECURITY_PSL_FILE}
  QEMU_DEPENDENCIES ${QEMU_DEPENDENCIES}
  PACK_DEPS_COPY_ONLY ON
  PACK_DEPS_LIBS_PATH ${LIBS_PATH}
  PACK_DEPS_COPY_TARGET copylibs_qemu
  IMAGE_FILES ${ENTITIES}
)
