use v6;
use Test;
plan 61;

use Algorithm::Diff;

my @d = (2,4,6,8,10);
my ($h, $i);

$i =  Algorithm::Diff::_replaceNextLargerWith( @d, 3, $h );
is( ~@d, '2 3 6 8 10',
  "_replaceNextLargerWith() works ok for inserts");
is( $i, 1, "_replaceNextLargerWith() returns correct index for inserts");

$i =  Algorithm::Diff::_replaceNextLargerWith( @d, 0, $h );
is( ~@d, '0 3 6 8 10',
  "_replaceNextLargerWith() works ok for inserts at beginning");
is( $i, 0,
  "_replaceNextLargerWith() returns correct index for inserts at beginning");

$i =  Algorithm::Diff::_replaceNextLargerWith( @d, 11, $h );
is( ~@d, '0 3 6 8 10 11',
  "_replaceNextLargerWith() works ok for inserts at end");
is( $i, 5,
  "_replaceNextLargerWith() returns correct index for inserts at end");

$i =  Algorithm::Diff::_replaceNextLargerWith( @d, 6, $h );
is( ~@d, '0 3 6 8 10 11',
  "_replaceNextLargerWith() doesn't change array for already seen elements");
ok( !$i.defined,
  "_replaceNextLargerWith() returns undef index for already seen elements");


my @a = <a b c e h j l m n p>;
my @b = <b c d e f j k l m r s t>;
my @correctResult = <b c e j l m>;
my $correctResult = @correctResult.join(' ');
my $skippedA = 'a h n p';
my $skippedB = 'd f k r s t';

# Result of LCS must be as long as @a
my @result = Algorithm::Diff::_longestCommonSubsequence( @a, @b );

is(  @result.grep( *.defined ).elems(),
  @correctResult.elems(),
  "_longestCommonSubsequence returns expected number of elements" );

# result has b[] line#s keyed by a[] line#
#say "result = " ~ @result;

my @aresult = map { @result[$_].defined ?? @a[$_] !! slip() } , 0..^@result;

my @bresult = map { @result[$_].defined ?? @b[@result[$_]]  !! slip() } , 0..^@result;

is( ~@aresult, $correctResult,
  "_longestCommonSubsequence @a results match expected results" );
is( ~@bresult, $correctResult,
  "_longestCommonSubsequence @b results match expected results" );


my ( @matchedA, @matchedB, @discardsA, @discardsB, $finishedA, $finishedB );

sub match
{
    my ( $a, $b ) = @_;
    @matchedA.push( @a[$a] );
    @matchedB.push( @b[$b] );
}

sub discard_b
{
    my ( $a, $b ) = @_;
    @discardsB.push(@b[$b]);
}

sub discard_a
{
    my ( $a, $b ) = @_;
    @discardsA.push(@a[$a]);
}

sub finished_a
{
    my ( $a, $b ) = @_;
    $finishedA = $a;
}

sub finished_b
{
    my ( $a, $b ) = @_;
    $finishedB = $b;
}

traverse_sequences(@a, @b,
    MATCH     => &match,
    DISCARD_A => &discard_a,
    DISCARD_B => &discard_b
);

is( ~@matchedA, $correctResult,
  "traverse_sequences() returns expected matches for @a");
is( ~@matchedB, $correctResult,
  "traverse_sequences() returns expected matches for @b");
is( ~@discardsA, $skippedA,
  "traverse_sequences() returns expected skips for @a");
is( ~@discardsB, $skippedB,
  "traverse_sequences() returns expected skips for @b");

@matchedA = @matchedB = @discardsA = @discardsB = ();
$finishedA = $finishedB = Mu;

traverse_sequences(@a,@b,
    MATCH      => &match,
    DISCARD_A  => &discard_a,
    DISCARD_B  => &discard_b,
    A_FINISHED => &finished_a,
    B_FINISHED => &finished_b,
);

is( ~@matchedA, $correctResult,
  "traverse_sequences() w/finished callback gives expected matches for @a");
is( ~@matchedB, $correctResult,
  "traverse_sequences() w/finished callback gives expected matches for @b");
is( ~@discardsA, $skippedA,
  "traverse_sequences() w/finished callback gives expected skips for @a");
is( ~@discardsB, $skippedB,
  "traverse_sequences() w/finished callback gives expected skips for @b");
is( $finishedA, 9, "traverse_sequences() index of finishedA is as expected" );
ok( !$finishedB.defined,
  "traverse_sequences() index of finishedB is as expected" );

########################################################

# Compare the diff output with the one from the Algorithm::Diff manpage.
my $diff = diff( @a, @b );

