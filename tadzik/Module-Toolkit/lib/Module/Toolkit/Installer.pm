unit class Module::Toolkit::Installer;
# "Adopted" from https://gist.github.com/niner/8ad4cbefde16d9494e16
# Which is, as it turns out, adopted from Panda itself
# It's the ciiiiircle of liiiiife...

role Distribution::Directory {
    has IO::Path $.path;
    has %!meta;

    method meta() {
        %!meta ||= from-json slurp ('META6.json', 'META.info').map({$.path.child($_)}).first: {$_ ~~ :f};
    }

    method sources() {
        my %sources = self.meta<provides>;
        $_ = $.path.child($_) for %sources.values;
        %sources
    }

    method scripts() {
        my %scripts;
        my $bin-dir = $.path.child('bin');
        if $bin-dir ~~ :d {
            for $bin-dir.dir -> $bin {
                my $basename = $bin.basename;
                next if $basename.substr(0, 1) eq '.';
                next if !$*DISTRO.is-win and $basename ~~ /\.bat$/;
                %scripts{$basename} = ~$bin;
            }
        }
        %scripts
    }

    method resources {
        my $resources-dir = $.path.child('resources');
        %( (self.meta<resources> // []).map({
            $_ => $_ ~~ m/^libraries\/(.*)/
                ?? ~$resources-dir.child('libraries').child($*VM.platform-library-name($0.Str.IO))
                !! ~$resources-dir.child('$_')
        }) );
    }
}

has CompUnit::Repository $.default-to =
    $*REPO.repo-chain\
        .grep(CompUnit::Repository::Installable)\
        .first(*.can-install);


multi method install(IO::Path() $from, Str() $curname) {
    self.install(
        $from,
        CompUnit::RepositoryRegistry.repository-for-name($curname))
}

multi method install(IO::Path() $from,
               CompUnit::Repository::Installable() $to = $.default-to,
               Bool() :$force = False) {
    my $dist-dir = Distribution::Directory.new(path => $from);

    $to.install(
        Distribution.new(|$dist-dir.meta),
        $dist-dir.sources,
        $dist-dir.scripts,
        $dist-dir.resources,
        :$force,
    );
}
