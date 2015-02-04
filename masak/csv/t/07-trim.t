use v6;
use Test;

use Text::CSV;

my $spacey =
qq|start,trailing spaces    ,     leading spaces,end\nmore,\t\t,  ,tabs and spaces|;

my $unspaced =
qq|start,trailing spaces,leading spaces,end\nmore,,,tabs and spaces|;

is csv-write(Text::CSV.parse($spacey)), $spacey,
  'Parsing CSV with edge spaces in fields round trips.';

is csv-write(Text::CSV.parse($spacey, :trim )),
  $unspaced, ':trim removes spaces from fields correctly.';


done;

# vim:ft=perl6
