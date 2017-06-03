use lib <lib>;
use Testo;
use Proc::Q;

plan 1;

my %ins is SetHash;
my @stuff = Nil, Blob.new(1, 2, 3), 'meow', '';
@stuff[^26] = |@stuff xx *;
my @l = 'a'..'z';
react whenever proc-q
    @stuff.map({
        $*EXECUTABLE, '-e', .defined ?? '$*IN.slurp.print' !! ''
    }),
    :in[@stuff]
{
    %ins{.out}++;
}

is-eqv %ins, @stuff.grep(*.defined).map({
    $_ ~~ Blob ?? "\x[1]\x[2]\x[3]" !! $_
}).SetHash, 'seen all the ins';
