# Ops::SI

Add postfix operators for [SI
prefixes](https://en.wikipedia.org/wiki/Metric_prefix).

## Installation
Installation can be done through [zef](https://github.com/ugexe/zef):

```
$ zef install Ops::SI
```

## Usage
In your Perl 6 code, use the module and you're all set.

```perl6
use Ops::SI;

dd 1k; # 1000
dd 2T; # 2000000000000
dd 3µ; # 0.000003
dd 4y; # 4e-24
```

## License
This module is distributed under the terms of the AGPL version 3.0. You can
find it in the `LICENSE` file distributed with the module.
