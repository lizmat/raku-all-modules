unit module Rabble::Verbs::Combinators;

use Rabble::Util;

#| [... [...] -- ...]
sub apply($ctx) is export {
  $ctx.stack.pop.();
}

#| [... a [...] -- ... a]
sub dip($ctx) is export {
  my (&op, $stash) = $ctx.stack.pop xx 2;
  &op(); $ctx.stack ↞ $stash
}
