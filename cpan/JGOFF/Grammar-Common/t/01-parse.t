use v6;
use Grammar::Common::Expression::Prefix;
use Grammar::Common::Expression::Prefix::Actions;
use Grammar::Common::Expression::Infix;
use Grammar::Common::Expression::Infix::Actions;
use Test;

plan 4;

#############################################################################

ok Grammar::Common::Expression::Prefix.new;
ok Grammar::Common::Expression::Prefix::Actions.new;
ok Grammar::Common::Expression::Infix.new;
ok Grammar::Common::Expression::Infix::Actions.new;

done-testing;

# vim: ft=perl6
