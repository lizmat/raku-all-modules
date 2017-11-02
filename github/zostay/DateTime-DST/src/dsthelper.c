#include <time.h>

/*
 * We do this in the shared library because sometimes time_t and fields in tm
 * are 32-bit and sometimes 64-bit. By doing it here, we let the compiler on the
 * destination host work out the details.
 */

unsigned long long is_dst(unsigned long long time) {
    struct tm check_time;
    time_t the_time = (time_t) time;
    localtime_r(&the_time, &check_time);
    return (unsigned long long) check_time.tm_isdst;
}
