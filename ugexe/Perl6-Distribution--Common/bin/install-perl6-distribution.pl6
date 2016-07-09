use Distribution::Common;

multi sub MAIN($path where *.IO.child('.git').d, Bool :$force) {
    install-dist( Distribution::Common::Git.new($path.IO, :$force) )
}

multi sub MAIN($path where *.ends-with('.tar.gz'), Bool :$force) {
    install-dist( Distribution::Common::Tar.new($path.IO, :$force) )
}

multi sub MAIN($path where *.IO.d, Bool :$force) {
    install-dist( Distribution::Common::Directory.new($path.IO, :$force) )
}

sub install-dist(Distribution::Common $dist, Bool :$force) {
    say "# [{$dist.prefix}]";
    say "# Name: {$dist.meta<name>}";
    say "# Provides:";
    say "#\t$_" for $dist.meta<provides>.values;

    say try {
        CATCH { default { say "Error: $_" } }
        CompUnit::RepositoryRegistry.repository-for-name("site").install($dist, :$force)
    } ?? "Install OK" !! "Install FAIL";
}
