# Pod::Strip (Perl6)

Strip Pod annotation from Perl6. Converts Pod documentation to empty lines of the same size. 

**Bugs**:

* Also strips Pod-style annotation from strings and comments! This is incorrect behaviour and is to be changed in the future.


## Installation

Using panda:
```
$ panda update
$ panda install Pod::Strip
```

Using ufo:
```
$ ufo
$ make
$ make test
$ make install
```

## Usage:

```
use Pod::Strip;

my Str $code = slurp $?FILE;
say pod-strip($code);
```
