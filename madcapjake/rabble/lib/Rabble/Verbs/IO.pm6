unit module Rabble::Verbs::IO;

sub emit($ctx) is export {
  $ctx.out.print: $ctx.stack[*-1].chr
}

sub dot-s($ctx) is export {
  $ctx.out.say: "⊣ {$ctx.stack} ⊢"
}
