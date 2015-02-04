use v6;
use Test;
use IO::String;

plan 1;

my $s = IO::String.new;
{
    my $*OUT = $s;

    say 'hello, world!';
}

is ~$s, "hello, world!\n", "contents of IO::String should match what's been printed" or diag(~$s);
