# File::Presence

Check that a file or directory exists and is readable.


## Synopsis

```perl6
use File::Presence;

my $config-dir = '~/.config';
my $config-file = 'bzzt';

say exists-readable-dir($config-dir)
    ?? 'readable dir exists'
    !! 'readable dir dne';

say exists-readable-file($config-file)
    ?? 'readable file exists'
    !! 'readable file dne';

say File::Presence.show($config-dir); # { :e, :d, :!f, :r, :w, :x }
say File::Presence.show($config-file); # { :e, :!d, :f, :r, :w, :!x }
```


## Installation

### Dependencies

- Rakudo Perl6


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
