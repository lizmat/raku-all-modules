use lib '.';
use t::CompileTestLib;
use NativeCall;

say "1..3";

compile_test_lib('01-argless');

sub Argless() is native('./01-argless') { * }
sub short() is native('./01-argless') is symbol('long_and_complicated_name') { *}

# This emits the "ok 1"
Argless();

say("ok 2 - survived the call");

short();
