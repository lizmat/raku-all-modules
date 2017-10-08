use Acme::POE::Tree:from<Perl5>;

my $tree = Acme::POE::Tree.new(${
    star_delay => 5.5,
    light_delay => 2,
    run_for => 10
});

$tree.run;
