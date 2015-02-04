Acme::Addslashes - Perl 6 port of Perl 5 version of Acme::Addslashes which
is "port" of PHP addslashes() function. Or something.

# Synopsis

```perl
use Acme::Addslashes;

my $unsafe_string  = "Robert'); DROP TABLE Students;--";

my $totally_safe_string = addslashes($unsafe_string);

# $totally_safe_string now contains:
# R̸o̸b̸e̸r̸t̸'̸)̸;̸ ̸D̸R̸O̸P̸ ̸T̸A̸B̸L̸E̸ ̸S̸t̸u̸d̸e̸n̸t̸s̸;̸-̸-̸

# If that's not enough slashes to be safe, then I don't know what is
```

# Functions

## `addslashes`

The only function exported by this module. Will literally add slashes to
anything. Letters, numbers, punctuation, whitespace, unicode symbols. You
name it, this function can add a slash to it.

# Author

Original function was written by James Aitken <jaitken@cpan.org>, this
port was done by Konrad Borowski <x.fix@o2.pl>. Ok, it's not really a port
as logic wasn't copied. But you can call it a port if you want.
