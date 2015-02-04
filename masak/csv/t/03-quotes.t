use v6;
use Test;

use Text::CSV;

sub ok_becomes($input, $output, $description = '') {
    is_deeply Text::CSV.parse($input), $output, $description;
}

ok_becomes qq[[[foo,bar,baz\n'foo','bar','baz'\n'foo','bar' , 'baz']]],
  [
    [<foo bar baz>],
    ["'foo'", "'bar'", "'baz'"],
    ["'foo'", "'bar' ", " 'baz'"]
  ],
  'single quotes carry no special significance';

ok_becomes qq[[[foo,bar,baz\n"foo","bar","baz"\n"foo","bar" , "baz"]]],
  [
    [<foo bar baz>] xx 3
  ], 'double quotes';

lives_ok { Text::CSV.parse(q[[[foo,ba'r,ba'z]]]) },
         'mid-string single quotes legal';
dies_ok { Text::CSV.parse(q[[[foo,ba"r,ba"z]]]) },
        'mid-string double quotes illegal';

is +Text::CSV.parse(q[[[foo,'bar,baz']]])[0], 3, 'cannot single-quote commas';
is +Text::CSV.parse(q[[[foo,"bar,baz"]]])[0], 2, 'can double-quote commas';

dies_ok { Text::CSV.parse(q[[["foo"oo"]]]) },
        'non-duplicated double quotes in double-quoted strings illegal';
lives_ok { Text::CSV.parse(q[[["foo""oo"]]]) },
         'duplicated double quotes in double-quoted strings legal';

ok_becomes q[[[foo,"ba""r","ba""""z"]]], [ [<foo ba"r ba""z>] ], 'quote escaping';

ok_becomes q[[[foo,"""","""baz"""]]], [ [<foo " "baz">] ], 'quote escaping at the boundary';

ok_becomes qq[[[foo,"ba\nr","baz"]]],
  [ ['foo', "ba\nr", 'baz'] ], 'newlines are allowed inside quotes';


done;

# vim:ft=perl6
