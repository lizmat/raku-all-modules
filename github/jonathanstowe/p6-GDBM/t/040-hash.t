#!perl6

use v6.c;
use Test;

use GDBM;

my $file = "hash-test.db";

subtest {
    my %hash;

    lives-ok { %hash := GDBM.new($file) }, "create one";

    nok %hash<foo>:exists, "non-existent key doesn't exist";

    lives-ok { %hash<foo> = "bar" }, "set a value";
    is %hash<foo>, "bar", "and got it back";
    ok %hash<foo>:exists, "and exists";
    lives-ok { %hash<foo>:delete }, "delete the value";
    nok %hash<foo>:exists, "non-existent key doesn't exist";

    lives-ok { %hash.close }, "close that";

    LEAVE {
        if $file.IO.e {
            $file.IO.unlink;
        }
    }
}, "bound";

subtest {
    my $hash = GDBM.new($file);



    isa-ok $hash, GDBM, "applied one using direct assignment";

    nok $hash<foo>:exists, "non-existent key doesn't exist";

    lives-ok { $hash<foo> = "bar" }, "set a value";
    is $hash<foo>, "bar", "and got it back";
    ok $hash<foo>:exists, "and exists";
    lives-ok { $hash<foo>:delete }, "delete the value";
    nok $hash<foo>:exists, "non-existent key doesn't exist";
    lives-ok { $hash.close }, "close that";

    LEAVE {
        if $file.IO.e {
            $file.IO.unlink;
        }
    }
}, "assigned to a scalar";





END {
    if $file.IO.e {
        $file.IO.unlink;
    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
