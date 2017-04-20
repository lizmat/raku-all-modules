#!/usr/bin/env perl6
use lib 'lib';
use MinG;
use MinG::S13;
use MinG::S13::Logic;
use Test;
use Test::META;

plan 5;

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

my @frases = ["Juan come pan", "manteca escupe Juan", "come escupe Juan", "Juan", "come", "Pan Come Manteca"];

my Bool $all-fine = True;

$all-fine = $all-fine and $parser.parse_me($g, @frases[0]);
$all-fine = $all-fine and $parser.parse_me($g, @frases[1]);
$all-fine = $all-fine and not($parser.parse_me($g, @frases[2]));
$all-fine = $all-fine and not($parser.parse_me($g, @frases[3]));
$all-fine = $all-fine and not($parser.parse_me($g, @frases[4]));
$all-fine = $all-fine and $parser.parse_me($g, @frases[5]);

ok $all-fine;

done-testing;
