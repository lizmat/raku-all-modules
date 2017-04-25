#!/usr/bin/env perl6
use lib 'lib';
use MinG;
use MinG::S13;
use MinG::S13::Logic;
use MinG::From::Text;
use Test;
use Test::META;

plan 8;

meta-ok();

my $p1 = Priority.new(pty => (0, 0, 0));
my $p2 = Priority.new(pty => (1, 0, 0));
my $p3 = Priority.new(pty => (0, 1, 0));
my $p4 = Priority.new(pty => (1, 1));

ok ($p1.bigger_than($p3)) && ($p3.bigger_than($p2)) && ($p2.bigger_than($p4));

my $deriv = Derivation.new(input => ("sanga", "changa", "wanga"));
say $deriv.input;
ok $deriv.input.elems == 3;
ok $deriv.still_going;

############
# BIG TEST #
############

my $c = feature_from_str("C");
my $selv = feature_from_str("=V");
my $v = feature_from_str("V");
my $d = feature_from_str("D");
my $seld = feature_from_str("=D");

my $force = MinG::LItem.new( features => ($selv, $c), phon => "");
my $juan = MinG::LItem.new( features => ($d), phon => "juan");
my $come = MinG::LItem.new( features => ($seld, $seld, $v), phon => "come");
my $escupe = MinG::LItem.new( features => ($seld, $seld, $v), phon => "escupe");
my $pan = MinG::LItem.new( features => ($d), phon => "pan");
my $manteca = MinG::LItem.new( features => ($d), phon => "manteca");

my $g = MinG::Grammar.new(lex => ($juan, $come, $escupe, $pan, $manteca, $force), start_cat => $c);

parse_and_spit($g, "juan escupe pan");

my $parser = MinG::S13::Parser.new();
$parser.init($g);

my @frases = ["Juan come pan", "manteca escupe Juan", "come escupe Juan", "Juan", "come", "Pan Come Manteca"];

my Bool $all-fine = True;

$all-fine = $all-fine and $parser.parse_str(@frases[0]);
$all-fine = $all-fine and $parser.parse_str(@frases[1]);
$all-fine = $all-fine and not($parser.parse_str(@frases[2]));
$all-fine = $all-fine and not($parser.parse_str(@frases[3]));
$all-fine = $all-fine and not($parser.parse_str(@frases[4]));
$all-fine = $all-fine and $parser.parse_str(@frases[5]);

@frases = ["pedro fue a la casa de juan", "qué pensaba juan", "el sordo es viejo", "es viejo", "nadie pensaba eso", "el sordo dijo que era alto", "qué dijo la amiga de maría"];
$parser.init(grammar_from_file($ESPA0));

$all-fine = $all-fine && $parser.large_parse(@frases[0]);
$all-fine = $all-fine && $parser.large_parse(@frases[1]);
$all-fine = $all-fine && $parser.large_parse(@frases[2]);
$all-fine = $all-fine && $parser.large_parse(@frases[3]);
$all-fine = $all-fine && $parser.large_parse(@frases[4]);
$all-fine = $all-fine && $parser.large_parse(@frases[5]);
$all-fine = $all-fine && $parser.large_parse(@frases[6]);

ok $all-fine;

##############
# SIXTH TEST #
##############

use MinG::EDMG;
my $edmg_f = MinG::EDMG::Feature.new(way => MERGE, pol => PLUS, is_adj => True);
nok $edmg_f.is_covert_mov;

###########################
# SEVENTH AND EIGTH TESTS #
###########################

ok MinG::EDMG::Feature.from_str("A<") eqv MinG::EDMG::Feature.new(way => MERGE,\
                                                      pol => PLUS,\
                                                      type => "A",\
                                                      side => MinG::EDMG::FSide::RIGHT,\
                                                      is_head_mov => True,\
                                                      head_mov_side => MinG::EDMG::FSide::LEFT);

ok MinG::EDMG::Feature.from_str("DELTA") eqv MinG::EDMG::Feature.new(way => MERGE,\
                                                         pol => MINUS,\
                                                         type => "DELTA");

done-testing;
