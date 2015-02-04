use v6;
use Test;

plan 6;

use Compress::Zlib;

gzspurt("t/compressed.gz", "this\nis\na\ntest");

my $wrap = zwrap(open("t/compressed.gz"), :gzip);
is $wrap.get, "this\n", 'first line roundtrips';
is $wrap.get, "is\n", 'second line roundtrips';
is $wrap.get, "a\n", 'third line roundtrips';
is $wrap.get, "test", 'fourth line roundtrips';

$wrap.close;
unlink("t/compressed.gz");

gzspurt("t/compressed.gz", "a»second\ntest");
$wrap = zwrap(open("t/compressed.gz"), :gzip);
is $wrap.get, "a»second\n", 'first multibyte line roundtrips';
is $wrap.get, "test", 'second multibyte line roundtrips';

$wrap.close;
unlink("t/compressed.gz");
