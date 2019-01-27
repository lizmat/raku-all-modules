unit class Build;

method build (IO() $dist-path) {
    my $make = $*VM.config<make>;
    my $src = $dist-path.add("src");
    my $res = $dist-path.add("resources");
    $res.mkdir;

    my $minisat = $src.add("minisat");
    my $solver = 'minisat';
    say "Building $solver release version...";
    run $make, '-C', ~$minisat, 'r';
    say "Copying $solver to resources";
    copy $minisat.add('build').add('release').add('bin').add($solver), $res.add($solver);
    True
}

# vim: ft=perl6
