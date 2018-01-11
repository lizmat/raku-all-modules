use v6.c;

use List::Util <uniqnum uniqstr uniq>;

use Test;
plan 25;

ok defined(&uniqnum), 'uniqnum defined';
ok defined(&uniqstr), 'uniqstr defined';
ok defined(&uniq),    'uniq defined';

is-deeply uniqstr(), (), 'uniqstr of empty list';

is-deeply uniqstr( <abc> ), (<abc>,), 'uniqstr of singleton list';

is-deeply uniqstr( <x x x> ), (<x>,), 'uniqstr of repeated-element list';

is-deeply uniqstr( <a b a c> ), <a b c>, 'uniqstr removes subsequent duplicates';

# Please note that in Perl 6, 1, 1.0 and 1E0 all stringify to "1", differently
# from Perl 5, and thus we get a different test result here.
is-deeply uniqstr( 1, 1.0, 1E0 ), ("1",), 'uniqstr compares strings';

{
    my int $warnings;
    CONTROL { when CX::Warn { ++$warnings; .resume } }

    is-deeply
      uniqstr( "", Nil),
      ("",),
      'uniqstr considers Nil and type objects and empty-string equivalent';

    is-deeply
      uniqstr(Any),
      ("",),
      'uniqstr on undef coerces to empty-string';

    is $warnings, 2, 'uniqstr on Nil and type objects yield warnings';
}

{
    my int $warnings;
    CONTROL { when CX::Warn { ++$warnings; .resume } }

    my $cafe = "café";
    is-deeply uniqstr($cafe), ($cafe,), 'uniqstr is happy with Unicode strings';

    is $warnings, 0, 'No warnings are printed when handling Unicode strings';
}

is-deeply
  uniqnum( <1 1.0 1E0 2 3> ),
  ( 1, 2, 3 ),
  'uniqnum compares numbers';

is-deeply
  uniqnum( <1 1.1 1.2 1.3> ),
  (1,1.1,1.2,1.3),
  'uniqnum distinguishes floats';

# In Perl 6, NaN is never equal to NaN.  Therefor, if we use numerical comparison
# for the uniqueness check, all NaN's will actually be passed on.  Whether this
# is a bug or a feature, I don't know.
is-deeply
  uniqnum( 0, 1, 12345, Inf, -Inf, NaN, 0, Inf, NaN),
  ( 0, 1, 12345, Inf, -Inf, NaN, NaN ),
  'uniqnum preserves the special values of +-Inf and Nan';

{
    my int $warnings;
    CONTROL { when CX::Warn { ++$warnings; .resume } }

    is-deeply
      uniqnum( 0, Nil ),
      (0,),
      'uniqnum considers Nil and type objects and zero equivalent';

    is-deeply
      uniqnum(Any),
      (0,),
      'uniqnum on Nil and type objects coerces to zero';

    is $warnings, 2, 'uniqnum on Nil and type objects yield warnings';
}

is-deeply uniq(), (), 'uniq of empty list';

{
    my int $warnings;
    CONTROL { when CX::Warn { ++$warnings; .resume } }

    is-deeply
      uniq( "", Nil ),
      ( "", Nil ),
      'uniq distintinguishes empty-string from undef';

    is-deeply
      uniq( Any,Any ),
      (Any,),
      'uniq considers duplicate Nil and type objects as identical';

    is $warnings, 0, 'uniq on Nil and type objects does not warn';
}

{
    "a a b" ~~ m/(.) ' ' (.) ' ' (.)/;
    is-deeply uniqstr($0, $1, $2), <a b>, 'uniqstr handles Match objects';

    "1 1 2" ~~ m/(.) ' ' (.) ' ' (.)/;
    is-deeply uniqnum( $0, $1, $2 ), (1,2), 'uniqnum handles Match objects';
}

# vim: ft=perl6 expandtab sw=4
