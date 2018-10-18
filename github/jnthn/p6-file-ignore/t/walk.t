use File::Ignore;
use Test;

my $ignorer = File::Ignore.parse: q:to/IGNORES/;
    *.swp
    output/
    gen_*.c
    IGNORES
my $test-path = $*PROGRAM.dirname ~ '/example';
is $ignorer.walk($test-path).sort, <README.md src/blah.c src/generate_foo_c.pl>,
    'Can walk directory structure and apply ignores';

done-testing;
