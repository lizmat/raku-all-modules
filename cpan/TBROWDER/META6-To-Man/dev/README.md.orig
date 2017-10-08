# META6::To::Man  [![Build Status](https://travis-ci.org/tbrowder/META6-To-Man-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/META6-To-Man-Perl6)

Produces a rudimentary *NIX man page from a Perl 6 META6.json (or META.json) file

# SYNOPSIS

```perl6
$ meta6-to-man META6.json > my-module.1
```

The output file should be a *NIX roff file. The default suffix number '1' may be changed by an option.

# USAGE


```perl6
$ meta6-to-man
Usage: ./bin/meta6-to-man META6.json [options...]

  Produces a POSIX 'man' page from data in the Perl 6 META6 file.  The
  file is written to stdout if no options are used.  To produce the desired
  file, the user will normally want to fine-tune the output file with or
  more of the available options.

Options:

  --man=F         Writes the man roff file to file 'F'. It is an error if
                  the file name does not end in '.N' where 'N' is a digit in
                  the range '1..8'.

  --install       Installs the output file to one of the standard man
                  directories. The directory actually chosen is the first
                  one found with write privileges for the user.  The
                  directories are searched in this order:

                    /usr/share/man/manN
                    /usr/local/share/man/manN
                    /usr/local/man/manN

  --install-to=D  Installs the output file to directory D.

  --debug         Normally for developer use.
```

# MISCELLANEOUS

View a local man page on a POSIX system (e.g., the one you just generated):

```perl6
man -l <man src file name>.<number>
```
Example:

```perl6
man -l m-module.1
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


## COPYRIGHT

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>> (IRC #perl6: tbrowder)
