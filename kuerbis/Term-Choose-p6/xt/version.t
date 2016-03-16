use v6;
use Test;

plan 6;



my %hash = (
    choose              => 'lib/Term/Choose.pm6',
    choose_ncurses      => 'lib/Term/Choose/NCurses.pm6',
    choose_linefold     => 'lib/Term/Choose/LineFold.pm6',
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

ok( %version<choose> > 0, 'Version greater than 0  OK' );

is( %podversion<choose>,        %version<choose>, 'Version in POD Term::Choose  OK' );
is( %version<choose_ncurses>,   %version<choose>, 'Version in Term::Choose::NCurses  OK' );
is( %version<choose_linefold>,  %version<choose>, 'Version in Term::Choose::LineFold  OK' );
is( $version_in_changelog,      %version<choose>, 'Version in "Changes"  OK' );
is( $release_date,              $today,           'Release date in Changes is date from today  OK' );
