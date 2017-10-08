/* readsecret.c                 -*- C -*-
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

#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

#include "readsecret.h"

#ifndef DEBUG
#define DEBUG 0
#endif


struct rlimit_wrap {
    char magic[4]; /* "RLim" */
    int resource;
    struct rlimit lim;
};

void* rsecret_inhibit_corefiles( void )
{
    int rc;
    struct rlimit_wrap* wrap;
    struct rlimit lim;
    wrap = malloc( sizeof(struct rlimit_wrap) );
    if( wrap == NULL )
	return NULL;
    wrap->magic[0] = 'R';
    wrap->magic[1] = 'L';
    wrap->magic[2] = 'i';
    wrap->magic[3] = 'm';
    wrap->resource = RLIMIT_CORE;
    rc = getrlimit( wrap->resource, & wrap->lim );
    if( rc != 0 ) {
	free(wrap);
	return NULL;
    }
    lim.rlim_cur = 0;
    lim.rlim_max = wrap->lim.rlim_max;
    rc = setrlimit( wrap->resource, & lim );
    if( rc != 0 ) {
	free( wrap );
	return NULL;
    }
    return wrap;
}

int rsecret_restore_corefiles( void* token )
{
    int rc;
    int save_errno;
    struct rlimit_wrap* wrap = (struct rlimit_wrap*) token;
    if( wrap == NULL
	|| wrap->magic[0]!='R' || wrap->magic[1]!='L'
	|| wrap->magic[2]!='i' || wrap->magic[3]=='m' )
	return -1;
    rc = setrlimit( wrap->resource, & wrap->lim );
    save_errno = errno;
    wrap->magic[0] = '\0';
    free( wrap );
    errno = save_errno;
    return rc;
}

static volatile sig_atomic_t rsecret_interrupted; /* set to signal number */
static volatile sig_atomic_t rsecret_got_timeout; /* set to timer_t id */


static void rsecret_catch_sig( int signo )
{
    rsecret_interrupted = signo;
}
static void rsecret_catch_timeout( int signo, siginfo_t* si, void* ctx )
{
#if DEBUG
    char x[40];
    snprintf( x, sizeof(x), "<<SIG %d code %d timer %ld>>\n",
	      signo, si->si_code, (long)si->si_int );
    write( 1, x, strlen(x) );
#endif
    if( si->si_code == SI_TIMER ) {
	rsecret_got_timeout = si->si_int; /* timer id number */
    }
    return;
}


void rsecret_overwrite_buffer( void* buf, size_t bufsize )
{
    volatile char* p = buf;
    size_t n;
    for( n=bufsize+1; n; --n )
	*(p++) = 0;
    return;
}


const char* rsecret_strerror( rsecret_error_ty rc )
{
    const char* m = "unknown error";
    switch( rc ) {
    case RSECRET_SUCCESS: m="no error"; break;
    case RSECRET_ERROR_BAD_ARG: m="arguments to function are invalid"; break;
    case RSECRET_ERROR_TTY_OPEN: m="can not open the controlling terminal"; break;
    case RSECRET_ERROR_SIGACTION: m="failed to establish signal handlers"; break;
    case RSECRET_ERROR_NOECHO: m="failed to set terminal to no-echo mode"; break;
    case RSECRET_ERROR_PROMPT: m="failed to write prompt"; break;
    case RSECRET_ERROR_READ: m="failure during reading of user input"; break;
    case RSECRET_ERROR_LENGTH: m="user input was too long to store in the supplied buffer"; break;
    case RSECRET_ERROR_INTERRUPTED: m="program was interrupted during input"; break;
    case RSECRET_ERROR_TIMER_CREATE: m="could not create real-time timer"; break;
    case RSECRET_ERROR_TIMEOUT: m="timeout waiting for user"; break;
    }
    return m;
}


rsecret_error_ty rsecret_get_secret_from_tty(
    char* buf, size_t bufsize,
    const char* prompt )
{
    return rsecret_get_secret_from_tty_timed(
	buf, bufsize,
	prompt,
	NULL );
}


rsecret_error_ty rsecret_get_secret_from_tty_timed(
    char* buf, size_t bufsize,
    const char* prompt,
    struct timespec* timeout )
{
    int success;
    int fd;
    int rc;
    int did_noecho;
    int did_sig_int;
    int did_sig_tstp;
    int did_sig_alrm;
    static struct termios term, term_save;
    struct sigaction sa_int,  sa_int_save;  /* for SIGINT */
    struct sigaction sa_tstp, sa_tstp_save; /* for SIGTSTP */
    struct sigaction sa_alrm, sa_alrm_save; /* for SIGALRM */
#ifdef L_ctermid
    char ctermpath[ L_ctermid + 1 ];
#else
    char ctermpath[ PATH_MAX + 1 ];
#endif
    int using_timers;
    timer_t timer;
    void* corefile_token;

