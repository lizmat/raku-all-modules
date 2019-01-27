#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "cast5.h"

#define BLOCK_SIZE 8

struct CAST5 {
    uint32_t *Km;
    uint8_t  *Kr;
    uint8_t   rounds;
};

// Converts 4 uint8_t in an array to a uint32.
static inline void
char_to_word(uint32_t *w, const uint8_t *p)
{
    *w = (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | (uint32_t)p[3];
}

// Converts a uint32 into an array of 4 uint8_t.
static inline void
word_to_char(uint8_t *p, const uint32_t *w)
{
    p[0] = (uint8_t)((*w >> 24) & 0xFF);
    p[1] = (uint8_t)((*w >> 16) & 0xFF);
    p[2] = (uint8_t)((*w >> 8 ) & 0xFF);
    p[3] = (uint8_t)( *w        & 0xFF);
}

// Gets a byte n from a uint32_t array a.
static inline uint8_t
b(uint32_t a[4], uint8_t i)
{
    return a[i >> 2] >> (24 - ((i & 3) << 3)) & 0xFF;
}

// Round function: f(D, Kmi, Kri)
static inline uint32_t
run_round(uint32_t D, uint32_t Kmi, uint8_t Kri, uint8_t type)
{
    uint32_t I;
    uint8_t  Ibe[4];
    uint32_t f;

    switch (type) {
        case 0:
            I = Kmi + D;
            break;
        case 1:
            I = Kmi ^ D;
            break;
        case 2:
            I = Kmi - D;
            break;
    }

    I = (I << Kri) | (I >> (32 - Kri));
    word_to_char(Ibe, &I);

    switch (type) {
        case 0:
            f = ((S1[Ibe[0]] ^ S2[Ibe[1]]) - S3[Ibe[2]]) + S4[Ibe[3]];
            break;
        case 1:
            f = ((S1[Ibe[0]] - S2[Ibe[1]]) + S3[Ibe[2]]) ^ S4[Ibe[3]];
            break;
        case 2:
            f = ((S1[Ibe[0]] + S2[Ibe[1]]) ^ S3[Ibe[2]]) - S4[Ibe[3]];
            break;
    }

    return f;
}

struct CAST5 *
cast5_init(const uint8_t *key, size_t key_len)
{
    uint8_t  padded_key[16];
    uint32_t Kr_wide[16];
    uint32_t x[4];
    uint32_t z[4];
    size_t   i;

    struct CAST5 *cast5 = calloc(1, sizeof(struct CAST5));
    cast5->Km = calloc(16, sizeof(uint32_t));
    cast5->Kr = calloc(16, sizeof(uint8_t));
    cast5->rounds = (key_len <= 10) ? 12 : 16;

    /**
     * Run our key schedule. This initializes are masking and rotating keys.
     */

    bzero(padded_key, 16);
    for (i = 0; i < key_len; ++i)
        padded_key[i] = key[i];

    char_to_word(x, padded_key);
    char_to_word(x + 1, padded_key + 4);
    char_to_word(x + 2, padded_key + 8);
    char_to_word(x + 3, padded_key + 12);

    z[0] = x[0] ^ S5[b(x, 13)] ^ S6[b(x, 15)] ^ S7[b(x, 12)] ^ S8[b(x, 14)] ^ S7[b(x, 8)];
    z[1] = x[2] ^ S5[b(z, 0)] ^ S6[b(z, 2)] ^ S7[b(z, 1)] ^ S8[b(z, 3)] ^ S8[b(x, 10)];
    z[2] = x[3] ^ S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S5[b(x, 9)];
    z[3] = x[1] ^ S5[b(z, 10)] ^ S6[b(z, 9)] ^ S7[b(z, 11)] ^ S8[b(z, 8)] ^ S6[b(x, 11)];
    cast5->Km[0] = S5[b(z, 8)] ^ S6[b(z, 9)] ^ S7[b(z, 7)] ^ S8[b(z, 6)] ^ S5[b(z, 2)];
    cast5->Km[1] = S5[b(z, 10)] ^ S6[b(z, 11)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S6[b(z, 6)];
    cast5->Km[2] = S5[b(z, 12)] ^ S6[b(z, 13)] ^ S7[b(z, 3)] ^ S8[b(z, 2)] ^ S7[b(z, 9)];
    cast5->Km[3] = S5[b(z, 14)] ^ S6[b(z, 15)] ^ S7[b(z, 1)] ^ S8[b(z, 0)] ^ S8[b(z, 12)];

    x[0] = z[2] ^ S5[b(z, 5)] ^ S6[b(z, 7)] ^ S7[b(z, 4)] ^ S8[b(z, 6)] ^ S7[b(z, 0)];
    x[1] = z[0] ^ S5[b(x, 0)] ^ S6[b(x, 2)] ^ S7[b(x, 1)] ^ S8[b(x, 3)] ^ S8[b(z, 2)];
    x[2] = z[1] ^ S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S5[b(z, 1)];
    x[3] = z[3] ^ S5[b(x, 10)] ^ S6[b(x, 9)] ^ S7[b(x, 11)] ^ S8[b(x, 8)] ^ S6[b(z, 3)];
    cast5->Km[4] = S5[b(x, 3)] ^ S6[b(x, 2)] ^ S7[b(x, 12)] ^ S8[b(x, 13)] ^ S5[b(x, 8)];
    cast5->Km[5] = S5[b(x, 1)] ^ S6[b(x, 0)] ^ S7[b(x, 14)] ^ S8[b(x, 15)] ^ S6[b(x, 13)];
    cast5->Km[6] = S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 8)] ^ S8[b(x, 9)] ^ S7[b(x, 3)];
    cast5->Km[7] = S5[b(x, 5)] ^ S6[b(x, 4)] ^ S7[b(x, 10)] ^ S8[b(x, 11)] ^ S8[b(x, 7)];

    z[0] = x[0] ^ S5[b(x, 13)] ^ S6[b(x, 15)] ^ S7[b(x, 12)] ^ S8[b(x, 14)] ^ S7[b(x, 8)];
    z[1] = x[2] ^ S5[b(z, 0)] ^ S6[b(z, 2)] ^ S7[b(z, 1)] ^ S8[b(z, 3)] ^ S8[b(x, 10)];
    z[2] = x[3] ^ S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S5[b(x, 9)];
    z[3] = x[1] ^ S5[b(z, 10)] ^ S6[b(z, 9)] ^ S7[b(z, 11)] ^ S8[b(z, 8)] ^ S6[b(x, 11)];
    cast5->Km[8]  = S5[b(z, 3)] ^ S6[b(z, 2)] ^ S7[b(z, 12)] ^ S8[b(z, 13)] ^ S5[b(z, 9)];
    cast5->Km[9] = S5[b(z, 1)] ^ S6[b(z, 0)] ^ S7[b(z, 14)] ^ S8[b(z, 15)] ^ S6[b(z, 12)];
    cast5->Km[10] = S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 8)] ^ S8[b(z, 9)] ^ S7[b(z, 2)];
    cast5->Km[11] = S5[b(z, 5)] ^ S6[b(z, 4)] ^ S7[b(z, 10)] ^ S8[b(z, 11)] ^ S8[b(z, 6)];

    x[0] = z[2] ^ S5[b(z, 5)] ^ S6[b(z, 7)] ^ S7[b(z, 4)] ^ S8[b(z, 6)] ^ S7[b(z, 0)];
    x[1] = z[0] ^ S5[b(x, 0)] ^ S6[b(x, 2)] ^ S7[b(x, 1)] ^ S8[b(x, 3)] ^ S8[b(z, 2)];
    x[2] = z[1] ^ S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S5[b(z, 1)];
    x[3] = z[3] ^ S5[b(x, 10)] ^ S6[b(x, 9)] ^ S7[b(x, 11)] ^ S8[b(x, 8)] ^ S6[b(z, 3)];
    cast5->Km[12] = S5[b(x, 8)] ^ S6[b(x, 9)] ^ S7[b(x, 7)] ^ S8[b(x, 6)] ^ S5[b(x, 3)];
    cast5->Km[13] = S5[b(x, 10)] ^ S6[b(x, 11)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S6[b(x, 7)];
    cast5->Km[14] = S5[b(x, 12)] ^ S6[b(x, 13)] ^ S7[b(x, 3)] ^ S8[b(x, 2)] ^ S7[b(x, 8)];
    cast5->Km[15] = S5[b(x, 14)] ^ S6[b(x, 15)] ^ S7[b(x, 1)] ^ S8[b(x, 0)] ^ S8[b(x, 13)];

    z[0] = x[0] ^ S5[b(x, 13)] ^ S6[b(x, 15)] ^ S7[b(x, 12)] ^ S8[b(x, 14)] ^ S7[b(x, 8)];
    z[1] = x[2] ^ S5[b(z, 0)] ^ S6[b(z, 2)] ^ S7[b(z, 1)] ^ S8[b(z, 3)] ^ S8[b(x, 10)];
    z[2] = x[3] ^ S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S5[b(x, 9)];
    z[3] = x[1] ^ S5[b(z, 10)] ^ S6[b(z, 9)] ^ S7[b(z, 11)] ^ S8[b(z, 8)] ^ S6[b(x, 11)];
    Kr_wide[0] = S5[b(z, 8)] ^ S6[b(z, 9)] ^ S7[b(z, 7)] ^ S8[b(z, 6)] ^ S5[b(z, 2)];
    Kr_wide[1] = S5[b(z, 10)] ^ S6[b(z, 11)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S6[b(z, 6)];
    Kr_wide[2] = S5[b(z, 12)] ^ S6[b(z, 13)] ^ S7[b(z, 3)] ^ S8[b(z, 2)] ^ S7[b(z, 9)];
    Kr_wide[3] = S5[b(z, 14)] ^ S6[b(z, 15)] ^ S7[b(z, 1)] ^ S8[b(z, 0)] ^ S8[b(z, 12)];

    x[0] = z[2] ^ S5[b(z, 5)] ^ S6[b(z, 7)] ^ S7[b(z, 4)] ^ S8[b(z, 6)] ^ S7[b(z, 0)];
    x[1] = z[0] ^ S5[b(x, 0)] ^ S6[b(x, 2)] ^ S7[b(x, 1)] ^ S8[b(x, 3)] ^ S8[b(z, 2)];
    x[2] = z[1] ^ S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S5[b(z, 1)];
    x[3] = z[3] ^ S5[b(x, 10)] ^ S6[b(x, 9)] ^ S7[b(x, 11)] ^ S8[b(x, 8)] ^ S6[b(z, 3)];
    Kr_wide[4] = S5[b(x, 3)] ^ S6[b(x, 2)] ^ S7[b(x, 12)] ^ S8[b(x, 13)] ^ S5[b(x, 8)];
    Kr_wide[5] = S5[b(x, 1)] ^ S6[b(x, 0)] ^ S7[b(x, 14)] ^ S8[b(x, 15)] ^ S6[b(x, 13)];
    Kr_wide[6] = S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 8)] ^ S8[b(x, 9)] ^ S7[b(x, 3)];
    Kr_wide[7] = S5[b(x, 5)] ^ S6[b(x, 4)] ^ S7[b(x, 10)] ^ S8[b(x, 11)] ^ S8[b(x, 7)];

    z[0] = x[0] ^ S5[b(x, 13)] ^ S6[b(x, 15)] ^ S7[b(x, 12)] ^ S8[b(x, 14)] ^ S7[b(x, 8)];
    z[1] = x[2] ^ S5[b(z, 0)] ^ S6[b(z, 2)] ^ S7[b(z, 1)] ^ S8[b(z, 3)] ^ S8[b(x, 10)];
    z[2] = x[3] ^ S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 5)] ^ S8[b(z, 4)] ^ S5[b(x, 9)];
    z[3] = x[1] ^ S5[b(z, 10)] ^ S6[b(z, 9)] ^ S7[b(z, 11)] ^ S8[b(z, 8)] ^ S6[b(x, 11)];
    Kr_wide[8]  = S5[b(z, 3)] ^ S6[b(z, 2)] ^ S7[b(z, 12)] ^ S8[b(z, 13)] ^ S5[b(z, 9)];
    Kr_wide[9] = S5[b(z, 1)] ^ S6[b(z, 0)] ^ S7[b(z, 14)] ^ S8[b(z, 15)] ^ S6[b(z, 12)];
    Kr_wide[10] = S5[b(z, 7)] ^ S6[b(z, 6)] ^ S7[b(z, 8)] ^ S8[b(z, 9)] ^ S7[b(z, 2)];
    Kr_wide[11] = S5[b(z, 5)] ^ S6[b(z, 4)] ^ S7[b(z, 10)] ^ S8[b(z, 11)] ^ S8[b(z, 6)];

    x[0] = z[2] ^ S5[b(z, 5)] ^ S6[b(z, 7)] ^ S7[b(z, 4)] ^ S8[b(z, 6)] ^ S7[b(z, 0)];
    x[1] = z[0] ^ S5[b(x, 0)] ^ S6[b(x, 2)] ^ S7[b(x, 1)] ^ S8[b(x, 3)] ^ S8[b(z, 2)];
    x[2] = z[1] ^ S5[b(x, 7)] ^ S6[b(x, 6)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S5[b(z, 1)];
    x[3] = z[3] ^ S5[b(x, 10)] ^ S6[b(x, 9)] ^ S7[b(x, 11)] ^ S8[b(x, 8)] ^ S6[b(z, 3)];
    Kr_wide[12] = S5[b(x, 8)] ^ S6[b(x, 9)] ^ S7[b(x, 7)] ^ S8[b(x, 6)] ^ S5[b(x, 3)];
    Kr_wide[13] = S5[b(x, 10)] ^ S6[b(x, 11)] ^ S7[b(x, 5)] ^ S8[b(x, 4)] ^ S6[b(x, 7)];
    Kr_wide[14] = S5[b(x, 12)] ^ S6[b(x, 13)] ^ S7[b(x, 3)] ^ S8[b(x, 2)] ^ S7[b(x, 8)];
    Kr_wide[15] = S5[b(x, 14)] ^ S6[b(x, 15)] ^ S7[b(x, 1)] ^ S8[b(x, 0)] ^ S8[b(x, 13)];

    // Only 5 bits of the rotating key are used.
    for (i = 0; i < 16; ++i)
        cast5->Kr[i] = Kr_wide[i] & 0x1F;

    return cast5;
}

