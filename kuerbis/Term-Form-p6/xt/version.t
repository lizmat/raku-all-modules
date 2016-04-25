use v6;
use Test;

plan 4;


my %hash = (
    form => 'lib/Term/Form.pm6',
);


my %version;
my %podversion;


my $c = -1;
for %hash.kv -> $k, $v {
    %version{$k}    = --$c;
    %podversion{$k} = --$c;
    for $v.IO.lines -> $line {
        if $line ~~ / ^ my \s \$VERSION \s \= \s . (\d\.\d\d\d[_\d\d]?) . \; / {
            %version{$k} = $0;
        }
        #if $line ~~ / ^ \= head1 \s VERSION / ff / ^ '=' /{
            if $$line ~~ / ^ Version \s (\S+) $/ {
                %podversion{$k} = $0;
            }
        #}
    }
}


my $version_in_changelog = --$c;
my $release_date = --$c;
for 'Changes'.IO.lines -> $line {
    if $line ~~ / ^ \s* ( \d+ \. \d\d\d [_\d\d]? ) \s+ ( \d\d\d\d '-' \d\d '-' \d\d) \s* $/ {
        $version_in_changelog = $0;
        $release_date = $1;
        last;
    }
}



my Date $today = Date.today;

ok( %version<form> > 0, 'Version greater than 0  OK' );

is( %podversion<form>,        %version<form>, 'Version in POD Term::Form  OK' );
is( $version_in_changelog,    %version<form>, 'Version in "Changes"  OK' );
is( $release_date,            $today,         'Release date in Changes is date from today  OK' );

