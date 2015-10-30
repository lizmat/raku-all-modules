#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <time.h>

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

#define pre(NAME) j2q(PRE, NAME)
#define j2q(A, B) j2(A, B)
#define j2(A, B) A ## _ ## B

#undef PRE
#define PRE p6_native_libc_errno
EXPORT int  pre(get)(void)   { return errno; }
EXPORT void pre(set)(int no) { errno = no; }

#undef PRE
#define PRE p6_native_libc_limits
EXPORT int                pre(char_bit)(void)   { return CHAR_BIT; }
EXPORT int                pre(schar_min)(void)  { return SCHAR_MIN; }
EXPORT int                pre(schar_max)(void)  { return SCHAR_MAX; }
EXPORT int                pre(uchar_max)(void)  { return UCHAR_MAX; }
EXPORT int                pre(char_min)(void)   { return CHAR_MIN; }
EXPORT int                pre(char_max)(void)   { return CHAR_MAX; }
EXPORT int                pre(mb_len_max)(void) { return MB_LEN_MAX; }
EXPORT int                pre(shrt_min)(void)   { return SHRT_MIN; }
EXPORT int                pre(shrt_max)(void)   { return SHRT_MAX; }
EXPORT int                pre(ushrt_max)(void)  { return USHRT_MAX; }
EXPORT int                pre(int_min)(void)    { return INT_MIN; }
EXPORT int                pre(int_max)(void)    { return INT_MAX; }
EXPORT unsigned           pre(uint_max)(void)   { return UINT_MAX; }
EXPORT long               pre(long_min)(void)   { return LONG_MIN; }
EXPORT long               pre(long_max)(void)   { return LONG_MAX; }
EXPORT unsigned long      pre(ulong_max)(void)  { return ULONG_MAX; }
EXPORT long long          pre(llong_min)(void)  { return LLONG_MIN; }
EXPORT long long          pre(llong_max)(void)  { return LLONG_MAX; }
EXPORT unsigned long long pre(ullong_max)(void) { return ULLONG_MAX; }

#undef PRE
#define PRE p6_native_libc_stdio
EXPORT int    pre(iofbf)(void)    { return _IOFBF; }
EXPORT int    pre(iolbf)(void)    { return _IOLBF; }
EXPORT int    pre(ionbf)(void)    { return _IONBF; }
EXPORT size_t pre(bufsiz)(void)   { return BUFSIZ; }
EXPORT int    pre(eof)(void)      { return EOF; }
EXPORT int    pre(seek_cur)(void) { return SEEK_CUR; }
EXPORT int    pre(seek_end)(void) { return SEEK_END; }
EXPORT int    pre(seek_set)(void) { return SEEK_SET; }

#undef PRE
#define PRE p6_native_libc_time
EXPORT size_t  pre(clock_size)(void)      { return sizeof (clock_t); }
EXPORT int     pre(clock_is_float)(void)  { return (clock_t)0.5 == 0.5; }
EXPORT int     pre(clock_is_signed)(void) { return (clock_t)-1 < 0; }
EXPORT size_t  pre(time_size)(void)       { return sizeof (time_t); }
EXPORT int     pre(time_is_float)(void)   { return (time_t)0.5 == 0.5; }
EXPORT int     pre(time_is_signed)(void)  { return (time_t)-1 < 0; }
EXPORT clock_t pre(clocks_per_sec)(void)  { return CLOCKS_PER_SEC; }
