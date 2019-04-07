use 5.008_008;
use ExtUtils::MakeMaker;

my $pm   = 'lib/Acme/Polyglot/Levenshtein/Damerau.pm';
my $repo = 'https://github.com/ugexe/Acme--Polyglot--Levenshtein--Damerau';
my $bugs = 'https://github.com/ugexe/Acme--Polyglot--Levenshtein--Damerau/issues';

WriteMakefile ( 
    NAME => 'Acme::Polyglot::Levenshtein::Damerau',
    VERSION => '0.1',
    ABSTRACT => 'Polyglot Perl 5/6 damerau levenshtein algorithm module',
    AUTHOR => 'Nick Logan <ugexe@cpan.org>',
    LICENSE => 'Artistic-2.0',
    MIN_PERL_VERSION => '5.008008',
    TEST_REQUIRES => {
        'Test' => '0',
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => $bugs,
        },
        provides => {
            'Acme::Polyglot::Levenshtein::Damerau' => {
                file    => $pm,
                version => '0.1',
            },
        },
    }
);
