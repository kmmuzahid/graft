cmake_minimum_required(VERSION 3.10)
project(graft_simd LANGUAGES C)

add_library(graft_simd SHARED
    graft_simd.c
    graft_simd.h
)

set_target_properties(graft_simd PROPERTIES
    PUBLIC_HEADER graft_simd.h
    C_STANDARD 99
    C_VISIBILITY_PRESET default
)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64|ARM64")
    if (MSVC)
        # MSVC ARM64 enables Neon by default
    else()
        target_compile_options(graft_simd PRIVATE -O3)
    endif()
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    if (MSVC)
        target_compile_options(graft_simd PRIVATE /O2 /arch:AVX2)
    else()
        target_compile_options(graft_simd PRIVATE -O3 -msse4.1)
    endif()
endif()
