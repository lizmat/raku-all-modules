unit module Rabble::Verbs::Comparators;

use Rabble::Util;

#| [a b -- true|false]
sub eq($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop == $ctx.stack.pop
}

#| [a b -- true|false]
sub noteq($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop != $ctx.stack.pop
}

#| [a b -- true|false]
sub gt($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop > ENTER $ctx.stack.pop
}

#| [a b -- true|false]
sub lt($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop < ENTER $ctx.stack.pop
}
