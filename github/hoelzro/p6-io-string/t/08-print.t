use v6;
use Test;
use IO::String;

plan 1;

my $s = IO::String.new;
{
    my $*OUT = $s;

    say 'hello, world!';
    $s.print-nl;

    $s.seek(7);
    print 'bobby';
    diag $s.tell;
}

is ~$s, "hello, bobby!\n\n", 'seek/ovewrite works';
