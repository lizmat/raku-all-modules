#include <stdlib.h>
#include <strings.h>
#include <stdio.h>

#ifdef VMS
#  include <file.h>
#else
#  if defined(__GNUC__) && defined(__cplusplus) && defined(WIN32)
#    define _NO_OLDNAMES
#  endif
#  include <fcntl.h>
#  if defined(__GNUC__) && defined(__cplusplus) && defined(WIN32)
#    undef _NO_OLDNAMES
#  endif
#endif

#ifdef I_UNISTD
#  include <unistd.h>
#endif

struct definition_pair {
  char *const_pattern;
  char *const_name;
  long long const_value;
};

/**
 * This set of definitions lets us construct Perl 6 code later...
 */
struct definition_pair definitions[] = {
  {
    "constant DN_ACCESS is export(:DN_ACCESS, :ALL) = %lld",
    "DN_ACCESS",
    #ifdef DN_ACCESS
      DN_ACCESS
    #else
      0
    #endif
  },
  {
    "constant DN_MODIFY is export(:DN_MODIFY, :ALL) = %lld",
    "DN_MODIFY",
    #ifdef DN_MODIFY
      DN_MODIFY
    #else
      0
    #endif
  },
  {
    "constant DN_CREATE is export(:DN_CREATE, :ALL) = %lld",
    "DN_CREATE",
    #ifdef DN_CREATE
      DN_CREATE
    #else
      0
    #endif
  },
  {
    "constant DN_DELETE is export(:DN_DELETE, :ALL) = %lld",
    "DN_DELETE",
    #ifdef DN_DELETE
      DN_DELETE
    #else
      0
    #endif
  },
  {
    "constant DN_RENAME is export(:DN_RENAME, :ALL) = %lld",
    "DN_RENAME",
    #ifdef DN_RENAME
      DN_RENAME
    #else
      0
    #endif
  },
  {
    "constant DN_ATTRIB is export(:DN_ATTRIB, :ALL) = %lld",
    "DN_ATTRIB",
    #ifdef DN_ATTRIB
      DN_ATTRIB
    #else
      0
    #endif
  },
  {
    "constant DN_MULTISHOT is export(:DN_MULTISHOT, :ALL) = %lld",
    "DN_MULTISHOT",
    #ifdef DN_MULTISHOT
      DN_MULTISHOT
    #else
      0
    #endif
  },
  {
    "constant FAPPEND is export(:FAPPEND, :ALL, :Fcompat) = %lld",
    "FAPPEND",
    #ifdef FAPPEND
      FAPPEND
    #else
      0
    #endif
  },
  {
    "constant FASYNC is export(:FASYNC, :ALL, :Fcompat) = %lld",
    "FASYNC",
    #ifdef FASYNC
      FASYNC
    #else
      0
    #endif
  },
  {
    "constant FCREAT is export(:FCREAT, :ALL, :Fcompat) = %lld",
    "FCREAT",
    #ifdef FCREAT
      FCREAT
    #else
      0
    #endif
  },
  {
    "constant FDEFER is export(:FDEFER, :ALL, :Fcompat) = %lld",
    "FDEFER",
    #ifdef FDEFER
      FDEFER
    #else
      0
    #endif
  },
  {
    "constant FDSYNC is export(:FDSYNC, :ALL) = %lld",
    "FDSYNC",
    #ifdef FDSYNC
      FDSYNC
    #else
      0
    #endif
  },
  {
    "constant FD_CLOEXEC is export(:FD_CLOEXEC, :ALL) = %lld",
    "FD_CLOEXEC",
    #ifdef FD_CLOEXEC
      FD_CLOEXEC
    #else
      0
    #endif
  },
  {
    "constant FEXCL is export(:FEXCL, :ALL, :Fcompat) = %lld",
    "FEXCL",
    #ifdef FEXCL
      FEXCL
    #else
      0
    #endif
  },
  {
    "constant FLARGEFILE is export(:FLARGEFILE, :ALL) = %lld",
    "FLARGEFILE",
    #ifdef FLARGEFILE
      FLARGEFILE
    #else
      0
    #endif
  },
  {
    "constant FNDELAY is export(:FNDELAY, :ALL, :Fcompat) = %lld",
    "FNDELAY",
    #ifdef FNDELAY
      FNDELAY
    #else
      0
    #endif
  },
  {
    "constant FRSYNC is export(:FRSYNC, :ALL) = %lld",
    "FRSYNC",
    #ifdef FRSYNC
      FRSYNC
    #else
      0
    #endif
  },
  {
    "constant FNONBLOCK is export(:FNONBLOCK, :ALL, :Fcompat) = %lld",
    "FNONBLOCK",
    #ifdef FNONBLOCK
      FNONBLOCK
    #else
      0
    #endif
  },
  {
    "constant FSYNC is export(:FSYNC, :ALL, :Fcompat) = %lld",
    "FSYNC",
    #ifdef FSYNC
      FSYNC
    #else
      0
    #endif
  },
  {
    "constant FTRUNC is export(:FTRUNC, :ALL, :Fcompat) = %lld",
    "FTRUNC",
    #ifdef FTRUNC
      FTRUNC
    #else
      0
    #endif
  },
  {
    "constant F_ALLOCSP is export(:F_ALLOCSP, :ALL) = %lld",
    "F_ALLOCSP",
    #ifdef F_ALLOCSP
      F_ALLOCSP
    #else
      0
    #endif
  },
  {
    "constant F_ALLOCSP64 is export(:F_ALLOCSP64, :ALL) = %lld",
    "F_ALLOCSP64",
    #ifdef F_ALLOCSP64
      F_ALLOCSP64
    #else
      0
    #endif
  },
  {
    "constant F_COMPAT is export(:F_COMPAT, :ALL) = %lld",
    "F_COMPAT",
    #ifdef F_COMPAT
      F_COMPAT
    #else
      0
    #endif
  },
  {
    "constant F_DUP2FD is export(:F_DUP2FD, :ALL) = %lld",
    "F_DUP2FD",
    #ifdef F_DUP2FD
      F_DUP2FD
    #else
      0
    #endif
  },
  {
    "constant F_DUPFD is export(:F_DUPFD, :ALL) = %lld",
    "F_DUPFD",
    #ifdef F_DUPFD
      F_DUPFD
    #else
      0
    #endif
  },
  {
    "constant F_EXLCK is export(:F_EXLCK, :ALL) = %lld",
    "F_EXLCK",
    #ifdef F_EXLCK
      F_EXLCK
    #else
      0
    #endif
  },
  {
    "constant F_FREESP is export(:F_FREESP, :ALL) = %lld",
    "F_FREESP",
    #ifdef F_FREESP
      F_FREESP
    #else
      0
    #endif
  },
  {
    "constant F_FREESP64 is export(:F_FREESP64, :ALL) = %lld",
    "F_FREESP64",
    #ifdef F_FREESP64
      F_FREESP64
    #else
      0
    #endif
  },
  {
    "constant F_FSYNC is export(:F_FSYNC, :ALL) = %lld",
    "F_FSYNC",
    #ifdef F_FSYNC
      F_FSYNC
    #else
      0
    #endif
  },
  {
    "constant F_FSYNC64 is export(:F_FSYNC64, :ALL) = %lld",
    "F_FSYNC64",
    #ifdef F_FSYNC64
      F_FSYNC64
    #else
      0
    #endif
  },
  {
    "constant F_GETFD is export(:F_GETFD, :ALL) = %lld",
    "F_GETFD",
    #ifdef F_GETFD
      F_GETFD
    #else
      0
    #endif
  },
  {
    "constant F_GETFL is export(:F_GETFL, :ALL) = %lld",
    "F_GETFL",
    #ifdef F_GETFL
      F_GETFL
    #else
      0
    #endif
  },
  {
    "constant F_GETLEASE is export(:F_GETLEASE, :ALL) = %lld",
    "F_GETLEASE",
    #ifdef F_GETLEASE
      F_GETLEASE
    #else
      0
    #endif
  },
  {
    "constant F_GETLK is export(:F_GETLK, :ALL) = %lld",
    "F_GETLK",
    #ifdef F_GETLK
      F_GETLK
    #else
      0
    #endif
  },
  {
    "constant F_GETLK64 is export(:F_GETLK64, :ALL) = %lld",
    "F_GETLK64",
    #ifdef F_GETLK64
      F_GETLK64
    #else
      0
    #endif
  },
  {
    "constant F_GETOWN is export(:F_GETOWN, :ALL) = %lld",
    "F_GETOWN",
    #ifdef F_GETOWN
      F_GETOWN
    #else
      0
    #endif
  },
  {
    "constant F_GETPIPE_SZ is export(:F_GETPIPE_SZ, :ALL) = %lld",
    "F_GETPIPE_SZ",
    #ifdef F_GETPIPE_SZ
      F_GETPIPE_SZ
    #else
      0
    #endif
  },
  {
    "constant F_GETSIG is export(:F_GETSIG, :ALL) = %lld",
    "F_GETSIG",
    #ifdef F_GETSIG
      F_GETSIG
    #else
      0
    #endif
  },
  {
    "constant F_NODNY is export(:F_NODNY, :ALL) = %lld",
    "F_NODNY",
    #ifdef F_NODNY
      F_NODNY
    #else
      0
    #endif
  },
  {
    "constant F_NOTIFY is export(:F_NOTIFY, :ALL) = %lld",
    "F_NOTIFY",
    #ifdef F_NOTIFY
      F_NOTIFY
    #else
      0
    #endif
  },
  {
    "constant F_POSIX is export(:F_POSIX, :ALL) = %lld",
    "F_POSIX",
    #ifdef F_POSIX
      F_POSIX
    #else
      0
    #endif
  },
  {
    "constant F_RDACC is export(:F_RDACC, :ALL) = %lld",
    "F_RDACC",
    #ifdef F_RDACC
      F_RDACC
    #else
      0
    #endif
  },
  {
    "constant F_RDDNY is export(:F_RDDNY, :ALL) = %lld",
    "F_RDDNY",
    #ifdef F_RDDNY
      F_RDDNY
    #else
      0
    #endif
  },
  {
    "constant F_RDLCK is export(:F_RDLCK, :ALL) = %lld",
    "F_RDLCK",
    #ifdef F_RDLCK
      F_RDLCK
    #else
      0
    #endif
  },
  {
    "constant F_RWACC is export(:F_RWACC, :ALL) = %lld",
    "F_RWACC",
    #ifdef F_RWACC
      F_RWACC
    #else
      0
    #endif
  },
  {
    "constant F_RWDNY is export(:F_RWDNY, :ALL) = %lld",
    "F_RWDNY",
    #ifdef F_RWDNY
      F_RWDNY
    #else
      0
    #endif
  },
  {
    "constant F_SETFD is export(:F_SETFD, :ALL) = %lld",
    "F_SETFD",
    #ifdef F_SETFD
      F_SETFD
    #else
      0
    #endif
  },
  {
    "constant F_SETFL is export(:F_SETFL, :ALL) = %lld",
    "F_SETFL",
    #ifdef F_SETFL
      F_SETFL
    #else
      0
    #endif
  },
  {
    "constant F_SETLEASE is export(:F_SETLEASE, :ALL) = %lld",
    "F_SETLEASE",
    #ifdef F_SETLEASE
      F_SETLEASE
    #else
      0
    #endif
  },
  {
    "constant F_SETLK is export(:F_SETLK, :ALL) = %lld",
    "F_SETLK",
    #ifdef F_SETLK
      F_SETLK
    #else
      0
    #endif
  },
  {
    "constant F_SETLK64 is export(:F_SETLK64, :ALL) = %lld",
    "F_SETLK64",
    #ifdef F_SETLK64
      F_SETLK64
    #else
      0
    #endif
  },
  {
    "constant F_SETLKW is export(:F_SETLKW, :ALL) = %lld",
    "F_SETLKW",
    #ifdef F_SETLKW
      F_SETLKW
    #else
      0
    #endif
  },
  {
    "constant F_SETLKW64 is export(:F_SETLKW64, :ALL) = %lld",
    "F_SETLKW64",
    #ifdef F_SETLKW64
      F_SETLKW64
    #else
      0
    #endif
  },
  {
    "constant F_SETOWN is export(:F_SETOWN, :ALL) = %lld",
    "F_SETOWN",
    #ifdef F_SETOWN
      F_SETOWN
    #else
      0
    #endif
  },
  {
    "constant F_SETPIPE_SZ is export(:F_SETPIPE_SZ, :ALL) = %lld",
    "F_SETPIPE_SZ",
    #ifdef F_SETPIPE_SZ
      F_SETPIPE_SZ
    #else
      0
    #endif
  },
  {
    "constant F_SETSIG is export(:F_SETSIG, :ALL) = %lld",
    "F_SETSIG",
    #ifdef F_SETSIG
      F_SETSIG
    #else
      0
    #endif
  },
  {
    "constant F_SHARE is export(:F_SHARE, :ALL) = %lld",
    "F_SHARE",
    #ifdef F_SHARE
      F_SHARE
    #else
      0
    #endif
  },
  {
    "constant F_SHLCK is export(:F_SHLCK, :ALL) = %lld",
    "F_SHLCK",
    #ifdef F_SHLCK
      F_SHLCK
    #else
      0
    #endif
  },
  {
    "constant F_UNLCK is export(:F_UNLCK, :ALL) = %lld",
    "F_UNLCK",
    #ifdef F_UNLCK
      F_UNLCK
    #else
      0
    #endif
  },
  {
    "constant F_UNSHARE is export(:F_UNSHARE, :ALL) = %lld",
    "F_UNSHARE",
    #ifdef F_UNSHARE
      F_UNSHARE
    #else
      0
    #endif
  },
  {
    "constant F_WRACC is export(:F_WRACC, :ALL) = %lld",
    "F_WRACC",
    #ifdef F_WRACC
      F_WRACC
    #else
      0
    #endif
  },
  {
    "constant F_WRDNY is export(:F_WRDNY, :ALL) = %lld",
    "F_WRDNY",
    #ifdef F_WRDNY
      F_WRDNY
    #else
      0
    #endif
  },
  {
    "constant F_WRLCK is export(:F_WRLCK, :ALL) = %lld",
    "F_WRLCK",
    #ifdef F_WRLCK
      F_WRLCK
    #else
      0
    #endif
  },
  {
    "constant LOCK_MAND is export(:LOCK_MAND, :ALL) = %lld",
    "LOCK_MAND",
    #ifdef LOCK_MAND
      LOCK_MAND
    #else
      0
    #endif
  },
  {
    "constant LOCK_READ is export(:LOCK_READ, :ALL) = %lld",
    "LOCK_READ",
    #ifdef LOCK_READ
      LOCK_READ
    #else
      0
    #endif
  },
  {
    "constant LOCK_WRITE is export(:LOCK_WRITE, :ALL) = %lld",
    "LOCK_WRITE",
    #ifdef LOCK_WRITE
      LOCK_WRITE
    #else
      0
    #endif
  },
  {
    "constant LOCK_RW is export(:LOCK_RW, :ALL) = %lld",
    "LOCK_RW",
    #ifdef LOCK_RW
      LOCK_RW
    #else
      0
    #endif
  },
  {
    "constant O_ACCMODE is export(:O_ACCMODE, :ALL) = %lld",
    "O_ACCMODE",
    #ifdef O_ACCMODE
      O_ACCMODE
    #else
      0
    #endif
  },
  {
    "constant O_ALIAS is export(:O_ALIAS, :ALL) = %lld",
    "O_ALIAS",
    #ifdef O_ALIAS
      O_ALIAS
    #else
      0
    #endif
  },
  {
    "constant O_ALT_IO is export(:O_ALT_IO, :ALL) = %lld",
    "O_ALT_IO",
    #ifdef O_ALT_IO
      O_ALT_IO
    #else
      0
    #endif
  },
  {
    "constant O_APPEND is export(:O_APPEND, :ALL) = %lld",
    "O_APPEND",
    #ifdef O_APPEND
      O_APPEND
    #else
      0
    #endif
  },
  {
    "constant O_ASYNC is export(:O_ASYNC, :ALL) = %lld",
    "O_ASYNC",
    #ifdef O_ASYNC
      O_ASYNC
    #else
      0
    #endif
  },
  {
    "constant O_BINARY is export(:O_BINARY, :ALL) = %lld",
    "O_BINARY",
    #ifdef O_BINARY
      O_BINARY
    #else
      0
    #endif
  },
  {
    "constant O_CREAT is export(:O_CREAT, :ALL) = %lld",
    "O_CREAT",
    #ifdef O_CREAT
      O_CREAT
    #else
      0
    #endif
  },
  {
    "constant O_DEFER is export(:O_DEFER, :ALL) = %lld",
    "O_DEFER",
    #ifdef O_DEFER
      O_DEFER
    #else
      0
    #endif
  },
  {
    "constant O_DIRECT is export(:O_DIRECT, :ALL) = %lld",
    "O_DIRECT",
    #ifdef O_DIRECT
      O_DIRECT
    #else
      0
    #endif
  },
  {
    "constant O_DIRECTORY is export(:O_DIRECTORY, :ALL) = %lld",
    "O_DIRECTORY",
    #ifdef O_DIRECTORY
      O_DIRECTORY
    #else
      0
    #endif
  },
  {
    "constant O_DSYNC is export(:O_DSYNC, :ALL) = %lld",
    "O_DSYNC",
    #ifdef O_DSYNC
      O_DSYNC
    #else
      0
    #endif
  },
  {
    "constant O_EVTONLY is export(:O_EVTONLY, :ALL) = %lld",
    "O_EVTONLY",
    #ifdef O_EVTONLY
      O_EVTONLY
    #else
      0
    #endif
  },
  {
    "constant O_EXCL is export(:O_EXCL, :ALL) = %lld",
    "O_EXCL",
    #ifdef O_EXCL
      O_EXCL
    #else
      0
    #endif
  },
  {
    "constant O_EXLOCK is export(:O_EXLOCK, :ALL) = %lld",
    "O_EXLOCK",
    #ifdef O_EXLOCK
      O_EXLOCK
    #else
      0
    #endif
  },
  {
    "constant O_IGNORE_CTTY is export(:O_IGNORE_CTTY, :ALL) = %lld",
    "O_IGNORE_CTTY",
    #ifdef O_IGNORE_CTTY
      O_IGNORE_CTTY
    #else
      0
    #endif
  },
  {
    "constant O_LARGEFILE is export(:O_LARGEFILE, :ALL) = %lld",
    "O_LARGEFILE",
    #ifdef O_LARGEFILE
      O_LARGEFILE
    #else
      0
    #endif
  },
  {
    "constant O_NDELAY is export(:O_NDELAY, :ALL) = %lld",
    "O_NDELAY",
    #ifdef O_NDELAY
      O_NDELAY
    #else
      0
    #endif
  },
  {
    "constant O_NOATIME is export(:O_NOATIME, :ALL) = %lld",
    "O_NOATIME",
    #ifdef O_NOATIME
      O_NOATIME
    #else
      0
    #endif
  },
  {
    "constant O_NOCTTY is export(:O_NOCTTY, :ALL) = %lld",
    "O_NOCTTY",
    #ifdef O_NOCTTY
      O_NOCTTY
    #else
      0
    #endif
  },
  {
    "constant O_NOFOLLOW is export(:O_NOFOLLOW, :ALL) = %lld",
    "O_NOFOLLOW",
    #ifdef O_NOFOLLOW
      O_NOFOLLOW
    #else
      0
    #endif
  },
  {
    "constant O_NOINHERIT is export(:O_NOINHERIT, :ALL) = %lld",
    "O_NOINHERIT",
    #ifdef O_NOINHERIT
      O_NOINHERIT
    #else
      0
    #endif
  },
  {
    "constant O_NOLINK is export(:O_NOLINK, :ALL) = %lld",
    "O_NOLINK",
    #ifdef O_NOLINK
      O_NOLINK
    #else
      0
    #endif
  },
  {
    "constant O_NONBLOCK is export(:O_NONBLOCK, :ALL) = %lld",
    "O_NONBLOCK",
    #ifdef O_NONBLOCK
      O_NONBLOCK
    #else
      0
    #endif
  },
  {
    "constant O_NOSIGPIPE is export(:O_NOSIGPIPE, :ALL) = %lld",
    "O_NOSIGPIPE",
    #ifdef O_NOSIGPIPE
      O_NOSIGPIPE
    #else
      0
    #endif
  },
  {
    "constant O_NOTRANS is export(:O_NOTRANS, :ALL) = %lld",
    "O_NOTRANS",
    #ifdef O_NOTRANS
      O_NOTRANS
    #else
      0
    #endif
  },
  {
    "constant O_RANDOM is export(:O_RANDOM, :ALL) = %lld",
    "O_RANDOM",
    #ifdef O_RANDOM
      O_RANDOM
    #else
      0
    #endif
  },
  {
    "constant O_RAW is export(:O_RAW, :ALL) = %lld",
    "O_RAW",
    #ifdef O_RAW
      O_RAW
    #else
      0
    #endif
  },
  {
    "constant O_RDONLY is export(:O_RDONLY, :ALL) = %lld",
    "O_RDONLY",
    #ifdef O_RDONLY
      O_RDONLY
    #else
      0
    #endif
  },
  {
    "constant O_RDWR is export(:O_RDWR, :ALL) = %lld",
    "O_RDWR",
    #ifdef O_RDWR
      O_RDWR
    #else
      0
    #endif
  },
  {
    "constant O_RSRC is export(:O_RSRC, :ALL) = %lld",
    "O_RSRC",
    #ifdef O_RSRC
      O_RSRC
    #else
      0
    #endif
  },
  {
    "constant O_RSYNC is export(:O_RSYNC, :ALL) = %lld",
    "O_RSYNC",
    #ifdef O_RSYNC
      O_RSYNC
    #else
      0
    #endif
  },
  {
    "constant O_SEQUENTIAL is export(:O_SEQUENTIAL, :ALL) = %lld",
    "O_SEQUENTIAL",
    #ifdef O_SEQUENTIAL
      O_SEQUENTIAL
    #else
      0
    #endif
  },
  {
    "constant O_SHLOCK is export(:O_SHLOCK, :ALL) = %lld",
    "O_SHLOCK",
    #ifdef O_SHLOCK
      O_SHLOCK
    #else
      0
    #endif
  },
  {
    "constant O_SYMLINK is export(:O_SYMLINK, :ALL) = %lld",
    "O_SYMLINK",
    #ifdef O_SYMLINK
      O_SYMLINK
    #else
      0
    #endif
  },
  {
    "constant O_SYNC is export(:O_SYNC, :ALL) = %lld",
    "O_SYNC",
    #ifdef O_SYNC
      O_SYNC
    #else
      0
    #endif
  },
  {
    "constant O_TEMPORARY is export(:O_TEMPORARY, :ALL) = %lld",
    "O_TEMPORARY",
    #ifdef O_TEMPORARY
      O_TEMPORARY
    #else
      0
    #endif
  },
  {
    "constant O_TEXT is export(:O_TEXT, :ALL) = %lld",
    "O_TEXT",
    #ifdef O_TEXT
      O_TEXT
    #else
      0
    #endif
  },
  {
    "constant O_TRUNC is export(:O_TRUNC, :ALL) = %lld",
    "O_TRUNC",
    #ifdef O_TRUNC
      O_TRUNC
    #else
      0
    #endif
  },
  {
    "constant O_TTY_INIT is export(:O_TTY_INIT, :ALL) = %lld",
    "O_TTY_INIT",
    #ifdef O_TTY_INIT
      O_TTY_INIT
    #else
      0
    #endif
  },
  {
    "constant O_WRONLY is export(:O_WRONLY, :ALL) = %lld",
    "O_WRONLY",
    #ifdef O_WRONLY
      O_WRONLY
    #else
      0
    #endif
  },
  {
    "constant S_ENFMT is export(:S_ENFMT, :ALL) = %lld",
    "S_ENFMT",
    #ifdef S_ENFMT
      S_ENFMT
    #else
      0
    #endif
  },
  {
    "constant S_IEXEC is export(:S_IEXEC, :ALL) = %lld",
    "S_IEXEC",
    #ifdef S_IEXEC
      S_IEXEC
    #else
      0
    #endif
  },
  {
    "constant S_IFBLK is export(:S_IFBLK, :ALL) = %lld",
    "S_IFBLK",
    #ifdef S_IFBLK
      S_IFBLK
    #else
      0
    #endif
  },
  {
    "constant S_IFCHR is export(:S_IFCHR, :ALL) = %lld",
    "S_IFCHR",
    #ifdef S_IFCHR
      S_IFCHR
    #else
      0
    #endif
  },
  {
    "constant S_IFDIR is export(:S_IFDIR, :ALL) = %lld",
    "S_IFDIR",
    #ifdef S_IFDIR
      S_IFDIR
    #else
      0
    #endif
  },
  {
    "constant S_IFIFO is export(:S_IFIFO, :ALL) = %lld",
    "S_IFIFO",
    #ifdef S_IFIFO
      S_IFIFO
    #else
      0
    #endif
  },
  {
    "constant S_IFLNK is export(:S_IFLNK, :ALL) = %lld",
    "S_IFLNK",
    #ifdef S_IFLNK
      S_IFLNK
    #else
      0
    #endif
  },
  {
    "constant S_IFREG is export(:S_IFREG, :ALL) = %lld",
    "S_IFREG",
    #ifdef S_IFREG
      S_IFREG
    #else
      0
    #endif
  },
  {
    "constant S_IFSOCK is export(:S_IFSOCK, :ALL) = %lld",
    "S_IFSOCK",
    #ifdef S_IFSOCK
      S_IFSOCK
    #else
      0
    #endif
  },
  {
    "constant S_IFWHT is export(:S_IFWHT, :ALL) = %lld",
    "S_IFWHT",
    #ifdef S_IFWHT
      S_IFWHT
    #else
      0
    #endif
  },
  {
    "constant S_IREAD is export(:S_IREAD, :ALL) = %lld",
    "S_IREAD",
    #ifdef S_IREAD
      S_IREAD
    #else
      0
    #endif
  },
  {
    "constant S_IRGRP is export(:S_IRGRP, :ALL) = %lld",
    "S_IRGRP",
    #ifdef S_IRGRP
      S_IRGRP
    #else
      0
    #endif
  },
  {
    "constant S_IROTH is export(:S_IROTH, :ALL) = %lld",
    "S_IROTH",
    #ifdef S_IROTH
      S_IROTH
    #else
      0
    #endif
  },
  {
    "constant S_IRUSR is export(:S_IRUSR, :ALL) = %lld",
    "S_IRUSR",
    #ifdef S_IRUSR
      S_IRUSR
    #else
      0
    #endif
  },
  {
    "constant S_IRWXG is export(:S_IRWXG, :ALL) = %lld",
    "S_IRWXG",
    #ifdef S_IRWXG
      S_IRWXG
    #else
      0
    #endif
  },
  {
    "constant S_IRWXO is export(:S_IRWXO, :ALL) = %lld",
    "S_IRWXO",
    #ifdef S_IRWXO
      S_IRWXO
    #else
      0
    #endif
  },
  {
    "constant S_IRWXU is export(:S_IRWXU, :ALL) = %lld",
    "S_IRWXU",
    #ifdef S_IRWXU
      S_IRWXU
    #else
      0
    #endif
  },
  {
    "constant S_ISGID is export(:S_ISGID, :ALL) = %lld",
    "S_ISGID",
    #ifdef S_ISGID
      S_ISGID
    #else
      0
    #endif
  },
  {
    "constant S_ISTXT is export(:S_ISTXT, :ALL) = %lld",
    "S_ISTXT",
    #ifdef S_ISTXT
      S_ISTXT
    #else
      0
    #endif
  },
  {
    "constant S_ISUID is export(:S_ISUID, :ALL) = %lld",
    "S_ISUID",
    #ifdef S_ISUID
      S_ISUID
    #else
      0
    #endif
  },
  {
    "constant S_ISVTX is export(:S_ISVTX, :ALL) = %lld",
    "S_ISVTX",
    #ifdef S_ISVTX
      S_ISVTX
    #else
      0
    #endif
  },
  {
    "constant S_IWGRP is export(:S_IWGRP, :ALL) = %lld",
    "S_IWGRP",
    #ifdef S_IWGRP
      S_IWGRP
    #else
      0
    #endif
  },
  {
    "constant S_IWOTH is export(:S_IWOTH, :ALL) = %lld",
    "S_IWOTH",
    #ifdef S_IWOTH
      S_IWOTH
    #else
      0
    #endif
  },
  {
    "constant S_IWRITE is export(:S_IWRITE, :ALL) = %lld",
    "S_IWRITE",
    #ifdef S_IWRITE
      S_IWRITE
    #else
      0
    #endif
  },
  {
    "constant S_IWUSR is export(:S_IWUSR, :ALL) = %lld",
    "S_IWUSR",
    #ifdef S_IWUSR
      S_IWUSR
    #else
      0
    #endif
  },
  {
    "constant S_IXGRP is export(:S_IXGRP, :ALL) = %lld",
    "S_IXGRP",
    #ifdef S_IXGRP
      S_IXGRP
    #else
      0
    #endif
  },
  {
    "constant S_IXOTH is export(:S_IXOTH, :ALL) = %lld",
    "S_IXOTH",
    #ifdef S_IXOTH
      S_IXOTH
    #else
      0
    #endif
  },
  {
    "constant S_IXUSR is export(:S_IXUSR, :ALL) = %lld",
    "S_IXUSR",
    #ifdef S_IXUSR
      S_IXUSR
    #else
      0
    #endif
  },
  {
    "constant LOCK_SH is export(:LOCK_SH, :ALL, :flock) = %lld",
    "LOCK_SH",
    #ifdef LOCK_SH
      LOCK_SH
    #else
      0
    #endif
  },
  {
    "constant LOCK_EX is export(:LOCK_EX, :ALL, :flock) = %lld",
    "LOCK_EX",
    #ifdef LOCK_EX
      LOCK_EX
    #else
      0
    #endif
  },
  {
    "constant LOCK_NB is export(:LOCK_NB, :ALL, :flock) = %lld",
    "LOCK_NB",
    #ifdef LOCK_NB
      LOCK_NB
    #else
      0
    #endif
  },
  {
    "constant LOCK_UN is export(:LOCK_UN, :ALL, :flock) = %lld",
    "LOCK_UN",
    #ifdef LOCK_UN
      LOCK_UN
    #else
      0
    #endif
  },
  {
    "constant SEEK_SET is export(:SEEK_SET, :ALL, :seek, :mode) = %lld",
    "SEEK_SET",
    #ifdef SEEK_SET
      SEEK_SET
    #else
      0
    #endif
  },
  {
    "constant SEEK_CUR is export(:SEEK_CUR, :ALL, :seek, :mode) = %lld",
    "SEEK_CUR",
    #ifdef SEEK_CUR
      SEEK_CUR
    #else
      0
    #endif
  },
  {
    "constant SEEK_END is export(:SEEK_END, :ALL, :seek, :mode) = %lld",
    "SEEK_END",
    #ifdef SEEK_END
      SEEK_END
    #else
      0
    #endif
  },
  {
    "constant S_IFMT is export(:S_IFMT, :ALL) = %lld",
    "S_IFMT",
    #ifdef S_IFMT
      S_IFMT
    #else
      0
    #endif
  },
  { (char*)NULL, 0 }
};

int main() {
  struct definition_pair *one = definitions;
  FILE *outfile = fopen("Fcntl.pm", "a");
  fprintf(outfile, "\n");

  while ( one->const_name != NULL ) {
    fprintf(outfile, one->const_pattern, one->const_value);
    fprintf(outfile, ";\n");
    one++;
  }

  fclose(outfile);

  return 0;
}
