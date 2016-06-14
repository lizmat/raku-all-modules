/* readsecret.h                 -*- C -*-
**
** Securely read a password or text secret from a command line (tty device).
**
** by Deron Meranda <http://deron.meranda.us/>
**
** Free software:
**     This code (including the files "readsecret.h" and
**     "readsecret.c") is hereby released into the PUBLIC DOMAIN.
**
**     As some countries or jurisdictions may not legally acknowledge
**     PUBLIC DOMAIN, I also hereby release this under the terms of
**     the "Creative Commons CC0 1.0 Universal" (CC0 1.0) license,
**     which can be read in full at:
**          http://creativecommons.org/publicdomain/zero/1.0/
**
*/

#if ! defined(HEADER_READSECRET_H)
#define HEADER_READSECRET_H

#include <stddef.h>
#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

#define RSECRET_VERSION_MAJOR 1
#define RSECRET_VERSION_MINOR 0
#define RSECRET_VERSION_STR   "1.0"

/* Possible return codes */
typedef enum {
    RSECRET_SUCCESS = 0,
    RSECRET_ERROR_BAD_ARG = 1, /* arguments to function are invalid */
    RSECRET_ERROR_TTY_OPEN = 2, /* can not open the controlling terminal */
    RSECRET_ERROR_SIGACTION = 3, /* failed to establish signal handlers */
    RSECRET_ERROR_NOECHO = 4, /* failed to set terminal to no-echo mode */
    RSECRET_ERROR_PROMPT = 5, /* failed to write prompt */
    RSECRET_ERROR_READ = 6, /* failure during reading of user input */
    RSECRET_ERROR_LENGTH = 7, /* user input was too long to hold in the supplied buffer */
    RSECRET_ERROR_INTERRUPTED = 8, /* program was interrupted during input */
    RSECRET_ERROR_TIMER_CREATE = 9, /* could not create real-time timer */
    RSECRET_ERROR_TIMEOUT = 10 /* User not quick enough, a timeout value expired */
}
rsecret_error_ty;


extern rsecret_error_ty rsecret_get_secret_from_tty(
    char* buf,
    size_t bufsize,
    const char* prompt
    );

extern rsecret_error_ty rsecret_get_secret_from_tty_timed(
    char* buf,
    size_t bufsize,
    const char* prompt,
    struct timespec* timeout
    );


/* rsecret_strerror() - returns a human readable one-line text description
 * of the error code.  Note this is currently in English only.
 */
extern const char* rsecret_strerror( rsecret_error_ty );


/* rsecret_overwrite_buffer() - securely overwrite a password or other
 * string secret.
 *
 * Note that using memset() may no be secure!  Read more at:
 * <http://www.dwheeler.com/secure-programs/Secure-Programs-HOWTO/protect-secrets.html>
 *
 * If you want to be really secure, use both memset and this
 * function, as with:
 *
 *    char secret[ 80 ];
 *    memset( secret, 0, sizeof(secret) );
 *    rsecret_overwrite_buffer( secret, sizeof(secret) );
 */
extern void rsecret_overwrite_buffer( void* buf, size_t bufsize );


/* rsecret_inhibit_corefiles() and rsecret_restore_corefiles() - pair
 * of functions are used to wrap any code within which the dumping of
 * core files should be prohibited.  The inihibit function returns an
 * opaque pointer to a token, which is then passed back to the restore
 * function later to put things back the way they were.
 *
 * These pairs can be nested, as long as each inhibit has a matching restore.
 *
 * The rsecret_inhibit_corefiles() function will return NULL on failure.
 * The rsecret_restore_corefiles() function returns 0 on success, or -1 on failure.
 */
extern void* rsecret_inhibit_corefiles( void );
extern int  rsecret_restore_corefiles( void* );


#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif /* HEADER_READSECRET_H */
