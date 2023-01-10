# Abseil adaptation for KasperskyOS - C++ Common Libraries

This is a fork of [Abseil C++](https://github.com/abseil/abseil-cpp) project adapted to be used with KasperskyOS. For more information about the target OS, please refer to [KaspeksyOS Community Edition](https://support.kaspersky.com/help/KCE/1.1/en-US/community_edition.htm).

The repository contains the Abseil C++ library code. Abseil is an open-source collection of C++ code (compliant to C++11) designed to augment the C++ standard library.

For general information on using Abseil, its features and so on, please see the [Abseil website](https://abseil.io/about).


## About Abseil

Abseil is an open-source collection of C++ library code designed to augment
the C++ standard library. The Abseil library code is collected from Google's
own C++ code base, has been extensively tested and used in production, and
is the same code we depend on in our daily coding lives.

In some cases, Abseil provides pieces missing from the C++ standard; in
others, Abseil provides alternatives to the standard for special needs
we've found through usage in the Google code base. We denote those cases
clearly within the library code we provide you.

Abseil is not meant to be a competitor to the standard library; we've
just found that many of these utilities serve a purpose within our code
base, and we now want to provide those resources to the C++ community as
a whole.


## Quickstart

If you want to just get started, make sure you at least run through the
[Abseil Quickstart](https://abseil.io/docs/cpp/quickstart). The Quickstart
contains information about setting up your development environment, downloading
the Abseil code, running tests, and getting a simple binary working.


## Building Abseil

For a default build and use, you need to install the KasperskyOS Community Edition SDK on your system. The latest version of the SDK can be downloaded from this [link](https://os.kaspersky.com/development/). The Abseil source code has been checked on the KasperskyOS Community Edition SDK version 1.1.0.

[Bazel](https://bazel.build) and [CMake](https://cmake.org/) are the official
build systems for Abseil.

See the [quickstart](https://abseil.io/docs/cpp/quickstart) for more information
on building Abseil using the Bazel build system.

If you require CMake support, please check the [CMake build
instructions](CMake/README.md) and [CMake
Quickstart](https://abseil.io/docs/cpp/quickstart-cmake).

## Codemap

Abseil contains the following C++ library components:

* [`base`](absl/base/) Abseil Fundamentals
  <br /> The `base` library contains initialization code and other code which
  all other Abseil code depends on. Code within `base` may not depend on any
  other code (other than the C++ standard library).
* [`algorithm`](absl/algorithm/)
  <br /> The `algorithm` library contains additions to the C++ `<algorithm>`
  library and container-based versions of such algorithms.
* [`cleanup`](absl/cleanup/)
  <br /> The `cleanup` library contains the control-flow-construct-like type
  `absl::Cleanup` which is used for executing a callback on scope exit.
* [`container`](absl/container/)
  <br /> The `container` library contains additional STL-style containers,
  including Abseil's unordered "Swiss table" containers.
* [`debugging`](absl/debugging/)
  <br /> The `debugging` library contains code useful for enabling leak
  checks, and stacktrace and symbolization utilities.
* [`hash`](absl/hash/)
  <br /> The `hash` library contains the hashing framework and default hash
  functor implementations for hashable types in Abseil.
* [`memory`](absl/memory/)
  <br /> The `memory` library contains C++11-compatible versions of
  `std::make_unique()` and related memory management facilities.
* [`meta`](absl/meta/)
  <br /> The `meta` library contains C++11-compatible versions of type checks
  available within C++14 and C++17 versions of the C++ `<type_traits>` library.
* [`numeric`](absl/numeric/)
  <br /> The `numeric` library contains C++11-compatible 128-bit integers.
* [`profiling`](absl/profiling/)
  <br /> The `profiling` library contains utility code for profiling C++
  entities.  It is currently a private dependency of other Abseil libraries.
* [`status`](absl/status/)
  <br /> The `status` contains abstractions for error handling, specifically
  `absl::Status` and `absl::StatusOr<T>`.
* [`strings`](absl/strings/)
  <br /> The `strings` library contains a variety of strings routines and
  utilities, including a C++11-compatible version of the C++17
  `std::string_view` type.
* [`synchronization`](absl/synchronization/)
  <br /> The `synchronization` library contains concurrency primitives (Abseil's
  `absl::Mutex` class, an alternative to `std::mutex`) and a variety of
  synchronization abstractions.
* [`time`](absl/time/)
  <br /> The `time` library contains abstractions for computing with absolute
  points in time, durations of time, and formatting and parsing time within
  time zones.
* [`types`](absl/types/)
  <br /> The `types` library contains non-container utility types, like a
  C++11-compatible version of the C++17 `std::optional` type.
* [`utility`](absl/utility/)
  <br /> The `utility` library contains utility and helper code.

## Contributing
Please see the [Contributing](CONTRIBUTING.md) page for generic info.

We'll follow the parent project contributing rules but would consider to accept only KasperskyOS-specific changes, so for that it is advised to use pull-requests.

## License

The Abseil C++ library is licensed under the terms of the Apache
license. See [LICENSE](LICENSE) for more information.

## Links

For more information about Abseil:

* Consult [Abseil Introduction](https://abseil.io/about/intro)
* Read [Why Adopt Abseil](https://abseil.io/about/philosophy) to understand the design philosophy.
* Peruse [Abseil Compatibility Guarantees](https://abseil.io/about/compatibility).
