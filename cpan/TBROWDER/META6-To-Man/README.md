# META6::To::Man  [![Build Status](https://travis-ci.org/tbrowder/META6-To-Man-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/META6-To-Man-Perl6)

Produces a rudimentary UNIX man page from a Perl 6 META6.json (or META.json) file

# SYNOPSIS

```perl6
$ meta6-to-man --meta6=./META6.json
```

The output file should be a UNIX roff file named '\<name\>.1' where
'\<name\>' is the 'name' key value in the META6.json file.

# USAGE

```perl6
$ meta6-to-man
Usage: ./bin/meta6-to-man --meta6=M [options...]

  Produces a UNIX 'man' page from data in the Perl 6 META6 file 'M'.
  The output is written to file 'F.1' where 'F' is the name from the META6
  file (which can be changed with the '--man' option below).

Mandatory argument:

  --meta6=M       Defines the desired META6.json file to be used. 'M' must be a
                  valid META6 file.

Options:

  --install       Installs the output file to one of the standard man
                  directories. The directory actually chosen is the first
                  one found with write privileges for the user.  The
                  directories are searched in this order:

                    /usr/share/man/manN
                    /usr/local/share/man/manN
                    /usr/local/man/manN

  --install-to=D  Installs the output file to directory D.

  --date=YYYY-MM-DD
                  The default is the current date.

  --man=F         Defines the man roff file 'F'. It is an error if
                  the file name does not end in '.N' where 'N' is a digit in
                  the range '1..8'.

  --quiet         Silences all messages. Normally for developer use.

  --debug         Normally for developer use.

```

The output troff file from running:

```
perl6 -Ilib ./bin/meta6-to-man --meta6=./META6.json --install-to=./doc
```

in the top-level directory in this repository can be found [here](./doc/META6::To::Man.1).

# MISCELLANEOUS

View a local man page on a POSIX system (e.g., the one you just generated):

```perl6
man -l <man src file name>.<number>
```
Example (note 'l' is the lower-case letter 'ell'):

```perl6
man -l My::Module.1
```

Man page numbers most likely for Perl 6 modules (from man-pages(7) :

+ 1 Commands (Programs)
	Those commands that can be executed by the user from within a shell.

+ 3 Library calls
	Most of the libc functions.

# REFERENCES

1. On a POSIX system:

  + man(7)
  + man-pages(7)

2. Writing man pages: https://liw.fi/manpages

# LICENSE

Artistic-2.0

# COPYRIGHT

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>> (IRC #perl6: tbrowder)
