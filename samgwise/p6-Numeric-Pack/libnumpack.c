#include <stdint.h>
#include <string.h>

//
// 32 bit packing
//
union Bits32 {
   float f;
   int32_t i;
   char bytes[4];
};

// float:
void pack_rat_to_float(int32_t n, int32_t d, char *bytes) {
  union Bits32 f2b;
  f2b.f = (float)n / d;
  memcpy(bytes, f2b.bytes, 4);
}

float unpack_bits_to_float(char *bytes) {
  union Bits32 f2b;
  memcpy(f2b.bytes, bytes, 4);
  return f2b.f;
}

//int32:
void pack_int32(int32_t i, char *bytes) {
  union Bits32 i2b;
  i2b.i = i;
  memcpy(bytes, i2b.bytes, 4);
}

int32_t unpack_int32(char *bytes) {
  union Bits32 b2i;
  memcpy(b2i.bytes, bytes, 4);
  return b2i.i;
}

//
// 64 bit packing
//
union Bits64 {
   char bytes[8];
   int64_t i;
   double d;
};

void pack_rat_to_double(int64_t n, int64_t d, char *bytes) {
  union Bits64 d2b;
  d2b.d = (double)n / d;
  memcpy(bytes, d2b.bytes, 8);
}

double unpack_bits_to_double(char *bytes) {
  union Bits64 d2b;
  memcpy(d2b.bytes, bytes, 8);
  return d2b.d;
}

//int64:
void pack_int64(int64_t i, char *bytes) {
  union Bits64 i2b;
  i2b.i = i;
  memcpy(bytes, i2b.bytes, 8);
}

int64_t unpack_int64(char *bytes) {
  union Bits64 b2i;
  memcpy(b2i.bytes, bytes, 8);
  return b2i.i;
}
