use Test;
use lib 'lib';

use MinG;
use MinG::S13;
use MinG::S13::Logic;
use MinG::From::Text;

plan 8;

sub fs(Str $s) {
    return feature_from_str($s);
}

##############
# FIRST TEST #
##############
ok "+V" eq feature_from_str("+V").to_str;

###############
# SECOND TEST #
###############
say MinG::Grammar.new(lex => ()).litem_tree.qtree();
ok "ROOT " eq MinG::Grammar.new(lex => ()).litem_tree.qtree();

##############
# THIRD TEST #
##############
my $fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));

my $g = MinG::Grammar.new(lex => ($fit));
my $q = $g.litem_tree.qtree();
say $q;
ok "[.ROOT  [.=A abc ] ] " eq $q;

##########################
# FOURTH AND FIFTH TESTS #
##########################
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
my $sit = MinG::LItem.new(phon => "jas", sem => "", features => (fs("+A")));
my $tit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("+A")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
my $t = $g.litem_tree;
ok $t.children_with_property(-> $x { $x.feat_node and $x.label.way == MERGE }).elems == 1;
$q = $t.qtree;
say $q;
ok "[.ROOT  [.=A abc ] [.+A jas abc ] ] " eq $q;

##############
# SIXTH TEST #
##############
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
$sit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("C")));
$tit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("-C")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
$q = $g.litem_tree.qtree();
say $q;
ok "[.ROOT  [.=A abc ] [.C [.=B [.+A gogo ] ] ] [.-C [.=B [.+A gogo ] ] ] ] " eq $q;

###########################
# SEVENTH AND EIGTH TESTS #
###########################
my $espg = grammar_from_file($ESPA0);
my $engg = grammar_from_file($ENG0);

my $parser = MinG::S13::Parser.new();
$parser.init($espg);
ok $parser.large_parse("maría dijo que pedro pensaba que era viejo");
$parser.init($engg);
ok $parser.large_parse("which wine the queen prefers");

done-testing;
