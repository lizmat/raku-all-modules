Perl 6 POSIX Library
====================

This module implements a Perl 6 interface to the functions specified by the POSIX IEEE Std 1003.1.  It is currently a work in progress and doesn't implement the full list of functions, so if you'd like something that's not currently present, please feel free to contribute!

Implemented Functions
---------------------

At present, the following functions have been implemented:

  * getgid() - Returns the user's real group identifier. Similar to the numeric context of Perl 6's builtin variable $*GROUP

  * getuid() - Returns the user's identifier. Similar to the numeric context of Perl 6's builtin variable $*USER

  * setgid(gid_t $gid) - Sets the real group identifier and the effective group identifier for this process. Accepts a single numeric argument - the group identifier to which the process will be set.

  * setuid(uid_t $uid) - Sets the real user identifier and the effective user identifier for this process. Accepts a single numeric argument - the user identifier to which the process will be set.

  * getpwnam(Str $username) -  Returns an anonymous class containing the broken-out fields of the record in the password database (e.g., the local password file /etc/passwd, NIS, and LDAP) that matches the provided username.  The class has the following accessor methods: username, password, uid, gid, gecos, homedir, and shell.  On Mac OS X, two additional fields are provided - changed and expiration - which correspond to the last password change date, and the account expiration date.

  * getgrnam(Str $group) - Returns an anonymous class containing the broken-out fields of the record in the group database that matches the provided group name.  The class has the following accessor methods: name, password, gid, and members.

  * getgrgid(gid_t $gid) - Returns an anonymous class containing the broken-out fields of the record in the group database that matches the provided group id.  The class has the following accessor methods: name, password, gid, and members.
  
Author
------

Cory Spencer <cspencer@sprocket.org>
