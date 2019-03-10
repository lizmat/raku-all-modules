use Bench;

my $bench = Bench.new;
my $repeat-times = 1000;

my $rc-code = -> $size, @p {
sub {
    use Random::Choice;
    choice(:$size, :@p);
}
};

sub choice(:$size where * ≥ 1 = 1, :@p where abs(1 - .sum) < 1e-3) {
    @p.pairs.Mix.roll($size)
}

my $mix-code = -> $size, @p {
sub {
    choice(:$size, :@p);
}
};

sub generate-p(Int $n --> List) {
    my @p;
    for ^$n {
        @p.push: rand;
    }

    my $sum = @p.sum;
    @p.map(* / $sum).List
}

{
    my @p = generate-p(10);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice(size=10, @p.elems=10)' => $rc-code(10, @p),
                        'Mix(size=10, @p.elems=10) ' => $mix-code(10, @p)
                    ));
}

{
    my @p = generate-p(10);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice(size=1000, @p.elems=10)' => $rc-code(1000, @p),
                        'Mix(size=1000, @p.elems=10) ' => $mix-code(1000, @p)
                    ));
}

{
    my @p = generate-p(1000);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice(size=10, @p.elems=1000)' => $rc-code(10, @p),
                        'Mix(size=10, @p.elems=1000) ' => $mix-code(10, @p)
                    ));
}

{
    my @p = generate-p(100);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice(size=100, @p.elems=100)' => $rc-code(100, @p),
                        'Mix(size=100, @p.elems=100)' => $mix-code(100, @p)
                    ));
}

{
    my @p = generate-p(1000);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice(size=1000, @p.elems=1000)' => $rc-code(1000, @p),
                        'Mix(size=1000, @p.elems=1000)' => $mix-code(1000, @p)
                    ));
}
