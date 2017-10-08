unit module Rabble::Verbs::Shufflers;

use Rabble::Util;

#| [a -- ]
sub drop($ctx) is export {
  $ctx.stack.pop;
}

#| [a b -- b]
sub nip($ctx) is export {
  my @stash = $ctx.stack.pop xx 2;
  $ctx.stack ↞ @stash.first;
}

#| [a -- a a]
sub dup($ctx) is export {
  $ctx.stack ↞ $ctx.stack[*-1]
}

#| [a b -- b a]
sub swap($ctx) is export {
  $ctx.stack.append: $ctx.stack.pop xx 2;
}

#| [x y z -- y z x]
sub rot($ctx) is export {
  my ($z, $y, $x) = $ctx.stack.pop xx 3;
  $ctx.stack.append: [$y, $z, $x];
}

sub und($ctx) is export {
  my ($top, $und) = $ctx.stack.pop xx 2;
  $ctx.stack.append: [$und, $top, $und];
}

#| [a b -- b a b]
sub tuck($ctx) is export {
  my ($b, $a) = $ctx.stack.pop xx 2;
  $ctx.stack.append: [$b, $a, $b];
}
