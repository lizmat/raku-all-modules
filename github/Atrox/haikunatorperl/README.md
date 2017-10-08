# Haikunator for Perl 6

[![Build Status](https://img.shields.io/travis/Atrox/haikunatorperl.svg?style=flat-square)](https://travis-ci.org/Atrox/haikunatorperl)

Generate Heroku-like random names to use in your **perl 6** applications.

## Installation

```
panda install Haikunator
```
or in your META.info:
```perl6
"depends" : [ "Haikunator" ],
```

## Usage

Haikunator is pretty simple.

```perl6
use Haikunator;

# default usage
haikunate() # => "wispy-dust-1337"

# custom length (default=4)
haikunate(:tokenLength(6)) # => "patient-king-887265"

# use hex instead of numbers
haikunate(:tokenHex(True)) # => "purple-breeze-98e1"

# use custom chars instead of numbers/hex
haikunate(:tokenChars("HAIKUNATE")) # => "summer-atom-IHEA"

# don't include a token
haikunate(:tokenLength(0)) # => "cold-wildflower"

# use a different delimiter
haikunate(:delimiter(".")) # => "restless.sea.7976"

# no token, space delimiter
haikunate(:tokenLength(0), :delimiter(" ")) # => "delicate haze"

# no token, empty delimiter
haikunate(:tokenLength(0), :delimiter("")) # => "billowingleaf"
```

## Options

The following options are available:

```perl6
haikunate(
  :delimiter("-"),
  :tokenLength(4),
  :tokenHex(False),
  :tokenChars("0123456789")
)
```
*If ```tokenHex``` is true, it overrides any tokens specified in ```tokenChars```*

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/atrox/haikunatorperl/issues)
- Fix bugs and [submit pull requests](https://github.com/atrox/haikunatorperl/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

## Other Languages

Haikunator is also available in other languages. Check them out:

- Node: https://github.com/Atrox/haikunatorjs
- .NET: https://github.com/Atrox/haikunator.net
- Python: https://github.com/Atrox/haikunatorpy
- PHP: https://github.com/Atrox/haikunatorphp
- Java: https://github.com/Atrox/haikunatorjava
- Go: https://github.com/Atrox/haikunatorgo
- Dart: https://github.com/Atrox/haikunatordart
- Ruby: https://github.com/usmanbashir/haikunator
- Rust: https://github.com/nishanths/rust-haikunator
