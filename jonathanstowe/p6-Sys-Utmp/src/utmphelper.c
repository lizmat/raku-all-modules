
#include <utmp.h>
#include <string.h>

#ifdef _AIX
#define _HAVE_UT_HOST	1
#endif

#ifdef NOUTFUNCS
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#ifdef BSD
#define _NO_UT_ID
#define _NO_UT_TYPE
#define _NO_UT_PID
#define _HAVE_UT_HOST
#define ut_user ut_name
#endif

/*
   define these so it still works as documented :)
*/

#ifndef USER_PROCESS
#define EMPTY           0       /* No valid user accounting information.  */

#define RUN_LVL         1       /* The system's runlevel.  */
#define BOOT_TIME       2       /* Time of system boot.  */
#define NEW_TIME        3       /* Time after system clock changed.  */
#define OLD_TIME        4       /* Time when system clock changed.  */

#define INIT_PROCESS    5       /* Process spawned by the init process.  */
#define LOGIN_PROCESS   6       /* Session leader of a logged in user.  */
#define USER_PROCESS    7       /* Normal process.  */
#define DEAD_PROCESS    8       /* Terminated process.  */

#define ACCOUNTING      9
#endif

/*
    It is almost certain that if these are not defined the fields they are
    for are not present or this is BSD :)
*/


static int ut_fd = -1;

static char _ut_name[] = _PATH_UTMP;

void utmpname(char *filename)
{
   strcpy(_ut_name, filename);
}

void setutent(void)
{
    if (ut_fd < 0)
    {
       if ((ut_fd = open(_ut_name, O_RDONLY)) < 0) 
       {
            croak("Can't open %s",_ut_name);
        }
    }

    lseek(ut_fd, (off_t) 0, SEEK_SET);
}

void endutent(void)
{
    if (ut_fd > 0)
    {
        close(ut_fd);
    }

    ut_fd = -1;
}

struct utmp *getutent(void) 
{
    static struct utmp s_utmp;
    int readval;

    if (ut_fd < 0)
    {
        setutent();
    }

    if ((readval = read(ut_fd, &s_utmp, sizeof(s_utmp))) < sizeof(s_utmp))
    {
        if (readval == 0)
        {
            return NULL;
        }
        else if (readval < 0) 
        {
            croak("Error reading %s", _ut_name);
        } 
        else 
        {
            croak("Partial record in %s [%d bytes]", _ut_name, readval );
        }
    }
    return &s_utmp;
}

#endif

struct _p_utmp {
	int	ut_type;
	int ut_pid;
	char *ut_line;
	char *ut_id;
	char *ut_user;
	char *ut_host;
	int  ut_tv;
};


extern struct _p_utmp *_p_getutent(void)
{
     static char *_ut_id;
     static struct utmp *utent;
	  static struct _p_utmp fixed_utent;


     utent = getutent();

     if ( utent )
     {

#ifdef _NO_UT_ID
       fixed_utent.ut_id = "";
#else
       static char ut_id[sizeof(utent->ut_id) + 1];
       strncpy(ut_id, utent->ut_id,sizeof(utent->ut_id));
       ut_id[sizeof(utent->ut_id)] = 0;
       fixed_utent.ut_id = ut_id;
#endif
#ifdef _NO_UT_TYPE
       fixed_utent.ut_type = 7;
#else
       fixed_utent.ut_type = utent->ut_type;
#endif
#ifdef _NO_UT_PID
       fixed_utent.ut_pid = -1; 
#else
       fixed_utent.ut_pid = utent->ut_pid;
#endif
#ifdef _HAVE_UT_TV
       fixed_utent.ut_tv = (int)utent->ut_tv.tv_sec;
#else
       fixed_utent.ut_tv = (int)utent->ut_time;
#endif
#ifdef _HAVE_UT_HOST
       static char ut_host[sizeof(utent->ut_host) + 1];
       strncpy(ut_host, utent->ut_host,sizeof(utent->ut_host));
       ut_host[sizeof(utent->ut_host)] = 0;
       fixed_utent.ut_host = ut_host;
#else
	    fixed_utent.ut_host = "";
#endif

       static char ut_user[sizeof(utent->ut_user) + 1];
       strncpy(ut_user, utent->ut_user,sizeof(utent->ut_user));
       ut_user[sizeof(utent->ut_user)] = 0;
       fixed_utent.ut_user = ut_user;

       static char ut_line[sizeof(utent->ut_line) + 1];
       strncpy(ut_line, utent->ut_line,sizeof(utent->ut_line));
       ut_line[sizeof(utent->ut_line)] = 0;
       fixed_utent.ut_line = ut_line;

       return &fixed_utent;
     }
     else
     {
        return (struct _p_utmp *)0;
     }
}


extern void _p_setutent(void)
{
    setutent();
}

extern void _p_endutent(void)
{
    endutent();
}

extern void _p_utmpname(const char * filename)
{
     utmpname(filename);
}

/*
#include <stdio.h>

int main() {
	struct _p_utmp *f;
   while (!(NULL == (f = _p_getutent()) )) {
   printf("%s\n%s\n%s\n%s\n", f->ut_line, f->ut_user, f->ut_id, f->ut_host);
	}
}
*/
