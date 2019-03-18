use v6.c;
use Test;
use P5caller;
%*ENV<RAKUDO_NO_DEPRECATIONS> = True;

plan 14;

ok defined(::('&caller')),          'is &caller imported?';
ok !defined(P5caller::{'&caller'}), 'is &caller externally NOT accessible?';

sub foo { bar }
my $the-line = $?LINE - 1;
sub bar {
    for caller, caller(1) -> ($package,$filename,$line,$subname,$code) {
        is $package, 'GLOBAL',          'did we get the right package';
        ok $?FILE.ends-with($filename), 'did we get the right file name';
        is $line, $the-line,            'did we get the right line number';
        is $subname, 'foo',             'did we get the right subname';
        isa-ok $code, Sub,              'did we get a Sub';
    }
}
foo();

sub BAZ() {
    is caller(Scalar), 'GLOBAL', 'did we get the right package name';
}
BAZ();

sub baz() {
    is caller(:scalar), 'GLOBAL', 'did we get the right package name';
}
baz();

# vim: ft=perl6 expandtab sw=4
