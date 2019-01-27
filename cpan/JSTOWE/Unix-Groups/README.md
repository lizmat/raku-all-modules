# Unix::Groups

Access to the Unix group file in Perl 6

## Synopsis

```perl6
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

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install User::Groups

## Support

Suggestions/patches are welcomed via github at https://github.com/jonathanstowe/User-Groups/issues

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017, 2019

