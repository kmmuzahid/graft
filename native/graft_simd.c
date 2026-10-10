#include "graft_simd.h"
#include <string.h>

#if defined(__ARM_NEON) || defined(__ARM_NEON__)
#include <arm_neon.h>
#define GRAFT_HAS_NEON 1
#endif

#if defined(__x86_64__) || defined(_M_X64)
#if defined(__SSE4_1__)
#include <smmintrin.h>
#define GRAFT_HAS_SSE4 1
#endif
#endif

GRAFT_EXPORT int32_t graft_simd_version(void) {
    return 100; // 1.0.0
}

GRAFT_EXPORT int32_t graft_simd_diff_props(
    const int64_t* old_props,
    const int64_t* new_props,
    int64_t count,
    uint64_t* out_dirty_words
) {
    if (count <= 0) {
        return 0;
    }

    const int64_t num_words = (count + 63) / 64;
    memset(out_dirty_words, 0, (size_t)num_words * sizeof(uint64_t));

    int32_t has_diff = 0;
    int64_t i = 0;

#if defined(GRAFT_HAS_NEON)
    // ⚡ ARM NEON 128-bit vector path (2x 64-bit lanes per register)
    // Unrolled by 4 vectors = 8 lanes (64 bytes) per iteration
    for (; i + 7 < count; i += 8) {
        uint64x2_t a0 = vld1q_u64((const uint64_t*)(old_props + i));
        uint64x2_t b0 = vld1q_u64((const uint64_t*)(new_props + i));
        uint64x2_t eq0 = vceqq_u64(a0, b0);

        uint64x2_t a1 = vld1q_u64((const uint64_t*)(old_props + i + 2));
        uint64x2_t b1 = vld1q_u64((const uint64_t*)(new_props + i + 2));
        uint64x2_t eq1 = vceqq_u64(a1, b1);

        uint64x2_t a2 = vld1q_u64((const uint64_t*)(old_props + i + 4));
        uint64x2_t b2 = vld1q_u64((const uint64_t*)(new_props + i + 4));
        uint64x2_t eq2 = vceqq_u64(a2, b2);

        uint64x2_t a3 = vld1q_u64((const uint64_t*)(old_props + i + 6));
        uint64x2_t b3 = vld1q_u64((const uint64_t*)(new_props + i + 6));
        uint64x2_t eq3 = vceqq_u64(a3, b3);

        // Bitwise invert: 0xFFFFFFFFFFFFFFFF if equal -> 0 if equal, 1 if unequal
        uint64_t neq0 = ~vgetq_lane_u64(eq0, 0);
        uint64_t neq1 = ~vgetq_lane_u64(eq0, 1);
        uint64_t neq2 = ~vgetq_lane_u64(eq1, 0);
        uint64_t neq3 = ~vgetq_lane_u64(eq1, 1);
        uint64_t neq4 = ~vgetq_lane_u64(eq2, 0);
        uint64_t neq5 = ~vgetq_lane_u64(eq2, 1);
        uint64_t neq6 = ~vgetq_lane_u64(eq3, 0);
        uint64_t neq7 = ~vgetq_lane_u64(eq3, 1);

        if (neq0) { out_dirty_words[(i + 0) >> 6] |= (1ULL << ((i + 0) & 63)); has_diff = 1; }
        if (neq1) { out_dirty_words[(i + 1) >> 6] |= (1ULL << ((i + 1) & 63)); has_diff = 1; }
        if (neq2) { out_dirty_words[(i + 2) >> 6] |= (1ULL << ((i + 2) & 63)); has_diff = 1; }
        if (neq3) { out_dirty_words[(i + 3) >> 6] |= (1ULL << ((i + 3) & 63)); has_diff = 1; }
        if (neq4) { out_dirty_words[(i + 4) >> 6] |= (1ULL << ((i + 4) & 63)); has_diff = 1; }
        if (neq5) { out_dirty_words[(i + 5) >> 6] |= (1ULL << ((i + 5) & 63)); has_diff = 1; }
        if (neq6) { out_dirty_words[(i + 6) >> 6] |= (1ULL << ((i + 6) & 63)); has_diff = 1; }
        if (neq7) { out_dirty_words[(i + 7) >> 6] |= (1ULL << ((i + 7) & 63)); has_diff = 1; }
    }
#elif defined(GRAFT_HAS_SSE4)
    // ⚡ x86_64 SSE4.1 128-bit vector path (2x 64-bit lanes per register)
    for (; i + 3 < count; i += 4) {
        __m128i a0 = _mm_loadu_si128((const __m128i*)(old_props + i));
        __m128i b0 = _mm_loadu_si128((const __m128i*)(new_props + i));
        __m128i eq0 = _mm_cmpeq_epi64(a0, b0);

        __m128i a1 = _mm_loadu_si128((const __m128i*)(old_props + i + 2));
        __m128i b1 = _mm_loadu_si128((const __m128i*)(new_props + i + 2));
        __m128i eq1 = _mm_cmpeq_epi64(a1, b1);

        uint64_t val0 = (uint64_t)_mm_extract_epi64(eq0, 0);
        uint64_t val1 = (uint64_t)_mm_extract_epi64(eq0, 1);
        uint64_t val2 = (uint64_t)_mm_extract_epi64(eq1, 0);
        uint64_t val3 = (uint64_t)_mm_extract_epi64(eq1, 1);

        if (~val0) { out_dirty_words[(i + 0) >> 6] |= (1ULL << ((i + 0) & 63)); has_diff = 1; }
        if (~val1) { out_dirty_words[(i + 1) >> 6] |= (1ULL << ((i + 1) & 63)); has_diff = 1; }
        if (~val2) { out_dirty_words[(i + 2) >> 6] |= (1ULL << ((i + 2) & 63)); has_diff = 1; }
        if (~val3) { out_dirty_words[(i + 3) >> 6] |= (1ULL << ((i + 3) & 63)); has_diff = 1; }
    }
#endif

    // Remaining scalar elements (and universal fallback)
    for (; i < count; i++) {
        if (old_props[i] != new_props[i]) {
            out_dirty_words[i >> 6] |= (1ULL << (i & 63));
            has_diff = 1;
        }
    }

    return has_diff;
}
