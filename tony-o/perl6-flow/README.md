#flow
##a pp6 implementation of prove with the ability to adapt to _newer_ methods of testing

[![Build Status](https://travis-ci.org/tony-o/perl6-flow.svg?branch=master)](https://travis-ci.org/tony-o/perl6-flow)

`flow` is intended to be an extensible `prove` replacement written entirely in `perl6`.  it's written in a way that it can be configured to use any new testing methods (think: a harness designed for parallel testing, like `mocha`). can't prove do this? kind of, you can run your tests through whatever you'd like as long as they end up in a TAP output and it will work with `prove`.

with `flow`, there isn't any need to translate your test files into TAP as long as there is a `::Plugin` available for how you write your tests.

#current state

`flow` ships with only parsing `TAP` output, there are other testing harnesses out there but they're not widely used if at all.

`flow` is being released in the environment to try and help test the TAP output parsing and provide a speedier alternative to plain `prove` (`prove -j9` is faster on my system for modules with very few tests/scripts but `prove` isn't commonly run this way by package installers)

#`flow` vs `prove`

Here is the benchmark for `Bailador` module - chosen since it has a medium level of testing -

###Script

```perl6
#!/usr/bin/env perl6

use Bench;

my $b = Bench.new;

$b.cmpthese(500, {
  prove  => sub {
    qx<prove -j9 -e 'perl6 -Ilib' t/>;
  },
  flow   => sub {
    qx<perl6 -I../../p6-flow/lib ../../p6-flow/bin/flow test>;
  }
});
```

###Benchmark

```
tonyo@mbp:~/projects/benchmark/Bailador$ ./prove-vs-flow.pl6
Benchmark:
Timing 500 iterations of flow, prove...
      flow: 1728.3408 wallclock secs @ 0.2893/s (n=500)
           prove: 3006.5033 wallclock secs @ 0.1663/s (n=500)
           O-------O--------O-------O------O
           |       | s/iter | prove | flow |
           O=======O========O=======O======O
           | prove | 6.01   | --    | -43% |
           | flow  | 3.46   | 74%   | --   |
           ---------------------------------
```

#what is being worked on now

* interface changes
* having the tests stream live results instead of just the end result 
* more configuration options

#usage

Current directory:

`flow test`

Some other directory or directories:

`flow test [<dir>]`

#installation

`zef install flow`

or

`panda install flow`

#license

[WTFPL](http://www.wtfpl.net/about/)
