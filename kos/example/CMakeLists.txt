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

cmake_minimum_required(VERSION 3.25)

project(example)

# Initialize CMake library for the KasperskyOS SDK.
include(platform)
initialize_platform()

# Include the CMake library named doxygen
# for documentation of source texts.
include(platform/doxygen)
add_project_documentation_main_target()

# Detect board.
if(CMAKE_SYSTEM_SOC STREQUAL "BCM2711")
  set(BOARD "RPI4_BCM2711")
elseif(CMAKE_SYSTEM_SOC STREQUAL "RK3568")
  set(BOARD "RADXA_ROCK_3A")
else()
  message(FATAL_ERROR "Unsupported board for SoC '${CMAKE_SYSTEM_SOC}'")
endif()

add_subdirectory(hello)
add_subdirectory(einit)
