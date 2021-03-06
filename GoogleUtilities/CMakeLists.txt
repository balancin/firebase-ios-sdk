# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(APPLE)
  # Environment and Logger subspecs
  file(
    GLOB sources
    Environment/*.m
    Environment/third_party/*.m
    Logger/*.m
  )
  file(
    GLOB headers
    Environment/Public/*.h
    Environment/third_party/*.h
    Logger/Private/*.h
    Logger/Public/*.h
  )

  podspec_version(version ${PROJECT_SOURCE_DIR}/GoogleUtilities.podspec)

  objc_framework(
    GoogleUtilities
    SOURCES ${sources}
    HEADERS ${headers}
    VERSION ${version}
    INCLUDES
      Private
      Public
    DEPENDS
      "-framework Foundation"
    EXCLUDE_FROM_ALL
  )

  target_compile_options(
    GoogleUtilities
    PRIVATE
      -Wno-deprecated-declarations
  )
endif()
