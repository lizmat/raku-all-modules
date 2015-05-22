/*
 * Helper library for Sys::Lastlog
*/

#include <utmp.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <pwd.h>
#include <unistd.h>
#include <string.h>

#ifdef USE_LASTLOG_H
#include <lastlog.h>
#endif

int get_lastlog_fd(void);
char *lastlog_path(void);


/* 
 * Functions to provide a getut* like interface to lastlog
 */
struct lastlog *getllent(void)
{

   static struct lastlog llent;

   int ll_fd;

   if ( (ll_fd =  get_lastlog_fd() ) == -1 )
   {
     return( ( void *)0);
   }

   if(read( ll_fd,&llent, sizeof( struct lastlog )) != sizeof( struct lastlog))
   {
      close(ll_fd);
      return ( (void *)0 );
   }
   else
   {
      return ( &llent );
   }
}

struct lastlog *getlluid(int uid)
{
  static struct lastlog llent;
  int ll_fd;

  off_t where;

  if ( (ll_fd =  get_lastlog_fd() ) == -1 )
  {
     return( ( void *)0);
  }


  where = lseek(ll_fd,0, SEEK_CUR);

  lseek(ll_fd, (off_t)(uid * sizeof( struct lastlog)), SEEK_SET);


  if(read( ll_fd,&llent, sizeof( struct lastlog )) != sizeof( struct lastlog))
  {
      lseek(ll_fd,where, SEEK_SET );
      return ( (void *)0 );
  }
  else
  {
      lseek(ll_fd,where, SEEK_SET );
      return ( &llent );
  }
}

struct lastlog *getllnam(char *logname)
{
    struct passwd *pwd;
    struct lastlog *llent;

    if((pwd = getpwnam(logname)))
    {
      llent = getlluid(pwd->pw_uid);
    }
    else
    {
      llent = (void *)0;
    }
	 return llent;
}

int get_lastlog_fd(void)
{

   static int ll_fd = -1;

   if ( ll_fd == -1 )
   {
     ll_fd = open((char *)lastlog_path(),O_RDONLY);
   }

   return(ll_fd);
}

char *lastlog_path(void)
{
   return _PATH_LASTLOG;
}

void setllent(void)
{
   int ll_fd;

   if ((ll_fd =  get_lastlog_fd()) != -1)
   {
      lseek(ll_fd,0, SEEK_SET);
   }     
}

/*
 * This provides a shim as NativeCall doesn't quite deal with char foo[] yet
 */

struct p_lastlog {
	int   ll_time;
	char *ll_line;
	char *ll_host;
};

/* 
 * copy a lastlog * to a p_laslog *
*/
struct p_lastlog *ll2p(struct lastlog *llent) {

	static struct p_lastlog p_llent;

	if ( llent != NULL ) {
		static char ll_line[sizeof(llent->ll_line) + 1];
		strncpy(ll_line,llent->ll_line, sizeof(llent->ll_line));
		ll_line[sizeof(llent->ll_line)] = 0;
		p_llent.ll_line = ll_line;
		static char ll_host[sizeof(llent->ll_host) + 1];
		strncpy(ll_host,llent->ll_host, sizeof(llent->ll_host));
		ll_host[sizeof(llent->ll_host)] = 0;
		p_llent.ll_host = ll_host;

		p_llent.ll_time = llent->ll_time;

		return &p_llent;
	}
	else {
		return (struct p_lastlog *)0;
	}
}

/*
 * These are the functions that return the amended structure;
 */
extern struct p_lastlog *p_getllent(void) {
	return ll2p(getllent());
}

extern struct p_lastlog *p_getlluid(int uid) {
	return ll2p(getlluid(uid));
}

extern struct p_lastlog *p_getllnam(char *logname) {
	return ll2p(getllnam(logname));
}

extern void p_setllent(void) {
	setllent();
}
