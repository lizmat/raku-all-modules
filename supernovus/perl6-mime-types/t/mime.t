use v6;
use Test;

BEGIN { @*INC.push: './lib'; }

use MIME::Types;

my $mime = MIME::Types.new('./doc/mime.types');

plan 5;

is $mime.type('txt'), 'text/plain', 'Get a simple type';
is $mime.type('svg'), 'image/svg+xml', 'Get a + type';
my @known = $mime.extensions('application/vnd.ms-excel');
is @known[0], 'xls', 'Get extensions, first';
is @known[1], 'xlb', 'Get extensions, second';
is @known[2], 'xlt', 'Get extensions, third';
