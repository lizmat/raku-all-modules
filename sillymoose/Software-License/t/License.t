use v6;
use Test;
use lib 'lib';
use Software::License;

plan 7;

ok my $license = Software::License.new, 'Constructor';
ok $license.full-text('Apache2', "David Farrell"), 'Apache2 full_text';
ok $license.full-text('Artistic2', "David Farrell", 2015), 'Artistic2 full_text';
ok $license.full-text('BSD', "David Farrell", 2000), 'BSD full_text';
ok $license.full-text('FreeBSD', "David Farrell", 2009), 'FreeBSD full_text';
ok $license.full-text('GPL3', "David Farrell", 2000), 'GPL3 full_text';
ok $license.full-text('MIT', "David Farrell", 1999), 'MIT full_text';

