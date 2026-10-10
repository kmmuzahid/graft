#ifndef GRAFT_SIMD_H
#define GRAFT_SIMD_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define GRAFT_EXPORT __declspec(dllexport)
#else
#define GRAFT_EXPORT __attribute__((visibility("default")))
#endif

/**
 * Compares two arrays of 64-bit property values (hashes, pointers, integers)
 * using hardware SIMD vector instructions (ARM Neon / x86 AVX2 / SSE4) when available,
 * writing dirty bits directly into out_dirty_words.
 *
 * Bit set (1) indicates a difference at that property index.
 * Bit clear (0) indicates equality.
 *
 * @param old_props Array of old 64-bit property values.
 * @param new_props Array of new 64-bit property values.
 * @param count Total number of properties to compare.
 * @param out_dirty_words Output buffer of (count + 63) / 64 uint64_t words.
 * @return 1 if any property changed, 0 if identical.
 */
GRAFT_EXPORT int32_t graft_simd_diff_props(
    const int64_t* old_props,
    const int64_t* new_props,
    int64_t count,
    uint64_t* out_dirty_words
);

/**
 * Returns version of the Graft SIMD acceleration engine (e.g. 100 for 1.0.0).
 */
GRAFT_EXPORT int32_t graft_simd_version(void);

#ifdef __cplusplus
}
#endif

#endif // GRAFT_SIMD_H
