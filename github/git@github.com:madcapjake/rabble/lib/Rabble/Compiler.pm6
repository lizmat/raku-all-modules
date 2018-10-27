unit class Rabble::Compiler;

use Rabble::Util;

has $!context;
has %!lexicon;

submethod BUILD(:$!context, :%lexicon) {
  %!lexicon := %lexicon;
}

method Term($/) {
  say "Rabble::Compiler::Term: \t$/" if $*DEBUG;
  $/.make: ~$/;
}
method Name($/) {
  say "Rabble::Compiler::Name: \t$/" if $*DEBUG;
  $/.make: ~$/;
}
method Number($/) {
  say "Rabble::Compiler::Number:\t$/" if $*DEBUG;
  $/.make: {
    name      => ~$/,
    block     => { $!context.stack.push: +$/ },
    immediate => False
  }
}
method Word($/) {
  say "Rabble::Compiler::Word: \t$/" if $*DEBUG;
  $/.make: %!lexicon{~$/} // die "Unable to find '$/'"
}
method Quotation($/) {
  say "Rabble::Compiler::Quotation:\t$/" if $*DEBUG;
  my Map @internals = $<Expression>».made;
  $/.make: {
    name      => ~$/,
    block     => compile-words(@internals),
    immediate => False,
    quotation => True
  }
}
method Definition($/) {
  say "Rabble::Compiler::Definition:\t$/" if $*DEBUG;
  my &block = compile-words($<Expression>».made);

  %!lexicon.define :name($<Name>) :&block;
}
method Expression($/) {
  $/.make: $<Word>.made // $<Number>.made // $<Quotation>.made;
}
method Line($/) {
  "Compiling...".say if $*DEBUG;
  for $<Expression>».made.grep(* !~~ Nil) {
    $_.say if $*DEBUG;
    $_<quotation> ?? ($!context.stack ↞ $_<block>) !! $_<block>();
    $!context.stack.say if $*DEBUG;
  }
}
