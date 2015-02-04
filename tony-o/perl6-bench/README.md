#Bench[mark]

Benchmark tool for benchmarking how long a block of code runs for X iterations *or* how many times it can run in a given period.


#Usage

```perl6
use Bench;

my $b = Bench.new;

$b.timethese(1000, {
  first  => sub { sleep .05; },
  second => sub { sleep .005; },
});
'---------------------------------------------------------'.say;
$b.cmpthese(1000, {
  first  => sub { sleep .05; },
  second => sub { sleep .005; },
});
```

Output

```
Benchmark:
Timing 1000 iterations of first, second...
     first: 51.5808 wallclock secs @ 19.3871/s (n=1000)
    second: 6.4035 wallclock secs @ 156.1656/s (n=1000)
---------------------------------------------------------
Benchmark:
Timing 1000 iterations of first, second...
     first: 51.5511 wallclock secs @ 19.3982/s (n=1000)
    second: 6.4145 wallclock secs @ 155.8971/s (n=1000)
O--------O--------O-------O--------O
|        | Rate   | first | second |
O========O========O=======O========O
| first  | 19.4/s | --    | -88%   |
| second | 156/s  | 704%  | --     |
------------------------------------
```

#Methods

##.timestr(Array) returns Str

Takes an array returned from any of the following methods and returns a formatted string with the data filled in.  The string is similar to below: ```6.4145 wallclock secs @ 155.8971/s (n=1000)``` 

##.timeit(Int $iterations, Sub) returns Array

Times a single sub over X iterations.  Doesn't output anything by default, just returns an array of time spent and iterations.  Use in conjunction with ```.timestr```

##.countit(Rat $time, Sub) returns Array

Returns how many iterations of the Sub it can run in the specified time.  Use in conjunction with ```.timestr```

##.timethis(Int $iterations, Sub, Str :$title) returns Array

Runs the specified sub for $iterations and automatically prints out the ```.timestr```.  If $iterations is negative or 0 then it runs ```.countit``` instead of ```.timeit```

##.timethese(Int $iterations, Hash $Subs) returns Array

Similar to ```.timethis``` but the key in the hash becomes the title for the test.  An example of the output can be 

##.cmpthese(Int $iterations, Hash $Subs) returns Array

Similar to ```.timethese``` but it produces a cute little table comparing the results.

#License

Do whatever you want with it.

#Authors

[@tony-o](https://www.gittip.com/tony-o/)

