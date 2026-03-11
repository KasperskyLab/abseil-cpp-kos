# © 2026 AO Kaspersky Lab
# Licensed under the MIT License

# Declare and fetch the KasperskyOS-adapted Abseil C++ library.

cmake_minimum_required (VERSION 3.29)

project (abseil-cpp-kos LANGUAGES C CXX)

include (FetchContent)

option (ABSL_ENABLE_INSTALL "Generate installation target" ON)

# Configure the source location and patch application for Abseil C++ library.
# Official Abseil C++ library repository.
set (GIT_REPOSITORY https://github.com/abseil/abseil-cpp.git)
# Specific version to fetch.
set (GIT_TAG        20250512.0)
# Apply KasperskyOS adaptation patch after downloading.
set (GIT_PATCH      ${CMAKE_CURRENT_LIST_DIR}/KasperskyOS-CE-adaptation.patch)
set (PATCH_COMMAND  git apply ${GIT_PATCH})

# Prevent redundant patch application on subsequent builds.
if (ABSEIL_CPP_POPULATED)
    # Library has already been fetched — skip patching to avoid conflicts.
    set (PATCH_COMMAND)
else ()
    message (STATUS "Downloading abseil-cpp ${GIT_TAG}")
endif ()

# Declare the external dependency with patch configuration.
FetchContent_Declare (abseil-cpp
                      GIT_REPOSITORY ${GIT_REPOSITORY}
                      GIT_TAG        ${GIT_TAG}
                      GIT_SHALLOW    YES
                      PATCH_COMMAND  ${PATCH_COMMAND})

# Execute the download and integration of the Abseil C++ library into the build system.
FetchContent_MakeAvailable (abseil-cpp)

# Cache the population state to optimize subsequent builds.
set (ABSEIL_CPP_POPULATED ${abseil-cpp_POPULATED} CACHE INTERNAL "")
