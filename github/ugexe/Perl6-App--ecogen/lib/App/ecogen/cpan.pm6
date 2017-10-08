use App::ecogen;


class App::ecogen::cpan does Ecosystem {
    has $.prefix;
    has $!meta-list-uri = 'cpan-rsync.perl.org::CPAN/authors/id';

    method IO { self.prefix.IO }

    method meta-uris {
        my @command = '/usr/bin/rsync', '--dry-run', '--prune-empty-dirs', '-av', 
            '--include="/id/*/*/*/Perl6/"',      '--include="/id/*/*/*/Perl6/*.meta"', '--include="/id/*/*/*/Perl6/*.tar.gz"',
            '--include="/id/*/*/*/Perl6/*.tgz"', '--include="/id/*/*/*/Perl6/*.zip"',  '--exclude="/id/*/*/*/Perl6/*"',
            '--exclude="/id/*/*/*/*"',           '--exclude="id/*/*/CHECKSUMS"',       '--exclude="id/*/CHECKSUMS"',
            $!meta-list-uri, 'CPAN';

        my $indexing-proc = shell @command.join(' '), :out, :env(%*ENV);
        my $meta-uri-parts := $indexing-proc.out.slurp-rest(:close).lines.grep(*.ends-with('.meta'));
        my @meta-uris = $meta-uri-parts.grep({ !$_.starts-with('id/P/PS/PSIXDISTS/') }).map({ "http://www.cpan.org/authors/$_" });

        @meta-uris;
    }
}