# From the Algorithm::Diff manpage:
my $correctDiffResult = [
    [ [ '-', 0,  'a' ] ],
    [ [ '+', 2,  'd' ] ],
    [
      [ '-', 4,  'h' ],
      [ '+', 4,  'f' ]
    ],
    [ [ '+', 6,  'k' ] ],
    [
      [ '-', 8,  'n' ],
      [ '+', 9,  'r' ],
      [ '-', 9,  'p' ],
      [ '+', 10, 's' ],
      [ '+', 11, 't' ],
    ]
 ];

is( $diff, $correctDiffResult,
  'diff() returns expected output');


my @lcs = LCS( @a, @b );
is( ~@lcs, $correctResult,
  "LCS() returns expected result" );

is(LCS_length( @a, @b ), +@lcs,
  'LCS_length() returns expected result' );

my $keygen = sub { @_[0].uc };
my @au = @a>>.uc;
my %hash =  prepare(@b);

@lcs = LCS( @a, %hash );
is( ~@lcs, $correctResult,
  "LCS() with prepare returns expected result" );

@lcs = LCS( %hash, @a );
is( ~@lcs, $correctResult,
  "LCS() with prepare returns expected result" );


@lcs = LCS( @au, @b, $keygen );
is( ~@lcs, $correctResult.uc,
  "LCS() with keygen returns expected result" );

@lcs = LCS( @au, prepare(@b>>.uc), $keygen );
is( ~@lcs, $correctResult.uc,
  "LCS() with prepare and keygen returns expected result" );

########################################################################
# Exercise LCS (which in turn calls _longestCommonSubsequence,
# _replaceNextLargerWith & _withPositionsOfInInterval ) with
# various corner cases.
#

my $count = 1;
for (
     [ "a b c   e  h j   l m n p", "  b c d e f  j k l m    r s t", "b c e j l m" ],
     [ "", "", "" ],
     [ "a b c", "", "" ],
     [ "", "a b c d", "" ],
     [ "a b", "x y z", "" ],
     [ "    c  e   h j   l m n p r", "a b c d f g  j k l m      s t", "c j l m" ],
     [ "a b c d", "a b c d", "a b c d" ],
     [ "a     d", "a b c d", "a d" ],
     [ "a b c d", "a     d", "a d" ],
     [ "a b c d", "  b c  ", "b c" ],
     [ "  b c  ",  "a b c d", "b c" ],
     ) -> @group
{
    my ( $a, $b, $check ) = @group;
    @a = $a.comb(/ \S+ /);
    @b = $b.comb(/ \S+ /);
    is( ~LCS(@a,@b), $check, "Excercise LCS with various corner cases: #$count");
    $count++;
}

########################################################################
# Compare the compact_diff output with the one
# from the Algorithm::Diff manpage.

@a = <a b c   e  h j   l m n p     >;
@b = <  b c d e f  j k l m    r s t>;
my @cdiff = compact_diff( @a, @b );

is(@cdiff,
#   @a      @b       @a       @b
#  start   start   values   values
[    0,      0,   #       =
     0,      0,   #    a  !
     1,      0,   #  b c  =  b c
     3,      2,   #       !  d
     3,      3,   #    e  =  e
     4,      4,   #    f  !  h
     5,      5,   #    j  =  j
     6,      6,   #       !  k
     6,      7,   #  l m  =  l m
     8,      9,   #  n p  !  r s t
    10,     12    #
], "compact_diff() returns expected result" );

##################################################
# <Mike Schilli> m@perlmeister.com 03/23/2002:
# Tests for sdiff-interface
#################################################

