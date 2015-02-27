use v6;
use lib	'./lib';

use Test;

# These test vectors are from the english version of the spec.
# There are only two of them, and so far no other implementations
# too cross-check easily available.  So the evidence that our
# iplementation is correct is comparatively weak.

use Sum::SM3;

plan 11;

ok 1,'We use Sum::SM3 and we are still alive';

class S1 does Sum::SM3 does Sum::Marshal::Raw { };
my S1 $s .= new();
is S1.size, 256, 'Sum::SM3 size is correct, and a class method (:recourse)';
is $s.recourse, "Perl6", "Correct recourse for SM3";
ok $s.WHAT === S1, 'We create a Sum::SM3 class and object (:recourse)';
is S1.new.finalize("abc".encode("ascii")).fmt, "66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0", "SM3 test vector #1 (:recourse)";
is S1.new.finalize(buf8.new(flat((0x61..0x64) xx 16))).fmt, "debe9ff92275b8a138604889c18e5a4d6fdb70e5387e5765293dcba39c0c5732", "SM3 test vector #2 (:recourse)";

class S2 does Sum::SM3[:!recourse] does Sum::Marshal::Raw { };
my S2 $s2 .= new();
ok $s2.WHAT === S2, 'We create a Sum::SM3 class and object (:!recourse)';
is S2.size, 256, 'Sum::SM3 size is correct, and a class method (:!recourse)';
is S2.new.finalize("abc".encode("ascii")).fmt, "66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0", "SM3 test vector #1 (:!recourse)";
is S2.new.finalize(buf8.new((0x61..0x64) xx 16)).fmt, "debe9ff92275b8a138604889c18e5a4d6fdb70e5387e5765293dcba39c0c5732", "SM3 test vector #2 (:!recourse)";

diag "We have very few test vectors for SM3.  Use with caution.";

# Now grab the code in the synopsis from the POD and make sure it runs.
# This is currently complete hackery but might improve when pod support does.
# And also an outputs_ok Test.pm function that redirects $*OUT might be nice.
class sayer {
    has $.accum is rw = "";
    method print (*@s) { $.accum ~= [~] @s }
}
my sayer $p .= new();
# Rakudo-p currently does not serialize $=pod in PIR compunits so skip this.
if ($*VM.name ne 'parrot') {
{ temp $*OUT = $p; EVAL $Sum::SM3::Doc::synopsis; }
is $p.accum, $Sum::SM3::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <.xdigit>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';
}
