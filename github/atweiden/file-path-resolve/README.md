# File::Path::Resolve

Resolve file path strings which may include a leading `~`.

Resolve a path relative to another file.


## Synopsis

```perl6
use File::Path::Resolve;

my $tilde = '~';
File::Path::Resolve.absolute($tilde).perl.say;
# "/home/user".IO

my $conkyrc = '~/.config/conky/conkyrc';
File::Path::Resolve.absolute($conkyrc).perl.say;
# "/home/user/.config/conky/conkyrc".IO

my $script = 'data/script.lua';
File::Path::Resolve.relative($script, $conkyrc).perl.say;
# "/home/user/.config/conky/data/script.lua".IO

$*CWD.say;
# "/home/user/Documents/all".IO

my $dots = '../some/./document';
File::Path::Resolve.absolute($dots).perl.say;
# "/home/user/Documents/some/document".IO
```


## Installation

### Dependencies

- Rakudo Perl6


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
