## Slang::Mosdef

All the cool kids are using def to declare methods.  Now you can, too.

[![Build Status](https://travis-ci.org/bduggan/mosdef.svg?branch=master)](https://travis-ci.org/bduggan/mosdef)

```perl6
use Slang::Mosdef;

class Foo {
    def bar {
        say 'I am cool too';
    }
    method baz {
        say 'This is not as much fun';
    }
}
```

You can also use lambda for subs!

```perl6
my $yo = lambda { say 'oy' };
$yo();
```

Or λ!

```perl6
my $twice = λ ($x) { $x * 2 };
say $twice(0); # still 0
```

Compute 5 factorial using a Y combinator:
```perl6
say λ ( &f ) {
  λ ( \n ) {
    return f(&f)(n);
  }
}(
  λ ( &g ) {
    λ ( \n ) {
        return n==1 ?? 1 !! n * g(&g)(n-1);
    }
})(5)
```
