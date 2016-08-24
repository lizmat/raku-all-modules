use Distribution::IO;

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
                                        .grep(!*.ends-with('/')).cache;
            %hash
        }
    }

    method content($name-path) {
        self but role :: {
            method open(|)  { self }
            method close(|) { True }
            method slurp-rest(|c) { nextwith($name-path, |c) }
            method e { $name-path ~~ any($.ls-files) }
            method f { $name-path ~~ any($.ls-files) }
            method d { False }
            method r { True  }
            method w { False }
        }
    }

    method prefix { $!prefix }
}
