
#!perl6
use lib 'lib';
use Test;
use Failer;

plan 13;

sub make-fail { fail }

{
    my $orig-cwd = $*CWD;
    my $ret = sub {
        $*CWD = no-fail make-fail;
        flunk 'no-fail() did not return from routine';
    }();
    is-deeply $*CWD, $orig-cwd, 'assigning no-fail to something does not '
        ~ 'happen when it receives a Failure';
    isa-ok $ret, Failure, 'no-fail() returns a Failure';
    is-deeply $ret.handled, False, 'no-fail() returns unhandled Failure';
    $ret.so;
}

{
    my $ret = sub {
        my $foo = make-fail ∨-fail;
        flunk '∨-fail did not return from routine';
    }();
    isa-ok $ret, Failure, '∨-fail returns a Failure';
    is-deeply $ret.handled, False, '∨-fail returns unhandled Failure';
    $ret.so;
}

{
    my $ret = make-fail;
    is-deeply so-fail $ret, False, 'so-fail returns False for Failures';
    is-deeply $ret.handled, False, 'so-fail returns unhandled Failure';
    $ret.so;

    is-deeply so-fail 42, True,  'so-fail returns True for True things';
    is-deeply so-fail 0,  False,
        'so-fail returns False for defined, but False things';
}

{
    my $ret = make-fail;
    is-deeply de-fail $ret, False, 'de-fail returns False for Failures';
    is-deeply $ret.handled, False, 'de-fail returns unhandled Failure';
    $ret.so;

    is-deeply de-fail 42, True, 'de-fail returns True for defined things';
    is-deeply de-fail 0,  True,
        'de-fail returns True for defined, but False things';
}
