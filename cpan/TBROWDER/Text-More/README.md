# Text::More

[![Build Status](https://travis-ci.org/tbrowder/Text-More-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Text-More-Perl6)

Being a lazy programmer, I refactor chunks of code I find useful into
a module; whence comes this collection of Perl 6 subroutines I have
written during my coding adventures using Perl 5's new little sister.
I hope they will be useful to others.

The routines are described in detail in
[ALL-SUBS](https://github.com/tbrowder/Text-More-Perl6/blob/master/docs/ALL-SUBS.md)
which shows a short description of each exported routine along along
with its complete signature.

This module also includes a utility program in the
[bin](https://github.com/tbrowder/Text-More-Perl6/blob/master/bin)
directory.

## Status

This version is 0.\*.\* which is considered usable but may not be ready
for production.  The APIs are subject to change in which case the
version major number will be updated. Note that newly added
subroutines or application programs are not considered a change in
API.

## Debugging

For debugging, use one of the following methods:

- set the module's $DEBUG variable:

```Perl6
:$Text::More::DEBUG = True;
```

- set the environment variable:

```Perl6
TEXT_MORE_DEBUG=1
```

## Subroutines Exported by the `:ALL` Tag

See
[ALL-SUBS](https://github.com/tbrowder/Text-More-Perl6/blob/master/docs/ALL-SUBS.md)
for a list of export(:ALL) subroutines, each with a short description
along with its complete signature.  Note that individual subroutines
may also be exported:

```Perl6
use Text::More :ALL;
```

```Perl6
use Text::More :strip-comment;
```

## Utility Program

See the
[bin](https://github.com/tbrowder/Text-More-Perl6/blob/master/bin)
directory for a utility program (```create-md.p6```) to create a
**README.md** file for modules.

Executing it without any arguments results in the following:

```Perl6
Usage: ./create-md.p6 -m <file> | -b <bin dir> | -h [-d <odir>, -N, -M <max>, -D]

Reads the input module (or program files in the bin dir) and extracts
properly formatted comments into markdown files describing the subs
and other objects contained therein.  Output files are created in the
output directory (-d <dir>) if entered, or the current directory
otherwise.

Subroutine signature lines are folded into a nice format for the
markdown files unless the user uses the -N (no-fold) option.  The -M
<max> option specifies a user-desired maximum line length for folding.
The signature is output as a code block.

In program files, the comments are folded into lines no longer than
the maximum line length.  If the program has a help option (-h), the
result of that command will be added to the output as a code block.

See the lib/Text and bin directories for a module file and a program
with the known formats.  The markdown files in the docs directory in
this repository were created with this program from those files.

Modes (select one only):

  -m <module file>
  -b <bin directory>
  -h help

Options:

  -d <output directory>    default: current directory
  -M <max line length>     default: 78

  -N do NOT format or modify sub signature lines to max length
  -v verbose
  -D debug
```

## Contributing

Interested users are encouraged to contribute improvements and
corrections to this module, and pull requests, bug reports, and
suggestions are always welcome.

## Acknowledgements

The ```commify``` subroutine is based on the subroutine of the same
name found in the *Perl Cookbook*.

## LICENSE and COPYRIGHT

Artistic 2.0. See [LICENSE](https://github.com/tbrowder/Text-More-Perl6/blob/master/LICENSE).

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>>
