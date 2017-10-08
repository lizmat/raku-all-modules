# DateTime::Math

## Description

Provides to-seconds(), from-seconds(), duration-from-to() and the ability
to perform certain math operations on DateTime objects.

```perl
  use DateTime::Math;

  ## Given $dt1 and $dt2 are both DateTime objects.

  my $days = from-seconds($dt2 - $dt1, 'd');
  say "The events where $days days apart";

  my $target = $dt1 + to-seconds(1, 'M');
  say "One month after $dt1 would be $target";

  my $hours = duration-from-to(3, 'y', 'h');
  say "3 years contains $hours hours.";
```

The math functions allowed are:

 * Seconds = DateTime + DateTime
 * Seconds = DateTime - DateTime
 * DateTime = DateTime + Seconds
 * DateTime = DateTime - Seconds

~~And comparisons:~~

 * ~~DateTime cmp DateTime~~
 * ~~DateTime <=> DateTime~~
 * ~~DateTime == DateTime~~
 * ~~DateTime != DateTime~~
 * ~~DateTime <= DateTime~~
 * ~~DateTime < DateTime~~
 * ~~DateTime >= DateTime~~
 * ~~DateTime > DateTime~~

Note: Rakudo has since implemented internal DateTime comparisons, therefore DateTime::Math's comparisons have been removed.

Note that all of the math operations on DateTime objects are using the
POSIX time, which is stored as seconds, so it does not support sub-second
math at this time.

## Author

 * [Timothy Totten](https://github.com/supernovus/)

## Contributions by 
 * [Clifton Wood](https://github.com/Xliff/)

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

