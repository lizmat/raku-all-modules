use v6;
use Test;

use Text::CSV;

my $string =
qq|start,next  ,,end\nmore,,,empty spaces|;

my $tabby =
qq|start\tnext  \t\tend\nmore\t\t\tempty spaces|;

is csv-write(Text::CSV.parse($string)), $string,
  'Parsing CSV with empty fields round trips.';

is Text::CSV.parse($tabby, :separator("\t")),
    Text::CSV.parse($string),
    'Parsing tab delimited CSV with empty fields matches comma delimited.';

done;

# vim:ft=perl6
