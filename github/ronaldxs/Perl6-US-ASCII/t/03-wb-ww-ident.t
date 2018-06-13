
######################################################################
# Test wb and ww.
#
# wb tests copied from:
#   https://github.com/perl6/roast/blob/master/S05-mass/rx.t
#
# ww tests guessed from wb
#
######################################################################

use v6.c;
use Test;
use US-ASCII :UC;

plan 32;

constant $abc-def-ghi = "abc\ndef\n-==\nghi";
constant $def-ab-cedilla = "def\nabç\n-==\nghi";

grammar test-wb-ww-inherit does US-ASCII-UC {
    method check-wb {
        ok $abc-def-ghi ~~ /<?WB>def/, 'word boundary \W\w by inheritance';
    }
    method check-ww {
        ok $abc-def-ghi ~~ /d<?WW>ef/, 'within word \W\w by inheritance';
    }
}


#### <?wb>def       abc\ndef\n-==\nghi  y   word boundary \W\w
ok $abc-def-ghi ~~ /<?WB>def/, 'word boundary \W\w';
ok $abc-def-ghi ~~ /<?US-ASCII::wb>def/, 'word boundary \W\w longer name';
test-wb-ww-inherit.check-wb;
ok $abc-def-ghi ~~ /d<?WW>ef/,
    'within word just after word boundary \W\w\w';
ok $abc-def-ghi ~~ /d<?US-ASCII::ww>ef/,
    'within word just after word boundary \W\w\w longer name';
ok $abc-def-ghi ~~ /<!WW>def/, 'not within word \W\w';
test-wb-ww-inherit.check-ww;

#### abc<?wb>       abc\ndef\n-==\nghi  y   word boundary \w\W
ok $abc-def-ghi ~~ /abc<?WB>/, 'word boundary \w\W';
ok $abc-def-ghi ~~ /ab<?WW>c/,
    'within word just before word boundary \w\w\W';
ok $def-ab-cedilla ~~ /<?WB>ab<?WB>/, 'word boundaries \W\w\w\W unicode';
ok $def-ab-cedilla ~~ /<?WB>ab<!WW>/, 'not within word \wç unicode';

#### <?wb>abc       abc\ndef\n-==\nghi  y   BOS word boundary
ok $abc-def-ghi ~~ /<?WB>abc/, 'BOS word boundary';
ok $abc-def-ghi ~~ /a<?WW>bc/, 'just after BOS within word';
ok $abc-def-ghi ~~ /<!WW>abc/, 'BOS not within word';

#### ghi<?wb>       abc\ndef\n-==\nghi  y   EOS word boundary
ok $abc-def-ghi ~~ /ghi<?WB>/, 'EOS word boundary';
ok $abc-def-ghi ~~ /gh<?WW>i/, 'just before EOS within word';
ok $abc-def-ghi ~~ /ghi<!WW>/, 'EOS not within word';

#### a<?wb>         abc\ndef\n-==\nghi  n   \w\w word boundary
ok $abc-def-ghi !~~ /a<?WB>/, '\w\w word boundary';
ok $abc-def-ghi !~~ /a<!WW>/, '\w\w within word';

#### \-<?wb>            abc\ndef\n-==\nghi  n   \W\W word boundary
ok $abc-def-ghi !~~ /\-<?WB>/, '\W\W word boundary';
ok $abc-def-ghi ~~ /\-<!WB>/, '\W\W not within word';

# L<S05/Extensible metasyntax (C<< <...> >>)/"A leading ! indicates">

#### <!wb>def       abc\ndef\n-==\nghi  n   nonword boundary \W\w
ok $abc-def-ghi !~~ /<!WB>def/, 'nonword boundary \W\w';

#### abc<!wb>       abc\ndef\n-==\nghi  n   nonword boundary \w\W
ok $abc-def-ghi !~~ /abc<!WB>/, 'nonword boundary \w\W';

#### <!wb>abc       abc\ndef\n-==\nghi  n   BOS nonword boundary
ok $abc-def-ghi !~~ /<!WB>abc/, 'BOS nonword boundary';

#### ghi<!wb>       abc\ndef\n-==\nghi  n   EOS nonword boundary
ok $abc-def-ghi !~~ /ghi<!WB>/, 'EOS nonword boundary';

#### a<!wb>         abc\ndef\n-==\nghi  y   \w\w nonword boundary
ok $abc-def-ghi ~~ /a<!WB>/, '\w\w nonword boundary';

#### \-<!wb>            abc\ndef\n-==\nghi  y   \W\W nonword boundary
ok $abc-def-ghi ~~ /\-<!WB>/, '\W\W nonword boundary';

# tests from roast/S05-mass/stdrules.t
ok("abc1_2" ~~ m/^ <IDENT> $/, '<IDENT>');
is($/<IDENT>, 'abc1_2', 'Captured <IDENT>');
ok("abc1_2" ~~ m/^ <&IDENT> $/, '<&IDENT>');
ok(!defined($/<IDENT>), 'Uncaptured <.IDENT>');
ok(!( "7abc1_2" ~~ m/^ <IDENT> $/ ), 'not <IDENT>');
