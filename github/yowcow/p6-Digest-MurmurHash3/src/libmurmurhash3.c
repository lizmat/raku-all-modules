#include "MurmurHash3.h"

uint32_t
MurmurHash3_x86_32_i(const void * key, int len, uint32_t seed)
{
    uint32_t out = 0;
    MurmurHash3_x86_32(key, len, seed, &out);
    return out;
}
