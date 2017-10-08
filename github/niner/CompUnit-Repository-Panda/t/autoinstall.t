use Test;
use File::Temp;

plan 1;

sub mkrepo(IO::Path $dir) {
    mkdir $dir.child('precomp');
    mkdir $dir.child('sources');
    mkdir $dir.child('resources');
    mkdir $dir.child('dist');
    mkdir $dir.child('short');
    mkdir $dir.child('bin');
}

my $test-dir = tempdir.IO;
die "bogus tempdir $test-dir" unless $test-dir.chars > 5; # sanity check
mkrepo($test-dir);
mkrepo($test-dir.child('site'));
mkrepo($test-dir.child('vendor'));

%*ENV<RAKUDO_PREFIX> = $test-dir;
indir $*HOME.child('rakudo'), {
    run($*EXECUTABLE, 'tools/build/install-core-dist.pl', $test-dir);
};
indir $*HOME.child('install').child('panda'), {
    run($*EXECUTABLE, 'bootstrap.pl');
};
run($*EXECUTABLE, '-Ilib', 't/autoinstall.pl6');

ok(1, 'survived');

# vim: ft=perl6
