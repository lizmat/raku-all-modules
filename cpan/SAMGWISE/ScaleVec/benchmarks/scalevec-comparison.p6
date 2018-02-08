#! /usr/bin/env perl6
use v6;
use Bench;
use ScaleVec;

my ScaleVec $octatonic-scale-p6 .= new: :vector( (0, 2, 3, 5, 6, 8, 9, 11, 12) );

unit sub MAIN(Int :$iterations = 1000);
my Bench $b .= new;

my $input = variable-input-generator;

say '-' x 78;
say '| ScaleVec::Native vs ScaleVec |';
say "=== step ===";
$b.cmpthese($iterations, {
  'Int (P6)'         => sub { $octatonic-scale-p6.step($input()) },

  'Rat (P6)'         => sub { $octatonic-scale-p6.step($input()/5) },
});

say "=== refelxive ===";
$b.cmpthese($iterations, {

  'Int (P6)'    => sub { $octatonic-scale-p6.reflexive-step($input()) },

  'Rat (P6)'    => sub { $octatonic-scale-p6.reflexive-step($input()/5) },
});

sub variable-input-generator(Int $limit = 100 --> Callable) {
  my Int $value = 0;
  sub () {
    $value = $value + (($limit > $value) ?? 1 !! (-$limit * 2));
  }
}