@a = <abc def yyy xxx ghi jkl>;
@b = <abc dxf xxx ghi jkl>;
$correctDiffResult = [ ['u', 'abc', 'abc'],
                        ['c', 'def', 'dxf'],
                        ['-', 'yyy', ''],
                        ['u', 'xxx', 'xxx'],
                        ['u', 'ghi', 'ghi'],
                        ['u', 'jkl', 'jkl'] ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() returns expected output for multi-character strings');

#################################################
@a = <a b c e h j l m n p>;
@b = <b c d e f j k l m r s t>;
$correctDiffResult = [ ['-', 'a', '' ],
                       ['u', 'b', 'b'],
                       ['u', 'c', 'c'],
                       ['+', '',  'd'],
                       ['u', 'e', 'e'],
                       ['c', 'h', 'f'],
                       ['u', 'j', 'j'],
                       ['+', '',  'k'],
                       ['u', 'l', 'l'],
                       ['u', 'm', 'm'],
                       ['c', 'n', 'r'],
                       ['c', 'p', 's'],
                       ['+', '',  't'],
                     ];
@result = sdiff(@a, @b);
is(@result,$correctDiffResult,
  'sdiff() output correct');

#################################################
@a = <a b c d e>;
@b = <a e>;
$correctDiffResult = [ ['u', 'a', 'a' ],
                       ['-', 'b', ''],
                       ['-', 'c', ''],
                       ['-', 'd', ''],
                       ['u', 'e', 'e'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a e>;
@b = <a b c d e>;
$correctDiffResult = [ ['u', 'a', 'a' ],
                       ['+', '', 'b'],
                       ['+', '', 'c'],
                       ['+', '', 'd'],
                       ['u', 'e', 'e'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');
#################################################
@a = <v x a e>;
@b = <w y a b c d e>;
$correctDiffResult = [
                       ['c', 'v', 'w' ],
                       ['c', 'x', 'y' ],
                       ['u', 'a', 'a' ],
                       ['+', '', 'b'],
                       ['+', '', 'c'],
                       ['+', '', 'd'],
                       ['u', 'e', 'e'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <x a e>;
@b = <a b c d e>;
$correctDiffResult = [
                       ['-', 'x', '' ],
                       ['u', 'a', 'a' ],
                       ['+', '', 'b'],
                       ['+', '', 'c'],
                       ['+', '', 'd'],
                       ['u', 'e', 'e'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a e>;
@b = <x a b c d e>;
$correctDiffResult = [
                       ['+', '', 'x' ],
                       ['u', 'a', 'a' ],
                       ['+', '', 'b'],
                       ['+', '', 'c'],
                       ['+', '', 'd'],
                       ['u', 'e', 'e'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a e v>;
@b = <x a b c d e w x>;
$correctDiffResult = [
                       ['+', '', 'x' ],
                       ['u', 'a', 'a' ],
                       ['+', '', 'b'],
                       ['+', '', 'c'],
                       ['+', '', 'd'],
                       ['u', 'e', 'e'],
                       ['c', 'v', 'w'],
                       ['+', '',  'x'],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a=();
@b = <a b c>;
$correctDiffResult = [
                       ['+', '', 'a' ],
                       ['+', '', 'b' ],
                       ['+', '', 'c' ],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a b c>;
@b = ();
$correctDiffResult = [
                       ['-', 'a', '' ],
                       ['-', 'b', '' ],
                       ['-', 'c', '' ],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a b c>;
@b = <1>;
$correctDiffResult = [
                       ['c', 'a', '1' ],
                       ['-', 'b', '' ],
                       ['-', 'c', '' ],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a b c>;
@b = <c>;
$correctDiffResult = [
                       ['-', 'a', '' ],
                       ['-', 'b', '' ],
                       ['u', 'c', 'c' ],
                     ];
@result = sdiff(@a, @b);
is(@result, $correctDiffResult,
  'sdiff() output ok, various corner cases');

#################################################
@a = <a b c>;
@b = <a x c>;
my $r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                    );

is($r, "M 0 0C 1 1M 2 2",
  "traverse_balanced() output ok" );

#################################################
#No CHANGE callback => use discard_a/b instead
@a = <a b c>;
@b = <a x c>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   );
is($r, "M 0 0DA 1 1DB 2 1M 2 2",
  "traverse_balanced() with no CHANGE callback output ok");

#################################################
@a = <a x y c>;
@b = <a v w c>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "M 0 0C 1 1C 2 2M 3 3",
  "traverse_balanced() output ok, various corner cases");


#################################################
@a = <a x y c>;
@b = <a v c>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "M 0 0C 1 1DA 2 2M 3 2",
  "traverse_balanced() output ok, various corner cases");

#################################################
@a = <x y c>;
@b = <v w c>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r,  "C 0 0C 1 1M 2 2",
  "traverse_balanced() output ok, various corner cases");

#################################################
@a = <a x y z>;
@b = <b v w>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "C 0 0C 1 1C 2 2DA 3 3",
  "traverse_balanced() output ok, various corner cases");

#################################################
@a = <a z>;
@b = <a>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "M 0 0DA 1 1",
  "traverse_balanced() output ok, various corner cases");

#################################################
@a = <z a>;
@b = <a>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "DA 0 0M 1 0",
  "traverse_balanced() output ok, various corner cases");

#################################################
@a = <a b c>;
@b = <x y z>;
$r = "";
traverse_balanced( @a, @b,
                   MATCH     => sub { $r ~= "M " ~@_;},
                   DISCARD_A => sub { $r ~= "DA " ~@_;},
                   DISCARD_B => sub { $r ~= "DB " ~@_;},
                   CHANGE    => sub { $r ~= "C " ~@_;},
                   );
is($r, "C 0 0C 1 1C 2 2",
  "traverse_balanced() output ok, various corner cases");
