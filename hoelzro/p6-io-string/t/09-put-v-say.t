use v6;
use Test;
use IO::String;

plan 1;

class T {
    method Str { 'hello' }
    method gist { 'world' }
}

my $s = IO::String.new;
my $t = T.new;
{
    my $*OUT = $s;

    put $t;
    say $t;
}

is ~$s, "hello\nworld\n", 'put and say are different';
