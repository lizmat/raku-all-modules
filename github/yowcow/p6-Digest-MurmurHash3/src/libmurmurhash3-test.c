#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include "MurmurHash3.h"

void test_MurmurHash3_x86_32() {
    const char * key = "hogefugafoobar";
    int len = 14;
    uint32_t seed = 12345678;
    uint32_t result;

    printf("Testing %s ... ", __func__);

    MurmurHash3_x86_32(key, len, seed, &result);

    assert(result == 463552099);

    printf("Done\n");
}

void test_MurmurHash3_x86_128() {
    const char * key = "hogefugafoobar";
    int len = 14;
    uint32_t seed = 12345678;
    uint32_t result[4];

    printf("Testing %s ... ", __func__);

    MurmurHash3_x86_128(key, len, seed, &result);

    assert(result[0] == 1512736128);
    assert(result[1] == 3528938480);
    assert(result[2] == 3633978259);
    assert(result[3] == 481906499);

    printf("Done\n");
}

int main() {

    test_MurmurHash3_x86_32();
    test_MurmurHash3_x86_128();

    return 0;
}
