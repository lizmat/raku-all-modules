use v6;
use Test;
use IO::String;

plan 29;

# getc
{
    my $buf = "hello,\nworld!\n";
    my $s = IO::String.new(buffer => $buf);
    for $buf.comb {
        ok !$s.eof, "not yet eof";
        is $s.getc, $_, "getc is $_";
    }
    ok $s.eof, "we have eof";
}
