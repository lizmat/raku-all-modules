use Distribution::Common::Directory;
use Distribution::Common::Git;
use Distribution::Common::Tar;

multi sub MAIN($path where *.IO.child('.git').d, Bool :$force, Bool :$git where *.so) {
    install-dist( Distribution::Common::Git.new($path.IO), :$force )
}

multi sub MAIN($path where *.ends-with('.tar.gz'), Bool :$force, Bool :$tar where *.so) {
    install-dist( Distribution::Common::Tar.new($path.IO), :$force )
}

multi sub MAIN($path where *.IO.d, Bool :$force, Bool :$dir where *.so = True) {
    install-dist( Distribution::Common::Directory.new($path.IO), :$force )
}

sub install-dist(Distribution::Common $dist, Bool :$force) {
    say "# [{$dist.prefix}]";
    say "# Name: {$dist.meta<name>}";
    say "# Provides:";
    say $dist.meta<provides>;
    say "#\t{.key} => {.value}" for $dist.meta<provides>.pairs;

    say try {
        CATCH { default { say "Error: $_" } }
        CompUnit::RepositoryRegistry.repository-for-name("site").install($dist, :$force)
    } ?? "Install OK" !! "Install FAIL";
}
