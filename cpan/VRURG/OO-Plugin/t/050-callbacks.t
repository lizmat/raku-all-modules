use v6.d;
use Test;
use OO::Plugin;
use OO::Plugin::Manager;

plan 13;

plugin CB1 before CB2 {
    multi method on-callback ( 'cb-test1', $msg, Str:D $param1, Int $param2 ) {
        is $param1, "A STRING", "callback parameter passing: 1";
        is $param2, -42, "callback parameter passing: 2";
        plug-last 42;
    }

    multi method on-callback ( 'cb-test3', $msg ) {
        state $rcount = 0;
        flunk "too many redos" if $rcount++ > 2;
        if $msg.private<pass> {
            pass "callback second pass after redo";
            return "CB1";
        }
        else {
            pass "callback first pass: initiating redo";
            $msg.private<pass> = True;
            plug-redo;
        }
    }

    multi method on-callback ( 'cb-test4', $msg ) {
        pass "fourth callback by CB1";
        "this is not right"
    }
}

plugin CB2 {
    multi method on-callback ( 'cb-test2', $msg ) {
        pass "callback without parameters";
        pi
    }

    multi method on-callback ('cb-test3', $msg) {
        pass "CB1 cb-test3";
        return "CB2";
    }
}

plugin CB3 after CB2 {
    multi method on-callback( 'cb-test1', $msg, Str:D $param1, Int $param2 ) {
        flunk "this callback must not get control";
        return $msg.rc / 2;
    }

    multi method on-callback ( 'cb-test4', $msg ) {
        pass "fourth callback by CB2";
        $msg.set-rc( "this is right" ) # This will override
    }
}

my $mgr = OO::Plugin::Manager.new;
$mgr.initialize;

is $mgr.cb('cb-test1', "A STRING", -42), 42, "first callback return value from CB1";
nok $mgr.cb('cb-test2', "A STRING", -42).defined, "second callback: no handler found, Any returned";
is $mgr.cb('cb-test2' ), pi, "second callback return value from CB2";
is $mgr.cb('cb-test3' ), "CB1", "CB2 doesn't override CB1's return value";
is $mgr.cb('cb-test4' ), "this is right", "CB2 overrides CB1's return value";

done-testing;

# vim: ft=perl6
