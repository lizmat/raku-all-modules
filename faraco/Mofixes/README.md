[![Build Status](https://travis-ci.org/faraco/Mofixes.svg?branch=master)](https://travis-ci.org/faraco/Mofixes)
---
### Mofixes
A collection of prefix, postfix, infix, and circumfix ready to use for Perl 6.


### Install
* Using zef(or panda):	`zef update && zef install Mofixes`

### Usage
```perl6
use Mofixes;

# prefixes (mnemonic)
mofact 6; # 720
mofactadd 6; # 20
mofactminus 6; # -16
mofactdivide 6; # 0.005556

# postfixes
6!; # 720
6!+; # 20
6!-; # -16
6!!/; # 0.005556

exit;
```

### Status
**[under heavy development]()**

> Feel free to contribute. I'll review them ASAP and pull them if its benefits the distribution(even a single typo fix is much appreciated).
