#!perl6

use v6.c;
use Test;

use GDBM;


my $filename = 'tmp-' ~ $*PID ~ '.db';

subtest {
    my $obj;
    lives-ok { $obj = GDBM.new($filename) }, "create one";

    isa-ok $obj, GDBM, "and it's the right sort of object";

    ok $obj.filename.IO.e, "and the file exists";
    $obj.close;
    $filename.IO.unlink;
}, "positional constructor";

subtest {
    my $obj;
    lives-ok { $obj = GDBM.new(:$filename) }, "create one";

    isa-ok $obj, GDBM, "and it's the right sort of object";

    ok $obj.filename.IO.e, "and the file exists";
    $obj.close;
    $filename.IO.unlink;
}, "named constructor";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
