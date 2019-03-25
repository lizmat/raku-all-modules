use v6.c;
use Test;
use Pod::Load;

diag "Testing strings with metadata";
my $string-with-pod = q:to/EOH/;
=begin pod :ver(3) :skip-test<Chunk>
This ordinary paragraph introduces a code block:
    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);
=end pod
EOH

my @pod = load( $string-with-pod );
ok( @pod, "String load returns something" );
like( @pod[0].^name, /Pod\:\:/, "The first element of that is a Pod");
is( @pod[0].config, {:ver(3), :skip-test<Chunk>}, "Config passed" );
done-testing;