void
cast5_encode(struct CAST5 *cast5, const uint8_t *in, uint8_t *out)
{
    uint32_t L;
    uint32_t R;
    uint32_t tmp;
    uint32_t Kmi;
    uint8_t  Kri;
    uint8_t  type;
    uint32_t f;
    size_t   i;

    char_to_word(&L, in);
    char_to_word(&R, in + 4);

    for (i = 0; i < cast5->rounds; ++i) {
        Kmi  = cast5->Km[i];
        Kri  = cast5->Kr[i];
        type = i % 3;
        f    = run_round(R, Kmi, Kri, type);

        tmp = L;
        L   = R;
        R   = tmp ^ f;
    }

    word_to_char(out, &R);
    word_to_char(out + 4, &L);
}

void
cast5_decode(struct CAST5 *cast5, const uint8_t *in, uint8_t *out)
{
    uint32_t L;
    uint32_t R;
    uint32_t tmp;
    uint32_t Kmi;
    uint8_t  Kri;
    uint8_t  type;
    uint32_t f;
    size_t   i;

    char_to_word(&L, in);
    char_to_word(&R, in + 4);

    for (i = 0; i < cast5->rounds; ++i) {
        Kmi  = cast5->Km[cast5->rounds - i - 1];
        Kri  = cast5->Kr[cast5->rounds - i - 1];
        type = (cast5->rounds - i - 1) % 3;
        f    = run_round(R, Kmi, Kri, type);

        tmp = L;
        L   = R;
        R   = tmp ^ f;
    }

    word_to_char(out, &R);
    word_to_char(out + 4, &L);
}

void
cast5_free(struct CAST5 *cast5)
{
    if (cast5 != NULL) {
        free(cast5->Km);
        free(cast5->Kr);
        free(cast5);
    }
}
