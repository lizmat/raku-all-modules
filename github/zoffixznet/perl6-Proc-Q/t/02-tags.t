use lib <lib>;
use Testo;
use Proc::Q;

plan 1;

my %tags is SetHash;
my @stuff = Nil, Any, class Foo {}, class Bar {}.new,
    42, 'meow', <foo bar>;
my @l = 'a'..'z';
react whenever proc-q
    @l.map({$*EXECUTABLE, '-e', ""}),
    :tags[|@stuff, |(@stuff.pick xx @l-@stuff)]
{
    %tags{.tag ~~ Iterable ?? $(.tag) !! .tag}++;
}

is-eqv %tags, @stuff.SetHash, 'seen all the tags';
