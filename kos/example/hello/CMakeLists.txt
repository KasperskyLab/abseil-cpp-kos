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

project(hello)

# Include the CMake library named nk
# for working with the NK compiler (nk-gen-c).
include(platform/nk)

# Set the linker and compiler flags.
project_header_default("STANDARD_GNU_17:YES" "STRICT_WARNINGS:YES")

find_package(absl)

generate_edl_file(Hello PREFIX example)
nk_build_edl_files(Hello_EDL NK_MODULE example EDL "${EDL_FILE}")

add_executable(Hello src/main.cpp)
add_dependencies(Hello Hello_EDL)
target_compile_features(Hello PRIVATE cxx_std_17)
target_link_libraries(Hello PRIVATE absl::strings)
