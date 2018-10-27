use v6;

#use lib 'lib';

use Test;
use Netstring;

plan 4;

my $test_str = "hello world!";
my $test_buf = $test_str.encode;

my $wanted_str = "12:hello world!,";
my $wanted_buf = $wanted_str.encode;

is to-netstring($test_str), $wanted_str, 'to-netstring(Str)';
is to-netstring($test_buf), $wanted_str, 'to-netstring(Buf)';

## This would use 'is', but 'is' with Buf objects is broken at the moment.
ok to-netstring-buf($test_str) == $wanted_buf, 'to-netstring-buf(Str)';
ok to-netstring-buf($test_buf) == $wanted_buf, 'to-netstring-buf(Buf)';

