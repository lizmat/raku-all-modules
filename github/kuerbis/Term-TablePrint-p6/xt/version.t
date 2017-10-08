use v6;
use Test;

plan 4;


my $meta-file = 'META6.json';
my $version-meta;

for $meta-file.IO.lines -> $line {
    if $line ~~ / ^ \s* '"version"' \s* ':' \s* \" ( \d+ \. \d+ \. \d+ ) \" / {
        $version-meta = $0;
    }
}


my $pm-file = 'lib/Term/TablePrint.pm6';
my $version-pm;

for $pm-file.IO.lines -> $line {
    if $line ~~ / ':ver<' ( \d+ '.' \d+ '.' \d+ ) '>' / {
        $version-pm = $0;
    }
    ##if $line ~~ / ^ \= head1 \s VERSION / ff / ^ '=' /{
    #    if $$line ~~ / ^ Version \s (\S+) $/ {
    #        $version-pod = $0;
    #    }
    ##}
}


my $change-file = 'Changes';
my $version-change;
my $release-date;

for $change-file.IO.lines -> $line {
    if $line ~~ / ^ \s* ( \d+ \. \d+ \. \d+ ) \s+ ( \d\d\d\d '-' \d\d '-' \d\d) \s* $/ {
        $version-change = $0;
        $release-date = $1;
        last;
    }
}


my Date $today = Date.today;


ok( $version-pm.defined,          'Version defined  OK' );
is( $version-meta,   $version-pm, 'Version in "META6"  OK' );
is( $version-change, $version-pm, 'Version in "Changes"  OK' );
is( $release-date,   $today,      'Release date in Changes is date from today  OK' );
