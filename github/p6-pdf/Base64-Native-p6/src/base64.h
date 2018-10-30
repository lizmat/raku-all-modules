#ifndef __BASE64_H
#define __BASE64_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

DLLEXPORT void base64_encode (uint8_t* in, size_t inlen,
			      uint8_t* out, size_t outlen);

DLLEXPORT void base64_encode_uri (uint8_t* in, size_t inlen,
				  uint8_t* out, size_t outlen);

DLLEXPORT ssize_t base64_decode (uint8_t* in, size_t inlen,
				 uint8_t* out, size_t outlen);

#endif /* __BASE64_H */
