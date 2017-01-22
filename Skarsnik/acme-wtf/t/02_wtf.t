use Test;
use Test::Output;
use Acme::WTF;

plan 2;

my $what-like = /<:Lu>+<:P>+ ' what'/;

output-like { say 'what' }, $what-like;
throws-like { die 'what' }, $what-like;

