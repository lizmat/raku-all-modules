/* public api for steve reid's public domain SHA-1 implementation */
/* this file is in the public domain */

#ifndef __SHA1_H
#define __SHA1_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    unsigned int  state[5];
    unsigned int  count[2];
    unsigned char buffer[64];
} SHA1_CTX;

#define SHA1_DIGEST_SIZE 20

DLLEXPORT void compute_sha1(const unsigned char *str, size_t len, unsigned char *output);

#ifdef __cplusplus
}
#endif

#endif /* __SHA1_H */
