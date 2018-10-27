use v6;

unit module Net::OSC::Types;

my package EXPORT::DEFAULT {
  our subset OSCPath of Str where *.substr-eq('/', 0);

  our subset ActionTuple of List where -> $t { $t[0] ~~ Regex and $t[1] ~~ Callable }
}
