[![Build Status](https://travis-ci.org/FCO/Injector.svg?branch=master)](https://travis-ci.org/FCO/Injector)

# Injector

A perl6 dependency injector

## Synopsys

```perl6
use lib "lib";

use Injector;

class Rand {
    has $.r = ("a" .. "z").roll(rand * 10).join;
}

class C2 {
    has Int $.a is injected
}

class C1 {
    has C2      $.c2    is injected;
    has Int     $.b     is injected<test>;
    has Rand    $.r     is injected{:lifecycle<instance>};
}

BEGIN {
    bind 42;
    bind 13, :name<test>;
}

my C1 $c is injected;
say $c;                     # C1.new(c2 => C2.new(a => 42), b => 13, r => Rand.new(r => "qo"))

for ^3 {
    given C1.new: :123b {
        .c2.a.say;          # 42                            42                          42
        .b.say;             # 123                           123                         123
        .r.say;             # Rand.new(r => "ztjbpvqka")    Rand.new(r => "zsmqnrr")    Rand.new(r => "wmsq")
    }
}
```



