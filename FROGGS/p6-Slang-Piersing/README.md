## Slang::Piersing

This slang allows identifier names like #foo?' and 'foo!':

```perl6
sub foo?($a, $b) { $a * $b };
sub foo!($a, $b) { $a + $b };

foo? 3, 5  # 15
foo?(3, 5) # 15
foo!(3, 5) #  8
```
