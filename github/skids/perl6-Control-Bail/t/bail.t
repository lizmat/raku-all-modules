
use v6;
use lib <blib/lib lib>;

use Test;

plan 15;

use Control::Bail;

my $*d;
sub normal_return_trail {
    trail { $*d = 'normal_return_trail' };
}
sub normal_return_bail {
    bail { $*d = 'normal_return_bail' };
}
sub normal_return_trail-keep {
    trail-keep { $*d = 'normal_return_trail-keep' };
}
sub normal_return_trail-undo {
    trail-undo { $*d = 'normal_return_trail-undo' };
}
sub normal_return_trail-leave {
    trail-leave { $*d = 'normal_return_trail-leave' };
}

normal_return_trail();
is $*d, 'normal_return_trail', "Normal returns run trail clauses";
normal_return_bail();
isnt $*d, 'normal_return_bail', "Normal returns do not run bail clauses";
normal_return_trail-keep();
is $*d, 'normal_return_trail-keep', "Normal returns run trail-keep clauses";
normal_return_trail-undo();
isnt $*d, 'normal_return_trail-undo', "Normal returns do not run trail-undo clauses";
normal_return_trail-leave();
is $*d, 'normal_return_trail-leave', "Normal returns run trail-leave clauses";

sub abnormal_return_trail {
    trail { $*d = 'abnormal_return_trail' };
    fail "abnormally";
    1;
}
sub abnormal_return_bail {
    bail { $*d = 'abnormal_return_bail' };
    fail "abnormally";
    1;
}
sub abnormal_return_trail-keep {
    trail-keep { $*d = 'abnormal_return_trail-keep' };
    fail "abnormally";
    1;
}
sub abnormal_return_trail-undo {
    trail-undo { $*d = 'abnormal_return_trail-undo' };
    fail "abnormally";
    1;
}
sub abnormal_return_trail-leave {
    trail-leave { $*d = 'abnormal_return_trail-leave' };
    fail "abnormally";
    1;
}

$ = abnormal_return_bail();
is $*d, 'abnormal_return_bail', "Abnormal returns run bail clauses";
$ = abnormal_return_trail();
is $*d, 'abnormal_return_trail', "Abnormal returns run trail clauses";
$ = abnormal_return_trail-undo();
is $*d, 'abnormal_return_trail-undo', "Abnormal returns run trail-undo clauses";
$ = abnormal_return_trail-leave();
is $*d, 'abnormal_return_trail-leave', "Abnormal returns run trail-leave clauses";
$ = abnormal_return_trail-keep();
isnt $*d, 'abnormal_return_trail-keep', "Abnormal returns do not run trail-keep clauses";


# Really this is just testing the leave queue itself but JIC
$*d = '';
sub normal_return_2trail {
    trail { $*d ~= '1' };
    trail { $*d ~= '2' };
}
normal_return_2trail();
is $*d, "21", "trail lifo";
$*d = "";
normal_return_2trail();
is $*d, "21", "trail does not stack in subs";

$*d = '';
sub normal_return_trail_LEAVE {
    LEAVE { $*d ~= '1' };
    trail { $*d ~= '2' };
    LEAVE { $*d ~= '3' };
}
normal_return_trail_LEAVE();
is $*d, "321", "trail plus LEAVE lifo";

$*d = "";
for 0..2 {
    LEAVE { $*d ~= '1' };
    trail { $*d ~= '2' };
    LEAVE { $*d ~= '3' };
}
is $*d, "321321321", "trail does not stack in loops";

$*d = "";
my &d = {
    LEAVE { $*d ~= '1' };
    trail { $*d ~= '2' };
    LEAVE { $*d ~= '3' };
}
&d();
&d();
is $*d, "321321", "trail does not stack in closures";
