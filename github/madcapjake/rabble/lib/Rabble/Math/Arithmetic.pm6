unit module Rabble::Math::Arithmetic;

use Rabble::Util;

#| [a b -- c]
sub plus($ctx) is export {
  $ctx.stack ↞ ($ctx.stack.pop + $ctx.stack.pop);
}

#| [a b -- c]
sub multiply($ctx) is export {
  $ctx.stack ↞ ($ctx.stack.pop * $ctx.stack.pop);
}

#| [x y -- z]
sub subtract($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop - ENTER $ctx.stack.pop
}

#| [d n -- q]
sub divide($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop / ENTER $ctx.stack.pop
}

#| [x y -- rem]
sub modulo($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop % ENTER $ctx.stack.pop
}

#| [x y -- rem quot]
sub ratdiv($ctx) is export {
  $ctx.stack.append: ([R/] $ctx.stack.pop xx 2).nude
}

#| [a -- b]
sub abs($ctx) is export {
  $ctx.stack ↞ $ctx.stack.pop.abs;
}

#| [a -- b]
sub inc($ctx) is export {
  $ctx.stack ↞ ++$ctx.stack.pop;
}

#| [a -- b]
sub dec($ctx) is export {
  $ctx.stack ↞ --$ctx.stack.pop;
}
