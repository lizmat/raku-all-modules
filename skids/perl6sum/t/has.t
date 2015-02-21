use v6;
use lib	'./lib';

use Test;

use Sum::HAS;
use Sum::librhash;

if $Sum::librhash::up {
   plan 13;
}
else {
   plan 2;
}

ok 1,'We use Sum::HAS and we are still alive';

# With no pure Perl6 implementation, this should die
eval_dies_ok "class H1p does Sum::HAS[:!recourse] does Sum::Marshal::Raw { }", "Attempt to use nonexistant pure-Perl6 code dies.";

unless $Sum::librhash::up {
   diag "No librhash working, skipping most tests.";
   exit;
}

my $recourse = "librhash";
class H1 does Sum::HAS160 does Sum::Marshal::Raw { };
my H1 $s .= new();
is $s.recourse, $recourse, "Correct recourse for HAS-160";
ok $s.WHAT === H1, 'We create a Sum::HAS160 class and object';

is H1.new.finalize.fmt("%2.2X"," "), "30 79 64 EF 34 15 1D 37 C8 04 7A DE C7 AB 50 F4 FF 89 76 2D", "HAS-160 test vector #1 (empty message)";
is H1.new.finalize("a".encode("ascii")).fmt("%2.2X"," "), "48 72 BC BC 4C D0 F0 A9 DC 7C 2F 70 45 E5 B4 3B 6C 83 0D B8", "HAS-160 test vector #2";
is H1.new.finalize("abc".encode("ascii")).fmt("%2.2X"," "), "97 5E 81 04 88 CF 2A 3D 49 83 84 78 12 4A FC E4 B1 C7 88 04", "HAS-160 test vector #3";
is H1.new.finalize("message digest".encode("ascii")).fmt("%2.2X"," "), "23 38 DB C8 63 8D 31 22 5F 73 08 62 46 BA 52 9F 96 71 0B C6", "HAS-160 test vector #4";
is H1.new.finalize("abcdefghijklmnopqrstuvwxyz".encode("ascii")).fmt("%2.2X"," "), "59 61 85 C9 AB 67 03 D0 D0 DB B9 87 02 BC 0F 57 29 CD 1D 3C", "HAS-160 test vector #5";
is H1.new.finalize("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".encode("ascii")).fmt("%2.2X"," "), "CB 5D 7E FB CA 2F 02 E0 FB 71 67 CA BB 12 3A F5 79 57 64 E5", "HAS-160 test vector #6";
is H1.new.finalize(("1234567890" x 8).encode("ascii")).fmt("%2.2X"," "), "07 F0 5C 8C 07 73 C5 5C A3 A5 A6 95 CE 6A CA 4C 43 89 11 B5", "HAS-160 test vector #7";
is H1.new.finalize(("a" x 1000000).encode("ascii")).fmt("%2.2X"," "), "D6 AD 6F 06 08 B8 78 DA 9B 87 99 9C 25 25 CC 84 F4 C9 F1 8D", "HAS-160 test vector #8";

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
{ temp $*OUT = $p; EVAL $Sum::HAS::Doc::synopsis; }
is $p.accum, $Sum::HAS::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <.xdigit>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';
}
