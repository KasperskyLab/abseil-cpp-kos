// Copyright 2021 The Abseil Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// © 2024 AO Kaspersky Lab
// Licensed under the Apache License, Version 2.0 (the "License")

#include "absl/strings/internal/cord_rep_crc.h"

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "absl/base/config.h"
#include "absl/strings/internal/cord_internal.h"
#include "absl/strings/internal/cord_rep_test_util.h"

namespace absl {
ABSL_NAMESPACE_BEGIN
namespace cord_internal {
namespace {

using ::absl::cordrep_testing::MakeFlat;
using ::testing::Eq;
using ::testing::Ne;

#if !defined(NDEBUG) && defined(GTEST_HAS_DEATH_TEST)

TEST(CordRepCrc, NewWithNullPtr) {
  EXPECT_DEATH(CordRepCrc::New(nullptr, 0), "");
}

TEST(CordRepCrc, RemoveCrcWithNullptr) {
  EXPECT_DEATH(RemoveCrcNode(nullptr), "");
}

#endif  // !NDEBUG && GTEST_HAS_DEATH_TEST

TEST(CordRepCrc, NewDestroy) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRepCrc* crc = CordRepCrc::New(rep, 12345);
  EXPECT_TRUE(crc->refcount.IsOne());
  EXPECT_THAT(crc->child, Eq(rep));
  EXPECT_THAT(crc->crc, Eq(12345));
  EXPECT_TRUE(rep->refcount.IsOne());
  CordRepCrc::Destroy(crc);
}

TEST(CordRepCrc, NewExistingCrcNotShared) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRepCrc* crc = CordRepCrc::New(rep, 12345);
  CordRepCrc* new_crc = CordRepCrc::New(crc, 54321);
  EXPECT_THAT(new_crc, Eq(crc));
  EXPECT_TRUE(new_crc->refcount.IsOne());
  EXPECT_THAT(new_crc->child, Eq(rep));
  EXPECT_THAT(new_crc->crc, Eq(54321));
  EXPECT_TRUE(rep->refcount.IsOne());
  CordRepCrc::Destroy(new_crc);
}

TEST(CordRepCrc, NewExistingCrcShared) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRepCrc* crc = CordRepCrc::New(rep, 12345);
  CordRep::Ref(crc);
  CordRepCrc* new_crc = CordRepCrc::New(crc, 54321);

  EXPECT_THAT(new_crc, Ne(crc));
  EXPECT_TRUE(new_crc->refcount.IsOne());
  EXPECT_TRUE(crc->refcount.IsOne());
  EXPECT_FALSE(rep->refcount.IsOne());
  EXPECT_THAT(crc->child, Eq(rep));
  EXPECT_THAT(new_crc->child, Eq(rep));
  EXPECT_THAT(crc->crc, Eq(12345));
  EXPECT_THAT(new_crc->crc, Eq(54321));

  CordRep::Unref(crc);
  CordRep::Unref(new_crc);
}

TEST(CordRepCrc, RemoveCrcNotCrc) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRep* nocrc = RemoveCrcNode(rep);
  EXPECT_THAT(nocrc, Eq(rep));
  CordRep::Unref(nocrc);
}

TEST(CordRepCrc, RemoveCrcNotShared) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRepCrc* crc = CordRepCrc::New(rep, 12345);
  CordRep* nocrc = RemoveCrcNode(crc);
  EXPECT_THAT(nocrc, Eq(rep));
  EXPECT_TRUE(rep->refcount.IsOne());
  CordRep::Unref(nocrc);
}

TEST(CordRepCrc, RemoveCrcShared) {
  CordRep* rep = cordrep_testing::MakeFlat("Hello world");
  CordRepCrc* crc = CordRepCrc::New(rep, 12345);
  CordRep::Ref(crc);
  CordRep* nocrc = RemoveCrcNode(crc);
  EXPECT_THAT(nocrc, Eq(rep));
  EXPECT_FALSE(rep->refcount.IsOne());
  CordRep::Unref(nocrc);
  CordRep::Unref(crc);
}

}  // namespace
}  // namespace cord_internal
ABSL_NAMESPACE_END
}  // namespace absl
