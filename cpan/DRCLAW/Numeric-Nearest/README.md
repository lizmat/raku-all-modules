# Numeric::Nearest

A simple module to find the nearest element in a ordered list without processing all elements.

The grep sub will process all elements in a list, which is slow when you have an ordered list of numbers.

Hashes only work for keys matching exaclty. 

## Example
```perl6
use Numeric::Nearest;

my @l=1,2,3,4;

say nearestPair(1.2, @l);
```

The closest entry in the list to 1.2 is 1.


## Details

- Binary search is used to locate the closest elements. Essential for large lists of time series data.
- An optional start named parameters can be used to start the binary search at a particular point (last run)
- For keys out of range, the start of the end element of the list is returned. Which ever is closest.


## Exported subs

```perl6
sub nearestPair($key,$list,:$start);
```

Returns a pair of index => value of the element of $list which is nearest in magnitude to $key

```perl6
sub nearestPairs($key,$list);
```

Returns a sequence of index => values, one for each element in the $keys variable.


## License 
Artistic-2.0
