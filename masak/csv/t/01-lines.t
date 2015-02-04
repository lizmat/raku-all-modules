use v6;
use Test;

use Text::CSV;

sub ok_becomes($input, $output, $description = '') {
    is_deeply Text::CSV.parse($input), $output, $description;
}

ok_becomes qq[[[foo\nbar\nbaz]]],
  [['foo'], ['bar'], ['baz']], 'three lines, no commas';

ok_becomes qq[[[foo\nbar\nbaz\n]]],
  [['foo'], ['bar'], ['baz']], 'three lines, no commas, final empty line';

done;

# vim:ft=perl6
