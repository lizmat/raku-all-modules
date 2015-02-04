use v6;
use Test;

use Text::CSV;

my $input = qq[[[one,two\nthree,four,excess\nfive]]];

my Text::CSV $parser .= new( :output<hashes>, :!strict );
is_deeply $parser.parse($input),
          [ { one => 'three', two => 'four' },
            { one => 'five' } ],
          'the defaults are stored in attributes in the class';

done;

# vim:ft=perl6
