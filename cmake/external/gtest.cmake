# Copyright (c) 2016 Gang Liao <gangliao@umd.edu> All Rights Reserve.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

INCLUDE(ExternalProject)

if (NOT WITH_TESTING)
    return()
endif()

ENABLE_TESTING()

SET(GTEST_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gtest)
SET(GTEST_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/third_party/gtest)
SET(GTEST_INCLUDE_DIR "${GTEST_INSTALL_DIR}/include" CACHE PATH "gtest include directory." FORCE)

INCLUDE_DIRECTORIES(${GTEST_INCLUDE_DIR})

IF(WIN32)
    set(GTEST_LIBRARIES
        "${GTEST_INSTALL_DIR}/lib/gtest.lib" CACHE FILEPATH "gtest libraries." FORCE)
    set(GTEST_MAIN_LIBRARIES
        "${GTEST_INSTALL_DIR}/lib/gtest_main.lib" CACHE FILEPATH "gtest main libraries." FORCE)
ELSE(WIN32)
    set(GTEST_LIBRARIES
        "${GTEST_INSTALL_DIR}/lib/libgtest.a" CACHE FILEPATH "gtest libraries." FORCE)
    set(GTEST_MAIN_LIBRARIES
        "${GTEST_INSTALL_DIR}/lib/libgtest_main.a" CACHE FILEPATH "gtest main libraries." FORCE)
ENDIF(WIN32)

ExternalProject_Add(
    extern_gtest
    ${EXTERNAL_PROJECT_LOG_ARGS}
    SOURCE_DIR       ${GTEST_SOURCES_DIR}
    UPDATE_COMMAND   ""
    DOWNLOAD_COMMAND ""
    ${EXTERNAL_PROJECT_CMAKE_ARGS}
    CMAKE_ARGS       -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    CMAKE_ARGS       -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    CMAKE_ARGS       -DCMAKE_AR=${CMAKE_AR}
    CMAKE_ARGS       -DCMAKE_RANLIB=${CMAKE_RANLIB}
    CMAKE_ARGS       -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    CMAKE_ARGS       -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    CMAKE_ARGS       -DCMAKE_INSTALL_PREFIX=${GTEST_INSTALL_DIR}
    CMAKE_ARGS       -DCMAKE_INSTALL_LIBDIR=${GTEST_INSTALL_DIR}/lib
    CMAKE_ARGS       -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    CMAKE_ARGS       -DBUILD_GMOCK=ON
    CMAKE_ARGS       -Dgtest_disable_pthreads=ON
    CMAKE_ARGS       -Dgtest_force_shared_crt=ON
    CMAKE_ARGS       -DCMAKE_BUILD_TYPE=Release
    CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${GTEST_INSTALL_DIR}
                     -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
                     -DCMAKE_BUILD_TYPE:STRING=Release
)

ADD_LIBRARY(gtest STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET gtest PROPERTY IMPORTED_LOCATION ${GTEST_LIBRARIES})
ADD_DEPENDENCIES(gtest extern_gtest)

ADD_LIBRARY(gtest_main STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET gtest_main PROPERTY IMPORTED_LOCATION ${GTEST_MAIN_LIBRARIES})
ADD_DEPENDENCIES(gtest_main extern_gtest)