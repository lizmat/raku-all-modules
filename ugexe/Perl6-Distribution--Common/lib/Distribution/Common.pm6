use Distribution::IO;
use Distribution::IO::Proc;

BEGIN { die "Need a bleading edge rakudo" if ::("Distribution::Hash") ~~ Failure }

role Distribution::Common does Distribution {
    also does Distribution::IO; # requires 'ls-files', 'slurp-rest'

    has $!prefix;
    has %!meta;

    submethod BUILD(:$!prefix, :%!meta) { }
    method new($prefix, :%meta) {
        self.bless(:$prefix, :%meta);
    }

    method meta {
        state $meta-basename = self.ls-files.first(*.ends-with('META6.json' | 'META.info'))
            or die "No META6.json file found. Aborting";
        %!meta ||= do {
            my $json = $.slurp-rest($meta-basename, :!bin);
            my %hash = %( Rakudo::Internals::JSON.from-json($json) );
            %hash<files> = self.ls-files.grep(*.starts-with('bin/' | 'resources/'))
                                        .grep(!*.ends-with('/'));
            %hash
        }
    }

    method content($name-path) {
        self but role :: {
            method open(|)  { self }
            method close(|) { True }
            method slurp-rest(|c) { nextwith($name-path, |c) }
        }
    }

    method prefix { $!prefix }
}

class Distribution::Common::Tar does Distribution::Common does Distribution::IO::Proc::Tar { }
class Distribution::Common::Git does Distribution::Common does Distribution::IO::Proc::Git { }
class Distribution::Common::Directory does Distribution::Common does Distribution::IO::Directory { }
