#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* Get prototype. */
#include "base64.h"

#define B64_ENC_COMMON "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define B64_ENC_STD B64_ENC_COMMON "+/"
#define B64_ENC_URI B64_ENC_COMMON "-_"
static const char b64_enc_std[64] = B64_ENC_STD;
static const char b64_enc_uri[64] = B64_ENC_URI;

// --- Base-64 byte decoding table ---

#define PADDING '='
#define W 254 // Whitespace
#define X 255 // Illegal Character

static uint8_t b64_dec[256] = {
//  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  // 0 
    W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  W,  // 1
    W,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  62, X,  62, X,  63, // 2
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, X,  X,  X,  X,  X,  X,  // 3
    X,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,  // 4
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, X,  X,  X,  X,  63, // 5
    X,  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, // 6
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, X,  X,  X,  X,  X,  // 7
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // 8
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // 9
    W,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // A
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // B
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // C
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // D
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  // E
    X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X,  X   // F
};

// --- Base-64 encoding ---

static void
base64_encode_blocks (const char *enc, uint8_t *in, size_t block_count, uint8_t *out) {
  for (;block_count > 0; block_count--, in += 3) {
      *out++ = enc[in[0] >> 2];
      *out++ = enc[((in[0] << 4) + (in[1] >> 4)) & 0x3f];
      *out++ = enc[((in[1] << 2) + (in[2] >> 6)) & 0x3f];
      *out++ = enc[in[2] & 0x3f];
    }
}

static void
base64_encode_tail (const char *b64_enc_table,
                   uint8_t* in, size_t inlen,
                   size_t whole_blocks,
                   uint8_t* out, size_t outlen
                   ) {

  /* Skip over whole blocks */
  inlen -= whole_blocks * 3;
  in += whole_blocks * 3;
  outlen -= whole_blocks * 4;
  out += whole_blocks * 4;

  if (inlen > 0 && outlen > 0) {
    /* Prepare final partial block */
    uint8_t in_tail[3] = {
      in[0],
      inlen > 1 ? in[1] : 0,
      inlen > 2 ? in[2] : 0
    };
    uint8_t out_tail[4];
    uint8_t i;

    base64_encode_blocks (b64_enc_std, in_tail, 1, out_tail);
    /* Pad */
    if (inlen < 2) {
      out_tail[2] = PADDING;
    }
    out_tail[3] = PADDING;

    for (i = 0; i < 4 && outlen > 0; outlen--) {
      *out++ = out_tail[i++];
    }
  }

}

static void
encode (const char *b64_enc_table,
	uint8_t* in, size_t inlen,
	uint8_t* out, size_t outlen) {
  size_t whole_blocks = inlen / 3;
  if (whole_blocks * 4 > outlen) {
    whole_blocks = outlen / 4;
  }
  base64_encode_blocks (b64_enc_table, in, whole_blocks, out);
  base64_encode_tail (b64_enc_table, in, inlen, whole_blocks, out, outlen);

}

DLLEXPORT void
base64_encode (uint8_t* in, size_t inlen,
	       uint8_t* out, size_t outlen) {
  encode (b64_enc_std, in, inlen, out, outlen);
}

DLLEXPORT void
base64_encode_uri (uint8_t* in, size_t inlen,
		   uint8_t* out, size_t outlen) {
  encode (b64_enc_uri, in, inlen, out, outlen);
}

// --- Base-64 decoding ---
// Works with both URI and STD encoded data.

static uint8_t next_digit (uint8_t* in,
			  size_t inlen,
			  size_t *i,
			  uint8_t *n_digits,
			  ssize_t *error_pos
			  ) {
  uint8_t digit = 0;

  if (*i < inlen) {
    digit = b64_dec[ in[ (*i)++ ] ];

    switch (digit) {
      case X : // Illegal character
	if (!*error_pos) *error_pos = *i;
      case W : // White-space
        digit = next_digit(in, inlen, i, n_digits, error_pos);
        break;

      default : // Valid digit
	(*n_digits)++;
    }
  }

  return digit;
}

DLLEXPORT ssize_t
base64_decode (uint8_t* in, size_t inlen,
	       uint8_t* out, size_t outlen) {
    size_t i;
    int32_t j;
    ssize_t error_pos = 0;

    // Right trim padding and whitespace
    while (inlen > 0
           && (in[inlen - 1] == PADDING
               || b64_dec[ in[inlen - 1] ] == W)) {
      inlen--;
    }

    for (i = 0, j = 0; i < inlen && j < outlen && !error_pos;) {

      uint32_t triple = 0;
      uint8_t n_digits = 0;
      int8_t k, m;

      for (k = 0; k < 4; k++) {
        triple <<= 6;
	triple += next_digit(in, inlen, &i, &n_digits, &error_pos);
      }

      m = n_digits == 4 ? 0 : n_digits == 3 ? 1 : 2;
      for (k = 2; k >= m && j < outlen; k--) {
	out[j++] = triple >> k * 8;
      }
    }

    return error_pos ? -error_pos : j;
}
