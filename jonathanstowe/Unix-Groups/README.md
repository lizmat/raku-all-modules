# Unix::Groups

Access to the Unix group file in Perl 6

## Synopsis

```
use Unix::Groups;

my $groups = Unix::Groups.new;

say "The logged in user is member of these groups:";

for $groups.groups-for-user($*USER.Str) -> $group {
	say $group.name;
}
```

## Description

This module provides access to the group details from ```/etc/group```,
with similar to ```getgrent()```, ```getgrnam``` and ```getgrgid```
in the Unix standard C library.

The methods either return a Unix::Groups::Group object or an array of
those objects.

Because this module goes directly to the group file, if your system is
configured to retrieve its group information from e.g. NIS or LDAP it
may not necessarily reflect all the groups present, just the local ones.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install User::Groups

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/User-Groups

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015

