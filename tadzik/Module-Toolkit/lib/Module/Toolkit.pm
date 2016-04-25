unit class Module::Toolkit;
use Module::Toolkit::Ecosystem;
use Module::Toolkit::Fetcher;
use Module::Toolkit::Installer;
use TAP;
use File::Find;
use JSON::Fast;

has $.ecosystem
    handles <project-list get-project get-dependencies>
    = Module::Toolkit::Ecosystem.new;

has $.fetcher
    = Module::Toolkit::Fetcher.new;

has $.installer
    handles <install>
    = Module::Toolkit::Installer.new;

#| Check if a C<$dist>ribution is currently installed. If this returns
#| True, you should be able to C<install()> it without C<:force>
method is-installed(Distribution $dist) {
    so $*REPO.resolve(
        CompUnit::DependencySpecification.new(
            :short-name($dist.name),
            :auth-matcher($dist.auth),
            :version-matcher($dist.version),
        )
    ) or so any($*REPO.repo-chain.grep(
                CompUnit::Repository::Installation
            )).prefix.child('dist').child($dist.id).IO.e;
}

#| Fetch a given C<$dist>ribution, store in C<$to>
multi method fetch(Distribution $dist, IO::Path() $to) {
    my $url = $dist.source-url // $dist.support<source>;
    $.fetcher.fetch($url, $to);
}

#| Fetch a distribution from a given C<$url>, store in C<$to>
multi method fetch(Str $url, IO::Path() $to) {
    $.fetcher.fetch($url, $to);
}

class Sink is IO::Handle {
    method print(|) { }
    method flush    { }
}

#| Run tests for a distribution in a given directory
#| TAP output will be written to C<$output> if supplied,
#| ignored otherwise
method test(IO::Path() $where, :$output = Sink.new) {
    temp $*CWD = chdir($where);
    return True unless $*CWD.child('t').IO.d;

    my @tests = find(dir => $*CWD.child('t'), name => /\.t$/).list».Str;
    my $handler = TAP::Harness::SourceHandler::Perl6.new(
        incdirs => [ $*CWD.child('lib') ]
    );

	my $run = TAP::Harness.new(
        handlers => $handler, :$output
    ).run(@tests);

    $run.result.get-status eq 'PASS'
}

#| Find the path to any valid metadata file in a given directory
method find-meta-file(IO::Path() $dir) {
    if $dir.child('META6.json').f {
        return $dir.child('META6.json')
    }
    if $dir.child('META.info').f {
        return $dir.child('META.info')
    }
}

#| Obtain a Distribution object for a given C<$location>, which can
#| be whatever Module::Toolkit::Fetcher may be able to handle.
#|
#| You have to supply a $tmpdir since it may be necessary to download
#| the distribution into a temporary location in order to read its
#| metadata. It may or may not be used, and you should rely on the
#| source-url attribute rather than the C<$tmpdir> you passed in.
method dist-from-location(Str $location, IO::Path() $tmpdir) {
    try {
        self.fetch($location, $tmpdir.IO);
        CATCH { default {
            return False;
        }}
    }

    my $meta = self.find-meta-file($tmpdir.IO);
    if $meta {
        my $dist = from-json slurp $meta;
        my @dep  = |($dist<depends>:delete);
        my @bdep = |($dist<build-depends>:delete);
        my @tdep = |($dist<test-depends>:delete);

        return Module::Toolkit::Distribution.new(
            |$dist,
            depends       => @dep,
            build-depends => @bdep,
            test-depends  => @tdep,
            source-url    => $tmpdir,
        );
    }
    return False;
}