    /* Keep track of what changes were made so the cleanup code can undo
     * them later.
     */
    success = RSECRET_SUCCESS;
    fd = -1;
    did_noecho = 0;
    did_sig_int = 0;
    did_sig_tstp = 0;
    did_sig_alrm = 0;
    corefile_token = NULL;

    /* Check the arguments */
    using_timers = timeout != NULL && (timeout->tv_sec != 0 || timeout->tv_nsec != 0 );
    if( using_timers ) {
	memset( &timer, 0, sizeof(timer) );
    }

    if( buf == NULL || bufsize < 2 )
	return RSECRET_ERROR_BAD_ARG;

    rsecret_overwrite_buffer( buf, bufsize );
    buf[0] = '\0';


    /* Determine the controlling terminal path */
    ctermpath[0] = '\0';
#ifdef L_ctermid
    ctermid( ctermpath );
#endif
    if( ! ctermpath[0] )
	strcpy( ctermpath, "/dev/tty" );

#if DEBUG
    fprintf( stderr, "cterm is %s\n", ctermpath );
#endif

    /* Open the controlling terminal */
    fd = open( ctermpath, O_RDWR );
    if( fd < 0 ) {
	return RSECRET_ERROR_TTY_OPEN;
    }

#if DEBUG
    fprintf( stderr, "tty is opened\n" );
#endif

    /* We now begin to allocate resources and change the process
     * environment. So we must be careful to later undo these
     * changes. Thus no longer use 'return' to escape, instead we must
     * use 'goto error'.
     */

    /* Inhibit core files */
    corefile_token = rsecret_inhibit_corefiles();

    /* Create timers */
    if( using_timers ) {
	rc = timer_create( CLOCK_REALTIME, NULL, &timer );
	if( rc != 0 ) {
	    success = RSECRET_ERROR_TIMER_CREATE;
	    goto cleanup;
	}
	rsecret_got_timeout = 0;

	/* Establish SIGALRM signal handler */
	memset( &sa_alrm, 0, sizeof(sa_alrm) );
	sa_alrm.sa_flags = SA_SIGINFO;
	sa_alrm.sa_sigaction = rsecret_catch_timeout;

	rc = sigaction( SIGALRM, &sa_alrm, &sa_alrm_save );
	if( rc == 0 ) {
	    did_sig_alrm = 1;
	}
	else {
	    success = RSECRET_ERROR_SIGACTION;
	    goto cleanup;
	}
    }/* endif using timers */


    /* Trap interrupts.  We only establish our own handlers if the
     * signal has not been set to ignored; since if it is already ignore
     * we should likewise continue to ignore it.
     */
    rsecret_interrupted = 0;

#ifdef SIGINT
    rc = sigaction( SIGINT, NULL, &sa_int_save );
    if( rc == 0 && sa_int_save.sa_handler != SIG_IGN ) {
	memset( &sa_int, 0, sizeof(sa_int) );
	sigemptyset( &sa_int.sa_mask );
	sa_int.sa_flags = 0;
	sa_int.sa_handler = rsecret_catch_sig;
	rc = sigaction( SIGINT, &sa_int, &sa_int_save );
	if( rc == 0 ) {
	    did_sig_int = 1;
	}
    }
    if( ! did_sig_int ) {
	success = RSECRET_ERROR_SIGACTION;
	goto cleanup;
    }
#endif
#ifdef SIGTSTP
    rc = sigaction( SIGTSTP, NULL, &sa_tstp_save );
    if( rc == 0 && sa_tstp_save.sa_handler != SIG_IGN ) {
	memset( &sa_tstp, 0, sizeof(sa_tstp) );
	sigemptyset( &sa_tstp.sa_mask );
	sa_tstp.sa_flags = 0;
	sa_tstp.sa_handler = rsecret_catch_sig;
	rc = sigaction( SIGTSTP, &sa_tstp, &sa_tstp_save );
	if( rc == 0 ) {
	    did_sig_tstp = 1;
	}
    }
    if( ! did_sig_tstp ) {
	success = RSECRET_ERROR_SIGACTION;
	goto cleanup;
    }
#endif

#if DEBUG
    fprintf(stderr,"changing tty flags\n" );
#endif

  /* Turn off terminal echo */
    rc = tcgetattr( fd, &term_save );
    if( rc < 0 ) {
	success = RSECRET_ERROR_NOECHO;
	goto cleanup;
    }
    term = term_save;
    term.c_iflag |= ICRNL; /* input mode: translate CR to NL on input */
    term.c_oflag |= ONLCR | OPOST; /* output mode: map NL to CR+NL, enable output processing */
    term.c_lflag &= ~(ECHO | ECHOE | ECHOK); /* local mode: disable echoing of input characters */
    term.c_lflag |= ECHONL; /* local mode: ... but do echo a NL character (if ICANON also set) */

