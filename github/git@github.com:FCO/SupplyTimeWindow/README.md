[![Build Status](https://travis-ci.org/FCO/SupplyTimeWindow.svg?branch=master)](https://travis-ci.org/FCO/SupplyTimeWindow)

# SupplyTimeWindow

```perl6
use SupplyTimeWindow;

my $s = Supplier.new;
my $t = $s.Supply.time-window: 1;

start react whenever $t { .say }
                                
for ^10 -> $i { $s.emit: $i; sleep .5.rand }
```

SupplyTimeWindow creates `time-window()` new method on `Supply`ies that receives the size of the time window in seconds.
Every time the original `Supply` emits, it will emit an `Array` with each value emitted less than `time window`'s size seconds.

```perl6
multi method time-window($seconds --> Supply) {...}
```

It also accepts a optional named parameter `transform`, it's a `Callable` that will be used to transform the time window array.

```perl6
multi method time-window($seconds, :&transform! --> Supply) {...}
```
