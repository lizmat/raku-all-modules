use v6;

use Compress::Snappy;
use Test;

nok Compress::Snappy::validate(Buf.new()), 'zero length buf is invalid';
nok Compress::Snappy::validate(Buf.new(1)), 'buf with just a one is invalid';

my @compressed = Compress::Snappy::compress('a' x 800).list;
my $mangled = Buf.new: 1 + @compressed[0], @compressed[1 .. *];
nok Compress::Snappy::validate($mangled), 'mangled header';

@compressed[$_]++ for 40 .. 50;
nok Compress::Snappy::validate(Buf.new: @compressed), 'mangled content';

done-testing;