    rc = tcsetattr( fd, /*TCSANOW*/ TCSAFLUSH, &term );
    if( rc == 0 ) {
	did_noecho = 1;
    } else {
	success = RSECRET_ERROR_NOECHO;
	goto cleanup;
    }

    /* Write the prompt, if any */
    if( prompt && prompt[0] ) {
	int n;
	n = write( fd, prompt, strlen(prompt) );
	if( n < 0 || n != strlen(prompt) ) {
	    success = RSECRET_ERROR_PROMPT;
	    goto cleanup;
	}
	rc = tcdrain( fd ); /* wait until prompt gets displayed */
    }

    /* Start timers */
    if( using_timers ) {
	struct itimerspec itspec;
	itspec.it_interval.tv_sec = 0;
	itspec.it_interval.tv_nsec = 0;
	itspec.it_value.tv_sec = timeout->tv_sec;
	itspec.it_value.tv_nsec = timeout->tv_nsec;
	rc = timer_settime( timer, 0, & itspec, NULL );
    }

    /* Read the secret */
    {
	int at = 0;
	while( ! ( rsecret_interrupted
		   || (using_timers && rsecret_got_timeout) ) ) {
	    int n;
	    char c;
	    n = read( fd, &c, 1 );
	    if( n < 0 ) {
		if( errno == EINTR || errno == EAGAIN ) {
		    if( using_timers && rsecret_got_timeout ) {
			success = RSECRET_ERROR_TIMEOUT;
		    }
		    else {
			success = RSECRET_ERROR_INTERRUPTED;
		    }
		}
		else {
		    success = RSECRET_ERROR_READ;
		}
		break; /* Aborted or error, exit while loop */
	    }
	    if( n == 0 || c == '\n' )
		break; /* Done, exit while loop */

	    /* Process character */
	    if( (at+1) < bufsize ) {
		buf[ at++ ] = c;
	    } else {
		/* Text entered is too long */
		at = 0;
		success = RSECRET_ERROR_LENGTH;
	    }
	    c = '\0'; /* overwrite variable so characters don't leak */
	}/* next character */

	buf[ at ] = '\0';
	at = 0;
    }/* end-while read next character */

  cleanup:
    /* Erase secret if error occured */
    if( success != RSECRET_SUCCESS ) {
	memset( buf, 0, bufsize );
	rsecret_overwrite_buffer( buf, bufsize );
    }

    /* Reset terminal */
    if( success != RSECRET_SUCCESS ) {
	/* Make sure any characters already typed by user get tossed
	 * so they don't end up getting printed out later.  We send
	 * a BELL to the terminal, wait a tiny bit, and then flush
	 * any pending unread input characters.
	 */
	struct timespec ts;
	ts.tv_sec = 0;
	ts.tv_nsec = 750000000l;/* 3/4 second */
	tcflush( fd, TCIFLUSH );
	write( fd, "\007XXXX\n", 6 );
	nanosleep( &ts, NULL );
	tcflush( fd, TCIFLUSH );
    }
    if( did_noecho ) {
	tcsetattr( fd, TCSANOW, &term_save );
    }

    /* Close terminal */
    if( fd >= 0 ) {
	close( fd );
	fd = -1;
    }

    /* Destroy timers */
    if( using_timers ) {
	rc = timer_delete( timer );
	rsecret_got_timeout = 0;
    }

    /* Restore signal handlers */
#ifdef SIGINT
    if( did_sig_int ) {
	sigaction( SIGINT, &sa_int_save, NULL );
    }
#endif
#ifdef SIGTSTP
    if( did_sig_tstp ) {
	sigaction( SIGTSTP, &sa_tstp_save, NULL );
    }
#endif
#ifdef SIGALRM
    if( did_sig_alrm ) {
	sigaction( SIGALRM, &sa_alrm_save, NULL );
    }
#endif

    /* Overwrite any local variables to prevent leakage */
    rc = 0;
    rsecret_overwrite_buffer( &term, sizeof(term) );
    rsecret_overwrite_buffer( &term_save, sizeof(term_save) );
    rsecret_overwrite_buffer( &sa_int, sizeof(sa_int) );
    rsecret_overwrite_buffer( &sa_int_save, sizeof(sa_int_save) );
    rsecret_overwrite_buffer( &sa_tstp, sizeof(sa_tstp) );
    rsecret_overwrite_buffer( &sa_tstp_save, sizeof(sa_tstp_save) );

    /* If an error erase the secret */
    if( success != RSECRET_SUCCESS ) {
	memset( buf, 0, bufsize );
	rsecret_overwrite_buffer( buf, bufsize );
    }

    /* Re-enable core file dumping (or put state back the way it was) */
    rsecret_restore_corefiles( corefile_token );

    /* If interrupted re-raise the same signal */
    if( success == RSECRET_ERROR_INTERRUPTED && rsecret_interrupted ) {
	raise( rsecret_interrupted );
    }
    return success;
}
