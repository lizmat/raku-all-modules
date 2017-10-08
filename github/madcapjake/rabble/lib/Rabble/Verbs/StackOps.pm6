unit module Rabble::Verbs::StackOps;

sub dot($ctx) is export {
  $ctx.out.say: $ctx.stack.pop;
}
